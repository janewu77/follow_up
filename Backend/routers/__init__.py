"""
API Routers

路由结构：
- /api/*   - API（使用数据库 + LLM）
"""
from fastapi import APIRouter

# 导入 API 路由
from . import auth, users, parse, events

# 创建 API 路由器
api_router = APIRouter(prefix="/api", tags=["API"])

# 注册 API 路由
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(parse.router)
api_router.include_router(events.router)
