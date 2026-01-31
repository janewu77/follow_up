"""
用户路由 - /api/user/*

TODO: 实现真实的数据库查询
"""
from fastapi import APIRouter, HTTPException, status, Depends

from schemas import UserResponse
from auth import get_current_user

router = APIRouter(prefix="/user", tags=["用户"])


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: dict = Depends(get_current_user)):
    """
    获取当前登录用户信息
    
    需要在 Header 中携带 Authorization: Bearer <token>
    
    TODO: 实现真实的数据库查询
    """
    # TODO: 从数据库查询用户详细信息
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="API not implemented yet. Use /mock/user/me for development.",
    )
