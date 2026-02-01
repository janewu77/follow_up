"""
Event Parsing Routes - /api/parse

Uses LangChain + OpenAI for intelligent event parsing
Supports single or multiple image batch parsing
"""
import uuid
import os
import time
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status

from schemas import ParseRequest, ParseResponse, ParsedEvent
from auth import get_current_user
from models import User
from logging_config import get_logger
from services.image_utils import generate_thumbnail

logger = get_logger(__name__)

# Try importing LLM service, use fallback if failed
try:
    from services.llm_service import parse_text_with_llm, parse_image_with_llm
    from config import settings
    # Check API key (check both settings and environment variables)
    LLM_AVAILABLE = bool(settings.OPENAI_API_KEY or os.getenv("OPENAI_API_KEY"))
    if LLM_AVAILABLE:
        logger.info("LLM service available (OpenAI API key configured)")
    else:
        logger.warning("LLM service unavailable (OpenAI API key not configured)")
except (ImportError, ValueError) as e:
    LLM_AVAILABLE = False
    logger.warning(f"LLM service unavailable: {e}")

router = APIRouter(tags=["Event Parsing"])


def parse_text_fallback(text: str, additional_note: str = None) -> list[ParsedEvent]:
    """
    Parse text content (Fallback - simple keyword matching)
    Used when LLM is unavailable
    
    Note: This fallback uses Chinese keywords for matching.
    For English text, this will provide basic parsing only.
    """
    import re
    from datetime import datetime, timedelta
    
    now = datetime.now()
    
    # Simple time keyword recognition (Chinese keywords)
    if "明天" in text or "tomorrow" in text.lower():
        event_date = now + timedelta(days=1)
    elif "后天" in text or "day after tomorrow" in text.lower():
        event_date = now + timedelta(days=2)
    elif "下周" in text or "next week" in text.lower():
        event_date = now + timedelta(days=7)
    else:
        event_date = now + timedelta(days=3)
    
    # Simple time point recognition (Chinese keywords)
    hour = 14
    if "上午" in text or "早上" in text or "morning" in text.lower():
        hour = 10
    elif "下午" in text or "afternoon" in text.lower():
        hour = 14
    elif "晚上" in text or "evening" in text.lower() or "night" in text.lower():
        hour = 19
    
    # Try to extract specific time
    time_match = re.search(r'(\d{1,2})[点时]|(\d{1,2}):(\d{2})|(\d{1,2})\s*(am|pm)', text.lower())
    if time_match:
        if time_match.group(1):  # Chinese format: "3点"
            hour = int(time_match.group(1))
            if hour < 12 and ("下午" in text or "晚上" in text or "pm" in text.lower()):
                hour += 12
        elif time_match.group(2):  # Format: "3:00"
            hour = int(time_match.group(2))
            minute = int(time_match.group(3))
        elif time_match.group(4):  # Format: "3 pm"
            hour = int(time_match.group(4))
            if time_match.group(5) == "pm" and hour < 12:
                hour += 12
    
    start_time = event_date.replace(hour=hour, minute=0, second=0, microsecond=0)
    
    # Extract title
    title = "Meeting"
    keywords = {
        "开会": "Meeting", "meeting": "Meeting",
        "聚餐": "Dinner", "dinner": "Dinner", "吃饭": "Dinner",
        "音乐会": "Concert", "concert": "Concert",
        "演出": "Performance", "performance": "Performance",
        "面试": "Interview", "interview": "Interview",
        "约会": "Appointment", "appointment": "Appointment"
    }
    for kw, t in keywords.items():
        if kw in text.lower():
            title = t
            break
    else:
        title = text[:10].strip() if len(text) > 10 else text.strip()
    
    return [ParsedEvent(
        id=None,
        title=title,
        start_time=start_time,
        end_time=None,
        location=additional_note,
        description=text,
        source_type="text",
        is_followed=False,
    )]


def parse_image_fallback(image_base64: str, additional_note: str = None) -> list[ParsedEvent]:
    """
    Parse image content (Fallback)
    Returns empty list when LLM is unavailable, let caller handle it
    """
    logger.warning("Image parsing fallback called - LLM unavailable, cannot parse image")
    # No longer return mock data, return empty list
    return []


def is_llm_available() -> bool:
    """Dynamically check if LLM is available"""
    try:
        from config import settings
        return bool(settings.OPENAI_API_KEY or os.getenv("OPENAI_API_KEY"))
    except Exception:
        return False


class TextParseResult:
    """Text parsing result"""
    def __init__(self, events: list, needs_clarification: bool = False, clarification_question: str = None):
        self.events = events
        self.needs_clarification = needs_clarification
        self.clarification_question = clarification_question


def parse_text(text: str, additional_note: str = None) -> TextParseResult:
    """
    Parse text content
    Prioritizes LLM, falls back to simple keyword parsing if LLM unavailable
    Returns event list and possible clarification questions
    """
    llm_available = is_llm_available()
    logger.debug(f"Parsing text (length={len(text)}, LLM_AVAILABLE={llm_available})")
    start_time = time.time()
    
    if llm_available:
        try:
            result = parse_text_with_llm(text, additional_note)
            elapsed = time.time() - start_time
            logger.info(f"LLM parsed {len(result.events)} event(s) from text in {elapsed:.2f}s")
            return TextParseResult(
                events=result.events,
                needs_clarification=result.needs_clarification,
                clarification_question=result.clarification_question,
            )
        except Exception as e:
            logger.error(f"LLM text parsing failed: {e}", exc_info=True)
    
    # For text parsing, use simple keyword matching as fallback
    # This is not mock data, but actual parsing based on user input
    logger.debug("Using keyword-based text parser (fallback)")
    events = parse_text_fallback(text, additional_note)
    if events:
        logger.info(f"Keyword parser extracted {len(events)} event(s) from text")
    return TextParseResult(events=events, needs_clarification=False, clarification_question=None)


class ImageParseResult:
    """Image parsing result"""
    def __init__(self, events: list, needs_clarification: bool = False, clarification_question: str = None):
        self.events = events
        self.needs_clarification = needs_clarification
        self.clarification_question = clarification_question


def parse_image(image_base64: str, additional_note: str = None) -> ImageParseResult:
    """
    Parse single image content
    Uses LLM Vision to parse event information from image
    Also generates thumbnail attached to each event
    Returns event list and possible clarification questions
    """
    # Generate thumbnail
    thumbnail = generate_thumbnail(image_base64)
    if thumbnail:
        logger.debug(f"Generated thumbnail for image, size: {len(thumbnail)} chars")
    
    llm_available = is_llm_available()
    logger.debug(f"Parsing image (LLM_AVAILABLE={llm_available})")
    
    if not llm_available:
        logger.error("Cannot parse image: LLM service unavailable (OPENAI_API_KEY not configured)")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Image parsing service is temporarily unavailable. Please contact administrator to configure OpenAI API Key",
        )
    
    # Parse image
    try:
        result = parse_image_with_llm(image_base64, additional_note)
        logger.info(f"LLM parsed {len(result.events)} event(s) from image")
        
        # Attach thumbnail to each event
        for event in result.events:
            event.source_thumbnail = thumbnail
        
        return ImageParseResult(
            events=result.events,
            needs_clarification=result.needs_clarification,
            clarification_question=result.clarification_question,
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"LLM image parsing failed: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Image parsing failed: {str(e)}",
        )


def parse_images(images_base64: List[str], additional_note: str = None) -> list[ParsedEvent]:
    """
    Batch parse multiple image contents
    Uses LLM Vision for batch processing, falls back to individual processing on failure
    Generates thumbnail for each image and attaches to corresponding events
    """
    llm_available = is_llm_available()
    logger.debug(f"Parsing {len(images_base64)} images (LLM_AVAILABLE={llm_available})")
    start_time = time.time()
    
    if not llm_available:
        logger.error("Cannot parse images: LLM service unavailable (OPENAI_API_KEY not configured)")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Image parsing service is temporarily unavailable. Please contact administrator to configure OpenAI API Key",
        )
    
    all_events = []
    
    try:
        from services.llm_service import parse_images_with_llm
        # Try batch processing
        events = parse_images_with_llm(images_base64, additional_note)
        if events:
            elapsed = time.time() - start_time
            logger.info(f"LLM batch parsed {len(events)} event(s) from {len(images_base64)} image(s) in {elapsed:.2f}s")
            
            # Generate and attach thumbnail for each event (using first image's thumbnail)
            if images_base64:
                thumbnail = generate_thumbnail(images_base64[0])
                for event in events:
                    event.source_thumbnail = thumbnail
            
            return events
        else:
            logger.warning("LLM batch returned no events, trying individual parsing")
    except HTTPException:
        raise
    except Exception as e:
        logger.warning(f"Batch parsing failed, falling back to individual parsing: {e}")
    
    # Fallback: Process each image individually
    logger.debug("Using individual image parsing (fallback)")
    for idx, image_base64 in enumerate(images_base64):
        try:
            events = parse_image(image_base64, additional_note)
            all_events.extend(events)
            logger.debug(f"Parsed image {idx+1}/{len(images_base64)}: {len(events)} event(s)")
        except Exception as e:
            logger.warning(f"Failed to parse image {idx+1}: {e}")
            continue
    
    elapsed = time.time() - start_time
    logger.info(f"Parsed {len(all_events)} total event(s) from {len(images_base64)} image(s) in {elapsed:.2f}s")
    return all_events


@router.post("/parse", response_model=ParseResponse)
async def parse_event(
    request: ParseRequest,
    current_user: User = Depends(get_current_user)
):
    """
    Parse event information
    
    Supports two input types: text and image:
    - text: Extract events from text description
    - image: Recognize events from images (posters, etc.)
    
    When information is incomplete, returns needs_clarification=true and clarification question.
    Frontend can put user's answer in additional_note and call the parse endpoint again.
    
    Requires authentication: Authorization: Bearer <token>
    """
    parse_id = str(uuid.uuid4())
    logger.info(
        f"Parse request from user {current_user.username}: "
        f"type={request.input_type}, parse_id={parse_id}"
    )
    
    # Initialize result variables
    events = []
    needs_clarification = False
    clarification_question = None
    
    if request.input_type == "text":
        if not request.text_content:
            logger.warning(f"Parse failed: text_content is required")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="text_content is required for text input type",
            )
        result = parse_text(request.text_content, request.additional_note)
        events = result.events
        needs_clarification = result.needs_clarification
        clarification_question = result.clarification_question
    
    elif request.input_type == "image":
        # Support single or multiple images
        images_to_parse = []
        
        # Prefer images_base64 (multiple images)
        if request.images_base64:
            images_to_parse = request.images_base64
        # Backward compatibility: support single image image_base64
        elif request.image_base64:
            images_to_parse = [request.image_base64]
        else:
            logger.warning(f"Parse failed: image_base64 or images_base64 is required")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="image_base64 or images_base64 is required for image input type",
            )
        
        # Process multiple images
        if len(images_to_parse) == 1:
            # Single image: use existing logic (includes thumbnail generation)
            result = parse_image(images_to_parse[0], request.additional_note)
            events = result.events
            needs_clarification = result.needs_clarification
            clarification_question = result.clarification_question
        else:
            # Multiple images: batch processing (clarification not supported yet)
            events = parse_images(images_to_parse, request.additional_note)
    
    else:
        logger.warning(f"Parse failed: invalid input_type={request.input_type}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="input_type must be 'text' or 'image'",
        )
    
    logger.info(
        f"Parse completed: parse_id={parse_id}, "
        f"user={current_user.username}, "
        f"events_count={len(events)}, "
        f"needs_clarification={needs_clarification}"
    )
    
    return ParseResponse(
        events=events,
        parse_id=parse_id,
        needs_clarification=needs_clarification,
        clarification_question=clarification_question,
    )
