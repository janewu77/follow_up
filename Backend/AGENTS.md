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
│   └── events.py        # /api/events/*
├── services/            # Services layer
│   ├── __init__.py
│   ├── llm_service.py   # LangChain integration (✅ implemented)
│   └── README.md        # LLM service documentation
└── tests/               # TODO: create
    ├── test_auth.py
    ├── test_parse.py
    └── test_events.py
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | User login, returns JWT |
| GET | `/api/user/me` | Get current user info |
| POST | `/api/parse` | Parse text/image to events |
| GET | `/api/events` | List user's events |
| POST | `/api/events` | Create new event |
| PUT | `/api/events/{id}` | Update event |
| DELETE | `/api/events/{id}` | Delete event |
| GET | `/api/events/{id}/ics` | Download ICS file |
| GET | `/api/health` | Health check |

---

## Preset Users (for development)

| Username | Password |
|----------|----------|
| alice | alice123 |
| bob | bob123 |
| jane | jane123 |
| xiao | xiao123 |

---

## Development Commands

```bash
# Install dependencies
uv sync

# Run development server
uv run uvicorn main:app --reload

# Run tests
uv run pytest

# Format code
uv run ruff format .

# Lint code
uv run ruff check .
```

---

## Implementation Checklist

### Phase 1: Core (P0)

- [x] Database models (User, Event) with SQLAlchemy
- [x] User authentication with database
- [x] LangChain text parsing integration
- [x] OpenAI Vision image parsing
- [x] Events CRUD with database
- [x] ICS file generation

### Phase 2: Enhanced (P1)

- [ ] Batch event parsing
- [ ] Voice-to-text (Whisper API)
- [ ] WebSocket streaming response

---

## Important Notes

### Unit Testing Requirements

**All code changes MUST include unit tests.**

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
