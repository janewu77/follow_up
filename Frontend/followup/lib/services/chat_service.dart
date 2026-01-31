import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

/// Chat event types from SSE stream
enum ChatEventType {
  status,
  intent,
  token,
  action,
  done,
  error,
}

/// Chat event data
class ChatEvent {
  final ChatEventType type;
  final String? message;
  final String? intent;
  final String? token;
  final Map<String, dynamic>? actionResult;
  final String? sessionId;
  final String? error;

  ChatEvent({
    required this.type,
    this.message,
    this.intent,
    this.token,
    this.actionResult,
    this.sessionId,
    this.error,
  });

  factory ChatEvent.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    ChatEventType type;
    
    switch (typeStr) {
      case 'status':
        type = ChatEventType.status;
        break;
      case 'intent':
        type = ChatEventType.intent;
        break;
      case 'token':
        type = ChatEventType.token;
        break;
      case 'action':
        type = ChatEventType.action;
        break;
      case 'done':
        type = ChatEventType.done;
        break;
      case 'error':
        type = ChatEventType.error;
        break;
      default:
        type = ChatEventType.status;
    }

    return ChatEvent(
      type: type,
      message: json['message'] as String?,
      intent: json['intent'] as String?,
      token: json['token'] as String?,
      actionResult: json['action_result'] as Map<String, dynamic>?,
      sessionId: json['session_id'] as String?,
      error: json['error'] as String?,
    );
  }
}

/// Chat service for streaming API
class ChatService {
  static String? _sessionId;

  /// Get current session ID
  static String? get sessionId => _sessionId;

  /// Clear session (for new conversation)
  static void clearSession() {
    _sessionId = null;
  }

  /// Send message with streaming response
  static Stream<ChatEvent> sendMessageStream({
    required String message,
    String? imageBase64,
    List<String>? imagesBase64,
  }) async* {
    final token = await AuthService.getToken();
    if (token == null) {
      yield ChatEvent(
        type: ChatEventType.error,
        error: 'Not authenticated',
      );
      return;
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/chat?stream=true');
    
    final requestBody = <String, dynamic>{
      'message': message,
      if (_sessionId != null) 'session_id': _sessionId,
      if (imagesBase64 != null && imagesBase64.isNotEmpty)
        'images_base64': imagesBase64
      else if (imageBase64 != null)
        'image_base64': imageBase64,
    };

    final request = http.Request('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode(requestBody);

    try {
      final client = http.Client();
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        yield ChatEvent(
          type: ChatEventType.error,
          error: 'Server error: ${streamedResponse.statusCode}',
        );
        client.close();
        return;
      }

      String buffer = '';
      
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        buffer += chunk;
        
        // Process complete lines
        while (buffer.contains('\n')) {
          final newlineIndex = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);
          
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            if (jsonStr.isEmpty) continue;
            
            try {
              final data = jsonDecode(jsonStr) as Map<String, dynamic>;
              final event = ChatEvent.fromJson(data);
              
              // Store session ID
              if (event.type == ChatEventType.done && event.sessionId != null) {
                _sessionId = event.sessionId;
              }
              
              yield event;
            } catch (e) {
              // Ignore parse errors for malformed JSON
            }
          }
        }
      }
      
      client.close();
    } catch (e) {
      yield ChatEvent(
        type: ChatEventType.error,
        error: e.toString(),
      );
    }
  }

  /// Send message without streaming (for fallback)
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? imageBase64,
    List<String>? imagesBase64,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/chat');
    
    final requestBody = <String, dynamic>{
      'message': message,
      if (_sessionId != null) 'session_id': _sessionId,
      if (imagesBase64 != null && imagesBase64.isNotEmpty)
        'images_base64': imagesBase64
      else if (imageBase64 != null)
        'image_base64': imageBase64,
    };

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    
    // Store session ID
    if (data['session_id'] != null) {
      _sessionId = data['session_id'] as String;
    }

    return data;
  }
}
