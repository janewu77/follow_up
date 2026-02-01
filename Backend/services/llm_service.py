"""
LLM Service - Event parsing using LangChain + OpenAI

Responsibilities:
- Initialize and manage LLM instances
- Call LLM API to parse text and images
- Convert LLM responses to business models
- Ask user when information is incomplete
- Complete incomplete information via web search
"""
import os
import time
import asyncio
from typing import List, Optional, NamedTuple
from datetime import datetime

from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import JsonOutputParser
from langchain_core.messages import HumanMessage

from schemas import ParsedEvent
from config import settings
from logging_config import get_logger
from services.prompts import (
    TEXT_PARSE_PROMPT,
    IMAGE_PARSE_SYSTEM_PROMPT,
    EventExtractionList,
)

logger = get_logger(__name__)


class ParseResult(NamedTuple):
    """Parse result containing event list and possible clarification questions"""
    events: List[ParsedEvent]
    needs_clarification: bool = False
    clarification_question: Optional[str] = None
    # Additional fields for incomplete events that may need search
    search_keywords: Optional[List[str]] = None
    partial_events: Optional[List[dict]] = None  # Events with title but no time


# ============================================================================
# LLM Initialization
# ============================================================================

def get_llm() -> ChatOpenAI:
    """
    Get OpenAI LLM instance

    Returns:
        Configured ChatOpenAI instance

    Raises:
        ValueError: If API Key is not configured
    """
    api_key = settings.OPENAI_API_KEY or os.getenv("OPENAI_API_KEY")
    if not api_key:
        logger.error("OPENAI_API_KEY is not configured")
        raise ValueError("OPENAI_API_KEY is not configured. Set it in .env file or environment variable.")

    logger.debug(f"Initializing LLM: model={settings.OPENAI_MODEL}, temperature=0.3")
    return ChatOpenAI(
        model=settings.OPENAI_MODEL,
        temperature=0.3,  # Lower temperature for more consistent results
        api_key=api_key,
    )


# ============================================================================
# Text Parsing
# ============================================================================

def parse_text_with_llm(
    text: str,
    additional_note: Optional[str] = None,
) -> ParseResult:
    """
    Parse event information from text using LangChain + OpenAI

    Args:
        text: Input text
        additional_note: Additional note (may contain user's answer to clarification question)

    Returns:
        ParseResult: Contains event list and possible clarification questions
    """
    start_time = time.time()
    logger.debug(f"Starting LLM text parsing (text_length={len(text)})")

    try:
        llm = get_llm()
        parser = JsonOutputParser(pydantic_object=EventExtractionList)

        # Build prompt
        current_time = datetime.now().isoformat()

        logger.debug(f"Calling LLM API (model={settings.OPENAI_MODEL})")

        # Call LLM
        chain = TEXT_PARSE_PROMPT | llm | parser
        result = chain.invoke({
            "current_time": current_time,
            "text": text,
            "additional_note": additional_note or "",
        })

        elapsed = time.time() - start_time
        logger.info(f"LLM API call completed in {elapsed:.2f}s")

        # Check if clarification is needed
        needs_clarification = result.get("needs_clarification", False)
        clarification_question = result.get("clarification_question")

        if needs_clarification:
            logger.info(f"LLM requests clarification: {clarification_question}")
        
        # NEW: If incomplete and web search enabled, try to complete
        if needs_clarification and settings.ENABLE_WEB_SEARCH:
            search_keywords = result.get("search_keywords", [])
            if search_keywords:
                logger.info(f"Attempting web search with keywords: {search_keywords}")
                
                try:
                    from services.search_service import (
                        search_event_info,
                        extract_event_details_from_search,
                        merge_event_info,
                        is_event_complete,
                    )
                    
                    # Extract location hint from first event if available
                    location_hint = None
                    if result.get("events") and len(result["events"]) > 0:
                        location_hint = result["events"][0].get("location")
                    
                    # Search web (run async in sync context)
                    search_results = asyncio.run(search_event_info(
                        query=" ".join(search_keywords),
                        location_hint=location_hint or result.get("location_hint"),
                        date_hint=result.get("date_hint"),
                    ))
                    
                    if search_results:
                        # Extract details from search results
                        first_event = result.get("events", [{}])[0] if result.get("events") else {}
                        completed_info = asyncio.run(extract_event_details_from_search(
                            search_results,
                            partial_event={
                                "title": first_event.get("title", ""),
                                "date_hint": result.get("date_hint"),
                                "location_hint": first_event.get("location", ""),
                            },
                        ))
                        
                        if completed_info:
                            # Merge with original result
                            result = merge_event_info(result, completed_info)
                            
                            # Re-check if still needs clarification
                            if is_event_complete(result):
                                needs_clarification = False
                                clarification_question = None
                                logger.info("Web search successfully completed event info")
                except Exception as e:
                    logger.warning(f"Web search failed, falling back to clarification: {e}")
        
        # Convert to ParsedEvent
        events = _convert_to_parsed_events(result, source_type="text")

        logger.info(f"LLM text parsing completed: {len(events)} event(s) extracted, needs_clarification={needs_clarification}")
        return ParseResult(
            events=events,
            needs_clarification=needs_clarification,
            clarification_question=clarification_question,
        )
    
    except Exception as e:
        elapsed = time.time() - start_time
        logger.error(f"LLM text parsing failed after {elapsed:.2f}s: {e}", exc_info=True)
        return ParseResult(events=[], needs_clarification=False, clarification_question=None)


# ============================================================================
# Image Parsing
# ============================================================================

def parse_image_with_llm(
    image_base64: str,
    additional_note: Optional[str] = None,
) -> ParseResult:
    """
    Parse event information from image using LangChain + OpenAI Vision

    Args:
        image_base64: Base64 encoded image
        additional_note: Additional note (may contain user's answer to clarification question)

    Returns:
        ParseResult: Contains event list and possible clarification questions
    """
    start_time = time.time()
    logger.debug(f"Starting LLM image parsing (base64_length={len(image_base64)})")

    try:
        llm = get_llm()
        parser = JsonOutputParser(pydantic_object=EventExtractionList)

        # Build system message
        current_time = datetime.now().isoformat()
        system_message = IMAGE_PARSE_SYSTEM_PROMPT.format(current_time=current_time)

        # Build user message (multimodal)
        user_content = [
            {
                "type": "image_url",
                "image_url": {
                    "url": f"data:image/jpeg;base64,{image_base64}",
                },
            },
            {
                "type": "text",
                "text": f"Additional note: {additional_note or 'None'}",
            },
        ]

        # Create messages
        messages = [
            ("system", system_message),
            HumanMessage(content=user_content),
        ]

        logger.debug(f"Calling LLM Vision API (model={settings.OPENAI_MODEL})")

        # Call LLM (supports Vision)
        response = llm.invoke(messages)

        elapsed = time.time() - start_time
        logger.info(f"LLM Vision API call completed in {elapsed:.2f}s")

        # Parse JSON response
        result = parser.parse(response.content)

        # Check if we have events and if they need time completion
        needs_clarification = result.get("needs_clarification", False)
        clarification_question = result.get("clarification_question")
        search_keywords = result.get("search_keywords", [])
        
        # Check if any event is missing start_time
        events_raw = result.get("events", [])
        has_event_without_time = any(
            e.get("title") and not e.get("start_time") 
            for e in events_raw
        )
        
        # Auto-generate search keywords from event titles if not provided
        if not search_keywords and has_event_without_time:
            for e in events_raw:
                if e.get("title"):
                    search_keywords.append(e["title"])
            if result.get("date_hint"):
                search_keywords.append(result["date_hint"])
            logger.info(f"[LLM-IMAGE] Auto-generated search keywords from event title: {search_keywords}")
        
        # Trigger web search if: we have search_keywords AND (missing time OR needs clarification)
        should_search = settings.ENABLE_WEB_SEARCH and search_keywords and (has_event_without_time or needs_clarification)
        
        if should_search:
            logger.info(f"[LLM-IMAGE] Event info incomplete (missing_time={has_event_without_time}), attempting web search with keywords: {search_keywords}")
            
            try:
                from services.search_service import (
                    search_event_info_sync,
                    extract_event_details_from_search_sync,
                    merge_event_info,
                )
                
                # Extract location hint from first event if available
                location_hint = None
                if events_raw:
                    location_hint = events_raw[0].get("location")
                
                logger.info(f"[LLM-IMAGE] Calling search_event_info_sync...")
                search_results = search_event_info_sync(
                    query=" ".join(search_keywords),
                    location_hint=location_hint,
                    date_hint=result.get("date_hint"),
                )
                
                logger.info(f"[LLM-IMAGE] Search returned {len(search_results) if search_results else 0} results")
                
                if search_results:
                    logger.info(f"[LLM-IMAGE] Extracting event details from search results...")
                    first_event = events_raw[0] if events_raw else {}
                    completed_info = extract_event_details_from_search_sync(
                        search_results,
                        partial_event={
                            "title": first_event.get("title", ""),
                            "date_hint": result.get("date_hint"),
                            "location_hint": first_event.get("location", ""),
                        },
                    )
                    
                    if completed_info:
                        logger.info(f"[LLM-IMAGE] Search found: {completed_info.event_name}, time={completed_info.start_time}")
                        # Merge with original result
                        result = merge_event_info(result, completed_info)
                        
                        # Check if we now have complete info
                        updated_events = result.get("events", [])
                        if updated_events and updated_events[0].get("start_time"):
                            needs_clarification = False
                            clarification_question = None
                            logger.info("[LLM-IMAGE] Web search successfully completed event info")
                        else:
                            logger.info("[LLM-IMAGE] Web search provided partial information")
                    else:
                        logger.info("[LLM-IMAGE] Could not extract event details from search results")
                else:
                    logger.info("[LLM-IMAGE] No search results returned")
            except Exception as e:
                logger.warning(f"[LLM-IMAGE] Web search failed: {e}", exc_info=True)
        elif has_event_without_time and not settings.ENABLE_WEB_SEARCH:
            logger.info("[LLM-IMAGE] Event info incomplete, but web search is disabled")
        
        # Convert to ParsedEvent (only events with valid start_time)
        events = _convert_to_parsed_events(result, source_type="image")
        
        # Collect partial events (have title but no start_time) for potential search in graph.py
        partial_events = [
            e for e in result.get("events", [])
            if e.get("title") and not e.get("start_time")
        ]

        logger.info(f"LLM image parsing completed: {len(events)} complete event(s), {len(partial_events)} partial event(s)")
        return ParseResult(
            events=events,
            needs_clarification=needs_clarification,
            clarification_question=clarification_question,
            search_keywords=search_keywords if search_keywords else None,
            partial_events=partial_events if partial_events else None,
        )
    
    except Exception as e:
        elapsed = time.time() - start_time
        logger.error(f"LLM image parsing failed after {elapsed:.2f}s: {e}", exc_info=True)
        return ParseResult(events=[], needs_clarification=False, clarification_question=None, search_keywords=None, partial_events=None)


def parse_images_with_llm(
    images_base64: List[str],
    additional_note: Optional[str] = None,
) -> List[ParsedEvent]:
    """
    Batch parse event information from multiple images using LangChain + OpenAI Vision

    Args:
        images_base64: List of base64 encoded images
        additional_note: Additional note

    Returns:
        List of parsed events (merged from all images)
    """
    if not images_base64:
        return []

    start_time = time.time()
    logger.debug(f"Starting LLM batch image parsing ({len(images_base64)} images)")

    all_events = []

    try:
        llm = get_llm()
        parser = JsonOutputParser(pydantic_object=EventExtractionList)
        current_time = datetime.now().isoformat()
        system_message = IMAGE_PARSE_SYSTEM_PROMPT.format(current_time=current_time)

        # Build multimodal messages for each image
        user_content = []

        # Add all images
        for img_base64 in images_base64:
            user_content.append({
                "type": "image_url",
                "image_url": {
                    "url": f"data:image/jpeg;base64,{img_base64}",
                },
            })

        # Add text instruction
        note_text = f"Please analyze the above {len(images_base64)} image(s) and extract all event information."
        if additional_note:
            note_text += f"\nAdditional note: {additional_note}"
        user_content.append({
            "type": "text",
            "text": note_text,
        })

        # Create messages
        messages = [
            ("system", system_message),
            HumanMessage(content=user_content),
        ]

        logger.debug(f"Calling LLM Vision API with {len(images_base64)} images (model={settings.OPENAI_MODEL})")

        # Call LLM (supports multiple images Vision)
        response = llm.invoke(messages)

        elapsed = time.time() - start_time
        logger.info(f"LLM batch Vision API call completed in {elapsed:.2f}s")

        # Parse JSON response
        result = parser.parse(response.content)

        # Convert to ParsedEvent
        events = _convert_to_parsed_events(result, source_type="image")

        logger.info(f"LLM batch image parsing completed: {len(events)} event(s) extracted from {len(images_base64)} image(s)")
        return events

    except Exception as e:
        elapsed = time.time() - start_time
        logger.error(f"LLM batch image parsing failed after {elapsed:.2f}s: {e}", exc_info=True)
        # If batch processing fails, try individual processing
        logger.info("Falling back to individual image parsing...")
        for idx, img_base64 in enumerate(images_base64):
            try:
                events = parse_image_with_llm(img_base64, additional_note)
                all_events.extend(events)
                logger.debug(f"Parsed image {idx+1}/{len(images_base64)}: {len(events)} event(s)")
            except Exception as img_error:
                logger.warning(f"Failed to parse image {idx+1}: {img_error}")
                continue

        return all_events


# ============================================================================
# Helper Functions
# ============================================================================

def _convert_to_parsed_events(
    result: dict,
    source_type: str,
) -> List[ParsedEvent]:
    """
    Convert LLM response to ParsedEvent list

    Args:
        result: LLM parsing result
        source_type: Source type (text/image)

    Returns:
        List of ParsedEvent
    """
    events = []
    for idx, event_data in enumerate(result.get("events", [])):
        try:
            # Skip events without start_time (will be handled by partial_events)
            start_time_str = event_data.get("start_time")
            if not start_time_str:
                logger.debug(f"Event {idx+1} '{event_data.get('title')}' has no start_time, skipping")
                continue
            
            events.append(ParsedEvent(
                id=None,
                title=event_data["title"],
                start_time=datetime.fromisoformat(start_time_str),
                end_time=datetime.fromisoformat(event_data["end_time"]) if event_data.get("end_time") else None,
                location=event_data.get("location"),
                description=event_data.get("description"),
                source_type=source_type,
                is_followed=False,
            ))
            logger.debug(f"Parsed event {idx+1}: {event_data.get('title')} @ {start_time_str}")
        except (KeyError, ValueError, TypeError) as e:
            # Skip events with invalid format
            logger.warning(f"Skipping invalid event data at index {idx}: {e}")
            continue

    return events
