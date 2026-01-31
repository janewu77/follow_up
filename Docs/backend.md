# FollowUP 后端开发计划

> 技术栈：Python + FastAPI + SQLAlchemy + LangChain + OpenAI

---

## 一、API 接口规范

### 1.1 认证接口

#### POST /api/auth/login
用户登录，返回 Token（Token = 密码）

**请求体**:
```json
{
  "username": "alice",
  "password": "alice123"
}
```

**响应 200**:
```json
{
  "access_token": "alice123",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "username": "alice",
    "created_at": "2026-01-01T00:00:00"
  }
}
```

**响应 401**:
```json
{"detail": "Invalid credentials"}
```

---

#### GET /api/user/me
获取当前用户信息

**Header**: `Authorization: Bearer <token>`

**响应 200**:
```json
{
  "id": 1,
  "username": "alice",
  "created_at": "2026-01-31T10:00:00Z"
}
```

---

### 1.2 日程解析接口

#### POST /api/parse
解析文字或图片中的日程信息

**Header**: `Authorization: Bearer <token>`

**请求体**:
```json
{
  "input_type": "text",
  "text_content": "下周三下午2点开会",
  "image_base64": null,
  "additional_note": "在星巴克"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| input_type | string | 是 | "text" 或 "image" |
| text_content | string | 否 | 文字内容 |
| image_base64 | string | 否 | 图片 base64 编码 |
| additional_note | string | 否 | 补充说明 |

**响应 200**:
```json
{
  "events": [
    {
      "id": null,
      "title": "开会",
      "start_time": "2026-02-05T14:00:00+08:00",
      "end_time": null,
      "location": "星巴克",
      "description": null,
      "source_type": "text",
      "source_thumbnail": null,
      "is_followed": false
    }
  ],
  "parse_id": "uuid-xxx"
}
```

> **注意**：当 `input_type` 为 `image` 时，`source_thumbnail` 会自动生成为 200x200 的 JPEG 缩略图（base64 编码），方便前端展示图片来源
```

---

### 1.3 智能对话接口

#### POST /api/chat

智能对话接口，基于 LangGraph 的 Agent，支持意图识别和多轮对话。

**功能特性**：
- 意图识别：自动识别用户意图（闲聊/创建日程/修改日程/删除日程/拒绝）
- 图片+文字输入：支持同时上传图片和文字消息
- 对话记忆：维护会话上下文，支持多轮对话
- 智能操作：根据意图自动执行相应的日程操作

**Header**: `Authorization: Bearer <token>`

**请求体**:
```json
{
  "message": "下周三下午2点开会",
  "image_base64": "data:image/jpeg;base64,/9j/4AAQ...",  // 可选
  "session_id": "uuid-xxx"  // 可选，用于多轮对话
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| message | string | 是 | 用户消息内容 |
| image_base64 | string | 否 | 图片 base64 编码（支持 data URI 格式） |
| session_id | string | 否 | 会话ID，用于维护对话上下文。首次请求可不传，系统会自动生成 |

**响应 200**:
```json
{
  "message": "好的，我已经为您创建了日程：下周三（2月5日）下午2点开会",
  "intent": "create_event",
  "session_id": "uuid-xxx",
  "action_result": {
    "event_id": 123,
    "title": "开会",
    "start_time": "2026-02-05T14:00:00+08:00"
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| message | string | Agent 回复消息 |
| intent | string | 识别的意图：`chat`（闲聊）/ `create_event`（创建日程）/ `update_event`（修改日程）/ `delete_event`（删除日程）/ `reject`（拒绝，超出范围） |
| session_id | string | 会话ID，用于后续多轮对话 |
| action_result | object | 操作结果（如创建的日程详情），仅在成功执行操作时返回 |

**意图说明**：
- `chat`: 普通闲聊，Agent 会友好回复
- `create_event`: 创建新日程，Agent 会解析消息并创建日程
- `update_event`: 修改现有日程，Agent 会匹配日程并更新
- `delete_event`: 删除日程，Agent 会匹配日程并删除
- `reject`: 请求超出范围，Agent 会礼貌拒绝

**多轮对话示例**：
```bash
# 第一轮：创建日程
POST /api/chat
{
  "message": "下周三下午2点开会"
}
# 响应：session_id = "abc123"

# 第二轮：修改刚才创建的日程（使用相同的 session_id）
POST /api/chat
{
  "message": "改成下午3点",
  "session_id": "abc123"
}
# Agent 会理解上下文，修改刚才创建的日程
```

**错误响应**:
- `401`: 未认证或 Token 无效
- `422`: 请求参数验证失败（如 message 为空）
- `500`: 服务器内部错误

---

#### DELETE /api/chat/{session_id}

清除指定会话的对话历史。

**Header**: `Authorization: Bearer <token>`

**路径参数**:
- `session_id`: 会话ID

**响应 200**:
```json
{
  "message": "对话历史已清除",
  "session_id": "uuid-xxx"
}
```

---

### 1.4 活动管理接口

#### GET /api/events
获取用户的活动列表

**Header**: `Authorization: Bearer <token>`

**Query 参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| followed_only | bool | 仅返回已 Follow 的活动 |

**响应 200**:
```json
{
  "events": [
    {
      "id": 1,
      "title": "汉堡爱乐音乐会",
      "start_time": "2026-02-15T19:30:00+01:00",
      "end_time": "2026-02-15T22:00:00+01:00",
      "location": "Elbphilharmonie",
      "description": "贝多芬第九交响曲",
      "source_type": "image",
      "source_thumbnail": "/9j/4AAQSkZJRg...(base64 缩略图)",
      "is_followed": true,
      "created_at": "2026-01-31T10:00:00Z"
    }
  ]
}
```

---

#### POST /api/events
创建/保存活动

**Header**: `Authorization: Bearer <token>`

**请求体**:
```json
{
  "title": "开会",
  "start_time": "2026-02-05T14:00:00+08:00",
  "end_time": null,
  "location": "星巴克",
  "description": "记得带PPT",
  "source_type": "text",
  "source_thumbnail": null,
  "is_followed": true
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| title | string | 是 | 活动标题 |
| start_time | datetime | 是 | 开始时间 |
| end_time | datetime | 否 | 结束时间 |
| location | string | 否 | 地点 |
| description | string | 否 | 描述 |
| source_type | string | 否 | 来源类型：text/image/voice/manual |
| source_thumbnail | string | 否 | 图片来源的缩略图（base64 编码） |
| is_followed | bool | 否 | 是否已 Follow（默认 true） |

**响应 201**: 返回创建的 event 对象

---

#### PUT /api/events/{id}
更新活动

**Header**: `Authorization: Bearer <token>`

**请求体**: 同 POST，字段可选

**响应 200**: 返回更新后的 event 对象

---

#### DELETE /api/events/{id}
删除活动

**Header**: `Authorization: Bearer <token>`

**响应 204**: 无内容

---

#### GET /api/events/{id}/ics
下载活动的 ICS 文件

**Header**: `Authorization: Bearer <token>`

**响应 200**:
- Content-Type: `text/calendar`
- Content-Disposition: `attachment; filename="event.ics"`
- Body: ICS 文件内容

---

### 1.5 健康检查

#### GET /api/health

**响应 200**:
```json
{"status": "healthy"}
```

---

## 二、数据库模型

### User 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| username | String(50) | 用户名，唯一 |
| password_hash | String(255) | 密码哈希 |
| created_at | DateTime | 创建时间 |

### Event 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| user_id | Integer | 外键 -> users.id |
| title | String(255) | 活动标题 |
| start_time | DateTime | 开始时间 |
| end_time | DateTime | 结束时间（可空） |
| location | String(500) | 地点（可空） |
| description | Text | 描述（可空） |
| source_type | String(50) | 来源类型：text/image/voice/manual |
| source_content | Text | 原始输入内容 |
| source_thumbnail | Text | 图片来源的缩略图（base64，约 200x200） |
| is_followed | Boolean | 是否已 Follow |
| created_at | DateTime | 创建时间 |

### Conversation 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| session_id | String(100) | 会话ID，唯一 |
| user_id | Integer | 外键 -> users.id |
| messages | JSON | 对话消息列表（存储历史对话） |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

### 预置用户

| Username | Password |
|----------|----------|
| alice | alice123 |
| bob | bob123 |
| jane | jane123 |
| xiao | xiao123 |
| moni | moni123 |

---

## 三、任务清单

### P0 - 核心功能

| 任务 ID | 任务描述 | 预估时间 |
|---------|----------|----------|
| BE-01 | 项目结构搭建（FastAPI + SQLAlchemy + SQLite） | 1h |
| BE-02 | 数据库模型定义（User, Event） | 0.5h |
| BE-03 | 预置用户初始化脚本 | 0.5h |
| BE-04 | 用户认证接口（POST /api/auth/login） | 1h |
| BE-05 | 固定 Token 验证中间件（Token = 密码） | 0.5h |
| BE-06 | 获取当前用户接口（GET /api/user/me） | 0.5h |
| BE-07 | LangChain 集成 + Prompt 模板 | 1.5h |
| BE-08 | 文字解析接口（POST /api/parse - text） | 1h |
| BE-09 | 图片解析接口（POST /api/parse - image） | 1h |
| BE-10 | 活动 CRUD 接口（GET/POST/PUT/DELETE /api/events） | 1.5h |
| BE-11 | ICS 文件生成接口（GET /api/events/{id}/ics） | 1h |
| BE-12 | CORS 配置 + 错误处理 | 0.5h |

**P0 预估总时间**: 约 10 小时

### P1 - 增强功能（可选）

| 任务 ID | 任务描述 | 预估时间 |
|---------|----------|----------|
| BE-13 | 多条日程批量解析 | 1h |
| BE-14 | 语音转文字（Whisper API） | 1.5h |
| BE-15 | WebSocket 流式响应 | 2h |

---

## 四、文件结构

```
Backend/
├── main.py              # FastAPI 入口
├── config.py            # 配置（DB URL, JWT Secret, OpenAI Key）
├── database.py          # SQLAlchemy 连接
├── models.py            # 数据库模型
├── schemas.py           # Pydantic 请求/响应模型
├── auth.py              # JWT 认证逻辑
├── routers/
│   ├── __init__.py
│   ├── auth.py          # /api/auth/*
│   ├── users.py         # /api/user/*
│   ├── parse.py         # /api/parse
│   ├── events.py        # /api/events/*
│   └── chat.py          # /api/chat (智能对话 Agent)
├── services/
│   ├── __init__.py
│   ├── llm_service.py   # LangChain 集成
│   ├── image_utils.py   # 图片处理（缩略图生成）
│   ├── agent/           # LangGraph Agent
│   │   ├── graph.py     # Agent state graph
│   │   ├── memory.py    # Conversation memory
│   │   └── prompts/     # Agent prompts
│   └── prompts/         # LLM prompts
└── requirements.txt
```

---

## 五、环境变量

```bash
# .env（开发环境）
DATABASE_URL=sqlite:///./followup.db
OPENAI_API_KEY=sk-xxx
# JWT 已替换为固定 Token 认证（Token = 密码）

# 生产环境（PostgreSQL）
DATABASE_URL=postgresql://user:password@host:port/database
OPENAI_API_KEY=sk-xxx
```

> **PostgreSQL 部署**：只需设置 `DATABASE_URL` 环境变量即可切换到 PostgreSQL，无需修改代码。启动时会自动创建表结构和预置用户。

---

## 六、开发顺序建议

1. **BE-01~03**: 项目搭建 + 数据库（可与前端并行）
2. **BE-04~06**: 认证模块（前端登录页依赖）
3. **BE-07~09**: 解析接口（核心功能）
4. **BE-10~11**: 活动管理 + ICS（前端联调需要）
5. **BE-12**: 收尾完善

---

## 七、API 调用示例

> 线上环境：`${BASE_URL}`（部署后替换为实际域名）
> 本地环境：`http://localhost:8000`

以下示例使用本地地址，线上调用时替换 `localhost:8000` 为实际域名即可。

### 认证说明

**Token = 密码**，预置用户的 Token：
- alice → `alice123`
- bob → `bob123`
- jane → `jane123`
- xiao → `xiao123`

---

### 7.1 登录

```bash
# 登录获取 Token（Token 就是密码）
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","password":"alice123"}'
```

**响应**：
```json
{
  "access_token": "alice123",
  "token_type": "bearer",
  "user": {"id": 1, "username": "alice", "created_at": "2026-01-01T00:00:00"}
}
```

---

### 7.2 获取用户信息

```bash
curl -X GET "http://localhost:8000/api/user/me" \
  -H "Authorization: Bearer alice123"
```

---

### 7.3 解析文字日程

```bash
# 中文文字
curl -X POST "http://localhost:8000/api/parse" \
  -H "Authorization: Bearer alice123" \
  -H "Content-Type: application/json" \
  -d '{
    "input_type": "text",
    "text_content": "明天下午3点在星巴克开会",
    "additional_note": "记得带电脑"
  }'
```

**响应**：
```json
{
  "events": [
    {
      "id": null,
      "title": "会议",
      "start_time": "2026-02-01T15:00:00",
      "end_time": null,
      "location": "记得带电脑",
      "description": "明天下午3点在星巴克开会",
      "source_type": "text",
      "is_followed": false
    }
  ],
  "parse_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

---

### 7.4 解析图片日程

```bash
# 图片 Base64（海报、截图等）
curl -X POST "http://localhost:8000/api/parse" \
  -H "Authorization: Bearer alice123" \
  -H "Content-Type: application/json" \
  -d '{
    "input_type": "image",
    "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
    "additional_note": "朋友推荐的音乐会"
  }'
```

---

### 7.5 创建活动

```bash
curl -X POST "http://localhost:8000/api/events" \
  -H "Authorization: Bearer alice123" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Team Meeting",
    "start_time": "2026-02-01T15:00:00",
    "end_time": "2026-02-01T16:00:00",
    "location": "Conference Room A",
    "description": "Weekly sync",
    "source_type": "text",
    "is_followed": true
  }'
```

**响应 201**：
```json
{
  "id": 1,
  "title": "Team Meeting",
  "start_time": "2026-02-01T15:00:00",
  "end_time": "2026-02-01T16:00:00",
  "location": "Conference Room A",
  "description": "Weekly sync",
  "source_type": "text",
  "source_thumbnail": null,
  "is_followed": true,
  "created_at": "2026-01-31T12:00:00"
}
```

---

### 7.6 获取活动列表

```bash
# 全部活动
curl -X GET "http://localhost:8000/api/events" \
  -H "Authorization: Bearer alice123"

# 仅已 Follow 的活动
curl -X GET "http://localhost:8000/api/events?followed_only=true" \
  -H "Authorization: Bearer alice123"
```

---

### 7.7 获取单个活动

```bash
curl -X GET "http://localhost:8000/api/events/1" \
  -H "Authorization: Bearer alice123"
```

---

### 7.8 更新活动

```bash
# 更新标题和 Follow 状态
curl -X PUT "http://localhost:8000/api/events/1" \
  -H "Authorization: Bearer alice123" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Meeting Title",
    "is_followed": true
  }'
```

---

### 7.9 删除活动

```bash
curl -X DELETE "http://localhost:8000/api/events/1" \
  -H "Authorization: Bearer alice123"

# 响应 204 No Content
```

---

### 7.10 下载 ICS 日历文件

```bash
# 下载到文件
curl -X GET "http://localhost:8000/api/events/1/ics" \
  -H "Authorization: Bearer alice123" \
  -o event.ics

# 查看内容
curl -X GET "http://localhost:8000/api/events/1/ics" \
  -H "Authorization: Bearer alice123"
```

---

### 7.11 智能对话

```bash
# 创建日程（第一轮对话）
curl -X POST "http://localhost:8000/api/chat" \
  -H "Authorization: Bearer alice123" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "下周三下午2点开会"
  }'
```

**响应**：
```json
{
  "message": "好的，我已经为您创建了日程：下周三（2月5日）下午2点开会",
  "intent": "create_event",
  "session_id": "abc123-def456-...",
  "action_result": {
    "event_id": 123,
    "title": "开会",
    "start_time": "2026-02-05T14:00:00+08:00"
  }
}
```

```bash
# 多轮对话：修改刚才创建的日程（使用 session_id）
curl -X POST "http://localhost:8000/api/chat" \
  -H "Authorization: Bearer alice123" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "改成下午3点",
    "session_id": "abc123-def456-..."
  }'
```

```bash
# 带图片的对话
curl -X POST "http://localhost:8000/api/chat" \
  -H "Authorization: Bearer alice123" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "这张海报上的活动帮我添加到日程",
    "image_base64": "data:image/jpeg;base64,/9j/4AAQ..."
  }'
```

```bash
# 清除对话历史
curl -X DELETE "http://localhost:8000/api/chat/abc123-def456-..." \
  -H "Authorization: Bearer alice123"
```

---

### 7.12 健康检查（无需认证）

```bash
curl -X GET "http://localhost:8000/api/health"
```

**响应**：
```json
{"status": "healthy"}
```

---

---

### PowerShell 用户

Windows PowerShell 中 JSON 需要转义：

```powershell
# 方式一：使用 -Body 和 ConvertTo-Json
$body = @{username="alice"; password="alice123"} | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:8000/api/auth/login" -Method POST -Body $body -ContentType "application/json"

# 方式二：使用 curl.exe（注意 .exe）
curl.exe -X POST "http://localhost:8000/api/auth/login" -H "Content-Type: application/json" -d "{\"username\":\"alice\",\"password\":\"alice123\"}"
```

---

*最后更新：2026-01-31*
