"""
Pydantic Schemas - 请求/响应模型
"""
from datetime import datetime
from typing import Optional, List, Literal
from pydantic import BaseModel, Field


# ============ 用户相关 ============

class LoginRequest(BaseModel):
    """登录请求"""
    username: str = Field(..., min_length=1, max_length=50)
    password: str = Field(..., min_length=1, max_length=100)


class UserResponse(BaseModel):
    """用户信息响应"""
    id: int
    username: str
    created_at: datetime


class LoginResponse(BaseModel):
    """登录响应"""
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


# ============ 日程解析相关 ============

class ParseRequest(BaseModel):
    """日程解析请求"""
    input_type: Literal["text", "image"] = Field(..., description="输入类型: text 或 image")
    text_content: Optional[str] = Field(None, description="文字内容")
    image_base64: Optional[str] = Field(None, description="图片 base64 编码")
    additional_note: Optional[str] = Field(None, description="补充说明")


class ParsedEvent(BaseModel):
    """解析出的活动"""
    id: Optional[int] = None
    title: str
    start_time: datetime
    end_time: Optional[datetime] = None
    location: Optional[str] = None
    description: Optional[str] = None
    source_type: str
    is_followed: bool = False


class ParseResponse(BaseModel):
    """日程解析响应"""
    events: List[ParsedEvent]
    parse_id: str


# ============ 活动管理相关 ============

class EventCreate(BaseModel):
    """创建活动请求"""
    title: str = Field(..., min_length=1, max_length=255)
    start_time: datetime
    end_time: Optional[datetime] = None
    location: Optional[str] = Field(None, max_length=500)
    description: Optional[str] = None
    source_type: Optional[str] = Field("manual", max_length=50)
    is_followed: bool = True


class EventUpdate(BaseModel):
    """更新活动请求"""
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    location: Optional[str] = Field(None, max_length=500)
    description: Optional[str] = None
    is_followed: Optional[bool] = None


class EventResponse(BaseModel):
    """活动响应"""
    id: int
    title: str
    start_time: datetime
    end_time: Optional[datetime] = None
    location: Optional[str] = None
    description: Optional[str] = None
    source_type: Optional[str] = None
    is_followed: bool = False
    created_at: datetime


class EventListResponse(BaseModel):
    """活动列表响应"""
    events: List[EventResponse]


# ============ 通用 ============

class ErrorResponse(BaseModel):
    """错误响应"""
    detail: str
