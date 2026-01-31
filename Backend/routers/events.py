"""
活动路由 - /api/events/*

CRUD 操作 + ICS 文件生成
使用固定 Token 认证
从数据库查询和操作
"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.responses import Response
from sqlalchemy.orm import Session
from icalendar import Calendar, Event as ICalEvent

from schemas import (
    EventCreate,
    EventUpdate,
    EventResponse,
    EventListResponse,
)
from auth import get_current_user
from database import get_db
from models import User, Event
from logging_config import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/events", tags=["活动管理"])


def event_to_response(event: Event) -> EventResponse:
    """将数据库模型转换为响应模型"""
    return EventResponse(
        id=event.id,
        title=event.title,
        start_time=event.start_time,
        end_time=event.end_time,
        location=event.location,
        description=event.description,
        source_type=event.source_type,
        is_followed=event.is_followed,
        created_at=event.created_at,
    )


@router.get("", response_model=EventListResponse)
async def list_events(
    followed_only: bool = Query(False, description="仅返回已 Follow 的活动"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    获取用户的活动列表

    需要认证：Authorization: Bearer <token>
    """
    logger.info(f"Listing events for user {current_user.username} (followed_only={followed_only})")
    
    query = db.query(Event).filter(Event.user_id == current_user.id)

    if followed_only:
        query = query.filter(Event.is_followed == True)  # noqa: E712

    events = query.order_by(Event.start_time).all()
    logger.info(f"Found {len(events)} event(s) for user {current_user.username}")

    return EventListResponse(
        events=[event_to_response(e) for e in events]
    )


@router.post("", response_model=EventResponse, status_code=status.HTTP_201_CREATED)
async def create_event(
    request: EventCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    创建新活动

    需要认证：Authorization: Bearer <token>
    """
    event = Event(
        user_id=current_user.id,
        title=request.title,
        start_time=request.start_time,
        end_time=request.end_time,
        location=request.location,
        description=request.description,
        source_type=request.source_type or "manual",
        is_followed=request.is_followed,
    )

    db.add(event)
    db.commit()
    db.refresh(event)

    return event_to_response(event)


@router.get("/{event_id}", response_model=EventResponse)
async def get_event(
    event_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    获取单个活动详情

    需要认证：Authorization: Bearer <token>
    """
    logger.debug(f"Getting event {event_id} for user {current_user.username}")
    
    event = db.query(Event).filter(
        Event.id == event_id,
        Event.user_id == current_user.id,
    ).first()

    if event is None:
        logger.warning(f"Event {event_id} not found for user {current_user.username}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )

    logger.debug(f"Event {event_id} retrieved: {event.title}")
    return event_to_response(event)


@router.put("/{event_id}", response_model=EventResponse)
async def update_event_endpoint(
    event_id: int,
    request: EventUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    更新活动

    需要认证：Authorization: Bearer <token>
    """
    event = db.query(Event).filter(
        Event.id == event_id,
        Event.user_id == current_user.id,
    ).first()

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )

    # 更新字段
    if request.title is not None:
        event.title = request.title
    if request.start_time is not None:
        event.start_time = request.start_time
    if request.end_time is not None:
        event.end_time = request.end_time
    if request.location is not None:
        event.location = request.location
    if request.description is not None:
        event.description = request.description
    if request.is_followed is not None:
        event.is_followed = request.is_followed

    db.commit()
    db.refresh(event)

    return event_to_response(event)


@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_event_endpoint(
    event_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    删除活动

    需要认证：Authorization: Bearer <token>
    """
    logger.info(f"Deleting event {event_id} for user {current_user.username}")
    
    event = db.query(Event).filter(
        Event.id == event_id,
        Event.user_id == current_user.id,
    ).first()

    if event is None:
        logger.warning(f"Event {event_id} not found for user {current_user.username}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )

    logger.info(f"Deleting event {event_id}: {event.title}")
    db.delete(event)
    db.commit()
    logger.info(f"Event {event_id} deleted successfully")

    return None


@router.get("/{event_id}/ics")
async def download_ics(
    event_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    下载活动的 ICS 文件

    需要认证：Authorization: Bearer <token>
    """
    event = db.query(Event).filter(
        Event.id == event_id,
        Event.user_id == current_user.id,
    ).first()

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )

    cal = Calendar()
    cal.add("prodid", "-//FollowUP//followup.app//")
    cal.add("version", "2.0")
    cal.add("calscale", "GREGORIAN")
    cal.add("method", "PUBLISH")

    ical_event = ICalEvent()
    ical_event.add("summary", event.title)
    ical_event.add("dtstart", event.start_time)

    if event.end_time:
        ical_event.add("dtend", event.end_time)

    if event.location:
        ical_event.add("location", event.location)

    if event.description:
        ical_event.add("description", event.description)

    ical_event.add("dtstamp", datetime.utcnow())
    ical_event.add("uid", f"event-{event_id}@followup.app")

    cal.add_component(ical_event)

    ics_content = cal.to_ical()

    safe_title = "".join(c for c in event.title if c.isalnum() or c in " -_").strip()
    filename = f"{safe_title or 'event'}.ics"

    return Response(
        content=ics_content,
        media_type="text/calendar",
        headers={
            "Content-Disposition": f'attachment; filename="{filename}"',
        },
    )
