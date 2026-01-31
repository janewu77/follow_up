import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/user.dart';
import '../models/event.dart';
import 'auth_service.dart';
import 'mock_service.dart';

// API 服务封装
class ApiService {
  // 是否使用 Mock 数据（开发时设为 true）
  static bool useMock = false;

  // 获取认证 Headers
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // 登录
  static Future<LoginResponse> login(String username, String password) async {
    if (useMock) {
      return MockService.login(username, password);
    }

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? "登录失败");
    }
  }

  // 解析日程
  static Future<ParseResponse> parseEvent({
    required String inputType,
    String? textContent,
    String? imageBase64,
    String? additionalNote,
  }) async {
    if (useMock) {
      return MockService.parseEvent(
        inputType: inputType,
        textContent: textContent,
        imageBase64: imageBase64,
        additionalNote: additionalNote,
      );
    }

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/parse"),
      headers: await _authHeaders(),
      body: jsonEncode({
        "input_type": inputType,
        "text_content": textContent,
        "image_base64": imageBase64,
        "additional_note": additionalNote,
      }),
    );

    if (response.statusCode == 200) {
      return ParseResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("解析失败");
    }
  }

  // 获取活动列表
  static Future<List<EventData>> getEvents({bool followedOnly = false}) async {
    if (useMock) {
      return MockService.getEvents(followedOnly: followedOnly);
    }

    final uri = Uri.parse("${ApiConfig.baseUrl}/api/events")
        .replace(queryParameters: {"followed_only": followedOnly.toString()});

    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["events"] as List)
          .map((e) => EventData.fromJson(e))
          .toList();
    } else {
      throw Exception("获取活动列表失败");
    }
  }

  // 创建活动
  static Future<EventData> createEvent(EventData event) async {
    if (useMock) {
      return MockService.createEvent(event);
    }

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/events"),
      headers: await _authHeaders(),
      body: jsonEncode(event.toJson()),
    );

    if (response.statusCode == 201) {
      return EventData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("创建活动失败");
    }
  }

  // 删除活动
  static Future<void> deleteEvent(int id) async {
    if (useMock) {
      return MockService.deleteEvent(id);
    }

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/api/events/$id"),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception("删除活动失败");
    }
  }

  // 切换关注状态
  static Future<EventData> toggleFollow(int id, bool isFollowed) async {
    if (useMock) {
      return MockService.toggleFollow(id, isFollowed);
    }

    final response = await http.patch(
      Uri.parse("${ApiConfig.baseUrl}/api/events/$id/follow"),
      headers: await _authHeaders(),
      body: jsonEncode({"is_followed": isFollowed}),
    );

    if (response.statusCode == 200) {
      return EventData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("操作失败");
    }
  }

  // 下载 ICS
  static Future<List<int>> downloadIcs(int eventId) async {
    if (useMock) {
      final content = await MockService.downloadIcs(eventId);
      return utf8.encode(content);
    }

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/api/events/$eventId/ics"),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("下载失败");
    }
  }
}
