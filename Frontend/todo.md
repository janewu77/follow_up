# Frontend API 对接修改清单

> 生成日期: 2026-02-01
> 分支: jane_f1

## 已完成的修复

### 1. 修复 toggleFollow API Bug ✅
**Commit:** `6b23790`

**问题：** 前端调用 `PATCH /api/events/{id}/follow`，但后端没有这个接口

**修复：** 改为 `PUT /api/events/{id}` 并传递 `{"is_followed": true/false}`

---

### 2. EventData 添加缺少字段 ✅
**Commit:** `e7a8d1f`

添加后端返回但前端缺少的字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `sourceThumbnail` | String? | 图片来源缩略图 (base64) |
| `createdAt` | DateTime? | 创建时间 |
| `recurrenceRule` | String? | RRULE 重复规则 |
| `recurrenceEnd` | DateTime? | 重复结束时间 |
| `parentEventId` | int? | 父活动 ID |
| `icsContent` | String? | ICS 文件内容 (base64) |
| `icsDownloadUrl` | String? | ICS 下载链接 |

---

### 3. ParseResponse 添加澄清字段 ✅
**Commit:** `6d54bb9`

| 字段 | 类型 | 说明 |
|------|------|------|
| `needsClarification` | bool | 是否需要用户澄清 |
| `clarificationQuestion` | String? | 澄清问题 |

---

### 4. 添加 updateEvent API ✅
**Commit:** `d31f6c2`

```dart
ApiService.updateEvent(id, {
  title,
  startTime,
  endTime,
  location,
  description,
  isFollowed,
  recurrenceRule,
  recurrenceEnd,
})
```
调用 `PUT /api/events/{id}`，支持部分更新

---

### 5. 添加 getEvent API ✅
**Commit:** `57ec229`

```dart
ApiService.getEvent(id)
```
调用 `GET /api/events/{id}`，获取单个活动详情

---

### 6. 添加 getCurrentUser API ✅
**Commit:** `c308cf4`

```dart
ApiService.getCurrentUser()
```
调用 `GET /api/user/me`，获取当前登录用户信息

---

### 7. 添加 searchEvents API ✅
**Commit:** `ce48a40`

```dart
ApiService.searchEvents(query, {limit: 10})
```
调用 `GET /api/events/search?q=...&limit=...`

---

### 8. 添加重复活动 API ✅
**Commit:** `d557a3a`

新增 Model：
- `DuplicateGroup` - 重复活动分组
- `DuplicatesResponse` - 重复活动查询响应
- `DeleteDuplicatesResponse` - 删除响应

```dart
ApiService.getDuplicates({similarityThreshold, timeWindowHours})
ApiService.deleteDuplicates(eventIds)
```
调用 `GET/DELETE /api/events/duplicates`

---

### 9. ChatService 添加 clearHistory ✅
**Commit:** `b5ef576`, `9d14975`

```dart
ChatService.clearHistory(sessionId)
```
调用 `DELETE /api/chat/{session_id}`，清除服务端对话历史

**前端控制：**
- 验证用户登录状态
- 使用用户名作为 session ID，确保只能删除自己的历史
- ChatPage `_clearConversation()` 同步清除服务端和本地历史

---

### 10. parseEvent 支持多图片 ✅
**Commit:** `dc87a86`

```dart
ApiService.parseEvent({
  inputType,
  textContent,
  imageBase64,      // 单张图片
  imagesBase64,     // 多张图片 (新增)
  additionalNote,
})
```

---

## 修改的文件

| 文件 | 修改内容 |
|------|----------|
| `lib/models/event.dart` | EventData、ParseResponse 添加字段，新增 DuplicateGroup 等模型 |
| `lib/services/api_service.dart` | 修复 toggleFollow，添加多个 API 方法 |
| `lib/services/mock_service.dart` | 同步添加 mock 实现 |
| `lib/services/chat_service.dart` | 添加 clearHistory 方法 |

---

## 后续可选优化

- [ ] 在 UI 中使用 `needsClarification` 字段显示澄清提示
- [ ] 添加活动搜索 UI
- [ ] 添加重复活动管理 UI
- [ ] 添加用户个人信息页面
