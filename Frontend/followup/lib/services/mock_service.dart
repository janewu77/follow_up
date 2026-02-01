import '../models/user.dart';
import '../models/event.dart';

// Mock 服务（开发用）
class MockService {
  // 当前登录用户（Mock）
  static User? _currentUser;

  // 模拟获取当前用户
  static Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_currentUser == null) {
      throw Exception("未登录");
    }
    return _currentUser!;
  }

  // 模拟登录
  static Future<LoginResponse> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (username == "alice" && password == "alice123") {
      _currentUser = User(id: 1, username: "alice");
      return LoginResponse(
        accessToken: "mock_token_12345",
        tokenType: "bearer",
        user: _currentUser!,
      );
    }
    if (username == "demo" && password == "demo123") {
      _currentUser = User(id: 2, username: "demo");
      return LoginResponse(
        accessToken: "mock_token_demo",
        tokenType: "bearer",
        user: _currentUser!,
      );
    }
    throw Exception("用户名或密码错误");
  }

  // 模拟解析日程
  static Future<ParseResponse> parseEvent({
    required String inputType,
    String? textContent,
    String? imageBase64,
    String? additionalNote,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // 模拟 AI 处理时间

    // 根据输入内容生成不同的 mock 数据
    if (textContent != null && textContent.contains("音乐会")) {
      return ParseResponse(
        events: [
          EventData(
            id: null,
            title: "古典音乐会",
            startTime: DateTime.now().add(const Duration(days: 7)),
            endTime: DateTime.now().add(const Duration(days: 7, hours: 2)),
            location: "音乐厅",
            description: "从文本识别的音乐会活动",
            sourceType: inputType,
            isFollowed: false,
          ),
        ],
        parseId: "mock-parse-${DateTime.now().millisecondsSinceEpoch}",
      );
    }

    return ParseResponse(
      events: [
        EventData(
          id: null,
          title: "Mock 会议",
          startTime: DateTime.now().add(const Duration(days: 3)),
          endTime: DateTime.now().add(const Duration(days: 3, hours: 1)),
          location: "Mock 地点",
          description: "这是一个 Mock 活动，从${inputType == 'text' ? '文本' : '图片'}识别",
          sourceType: inputType,
          isFollowed: false,
        ),
      ],
      parseId: "mock-parse-${DateTime.now().millisecondsSinceEpoch}",
    );
  }

  // 模拟获取活动列表
  static Future<List<EventData>> getEvents({bool followedOnly = false}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockEvents(followedOnly: followedOnly);
  }

  // 模拟获取单个活动
  static Future<EventData> getEvent(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final events = _getMockEvents();
    return events.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception("活动不存在"),
    );
  }

  // 模拟搜索活动
  static Future<List<EventData>> searchEvents(String query, {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final events = _getMockEvents();
    final lowerQuery = query.toLowerCase();
    return events
        .where((e) =>
            e.title.toLowerCase().contains(lowerQuery) ||
            (e.description?.toLowerCase().contains(lowerQuery) ?? false) ||
            (e.location?.toLowerCase().contains(lowerQuery) ?? false))
        .take(limit)
        .toList();
  }

  // Mock 活动数据
  static List<EventData> _getMockEvents({bool followedOnly = false}) {
    final allEvents = [
      EventData(
        id: 1,
        title: "汉堡爱乐音乐会",
        startTime: DateTime(2026, 2, 15, 19, 30),
        endTime: DateTime(2026, 2, 15, 22, 0),
        location: "Elbphilharmonie",
        description: "贝多芬第九交响曲",
        sourceType: "image",
        isFollowed: true,
      ),
      EventData(
        id: 2,
        title: "同学聚餐",
        startTime: DateTime(2026, 2, 8, 19, 0),
        endTime: null,
        location: "老地方",
        description: null,
        sourceType: "text",
        isFollowed: true,
      ),
      EventData(
        id: 3,
        title: "项目评审会议",
        startTime: DateTime(2026, 2, 10, 14, 0),
        endTime: DateTime(2026, 2, 10, 16, 0),
        location: "会议室 A",
        description: "季度项目进度评审",
        sourceType: "text",
        isFollowed: false,
      ),
      EventData(
        id: 4,
        title: "AI Hackathon Hamburg",
        startTime: DateTime(2026, 2, 20, 9, 0),
        endTime: DateTime(2026, 2, 21, 18, 0),
        location: "Hamburg Innovation Hub",
        description: "48小时 AI 黑客马拉松",
        sourceType: "image",
        isFollowed: true,
      ),
    ];

    if (followedOnly) {
      return allEvents.where((e) => e.isFollowed).toList();
    }
    return allEvents;
  }

  // 模拟创建活动
  static Future<EventData> createEvent(EventData event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return event.copyWith(
      id: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // 模拟更新活动
  static Future<EventData> updateEvent(int id, {
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    bool? isFollowed,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final events = await getEvents();
    final event = events.firstWhere((e) => e.id == id);
    return event.copyWith(
      title: title ?? event.title,
      startTime: startTime ?? event.startTime,
      endTime: endTime ?? event.endTime,
      location: location ?? event.location,
      description: description ?? event.description,
      isFollowed: isFollowed ?? event.isFollowed,
    );
  }

  // 模拟删除活动
  static Future<void> deleteEvent(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // 模拟切换关注状态
  static Future<EventData> toggleFollow(int id, bool isFollowed) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final events = await getEvents();
    final event = events.firstWhere((e) => e.id == id);
    return event.copyWith(isFollowed: isFollowed);
  }

  // 模拟下载 ICS
  static Future<String> downloadIcs(int eventId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 返回模拟的 ICS 内容
    return '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//FollowUP//Mock//EN
BEGIN:VEVENT
DTSTART:20260215T193000
DTEND:20260215T220000
SUMMARY:Mock Event
LOCATION:Mock Location
DESCRIPTION:This is a mock event
END:VEVENT
END:VCALENDAR''';
  }
}
