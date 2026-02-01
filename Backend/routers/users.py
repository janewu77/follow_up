"""
User Router - /api/user/*

Uses fixed Token authentication
Queries users from database
"""
from fastapi import APIRouter, Depends

from schemas import UserResponse
from auth import get_current_user
from models import User
from logging_config import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/user", tags=["Users"])


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_user),
):
    """
    Get current logged-in user info

    Requires Authorization header: Authorization: Bearer <token>

    Example: Authorization: Bearer alice123
    """
    logger.debug(f"Getting user info for: {current_user.username} (id={current_user.id})")
    return UserResponse(
        id=current_user.id,
        username=current_user.username,
        created_at=current_user.created_at,
    )
