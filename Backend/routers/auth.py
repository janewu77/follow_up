"""
认证路由 - /api/auth/*

TODO: 实现真实的数据库认证
"""
from fastapi import APIRouter, HTTPException, status

from schemas import LoginRequest, LoginResponse

router = APIRouter(prefix="/auth", tags=["认证"])


@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest):
    """
    用户登录
    
    使用数据库验证用户，返回 JWT Token
    
    TODO: 实现真实的数据库认证
    """
    # TODO: 实现数据库查询用户
    # TODO: 验证密码
    # TODO: 生成 JWT Token
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="API not implemented yet. Use /mock/auth/login for development.",
    )
