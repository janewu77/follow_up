"""
Authentication Router - /api/auth/*

Uses fixed Token authentication (Token = password)
Queries users from database
"""
from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy.orm import Session

from schemas import LoginRequest, LoginResponse, UserResponse
from database import get_db
from models import User
from logging_config import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/login", response_model=LoginResponse)
async def login(
    request: LoginRequest,
    db: Session = Depends(get_db),
):
    """
    User login

    Validates username and password, returns Token (Token = password)

    Preset users:
    - alice / alice123
    - bob / bob123
    - jane / jane123
    - xiao / xiao123
    - moni / moni123
    """
    logger.info(f"Login attempt for username: {request.username}")
    
    # Query user from database
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

    # Token is the password
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
