// 日程/活动模型
class EventData {
  final int? id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? description;
  final String? sourceType;
  final String? sourceThumbnail; // 图片来源缩略图 (base64)
  final bool isFollowed;
  final DateTime? createdAt; // 创建时间
  final String? recurrenceRule; // RRULE 重复规则
  final DateTime? recurrenceEnd; // 重复结束时间
  final int? parentEventId; // 父活动 ID（重复实例）
  final String? icsContent; // ICS 文件内容 (base64)
  final String? icsDownloadUrl; // ICS 下载链接

  EventData({
    this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.location,
    this.description,
    this.sourceType,
    this.sourceThumbnail,
    this.isFollowed = false,
    this.createdAt,
    this.recurrenceRule,
    this.recurrenceEnd,
    this.parentEventId,
    this.icsContent,
    this.icsDownloadUrl,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      id: json['id'] as int?,
      title: json['title'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      location: json['location'] as String?,
      description: json['description'] as String?,
      sourceType: json['source_type'] as String?,
      sourceThumbnail: json['source_thumbnail'] as String?,
      isFollowed: json['is_followed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      recurrenceRule: json['recurrence_rule'] as String?,
      recurrenceEnd: json['recurrence_end'] != null
          ? DateTime.parse(json['recurrence_end'] as String)
          : null,
      parentEventId: json['parent_event_id'] as int?,
      icsContent: json['ics_content'] as String?,
      icsDownloadUrl: json['ics_download_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'start_time': startTime.toIso8601String(),
      if (endTime != null) 'end_time': endTime!.toIso8601String(),
      if (location != null) 'location': location,
      if (description != null) 'description': description,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceThumbnail != null) 'source_thumbnail': sourceThumbnail,
      'is_followed': isFollowed,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (recurrenceEnd != null) 'recurrence_end': recurrenceEnd!.toIso8601String(),
    };
  }

  EventData copyWith({
    int? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    String? sourceType,
    String? sourceThumbnail,
    bool? isFollowed,
    DateTime? createdAt,
    String? recurrenceRule,
    DateTime? recurrenceEnd,
    int? parentEventId,
    String? icsContent,
    String? icsDownloadUrl,
  }) {
    return EventData(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      description: description ?? this.description,
      sourceType: sourceType ?? this.sourceType,
      sourceThumbnail: sourceThumbnail ?? this.sourceThumbnail,
      isFollowed: isFollowed ?? this.isFollowed,
      createdAt: createdAt ?? this.createdAt,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      recurrenceEnd: recurrenceEnd ?? this.recurrenceEnd,
      parentEventId: parentEventId ?? this.parentEventId,
      icsContent: icsContent ?? this.icsContent,
      icsDownloadUrl: icsDownloadUrl ?? this.icsDownloadUrl,
    );
  }
}

// 解析响应模型
class ParseResponse {
  final List<EventData> events;
  final String parseId;
  final bool needsClarification; // 是否需要用户澄清信息
  final String? clarificationQuestion; // 澄清问题

  ParseResponse({
    required this.events,
    required this.parseId,
    this.needsClarification = false,
    this.clarificationQuestion,
  });

  factory ParseResponse.fromJson(Map<String, dynamic> json) {
    return ParseResponse(
      events: (json['events'] as List)
          .map((e) => EventData.fromJson(e as Map<String, dynamic>))
          .toList(),
      parseId: json['parse_id'] as String,
      needsClarification: json['needs_clarification'] as bool? ?? false,
      clarificationQuestion: json['clarification_question'] as String?,
    );
  }
}

// 重复活动分组
class DuplicateGroup {
  final String key; // 重复标识
  final List<EventData> events; // 该组中的所有重复活动
  final int keepId; // 建议保留的活动 ID
  final List<int> deleteIds; // 建议删除的活动 ID

  DuplicateGroup({
    required this.key,
    required this.events,
    required this.keepId,
    required this.deleteIds,
  });

  factory DuplicateGroup.fromJson(Map<String, dynamic> json) {
    return DuplicateGroup(
      key: json['key'] as String,
      events: (json['events'] as List)
          .map((e) => EventData.fromJson(e as Map<String, dynamic>))
          .toList(),
      keepId: json['keep_id'] as int,
      deleteIds: (json['delete_ids'] as List).cast<int>(),
    );
  }
}

// 重复活动查询响应
class DuplicatesResponse {
  final int totalDuplicates; // 重复活动总数
  final List<DuplicateGroup> groups; // 重复活动分组

  DuplicatesResponse({
    required this.totalDuplicates,
    required this.groups,
  });

  factory DuplicatesResponse.fromJson(Map<String, dynamic> json) {
    return DuplicatesResponse(
      totalDuplicates: json['total_duplicates'] as int,
      groups: (json['groups'] as List)
          .map((g) => DuplicateGroup.fromJson(g as Map<String, dynamic>))
          .toList(),
    );
  }
}

// 删除重复活动响应
class DeleteDuplicatesResponse {
  final int deletedCount;
  final List<int> deletedIds;

  DeleteDuplicatesResponse({
    required this.deletedCount,
    required this.deletedIds,
  });

  factory DeleteDuplicatesResponse.fromJson(Map<String, dynamic> json) {
    return DeleteDuplicatesResponse(
      deletedCount: json['deleted_count'] as int,
      deletedIds: (json['deleted_ids'] as List).cast<int>(),
    );
  }
}
