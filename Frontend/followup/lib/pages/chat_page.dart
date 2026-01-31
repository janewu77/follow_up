import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';

/// AI Chat Page - Main page after login
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isTyping = false;
  String _currentResponse = '';
  String? _currentIntent;
  StreamSubscription<ChatEvent>? _streamSubscription;
  
  // Selected images for sending
  List<XFile> _selectedImages = [];
  List<String> _selectedImagesBase64 = [];

  @override
  void initState() {
    super.initState();
    // Add welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addWelcomeMessage();
    });
    // Listen to text changes to update send button state
    _messageController.addListener(() {
      setState(() {});
    });
  }

  void _addWelcomeMessage() {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.user?.username ?? 'User';
    
    setState(() {
      _messages.add(ChatMessage(
        content: l10n.chatWelcome(username),
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (images.isNotEmpty) {
        await _processSelectedImages(images);
      }
    } catch (e) {
      _showImageError('Failed to pick images: $e');
    }
  }

  /// Take photo with camera
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (image != null) {
        await _processSelectedImages([image]);
      }
    } catch (e) {
      _showImageError('Failed to take photo: $e');
    }
  }

  /// Process selected images and convert to base64
  Future<void> _processSelectedImages(List<XFile> images) async {
    final List<String> base64Images = [];
    
    for (final image in images) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      base64Images.add(base64String);
    }
    
    setState(() {
      _selectedImages = [..._selectedImages, ...images];
      _selectedImagesBase64 = [..._selectedImagesBase64, ...base64Images];
    });
  }

  /// Remove a selected image
  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _selectedImagesBase64.removeAt(index);
    });
  }

  /// Clear all selected images
  void _clearSelectedImages() {
    setState(() {
      _selectedImages.clear();
      _selectedImagesBase64.clear();
    });
  }

  /// Show error message
  void _showImageError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// Show attachment options bottom sheet
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                ),
                title: const Text('Photo Library'),
                subtitle: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              if (!kIsWeb) ...[
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppColors.accent),
                  ),
                  title: const Text('Camera'),
                  subtitle: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    final hasImages = _selectedImages.isNotEmpty;
    
    // Allow sending with just images (no text required)
    if (text.isEmpty && !hasImages) return;
    if (_isTyping) return;

    // Get username as session_id
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.user?.username ?? 'anonymous';

    // Capture images before clearing
    final imagesToSend = List<String>.from(_selectedImagesBase64);
    final imageFiles = List<XFile>.from(_selectedImages);

    // Add user message with images
    setState(() {
      _messages.add(ChatMessage(
        content: text.isEmpty ? '📷 Sent ${imageFiles.length} image${imageFiles.length > 1 ? 's' : ''}' : text,
        isUser: true,
        timestamp: DateTime.now(),
        images: imageFiles,
      ));
      _messageController.clear();
      _clearSelectedImages();
      _isTyping = true;
      _currentResponse = '';
      _currentIntent = null;
    });

    _scrollToBottom();

    // Start streaming with username as session_id and images
    _streamSubscription = ChatService.sendMessageStream(
      message: text.isEmpty ? 'Please analyze these images' : text,
      sessionId: username,
      imagesBase64: imagesToSend.isNotEmpty ? imagesToSend : null,
    ).listen(
      (event) {
        _handleChatEvent(event);
      },
      onError: (error) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            content: 'Error: $error',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ));
        });
      },
      onDone: () {
        _finishResponse();
      },
    );
  }

  void _handleChatEvent(ChatEvent event) {
    setState(() {
      switch (event.type) {
        case ChatEventType.status:
          // Could show status in UI if needed
          break;
        case ChatEventType.intent:
          _currentIntent = event.intent;
          break;
        case ChatEventType.token:
          _currentResponse += event.token ?? '';
          _scrollToBottom();
          break;
        case ChatEventType.action:
          // Handle action result (e.g., created events)
          if (event.actionResult != null) {
            _handleActionResult(event.actionResult!);
          }
          break;
        case ChatEventType.done:
          _finishResponse();
          break;
        case ChatEventType.error:
          _isTyping = false;
          _messages.add(ChatMessage(
            content: event.error ?? 'Unknown error',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ));
          break;
      }
    });
  }

  void _handleActionResult(Map<String, dynamic> actionResult) {
    // If events were created, show them
    if (actionResult.containsKey('events')) {
      final events = actionResult['events'] as List<dynamic>;
      final eventCount = events.length;
      
      if (eventCount > 0) {
        // The response message will include event details
        // Could add special UI for events here
      }
    }
  }

  void _finishResponse() {
    if (_currentResponse.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          content: _currentResponse,
          isUser: false,
          timestamp: DateTime.now(),
          intent: _currentIntent,
        ));
        _currentResponse = '';
        _currentIntent = null;
        _isTyping = false;
      });
      _scrollToBottom();
    } else {
      setState(() {
        _isTyping = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearConversation() {
    setState(() {
      _messages.clear();
      ChatService.clearSession();
    });
    _addWelcomeMessage();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      body: AnimatedWarmBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, l10n, isWide),
              // Chat messages
              Expanded(
                child: _buildMessageList(l10n),
              ),
              // Typing indicator with current response
              if (_isTyping) _buildTypingArea(),
              // Input area
              _buildInputArea(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo image - transparent background
          Image.asset(
            'assets/images/logo_transparent.png',
            height: 36,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          // Quick actions
          if (isWide) ...[
            _QuickActionButton(
              icon: Icons.add_photo_alternate_outlined,
              label: l10n.chatUploadImage,
              onTap: () => Navigator.pushNamed(context, '/input', arguments: {'mode': 'image'}),
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              icon: Icons.event_outlined,
              label: l10n.chatViewEvents,
              onTap: () => Navigator.pushNamed(context, '/events'),
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              icon: Icons.refresh,
              label: 'New Chat',
              onTap: _clearConversation,
            ),
            const SizedBox(width: 16),
          ],
          // User menu
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person_outline, color: AppColors.primary),
            ),
            onSelected: (value) {
              if (value == 'events') {
                Navigator.pushNamed(context, '/events');
              } else if (value == 'new_chat') {
                _clearConversation();
              } else if (value == 'logout') {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'events',
                child: Row(
                  children: [
                    const Icon(Icons.event_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.chatViewEvents),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'new_chat',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 8),
                    Text('New Chat'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.logout),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(AppLocalizations l10n) {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.chatStartHint,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _ChatBubble(message: message);
      },
    );
  }

  Widget _buildTypingArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 18,
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: _currentResponse.isEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TypingDot(delay: 0),
                        const SizedBox(width: 4),
                        _TypingDot(delay: 150),
                        const SizedBox(width: 4),
                        _TypingDot(delay: 300),
                      ],
                    )
                  : SelectableText(
                      _currentResponse,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image preview area
            if (_selectedImages.isNotEmpty) _buildImagePreview(),
            // Input row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Attachment button with options
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                    onPressed: _isTyping ? null : _showAttachmentOptions,
                  ),
                  const SizedBox(width: 8),
                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundStart,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: _selectedImages.isNotEmpty 
                              ? 'Add a message or send images...' 
                              : l10n.chatInputHint,
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                        enabled: !_isTyping,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      color: _isTyping 
                          ? AppColors.textMuted 
                          : (_messageController.text.trim().isNotEmpty || _selectedImages.isNotEmpty)
                              ? AppColors.primary
                              : AppColors.textMuted.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded),
                      color: Colors.white,
                      onPressed: _isTyping ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build image preview area
  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${_selectedImages.length} image${_selectedImages.length > 1 ? 's' : ''} selected',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearSelectedImages,
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImageWidget(_selectedImages[index]),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeSelectedImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build image widget (handles both web and mobile)
  Widget _buildImageWidget(XFile image) {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: image.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            );
          }
          return Container(
            width: 80,
            height: 80,
            color: AppColors.border,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(image.path),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }
  }
}

/// Chat message model
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? intent;
  final bool isError;
  final List<XFile>? images;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.intent,
    this.isError = false,
    this.images,
  });
}

/// Chat bubble widget
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final hasImages = message.images != null && message.images!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: message.isError ? AppColors.error : AppColors.primary,
              radius: 18,
              child: Icon(
                message.isError ? Icons.error_outline : Icons.smart_toy_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppColors.primary 
                    : message.isError 
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.intent != null && !isUser) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        message.intent!,
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  // Display images if present
                  if (hasImages) ...[
                    _buildMessageImages(message.images!),
                    if (message.content.isNotEmpty && !message.content.startsWith('📷'))
                      const SizedBox(height: 8),
                  ],
                  // Display text content (hide auto-generated image message)
                  if (!message.content.startsWith('📷'))
                    SelectableText(
                      message.content,
                      style: TextStyle(
                        color: isUser 
                            ? Colors.white 
                            : message.isError 
                                ? AppColors.error 
                                : AppColors.textPrimary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              radius: 18,
              child: const Icon(Icons.person, color: AppColors.primary, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  /// Build images grid in message bubble
  Widget _buildMessageImages(List<XFile> images) {
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildSingleImage(images.first),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: images.take(4).map((image) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 100,
            height: 100,
            child: _buildSingleImage(image),
          ),
        );
      }).toList(),
    );
  }

  /// Build a single image widget
  Widget _buildSingleImage(XFile image) {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: image.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          }
          return Container(
            color: AppColors.border,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(image.path),
        fit: BoxFit.cover,
      );
    }
  }
}

/// Quick action button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Typing animation dot
class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
