"""
API Routers

路由结构：
- /api/*   - 真实 API（使用数据库 + LLM）
- /mock/*  - Mock API（内存存储 + 模拟数据）
"""
from fastapi import APIRouter

# 导入 Mock 路由
from .mock import mock_router

# 导入真实 API 路由
from . import auth, users, parse, events

# 创建 API 路由器
api_router = APIRouter(prefix="/api", tags=["API"])

# 注册真实 API 路由
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(parse.router)
api_router.include_router(events.router)
