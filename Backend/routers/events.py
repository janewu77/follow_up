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
        source_thumbnail=event.source_thumbnail,
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


@router.get("/search", response_model=EventListResponse)
async def search_events(
    q: str = Query(..., min_length=1, description="搜索查询（自然语言）"),
    limit: int = Query(10, ge=1, le=50, description="返回结果数量"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    搜索活动（支持向量语义搜索）
    
    在 PostgreSQL 环境下使用向量相似度搜索，
    在 SQLite 环境下降级为 LIKE 文本搜索。

    需要认证：Authorization: Bearer <token>
    """
    from services.embedding_service import is_postgres, generate_embedding
    from sqlalchemy import text, or_
    
    logger.info(f"Searching events for user {current_user.username}: '{q}' (limit={limit})")
    
    events = []
    
    if is_postgres():
        # PostgreSQL: 使用向量相似度搜索
        query_embedding = generate_embedding(q)
        
        if query_embedding:
            # 向量搜索
            embedding_str = "[" + ",".join(map(str, query_embedding)) + "]"
            
            result = db.execute(text(f"""
                SELECT 
                    id, title, start_time, end_time, location, description,
                    source_type, source_thumbnail, is_followed, created_at,
                    1 - (embedding <=> :embedding::vector) as similarity
                FROM events
                WHERE user_id = :user_id
                    AND embedding IS NOT NULL
                ORDER BY embedding <=> :embedding::vector
                LIMIT :limit
            """), {
                "embedding": embedding_str,
                "user_id": current_user.id,
                "limit": limit,
            })
            
            rows = result.fetchall()
            for row in rows:
                events.append(Event(
                    id=row.id,
                    title=row.title,
                    start_time=row.start_time,
                    end_time=row.end_time,
                    location=row.location,
                    description=row.description,
                    source_type=row.source_type,
                    source_thumbnail=row.source_thumbnail,
                    is_followed=row.is_followed,
                    created_at=row.created_at,
                    user_id=current_user.id,
                ))
            
            logger.info(f"Vector search found {len(events)} event(s)")
        else:
            # 无法生成 embedding，降级到文本搜索
            logger.warning("Failed to generate embedding, falling back to text search")
    
    # 如果向量搜索没有结果或不支持，使用文本搜索
    if not events:
        # SQLite 或降级：使用 LIKE 文本搜索
        search_pattern = f"%{q}%"
        events = db.query(Event).filter(
            Event.user_id == current_user.id,
            or_(
                Event.title.ilike(search_pattern),
                Event.description.ilike(search_pattern),
                Event.location.ilike(search_pattern),
            )
        ).order_by(Event.start_time).limit(limit).all()
        
        logger.info(f"Text search found {len(events)} event(s)")
    
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
    from services.embedding_service import generate_event_embedding, is_postgres
    
    event = Event(
        user_id=current_user.id,
        title=request.title,
        start_time=request.start_time,
        end_time=request.end_time,
        location=request.location,
        description=request.description,
        source_type=request.source_type or "manual",
        source_thumbnail=request.source_thumbnail,
        is_followed=request.is_followed,
    )

    db.add(event)
    db.commit()
    db.refresh(event)
    
    # 生成 embedding（仅 PostgreSQL）
    if is_postgres():
        try:
            embedding = generate_event_embedding(
                title=request.title,
                description=request.description,
                location=request.location,
            )
            if embedding:
                from sqlalchemy import text
                embedding_str = "[" + ",".join(map(str, embedding)) + "]"
                db.execute(text("""
                    UPDATE events 
                    SET embedding = :embedding::vector 
                    WHERE id = :event_id
                """), {"embedding": embedding_str, "event_id": event.id})
                db.commit()
                logger.debug(f"Generated embedding for event {event.id}")
        except Exception as e:
            logger.warning(f"Failed to generate embedding for event {event.id}: {e}")

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

    # 记录是否有内容字段变更（需要重新生成 embedding）
    content_changed = False
    
    # 更新字段
    if request.title is not None:
        event.title = request.title
        content_changed = True
    if request.start_time is not None:
        event.start_time = request.start_time
    if request.end_time is not None:
        event.end_time = request.end_time
    if request.location is not None:
        event.location = request.location
        content_changed = True
    if request.description is not None:
        event.description = request.description
        content_changed = True
    if request.is_followed is not None:
        event.is_followed = request.is_followed

    db.commit()
    db.refresh(event)
    
    # 如果内容字段变更，重新生成 embedding（仅 PostgreSQL）
    if content_changed:
        from services.embedding_service import generate_event_embedding, is_postgres
        
        if is_postgres():
            try:
                embedding = generate_event_embedding(
                    title=event.title,
                    description=event.description,
                    location=event.location,
                )
                if embedding:
                    from sqlalchemy import text
                    embedding_str = "[" + ",".join(map(str, embedding)) + "]"
                    db.execute(text("""
                        UPDATE events 
                        SET embedding = :embedding::vector 
                        WHERE id = :event_id
                    """), {"embedding": embedding_str, "event_id": event.id})
                    db.commit()
                    logger.debug(f"Updated embedding for event {event.id}")
            except Exception as e:
                logger.warning(f"Failed to update embedding for event {event.id}: {e}")

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

    # 使用 ASCII 安全的文件名，避免 HTTP 头编码问题
    safe_title = "".join(c for c in event.title if c.isascii() and (c.isalnum() or c in " -_")).strip()
    filename = f"{safe_title or 'event'}.ics"
    
    # 对于包含非 ASCII 字符的标题，使用 RFC 5987 编码
    from urllib.parse import quote
    filename_encoded = quote(f"{event.title}.ics", safe="")

    return Response(
        content=ics_content,
        media_type="text/calendar",
        headers={
            "Content-Disposition": f"attachment; filename=\"{filename}\"; filename*=UTF-8''{filename_encoded}",
        },
    )
