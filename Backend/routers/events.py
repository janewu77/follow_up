"""
Event Routes - /api/events/*

CRUD operations + ICS file generation
Uses fixed Token authentication
Queries and operations from database
"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.responses import Response
from sqlalchemy.orm import Session

from schemas import (
    EventCreate,
    EventUpdate,
    EventResponse,
    EventListResponse,
    DuplicateGroup,
    DuplicatesResponse,
    DeleteDuplicatesRequest,
    DeleteDuplicatesResponse,
)
from auth import get_current_user
from database import get_db
from models import User, Event
from logging_config import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/events", tags=["Event Management"])


def event_to_response(event: Event, include_ics: bool = False) -> EventResponse:
    """
    Convert database model to response model
    
    Args:
        event: Event model instance
        include_ics: Whether to include ICS file content
    """
    ics_content = None
    ics_download_url = None
    
    if include_ics:
        from services.ics_service import generate_ics_content
        ics_content = generate_ics_content(event)
        ics_download_url = f"/api/events/{event.id}/ics"
    
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
        recurrence_rule=event.recurrence_rule,
        recurrence_end=event.recurrence_end,
        parent_event_id=event.parent_event_id,
        ics_content=ics_content,
        ics_download_url=ics_download_url,
    )


@router.get("", response_model=EventListResponse)
async def list_events(
    followed_only: bool = Query(False, description="Only return followed events"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Get user's event list

    Requires authentication: Authorization: Bearer <token>
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
    q: str = Query(..., min_length=1, description="Search query (natural language)"),
    limit: int = Query(10, ge=1, le=50, description="Number of results to return"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Search events (using text search)

    Requires authentication: Authorization: Bearer <token>
    """
    from sqlalchemy import or_
    
    logger.info(f"Searching events for user {current_user.username}: '{q}' (limit={limit})")
    
    # Use LIKE text search
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


@router.get("/duplicates", response_model=DuplicatesResponse)
async def find_duplicates(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    similarity_threshold: float = Query(0.8, ge=0.0, le=1.0, description="Title similarity threshold (0-1)"),
    time_window_hours: int = Query(24, ge=1, le=168, description="Time window in hours for considering events as similar"),
):
    """
    Query user's duplicate events
    
    Duplicate definition:
    1. Exact duplicates: Events with the same title and start time
    2. Similar events: Events with similar titles (>= threshold) within time window
    
    Returns grouped duplicate event list, each group contains:
    - key: Duplicate identifier
    - events: All duplicate events in this group
    - keep_id: Suggested event ID to keep (earliest created)
    - delete_ids: List of suggested event IDs to delete
    
    Requires authentication: Authorization: Bearer <token>
    """
    from collections import defaultdict
    from services.recurrence_service import detect_similar_events
    
    logger.info(f"Finding duplicate events for user {current_user.username} (similarity_threshold={similarity_threshold}, time_window={time_window_hours}h)")
    
    # Query all events
    all_events = db.query(Event).filter(
        Event.user_id == current_user.id
    ).order_by(Event.created_at).all()
    
    # Group 1: Exact duplicates (same title + same start_time)
    exact_groups_dict = defaultdict(list)
    for event in all_events:
        key = (event.title, event.start_time)
        exact_groups_dict[key].append(event)
    
    # Group 2: Similar events (similar title + nearby time)
    # Use a set to track already grouped events
    processed_events = set()
    similar_groups = []
    
    for i, event1 in enumerate(all_events):
        if event1.id in processed_events:
            continue
        
        similar_group = [event1]
        processed_events.add(event1.id)
        
        for event2 in all_events[i+1:]:
            if event2.id in processed_events:
                continue
            
            if detect_similar_events(
                event1.title,
                event2.title,
                event1.start_time,
                event2.start_time,
                similarity_threshold,
                time_window_hours,
            ):
                similar_group.append(event2)
                processed_events.add(event2.id)
        
        if len(similar_group) > 1:
            similar_groups.append(similar_group)
    
    # Combine exact duplicates and similar events
    duplicate_groups = []
    total_duplicates = 0
    
    # Process exact duplicates
    for (title, start_time), events in exact_groups_dict.items():
        if len(events) > 1:
            key_str = f"{title} @ {start_time.strftime('%Y-%m-%d %H:%M')}"
            
            sorted_events = sorted(events, key=lambda e: e.created_at)
            keep_event = sorted_events[0]
            delete_events = sorted_events[1:]
            
            duplicate_groups.append(DuplicateGroup(
                key=key_str,
                events=[event_to_response(e) for e in sorted_events],
                keep_id=keep_event.id,
                delete_ids=[e.id for e in delete_events],
            ))
            
            total_duplicates += len(delete_events)
    
    # Process similar events
    for similar_group in similar_groups:
        if len(similar_group) > 1:
            sorted_events = sorted(similar_group, key=lambda e: e.created_at)
            keep_event = sorted_events[0]
            delete_events = sorted_events[1:]
            
            # Create key from first event
            key_str = f"Similar: {keep_event.title} @ {keep_event.start_time.strftime('%Y-%m-%d %H:%M')}"
            
            duplicate_groups.append(DuplicateGroup(
                key=key_str,
                events=[event_to_response(e) for e in sorted_events],
                keep_id=keep_event.id,
                delete_ids=[e.id for e in delete_events],
            ))
            
            total_duplicates += len(delete_events)
    
    logger.info(f"Found {len(duplicate_groups)} duplicate group(s), {total_duplicates} event(s) to delete")
    
    return DuplicatesResponse(
        total_duplicates=total_duplicates,
        groups=duplicate_groups,
    )


@router.delete("/duplicates", response_model=DeleteDuplicatesResponse)
async def delete_duplicates(
    request: DeleteDuplicatesRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Batch delete duplicate events
    
    Pass in a list of event IDs to delete. Only events belonging to the current user will be deleted.
    It's recommended to call GET /api/events/duplicates first to get the duplicate event list,
    then pass delete_ids to this endpoint after confirmation.
    
    Requires authentication: Authorization: Bearer <token>
    """
    logger.info(f"Deleting duplicate events for user {current_user.username}: {request.event_ids}")
    
    # Query events to delete (only delete events belonging to current user)
    events_to_delete = db.query(Event).filter(
        Event.id.in_(request.event_ids),
        Event.user_id == current_user.id,
    ).all()
    
    deleted_ids = []
    for event in events_to_delete:
        logger.debug(f"Deleting duplicate event {event.id}: {event.title}")
        db.delete(event)
        deleted_ids.append(event.id)
    
    db.commit()
    
    logger.info(f"Deleted {len(deleted_ids)} duplicate event(s)")
    
    return DeleteDuplicatesResponse(
        deleted_count=len(deleted_ids),
        deleted_ids=deleted_ids,
    )


@router.post("", response_model=EventResponse, status_code=status.HTTP_201_CREATED)
async def create_event(
    request: EventCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Create new event

    Requires authentication: Authorization: Bearer <token>
    """
    # Check for duplicates
    duplicate = db.query(Event).filter(
        Event.user_id == current_user.id,
        Event.title == request.title,
        Event.start_time == request.start_time,
    ).first()
    
    if duplicate:
        logger.info(f"Duplicate event detected for user {current_user.username}: {request.title} at {request.start_time}")
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"This event already exists: {duplicate.title} ({duplicate.start_time.strftime('%Y-%m-%d %H:%M')}). Would you like me to modify it?",
        )
    
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

    # Return ICS content when creating event
    return event_to_response(event, include_ics=True)


@router.get("/{event_id}", response_model=EventResponse)
async def get_event(
    event_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Get single event details

    Requires authentication: Authorization: Bearer <token>
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
    Update event

    Requires authentication: Authorization: Bearer <token>
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

    # Update fields
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
    if request.recurrence_rule is not None:
        event.recurrence_rule = request.recurrence_rule
    if request.recurrence_end is not None:
        event.recurrence_end = request.recurrence_end

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
    Delete event

    Requires authentication: Authorization: Bearer <token>
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
    Download event ICS file

    Requires authentication: Authorization: Bearer <token>
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

    # Use ICS service to generate content
    from services.ics_service import generate_ics_bytes
    ics_content = generate_ics_bytes(event)

    # Use ASCII-safe filename to avoid HTTP header encoding issues
    safe_title = "".join(c for c in event.title if c.isascii() and (c.isalnum() or c in " -_")).strip()
    filename = f"{safe_title or 'event'}.ics"
    
    # For titles containing non-ASCII characters, use RFC 5987 encoding
    from urllib.parse import quote
    filename_encoded = quote(f"{event.title}.ics", safe="")

    return Response(
        content=ics_content,
        media_type="text/calendar",
        headers={
            "Content-Disposition": f"attachment; filename=\"{filename}\"; filename*=UTF-8''{filename_encoded}",
        },
    )
