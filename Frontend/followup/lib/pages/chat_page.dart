import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/event.dart';
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
  final FocusNode _sendButtonFocusNode = FocusNode();
  bool _isTyping = false;
  String _currentResponse = '';
  String? _currentIntent;
  String? _currentThinkingMessage;  // Thinking/status message to display
  Map<String, dynamic>? _currentActionResult;
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
    _sendButtonFocusNode.dispose();
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
      _currentActionResult = null;
      _currentThinkingMessage = null;
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
    debugPrint('ChatEvent received: type=${event.type}, message=${event.message}');
    setState(() {
      switch (event.type) {
        case ChatEventType.status:
          // Show status message to user
          debugPrint('Status: ${event.message}');
          _currentThinkingMessage = event.message;
          break;
        case ChatEventType.thinking:
          // Show thinking message with emoji
          debugPrint('Thinking: ${event.message}');
          _currentThinkingMessage = '💭 ${event.message ?? 'Thinking...'}';
          break;
        case ChatEventType.intent:
          _currentIntent = event.intent;
          break;
        case ChatEventType.token:
          _currentThinkingMessage = null;  // Clear thinking when receiving tokens
          _currentResponse += event.token ?? '';
          _scrollToBottom();
          break;
        case ChatEventType.content:
          // One-time complete content (non-streaming)
          _currentThinkingMessage = null;  // Clear thinking when receiving content
          _currentResponse = event.content ?? event.message ?? '';
          _scrollToBottom();
          break;
        case ChatEventType.action:
          // Handle action result (e.g., created events)
          if (event.actionResult != null) {
            _currentActionResult = event.actionResult;
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
    final action = actionResult['action'] as String?;
    
    // Refresh events list when events are modified
    if (action == 'create_event' || action == 'update_event' || action == 'delete_event') {
      // Check if operation was successful (has event_id or event_ids)
      final hasEventId = actionResult.containsKey('event_id') || actionResult.containsKey('event_ids');
      final hasError = actionResult.containsKey('error');
      final needMoreInfo = actionResult['need_more_info'] == true;
      
      if (hasEventId && !hasError && !needMoreInfo) {
        // Trigger events refresh in background
        // Note: EventsProvider will be refreshed when user navigates to events page
        debugPrint('Action completed: $action');
      }
    }
    
    // Log for debugging
    debugPrint('Action result: $actionResult');
  }

  void _finishResponse() {
    if (_currentResponse.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          content: _currentResponse,
          isUser: false,
          timestamp: DateTime.now(),
          intent: _currentIntent,
          actionResult: _currentActionResult,
        ));
        _currentResponse = '';
        _currentIntent = null;
        _currentActionResult = null;
        _currentThinkingMessage = null;
        _isTyping = false;
      });
      _scrollToBottom();
    } else {
      setState(() {
        _currentThinkingMessage = null;
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

  void _clearConversation() async {
    // 获取当前用户的 session ID (username)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.user?.username;
    
    // 只有登录用户才能清除历史
    if (username == null) {
      return;
    }

    // 清除本地消息
    setState(() {
      _messages.clear();
    });

    // 清除服务端历史（使用用户名作为 session ID）
    try {
      await ChatService.clearHistory(username);
    } catch (e) {
      // 服务端清除失败时静默处理，本地已清除
      debugPrint('Failed to clear server history: $e');
    }

    // 清除本地 session
    ChatService.clearSession();
    
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
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'events') {
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
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.profile),
                  ],
                ),
              ),
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
    debugPrint('Building typing area: thinking=$_currentThinkingMessage, response=${_currentResponse.length} chars');
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
              child: _currentResponse.isNotEmpty
                  ? MarkdownBody(
                      data: _currentResponse,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        strong: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        em: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                        listBullet: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                        code: TextStyle(
                          color: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          fontSize: 14,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  : _currentThinkingMessage != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentThinkingMessage!,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TypingDot(delay: 0),
                            const SizedBox(width: 4),
                            _TypingDot(delay: 150),
                            const SizedBox(width: 4),
                            _TypingDot(delay: 300),
                          ],
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
                        // Send button (arrow up) - focusable with Tab key
                        Builder(
                          builder: (context) {
                            final bool canSend = !_isTyping && 
                                (_messageController.text.trim().isNotEmpty || _selectedImages.isNotEmpty);
                            return Focus(
                              focusNode: _sendButtonFocusNode,
                              child: Builder(
                                builder: (context) {
                                  final isFocused = Focus.of(context).hasFocus;
                                  return GestureDetector(
                                    onTap: canSend ? _sendMessage : null,
                                    child: KeyboardListener(
                                      focusNode: FocusNode(skipTraversal: true),
                                      onKeyEvent: (event) {
                                        // Handle Enter/Space when focused
                                        if (canSend && 
                                            event is KeyDownEvent &&
                                            (event.logicalKey.keyLabel == 'Enter' || 
                                             event.logicalKey.keyLabel == ' ')) {
                                          _sendMessage();
                                        }
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: canSend 
                                              ? AppColors.primary
                                              : AppColors.primary.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(10),
                                          // Show focus ring when focused
                                          border: isFocused 
                                              ? Border.all(color: AppColors.accent, width: 2)
                                              : null,
                                          boxShadow: isFocused
                                              ? [BoxShadow(
                                                  color: AppColors.accent.withValues(alpha: 0.3),
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                )]
                                              : null,
                                        ),
                                        child: Icon(
                                          Icons.arrow_upward_rounded,
                                          color: canSend 
                                              ? Colors.white 
                                              : Colors.white.withValues(alpha: 0.7),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
  final Map<String, dynamic>? actionResult;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.intent,
    this.isError = false,
    this.images,
    this.actionResult,
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
                    isUser
                        ? SelectableText(
                            message.content,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          )
                        : MarkdownBody(
                            data: message.content,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: message.isError 
                                    ? AppColors.error 
                                    : AppColors.textPrimary,
                                fontSize: 15,
                                height: 1.5,
                              ),
                              strong: TextStyle(
                                color: message.isError 
                                    ? AppColors.error 
                                    : AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              em: TextStyle(
                                color: message.isError 
                                    ? AppColors.error 
                                    : AppColors.textPrimary,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                              listBullet: TextStyle(
                                color: message.isError 
                                    ? AppColors.error 
                                    : AppColors.textPrimary,
                                fontSize: 15,
                              ),
                              code: TextStyle(
                                color: AppColors.primary,
                                backgroundColor: AppColors.surface,
                                fontSize: 14,
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                  // ICS Download button when event is created
                  if (!isUser && _hasIcsContent(message.actionResult)) ...[
                    const SizedBox(height: 12),
                    _buildIcsDownloadButton(context, message.actionResult!),
                  ],
                  // Collapsible action_result display (hidden - for debugging only)
                  // if (!isUser && message.actionResult != null) ...[
                  //   const SizedBox(height: 8),
                  //   _buildActionResultCollapsible(context, message.actionResult!),
                  // ],
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

  /// Check if actionResult contains ICS content
  bool _hasIcsContent(Map<String, dynamic>? actionResult) {
    if (actionResult == null) return false;
    // Check for single event ICS
    if (actionResult['ics_content'] != null) return true;
    // Check for multiple events with ICS
    final events = actionResult['events'] as List<dynamic>?;
    if (events != null && events.isNotEmpty) {
      return events.any((e) => e['ics_content'] != null);
    }
    return false;
  }

  /// Build action buttons (ICS download + View Event)
  Widget _buildIcsDownloadButton(BuildContext context, Map<String, dynamic> actionResult) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Add to Calendar button
        _buildActionButton(
          context: context,
          icon: Icons.calendar_today_outlined,
          label: 'Add to Calendar',
          onTap: () => _downloadIcs(context, actionResult),
        ),
        // View Event Detail button
        _buildActionButton(
          context: context,
          icon: Icons.visibility_outlined,
          label: 'View Detail',
          onTap: () => _viewEventDetail(context, actionResult),
          isSecondary: true,
        ),
      ],
    );
  }

  /// Build collapsible action_result display
  Widget _buildActionResultCollapsible(BuildContext context, Map<String, dynamic> actionResult) {
    // Format action_result for display
    final action = actionResult['action'] as String? ?? 'unknown';
    final hasError = actionResult.containsKey('error');
    final needMoreInfo = actionResult['need_more_info'] == true;
    
    // Determine status icon and color
    IconData statusIcon;
    Color statusColor;
    if (hasError) {
      statusIcon = Icons.error_outline;
      statusColor = AppColors.error;
    } else if (needMoreInfo) {
      statusIcon = Icons.help_outline;
      statusColor = Colors.orange;
    } else {
      statusIcon = Icons.check_circle_outline;
      statusColor = Colors.green;
    }

    // Build summary text
    String summary = _getActionSummary(action, actionResult);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        leading: Icon(statusIcon, color: statusColor, size: 18),
        title: Text(
          summary,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.expand_more, size: 18),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: SelectableText(
              _formatJsonForDisplay(actionResult),
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get human-readable action summary
  String _getActionSummary(String action, Map<String, dynamic> actionResult) {
    switch (action) {
      case 'create_event':
        final eventId = actionResult['event_id'];
        return eventId != null ? 'Created event #$eventId' : 'Create event';
      case 'update_event':
        final eventId = actionResult['event_id'];
        return eventId != null ? 'Updated event #$eventId' : 'Update event';
      case 'delete_event':
        final eventIds = actionResult['event_ids'];
        return eventIds != null ? 'Deleted ${(eventIds as List).length} event(s)' : 'Delete event';
      case 'query_event':
        final events = actionResult['events'] as List?;
        return events != null ? 'Found ${events.length} event(s)' : 'Query events';
      case 'general_conversation':
        return 'General chat';
      default:
        return action.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Format JSON for display with proper indentation
  String _formatJsonForDisplay(Map<String, dynamic> data) {
    // Create a cleaned copy without large base64 content
    final cleaned = _cleanForDisplay(data);
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(cleaned);
  }

  /// Clean data for display (truncate large values)
  Map<String, dynamic> _cleanForDisplay(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is String && value.length > 100) {
        // Truncate long strings (like base64)
        result[key] = '${value.substring(0, 50)}... (${value.length} chars)';
      } else if (value is Map<String, dynamic>) {
        result[key] = _cleanForDisplay(value);
      } else if (value is List) {
        result[key] = value.map((e) {
          if (e is Map<String, dynamic>) {
            return _cleanForDisplay(e);
          } else if (e is String && e.length > 100) {
            return '${e.substring(0, 50)}... (${e.length} chars)';
          }
          return e;
        }).toList();
      } else {
        result[key] = value;
      }
    }
    return result;
  }

  /// Navigate to event detail page
  void _viewEventDetail(BuildContext context, Map<String, dynamic> actionResult) {
    EventData? eventData;

    // Try to get event from actionResult
    if (actionResult['event_id'] != null) {
      // Single event created
      eventData = EventData(
        id: actionResult['event_id'] as int,
        title: actionResult['event_title'] as String? ?? 'Event',
        startTime: DateTime.now(), // Will be loaded from server
      );
    } else if (actionResult['events'] != null) {
      // Multiple events - get first one
      final events = actionResult['events'] as List<dynamic>;
      if (events.isNotEmpty) {
        final firstEvent = events.first as Map<String, dynamic>;
        eventData = EventData(
          id: firstEvent['id'] as int?,
          title: firstEvent['title'] as String? ?? 'Event',
          startTime: firstEvent['start_time'] != null
              ? DateTime.parse(firstEvent['start_time'] as String)
              : DateTime.now(),
          endTime: firstEvent['end_time'] != null
              ? DateTime.parse(firstEvent['end_time'] as String)
              : null,
          location: firstEvent['location'] as String?,
        );
      }
    }

    if (eventData != null) {
      Navigator.pushNamed(
        context,
        '/preview',
        arguments: {'event': eventData, 'isEditing': true},
      );
    } else {
      // Fallback to events list
      Navigator.pushNamed(context, '/events');
    }
  }

  /// Build a single action button
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    final color = isSecondary ? AppColors.textSecondary : AppColors.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Download ICS file
  Future<void> _downloadIcs(BuildContext context, Map<String, dynamic> actionResult) async {
    try {
      String? icsBase64;
      String title = 'event';

      // Get ICS content from single event or first event in list
      if (actionResult['ics_content'] != null) {
        icsBase64 = actionResult['ics_content'] as String;
        title = actionResult['event_title'] as String? ?? 'event';
      } else {
        final events = actionResult['events'] as List<dynamic>?;
        if (events != null && events.isNotEmpty) {
          final firstEvent = events.first as Map<String, dynamic>;
          icsBase64 = firstEvent['ics_content'] as String?;
          title = firstEvent['title'] as String? ?? 'event';
        }
      }

      if (icsBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No calendar file available')),
        );
        return;
      }

      final icsBytes = base64Decode(icsBase64);
      final filename = '${title.replaceAll(RegExp(r'[^\w\s]'), '')}.ics';

      if (kIsWeb) {
        // Web platform download
        final blob = html.Blob([icsBytes], 'text/calendar');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calendar file downloaded')),
        );
      } else {
        // Mobile platform save file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(icsBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${file.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
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
