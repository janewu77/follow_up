# FollowUP Backend - Development Guide

## Project Overview

**FollowUP** is an intelligent calendar assistant that helps users achieve Work-Life Balance by automatically extracting events from text, images, and voice inputs.

---

## Architecture

### Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | FastAPI |
| Database | SQLite (dev) / PostgreSQL (prod) |
| ORM | SQLAlchemy |
| Auth | JWT (python-jose) |
| LLM | LangChain + OpenAI API |
| ICS | icalendar |

### Route Structure

```
/api/*    - Production API (database + LLM)
```

### Directory Structure

```
Backend/
├── main.py              # FastAPI entry point
├── auth.py              # Token authentication
├── schemas.py           # Pydantic request/response models
├── routers/
│   ├── __init__.py      # Exports api_router
│   ├── auth.py          # /api/auth/*
│   ├── users.py         # /api/user/*
│   ├── parse.py         # /api/parse
│   ├── events.py        # /api/events/*
│   └── chat.py          # /api/chat (智能对话 Agent)
├── services/            # Services layer
│   ├── __init__.py
│   ├── llm_service.py   # LangChain integration (✅ implemented)
│   └── README.md        # LLM service documentation
└── tests/               # Unit tests
    ├── test_auth.py
    ├── test_parse.py
    ├── test_events.py
    ├── test_chat.py     # Chat Agent tests
    └── test_database.py
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | User login, returns JWT |
| GET | `/api/user/me` | Get current user info |
| POST | `/api/parse` | Parse text/image to events |
| POST | `/api/chat` | Intelligent chat agent (intent recognition, event management) |
| DELETE | `/api/chat/{session_id}` | Clear conversation history |
| GET | `/api/events` | List user's events |
| POST | `/api/events` | Create new event |
| PUT | `/api/events/{id}` | Update event |
| DELETE | `/api/events/{id}` | Delete event |
| GET | `/api/events/{id}/ics` | Download ICS file |
| GET | `/api/health` | Health check |

---

## Chat API 详细说明

### POST `/api/chat`

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

### DELETE `/api/chat/{session_id}`

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

## Preset Users (for development)

| Username | Password |
|----------|----------|
| alice | alice123 |
| bob | bob123 |
| jane | jane123 |
| xiao | xiao123 |
| moni | moni123 |

---

## Development Commands

```bash
# Install dependencies
uv sync

# Run development server
uv run uvicorn main:app --reload

# Run tests (ALWAYS use venv/virtual environment)
# Option 1: Using uv (recommended)
uv run pytest

# Option 2: Using virtualenv
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
pytest

# Format code
uv run ruff format .

# Lint code
uv run ruff check .
```

**⚠️ IMPORTANT: Always run tests in a virtual environment (venv). Never run tests with system Python directly.**

---

## Implementation Checklist

### Phase 1: Core (P0)

- [x] Database models (User, Event, Conversation) with SQLAlchemy
- [x] User authentication with database
- [x] LangChain text parsing integration
- [x] OpenAI Vision image parsing
- [x] Events CRUD with database
- [x] ICS file generation
- [x] Intelligent chat agent with LangGraph (intent recognition, conversation memory)

### Phase 2: Enhanced (P1)

- [ ] Batch event parsing
- [ ] Voice-to-text (Whisper API)
- [ ] WebSocket streaming response

---

## Important Notes

### Unit Testing Requirements

**All code changes MUST include unit tests.**

**⚠️ CRITICAL: Always run tests in a virtual environment (venv).**

- **Never** run tests with system Python directly
- **Always** activate venv before running tests: `source venv/bin/activate` (Linux/Mac) or `venv\Scripts\activate` (Windows)
- **Recommended**: Use `uv run pytest` which automatically manages the virtual environment
- This ensures test isolation and prevents dependency conflicts

```python
# Example test structure
# tests/test_auth.py

import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_login_success():
    response = client.post("/api/auth/login", json={
        "username": "alice",
        "password": "alice123"
    })
    assert response.status_code == 200
    assert "access_token" in response.json()

def test_login_invalid_credentials():
    response = client.post("/api/auth/login", json={
        "username": "alice",
        "password": "wrong"
    })
    assert response.status_code == 401
```

### Code Style

- Use type hints for all function parameters and return values
- Use Pydantic models for request/response validation
- Handle errors with proper HTTP status codes
- Add docstrings to all public functions

### Environment Variables

```bash
# .env (do not commit!)
DATABASE_URL=sqlite:///./followup.db
JWT_SECRET=your-secret-key-here
OPENAI_API_KEY=sk-xxx
```

---

## Related Documentation

- [Backend Development Plan](../Docs/backend.md)
- [Frontend Development Plan](../Docs/frontend.md)
- [Product Specification](../Docs/产品说明.md)

---

*Last updated: 2026-01-31*
