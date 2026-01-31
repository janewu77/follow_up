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
          _buildAssistantAvatar(),
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

  /// Build assistant avatar for typing indicator
  Widget _buildAssistantAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5ABFB3), // Light teal
            Color(0xFF115E59), // Dark teal (primary)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'F',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(AppLocalizations l10n) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main input container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image preview area (inside the input box)
                  if (_selectedImages.isNotEmpty) _buildImagePreview(),
                  // Text input area
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, _selectedImages.isNotEmpty ? 8 : 16, 20, 4),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 24),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: _selectedImages.isNotEmpty 
                              ? 'Add a message...' 
                              : 'Reply...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: 5,
                        minLines: 1,
                        enabled: !_isTyping,
                      ),
                    ),
                  ),
                  // Bottom row with + button and send button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      children: [
                        // Attachment button (simple +)
                        GestureDetector(
                          onTap: _isTyping ? null : _showAttachmentOptions,
                          child: Icon(
                            Icons.add,
                            color: _isTyping 
                                ? AppColors.textMuted 
                                : AppColors.textSecondary,
                            size: 22,
                          ),
                        ),
                        const Spacer(),
                        // Send button (arrow up)
                        Builder(
                          builder: (context) {
                            final bool canSend = !_isTyping && 
                                (_messageController.text.trim().isNotEmpty || _selectedImages.isNotEmpty);
                            return GestureDetector(
                              onTap: canSend ? _sendMessage : null,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  // Disabled state: green with gray overlay (shows it's a green button but disabled)
                                  color: canSend 
                                      ? AppColors.primary
                                      : AppColors.primary.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: canSend 
                                      ? Colors.white 
                                      : Colors.white.withValues(alpha: 0.7),
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Disclaimer text
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 400;
                return Text(
                  isSmallScreen
                      ? 'FollowUP is AI-powered and may make mistakes.\nPlease verify important information.'
                      : 'FollowUP is AI-powered and may make mistakes. Please verify important information.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build image preview area (inside input container)
  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _selectedImages.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageWidget(image),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeSelectedImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Build image widget (handles both web and mobile)
  Widget _buildImageWidget(XFile image) {
    const double imageSize = 140;
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: image.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            );
          }
          return Container(
            width: imageSize,
            height: imageSize,
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
        width: imageSize,
        height: imageSize,
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

/// Assistant avatar widget - branded design with gradient
class _AssistantAvatar extends StatelessWidget {
  final bool isError;

  const _AssistantAvatar({this.isError = false});

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5ABFB3), // Light teal (accent)
            Color(0xFF115E59), // Dark teal (primary)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'F',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
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
            _AssistantAvatar(isError: message.isError),
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
