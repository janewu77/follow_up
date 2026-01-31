# Chat 流式响应使用指南

## 概述

Chat 接口现在支持：
- **流式响应**（Server-Sent Events, SSE）：实时看到 Agent 的回复生成过程
- **多图片上传**：支持一次上传多张图片，批量解析并创建多个日程
- **向后兼容**：保留单图片和文字输入的支持

## API 接口

### 流式模式

**请求**:
```http
POST /api/chat?stream=true
Authorization: Bearer <token>
Content-Type: application/json

{
  "message": "你好，今天天气怎么样？",
  "image_base64": "base64-string",  // 可选：单张图片（向后兼容）
  "images_base64": ["base64-1", "base64-2"],  // 可选：多张图片
  "session_id": "optional-session-id"
}
```

**请求字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| message | string | 是 | 用户消息内容 |
| image_base64 | string | 否 | 单张图片 base64 编码（向后兼容） |
| images_base64 | array[string] | 否 | 多张图片 base64 编码列表 |
| session_id | string | 否 | 会话ID，用于多轮对话 |

**注意**：
- `image_base64` 和 `images_base64` 可以同时使用，但 `images_base64` 优先级更高
- 如果只有一张图片，建议使用 `image_base64`（向后兼容）
- 如果有多张图片，使用 `images_base64` 数组
- 多图片时，Agent 会批量解析所有图片，可能创建多个日程

**响应** (text/event-stream):
```
data: {"type":"status","message":"正在识别意图..."}

data: {"type":"intent","intent":"chat"}

data: {"type":"token","token":"你"}

data: {"type":"token","token":"好"}

data: {"type":"token","token":"！"}

data: {"type":"token","token":"今"}

data: {"type":"token","token":"天"}

...

data: {"type":"done","session_id":"abc123-def456-..."}
```

### 非流式模式（默认）

**请求**:
```http
POST /api/chat
Authorization: Bearer <token>
Content-Type: application/json

{
  "message": "你好",
  "image_base64": "base64-string",  // 可选：单张图片
  "images_base64": ["base64-1", "base64-2"],  // 可选：多张图片
  "session_id": "optional-session-id"
}
```

**响应** (application/json):
```json
{
  "message": "你好！我是你的智能日程助手...",
  "intent": "chat",
  "session_id": "abc123-def456-...",
  "action_result": null
}
```

## Flutter 使用示例

### 方式 1：使用 http 包的 Stream（推荐）

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> chatStream(
  String message, 
  String token, 
  String? sessionId, {
  String? imageBase64,
  List<String>? imagesBase64,
}) async {
  final uri = Uri.parse('https://your-api.com/api/chat?stream=true');
  
  final request = http.Request('POST', uri);
  request.headers['Authorization'] = 'Bearer $token';
  request.headers['Content-Type'] = 'application/json';
  
  final requestBody = {
    'message': message,
    if (sessionId != null) 'session_id': sessionId,
    if (imagesBase64 != null && imagesBase64.isNotEmpty) 
      'images_base64': imagesBase64,
    else if (imageBase64 != null) 
      'image_base64': imageBase64,
  };
  
  request.body = jsonEncode(requestBody);

  final streamedResponse = await http.Client().send(request);
  
  // 监听流式响应
  await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
    // SSE 格式：每行以 "data: " 开头
    final lines = chunk.split('\n');
    
    for (final line in lines) {
      if (line.startsWith('data: ')) {
        final jsonStr = line.substring(6); // 去掉 "data: " 前缀
        try {
          final data = jsonDecode(jsonStr);
          
          switch (data['type']) {
            case 'intent':
              print('意图: ${data['intent']}');
              break;
            case 'token':
              // 实时显示 token
              print(data['token']); // 逐字输出
              break;
            case 'action':
              print('操作结果: ${data['action_result']}');
              break;
            case 'done':
              print('完成，session_id: ${data['session_id']}');
              break;
            case 'error':
              print('错误: ${data['error']}');
              break;
          }
        } catch (e) {
          // 忽略解析错误
        }
      }
    }
  }
}
```

### 方式 2：使用专门的 SSE 包（更简单）

首先添加依赖到 `pubspec.yaml`:
```yaml
dependencies:
  sse: ^4.0.0
```

然后使用：
```dart
import 'package:sse/sse.dart';
import 'dart:convert';

Future<void> chatStreamSSE(
  String message, 
  String token, 
  String? sessionId, {
  String? imageBase64,
  List<String>? imagesBase64,
}) async {
  final requestBody = <String, dynamic>{
    'message': message,
    if (sessionId != null) 'session_id': sessionId,
    if (imagesBase64 != null && imagesBase64.isNotEmpty) 
      'images_base64': imagesBase64,
    else if (imageBase64 != null) 
      'image_base64': imageBase64,
  };
  
  final client = SseClient(
    Uri.parse('https://your-api.com/api/chat?stream=true'),
    method: 'POST',
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(requestBody),
  );

  await for (final event in client.stream) {
    final data = jsonDecode(event.data);
    
    switch (data['type']) {
      case 'intent':
        print('意图: ${data['intent']}');
        break;
      case 'token':
        print(data['token']); // 实时显示
        break;
      case 'done':
        print('完成');
        break;
    }
  }
}
```

### 方式 3：完整的 Flutter Widget 示例

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatStreamWidget extends StatefulWidget {
  final String message;
  final String token;
  final String? sessionId;
  final String? imageBase64;
  final List<String>? imagesBase64;

  const ChatStreamWidget({
    Key? key,
    required this.message,
    required this.token,
    this.sessionId,
    this.imageBase64,
    this.imagesBase64,
  }) : super(key: key);

  @override
  _ChatStreamWidgetState createState() => _ChatStreamWidgetState();
}

class _ChatStreamWidgetState extends State<ChatStreamWidget> {
  String _response = '';
  String? _intent;
  String? _sessionId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  Future<void> _startStream() async {
    final uri = Uri.parse('https://your-api.com/api/chat?stream=true');
    
    final requestBody = {
      'message': widget.message,
      if (widget.sessionId != null) 'session_id': widget.sessionId,
      if (widget.imagesBase64 != null && widget.imagesBase64!.isNotEmpty)
        'images_base64': widget.imagesBase64,
      else if (widget.imageBase64 != null)
        'image_base64': widget.imageBase64,
    };
    
    final request = http.Request('POST', uri);
    request.headers['Authorization'] = 'Bearer ${widget.token}';
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode(requestBody);

    try {
      final streamedResponse = await http.Client().send(request);
      
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            try {
              final data = jsonDecode(jsonStr);
              
              setState(() {
                switch (data['type']) {
                  case 'intent':
                    _intent = data['intent'];
                    break;
                  case 'token':
                    _response += data['token'];
                    break;
                  case 'done':
                    _sessionId = data['session_id'];
                    _isLoading = false;
                    break;
                  case 'error':
                    _response = '错误: ${data['error']}';
                    _isLoading = false;
                    break;
                }
              });
            } catch (e) {
              // 忽略解析错误
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        _response = '连接错误: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_intent != null)
          Chip(
            label: Text('意图: $_intent'),
            backgroundColor: Colors.blue[100],
          ),
        SizedBox(height: 8),
        Text(
          _response,
          style: TextStyle(fontSize: 16),
        ),
        if (_isLoading)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
```

## 多图片上传支持

### 功能说明

Chat 接口和 Parse 接口现在都支持一次上传多张图片：

**Chat 接口** (`/api/chat`)：
- Agent 会批量解析所有图片
- 从每张图片中提取日程信息
- 为每个提取的事件创建日程记录
- 返回所有创建的日程列表

**Parse 接口** (`/api/parse`)：
- 批量解析多张图片
- 返回所有图片中提取的事件列表
- 支持批量处理和降级处理

### 使用场景

**场景 1：单张图片（向后兼容）**
```json
{
  "message": "帮我添加到日程",
  "image_base64": "base64-string"
}
```

**场景 2：多张图片（新功能）**
```json
{
  "message": "分析这些海报，添加到日程",
  "images_base64": [
    "base64-image-1",
    "base64-image-2",
    "base64-image-3"
  ]
}
```

**场景 3：Parse 接口多图片**
```json
POST /api/parse
{
  "input_type": "image",
  "images_base64": [
    "base64-image-1",
    "base64-image-2"
  ],
  "additional_note": "这些是朋友推荐的活动"
}
```

**响应示例（多图片）**:
```json
{
  "message": "好的，我已经从 3 张图片中为您创建了 3 个日程：\n\n1. **音乐会** - 2026年2月15日 19:30\n2. **展览** - 2026年2月20日 10:00\n3. **演出** - 2026年2月25日 20:00",
  "intent": "create_event",
  "session_id": "abc123-def456-...",
  "action_result": {
    "event_ids": [123, 124, 125],
    "events_count": 3,
    "events": [
      {"id": 123, "title": "音乐会", "start_time": "2026-02-15T19:30:00"},
      {"id": 124, "title": "展览", "start_time": "2026-02-20T10:00:00"},
      {"id": 125, "title": "演出", "start_time": "2026-02-25T20:00:00"}
    ]
  }
}
```

### 技术实现

**Chat 接口**：
- 多图片时，Agent 的 `handle_create_event` 会调用 `parse_images_with_llm()` 批量解析
- 批量解析失败时，降级到单图片/文本处理
- 为每个创建的事件生成缩略图（使用第一张图片）

**Parse 接口**：
- 优先使用 `parse_images_with_llm()` 批量解析所有图片
- 批量失败时，自动降级到逐个处理每张图片
- 为每个事件生成对应的缩略图

**共同特性**：
- **批量处理**：优先批量解析，提高效率
- **降级处理**：批量失败时自动逐个处理
- **缩略图**：为每个事件生成缩略图
- **错误处理**：单张图片失败不影响其他图片的处理

### 注意事项

1. **图片数量**：建议一次不超过 10 张图片
2. **图片大小**：每张图片建议不超过 5MB
3. **处理时间**：多图片处理时间会相应增加
4. **事件关联**：批量解析时，LLM 可能无法准确关联事件到具体图片，使用第一张图片的缩略图

## 事件类型说明

| 类型 | 说明 | 数据格式 |
|------|------|----------|
| `thinking` | 思考中状态 | `{"type": "thinking", "message": "正在理解您的请求..."}` |
| `status` | 状态更新 | `{"type": "status", "message": "正在识别意图..."}` |
| `intent` | 意图识别完成 | `{"type": "intent", "intent": "chat"}` |
| `token` | 文本 token（真流式，仅 chat 意图） | `{"type": "token", "token": "字"}` |
| `content` | 完整回复内容（非流式操作） | `{"type": "content", "content": "完整回复文本"}` |
| `action` | 操作结果（如创建的日程） | `{"type": "action", "action_result": {...}}` |
| `done` | 完成 | `{"type": "done", "session_id": "..."}` |
| `error` | 错误 | `{"type": "error", "error": "错误信息"}` |

### Thinking 事件

`thinking` 事件会在以下时机发送：

1. **开始处理**：`"正在理解您的请求..."`
2. **闲聊意图**：`"正在思考回复..."`
3. **创建日程**：`"正在创建日程..."`
4. **查询日程**：`"正在查询日程..."`
5. **修改日程**：`"正在修改日程..."`
6. **删除日程**：`"正在删除日程..."`

前端可以用这个事件来显示加载动画或状态提示，提升用户体验。

## 流式 vs 非流式意图

不同意图的响应方式不同：

| 意图 | 响应方式 | 说明 |
|------|---------|------|
| `chat` | **真流式** (`token` 事件) | 使用 LLM 流式生成，逐 token 返回 |
| `create_event` | 非流式 (`content` 事件) | 需要执行数据库操作，完成后返回完整结果 |
| `query_event` | 非流式 (`content` 事件) | 需要查询数据库，完成后返回完整结果 |
| `update_event` | 非流式 (`content` 事件) | 需要执行数据库操作，完成后返回完整结果 |
| `delete_event` | 非流式 (`content` 事件) | 需要执行数据库操作，完成后返回完整结果 |

**为什么不是所有意图都流式？**

- `chat` 意图：纯文本生成，LLM 可以边生成边返回
- 其他意图：需要先执行数据库操作（创建/查询/修改/删除），操作完成后才能生成回复

## 优势

1. **实时反馈**：chat 意图可以看到回复逐字生成，体验更好
2. **降低感知延迟**：对于 chat 意图，即使总时间相同，用户感觉更快
3. **更好的交互**：可以显示加载状态和进度
4. **操作明确**：对于增删改查操作，先执行再返回结果更可靠

## 注意事项

### 流式响应

1. **向后兼容**：默认 `stream=false`，保持原有行为
2. **错误处理**：流式响应中如果出错，会发送 `error` 事件
3. **连接管理**：Flutter 需要正确处理连接关闭和错误重试
4. **编码问题**：确保使用 UTF-8 编码处理中文

### 多图片上传

1. **图片数量**：建议一次不超过 10 张图片
2. **图片大小**：每张图片建议不超过 5MB
3. **处理时间**：多图片处理时间会相应增加
4. **事件关联**：批量解析时，LLM 可能无法准确关联事件到具体图片
5. **向后兼容**：保留 `image_base64` 单图片支持，`images_base64` 优先级更高

## 测试

### 测试流式响应（文字）

```bash
curl -N -X POST "http://localhost:8000/api/chat?stream=true" \
  -H "Authorization: Bearer alice123" \
  -H "Content-Type: application/json" \
  -d '{"message": "你好"}'
```

### 测试单张图片

```bash
# 先转换图片为 base64
IMAGE_BASE64=$(base64 -i path/to/image.jpg)

curl -N -X POST "http://localhost:8000/api/chat?stream=true" \
  -H "Authorization: Bearer alice123" \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"分析这张图片\", \"image_base64\": \"$IMAGE_BASE64\"}"
```

### 测试多张图片

```bash
# 转换多张图片为 base64
IMG1=$(base64 -i image1.jpg)
IMG2=$(base64 -i image2.jpg)
IMG3=$(base64 -i image3.jpg)

curl -N -X POST "http://localhost:8000/api/chat?stream=true" \
  -H "Authorization: Bearer alice123" \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"分析这些海报\", \"images_base64\": [\"$IMG1\", \"$IMG2\", \"$IMG3\"]}"
```

### 使用测试页面

我们提供了一个简单的 HTML 测试页面：`Backend/tests/chat_test.html`

**使用方法**：
1. 启动后端服务：`python Backend/main.py`
2. 在浏览器中打开 `Backend/tests/chat_test.html`
3. 配置 API 地址和 Token（默认：alice123）
4. 测试文字、单图片、多图片上传功能

**功能**：
- ✅ 文字消息发送
- ✅ 单张/多张图片上传（支持多选）
- ✅ 流式响应显示（实时打字效果）
- ✅ 非流式响应支持
- ✅ 对话历史管理
- ✅ 清除对话功能
- ✅ Thinking 状态显示

`-N` 参数禁用缓冲，可以看到实时输出。

## 向量搜索功能

### 概述

Chat Agent 和 Events API 支持基于向量的语义搜索，可以用自然语言查询日程。

### 环境要求

| 环境 | 数据库 | 向量搜索 |
|------|--------|----------|
| 开发 | SQLite | 降级为 LIKE 文本搜索 |
| 生产 | PostgreSQL + pgvector | 向量相似度搜索 |

### API 端点

```http
GET /api/events/search?q=开会相关的日程&limit=10
Authorization: Bearer <token>
```

**参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| q | string | 是 | 搜索查询（自然语言） |
| limit | int | 否 | 返回结果数量（默认 10，最大 50） |

**响应**: 与 `GET /api/events` 相同格式

### 工作原理

1. **Embedding 生成**：使用 OpenAI `text-embedding-3-small` 模型
2. **向量维度**：1536 维
3. **相似度计算**：余弦相似度（cosine similarity）
4. **自动 Embedding**：创建/更新日程时自动生成 embedding

### Chat Agent 集成

当用户通过 Chat 接口查询日程时（`query_event` 意图），Agent 会：

1. 在 PostgreSQL 环境下使用向量搜索找到语义相关的日程
2. 在 SQLite 环境下降级为普通查询
3. 用 LLM 根据搜索结果生成自然语言回复

**示例对话**:
```
用户: 我有哪些和产品相关的会议？
Agent: [使用向量搜索找到相关日程]
       您有以下与产品相关的会议：
       1. 产品评审会 - 2月5日 10:00
       2. 产品需求讨论 - 2月7日 14:30
```

### PostgreSQL 配置

生产环境需要安装 pgvector 扩展：

```sql
-- 需要 PostgreSQL 管理员权限
CREATE EXTENSION IF NOT EXISTS vector;
```

迁移脚本会自动：
1. 启用 pgvector 扩展
2. 添加 embedding 列
3. 创建向量索引（当数据量 >= 100 时）
