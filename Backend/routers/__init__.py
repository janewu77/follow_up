"""
API Routers

Route structure:
- /api/*   - API (uses database + LLM)
"""
from fastapi import APIRouter

# Import API routers
from . import auth, users, parse, events, chat

# Create API router
api_router = APIRouter(prefix="/api", tags=["API"])

# Register API routers
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(parse.router)
api_router.include_router(events.router)
api_router.include_router(chat.router)