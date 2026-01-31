"""
认证路由 - /api/auth/*

使用固定 Token 认证（Token = 密码）
从数据库查询用户
"""
from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy.orm import Session

from schemas import LoginRequest, LoginResponse, UserResponse
from database import get_db
from models import User
from logging_config import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/auth", tags=["认证"])


@router.post("/login", response_model=LoginResponse)
async def login(
    request: LoginRequest,
    db: Session = Depends(get_db),
):
    """
    用户登录

    验证用户名和密码，返回 Token（Token = 密码）

    预置用户：
    - alice / alice123
    - bob / bob123
    - jane / jane123
    - xiao / xiao123
    - moni / moni123
    """
    logger.info(f"Login attempt for username: {request.username}")
    
    # 从数据库查询用户
    user = db.query(User).filter(User.username == request.username).first()

    if user is None:
        logger.warning(f"Login failed: user '{request.username}' not found")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )
    
    if user.password != request.password:
        logger.warning(f"Login failed: incorrect password for user '{request.username}'")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    # Token 就是密码
    access_token = request.password
    
    logger.info(f"Login successful for user: {user.username} (id={user.id})")

    return LoginResponse(
        access_token=access_token,
        token_type="bearer",
        user=UserResponse(
            id=user.id,
            username=user.username,
            created_at=user.created_at,
        ),
    )
