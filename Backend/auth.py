"""
Authentication - 固定 Token 验证（Token = 密码）

从数据库查询用户并验证 Token
"""
from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from database import get_db
from models import User
from logging_config import get_logger

logger = get_logger(__name__)

# Bearer Token 安全模式
security = HTTPBearer(auto_error=False)


def verify_token(token: str, db: Session) -> Optional[User]:
    """
    验证固定 Token（Token = 密码）

    支持的 Token：
    - alice123 -> alice 用户
    - bob123 -> bob 用户
    - jane123 -> jane 用户
    - xiao123 -> xiao 用户
    - moni123 -> moni 用户
    """
    # 从数据库查找密码匹配的用户
    user = db.query(User).filter(User.password == token).first()
    return user


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    """
    依赖注入：获取当前登录用户

    使用固定 Token 验证：
    - Authorization: Bearer alice123
    - Authorization: Bearer bob123
    """
    if credentials is None:
        logger.warning("Authentication failed: no credentials provided")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated. Use 'Authorization: Bearer alice123'",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials
    user = verify_token(token, db)

    if user is None:
        logger.warning(f"Authentication failed: invalid token")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token. Valid tokens: alice123, bob123, jane123, xiao123, moni123",
            headers={"WWW-Authenticate": "Bearer"},
        )

    logger.debug(f"User authenticated: {user.username} (id={user.id})")
    return user


async def get_current_user_optional(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> Optional[User]:
    """
    可选认证：如果提供了 Token 则验证，否则返回 None
    """
    if credentials is None:
        return None

    token = credentials.credentials
    return verify_token(token, db)
