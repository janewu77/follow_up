"""
活动路由 - /api/events/*

CRUD 操作 + ICS 文件生成

TODO: 实现真实的数据库 CRUD
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query

from schemas import (
    EventCreate,
    EventUpdate,
    EventResponse,
    EventListResponse,
)
from auth import get_current_user

router = APIRouter(prefix="/events", tags=["活动管理"])


@router.get("", response_model=EventListResponse)
async def list_events(
    followed_only: bool = Query(False, description="仅返回已 Follow 的活动"),
    current_user: dict = Depends(get_current_user),
):
    """
    获取用户的活动列表
    
    - followed_only: 设为 true 时只返回已 Follow 的活动
    
    TODO: 实现数据库查询
    """
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="API not implemented yet. Use /mock/events for development.",
    )


@router.post("", response_model=EventResponse, status_code=status.HTTP_201_CREATED)
async def create_event(
    request: EventCreate,
    current_user: dict = Depends(get_current_user),
):
    """
    创建新活动
    
    TODO: 实现数据库写入
    """
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="API not implemented yet. Use /mock/events for development.",
    )


@router.get("/{event_id}", response_model=EventResponse)
async def get_event(
    event_id: int,
    current_user: dict = Depends(get_current_user),
):
    """
    获取单个活动详情
    
    TODO: 实现数据库查询
    """
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="API not implemented yet. Use /mock/events/{id} for development.",
    )


@router.put("/{event_id}", response_model=EventResponse)
async def update_event_endpoint(
    event_id: int,
    request: EventUpdate,
    current_user: dict = Depends(get_current_user),
):
    """
    更新活动
    
    TODO: 实现数据库更新
    """
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="API not implemented yet. Use /mock/events/{id} for development.",
    )


@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_event_endpoint(
    event_id: int,
    current_user: dict = Depends(get_current_user),
):
    """
    删除活动
    
    TODO: 实现数据库删除
    """
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="API not implemented yet. Use /mock/events/{id} for development.",
    )


@router.get("/{event_id}/ics")
async def download_ics(
    event_id: int,
    current_user: dict = Depends(get_current_user),
):
    """
    下载活动的 ICS 文件
    
    可直接导入到日历应用
    
    TODO: 实现数据库查询 + ICS 生成
    """
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="API not implemented yet. Use /mock/events/{id}/ics for development.",
    )
