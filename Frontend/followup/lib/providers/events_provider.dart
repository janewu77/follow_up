import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/api_service.dart';

// 活动状态管理
class EventsProvider extends ChangeNotifier {
  List<EventData> _events = [];
  List<EventData> _parsedEvents = [];
  bool _isLoading = false;
  bool _isParsing = false;
  String? _error;
  String? _parseId;

  List<EventData> get events => _events;
  List<EventData> get parsedEvents => _parsedEvents;
  List<EventData> get followedEvents => _events.where((e) => e.isFollowed).toList();
  bool get isLoading => _isLoading;
  bool get isParsing => _isParsing;
  String? get error => _error;
  String? get parseId => _parseId;

  // 获取活动列表
  Future<void> fetchEvents({bool followedOnly = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await ApiService.getEvents(followedOnly: followedOnly);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // 解析日程
  Future<bool> parseEvent({
    required String inputType,
    String? textContent,
    String? imageBase64,
    String? additionalNote,
  }) async {
    _isParsing = true;
    _error = null;
    _parsedEvents = [];
    notifyListeners();

    try {
      final response = await ApiService.parseEvent(
        inputType: inputType,
        textContent: textContent,
        imageBase64: imageBase64,
        additionalNote: additionalNote,
      );
      _parsedEvents = response.events;
      _parseId = response.parseId;
      _isParsing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isParsing = false;
      notifyListeners();
      return false;
    }
  }

  // 更新解析的活动
  void updateParsedEvent(int index, EventData event) {
    if (index >= 0 && index < _parsedEvents.length) {
      _parsedEvents[index] = event;
      notifyListeners();
    }
  }

  // 保存活动（创建或更新）
  Future<bool> saveEvent(EventData event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (event.id != null) {
        // 更新现有活动
        final updatedEvent = await ApiService.updateEvent(
          event.id!,
          title: event.title,
          startTime: event.startTime,
          endTime: event.endTime,
          location: event.location,
          description: event.description,
          isFollowed: event.isFollowed,
        );
        // 更新本地列表
        final index = _events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          _events[index] = updatedEvent;
        }
      } else {
        // 创建新活动
        final savedEvent = await ApiService.createEvent(event);
        _events.add(savedEvent);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 删除活动
  Future<bool> deleteEvent(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.deleteEvent(id);
      _events.removeWhere((e) => e.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 切换关注状态
  Future<bool> toggleFollow(int id) async {
    final index = _events.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    final currentEvent = _events[index];
    final newFollowStatus = !currentEvent.isFollowed;

    try {
      final updatedEvent = await ApiService.toggleFollow(id, newFollowStatus);
      _events[index] = updatedEvent;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // 下载 ICS
  Future<List<int>?> downloadIcs(int eventId) async {
    try {
      return await ApiService.downloadIcs(eventId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // 清除解析结果
  void clearParsedEvents() {
    _parsedEvents = [];
    _parseId = null;
    notifyListeners();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
