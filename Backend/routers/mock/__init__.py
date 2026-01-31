"""
Mock API Routers - /mock/*

用于前端开发调试，返回模拟数据
"""
from fastapi import APIRouter

from . import auth, users, parse, events

# 创建 Mock 路由器
mock_router = APIRouter(prefix="/mock", tags=["Mock API"])

# 注册所有 mock 路由
mock_router.include_router(auth.router)
mock_router.include_router(users.router)
mock_router.include_router(parse.router)
mock_router.include_router(events.router)
