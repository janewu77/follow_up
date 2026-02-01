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

  // 获取当前用户信息
  static Future<User> getCurrentUser() async {
    if (useMock) {
      return MockService.getCurrentUser();
    }

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/api/user/me"),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception("未登录或登录已过期");
    } else {
      throw Exception("获取用户信息失败");
    }
  }

  // 健康检查 - 测试后端连接
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/health"),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 解析日程
  // 支持单张图片 (imageBase64) 或多张图片 (imagesBase64)
  static Future<ParseResponse> parseEvent({
    required String inputType,
    String? textContent,
    String? imageBase64,
    List<String>? imagesBase64,
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

    final body = <String, dynamic>{
      "input_type": inputType,
      if (textContent != null) "text_content": textContent,
      if (additionalNote != null) "additional_note": additionalNote,
    };

    // 优先使用多图片数组，否则使用单张图片
    if (imagesBase64 != null && imagesBase64.isNotEmpty) {
      body["images_base64"] = imagesBase64;
    } else if (imageBase64 != null) {
      body["image_base64"] = imageBase64;
    }

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/parse"),
      headers: await _authHeaders(),
      body: jsonEncode(body),
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

  // 获取单个活动详情
  static Future<EventData> getEvent(int id) async {
    if (useMock) {
      return MockService.getEvent(id);
    }

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/api/events/$id"),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      return EventData.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception("活动不存在");
    } else {
      throw Exception("获取活动详情失败");
    }
  }

  // 搜索活动
  static Future<List<EventData>> searchEvents(String query, {int limit = 10}) async {
    if (useMock) {
      return MockService.searchEvents(query, limit: limit);
    }

    final uri = Uri.parse("${ApiConfig.baseUrl}/api/events/search")
        .replace(queryParameters: {
          "q": query,
          "limit": limit.toString(),
        });

    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["events"] as List)
          .map((e) => EventData.fromJson(e))
          .toList();
    } else {
      throw Exception("搜索失败");
    }
  }

  // 查找重复活动
  static Future<DuplicatesResponse> getDuplicates({
    double similarityThreshold = 0.8,
    int timeWindowHours = 24,
  }) async {
    if (useMock) {
      return MockService.getDuplicates();
    }

    final uri = Uri.parse("${ApiConfig.baseUrl}/api/events/duplicates")
        .replace(queryParameters: {
          "similarity_threshold": similarityThreshold.toString(),
          "time_window_hours": timeWindowHours.toString(),
        });

    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      return DuplicatesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("查找重复活动失败");
    }
  }

  // 批量删除重复活动
  static Future<DeleteDuplicatesResponse> deleteDuplicates(List<int> eventIds) async {
    if (useMock) {
      return MockService.deleteDuplicates(eventIds);
    }

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/api/events/duplicates"),
      headers: await _authHeaders(),
      body: jsonEncode({"event_ids": eventIds}),
    );

    if (response.statusCode == 200) {
      return DeleteDuplicatesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("删除重复活动失败");
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

  // 更新活动
  // PUT /api/events/{id} - 支持部分更新
  static Future<EventData> updateEvent(int id, {
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    bool? isFollowed,
    String? recurrenceRule,
    DateTime? recurrenceEnd,
  }) async {
    if (useMock) {
      return MockService.updateEvent(id,
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: location,
        description: description,
        isFollowed: isFollowed,
      );
    }

    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (startTime != null) body['start_time'] = startTime.toIso8601String();
    if (endTime != null) body['end_time'] = endTime.toIso8601String();
    if (location != null) body['location'] = location;
    if (description != null) body['description'] = description;
    if (isFollowed != null) body['is_followed'] = isFollowed;
    if (recurrenceRule != null) body['recurrence_rule'] = recurrenceRule;
    if (recurrenceEnd != null) body['recurrence_end'] = recurrenceEnd.toIso8601String();

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/api/events/$id"),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return EventData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("更新活动失败");
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
  // 使用 PUT /api/events/{id} 接口更新 is_followed 字段
  static Future<EventData> toggleFollow(int id, bool isFollowed) async {
    if (useMock) {
      return MockService.toggleFollow(id, isFollowed);
    }

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/api/events/$id"),
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
