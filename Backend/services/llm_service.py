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

        # Check if clarification is needed
        needs_clarification = result.get("needs_clarification", False)
        clarification_question = result.get("clarification_question")
        
        if needs_clarification:
            logger.info(f"LLM requests clarification: {clarification_question}")
        
        # NEW: If incomplete and web search enabled, try to complete
        if needs_clarification and settings.ENABLE_WEB_SEARCH:
            search_keywords = result.get("search_keywords", [])
            if search_keywords:
                logger.info(f"[LLM-IMAGE] Event information incomplete, attempting web search with keywords: {search_keywords}")
                
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
                    
                    logger.info(f"[LLM-IMAGE] Calling search_service.search_event_info...")
                    # Search web (run async in sync context)
                    search_results = asyncio.run(search_event_info(
                        query=" ".join(search_keywords),
                        location_hint=location_hint or result.get("location_hint"),
                        date_hint=result.get("date_hint"),
                    ))
                    
                    logger.info(f"[LLM-IMAGE] Search returned {len(search_results)} results")
                    
                    if search_results:
                        logger.info(f"[LLM-IMAGE] Extracting event details from search results...")
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
                            logger.info(f"[LLM-IMAGE] Merging search results with original event data...")
                            # Merge with original result
                            result = merge_event_info(result, completed_info)
                            
                            # Re-check if still needs clarification
                            if is_event_complete(result):
                                needs_clarification = False
                                clarification_question = None
                                logger.info("[LLM-IMAGE] Web search successfully completed event info - no clarification needed")
                            else:
                                logger.info("[LLM-IMAGE] Web search provided partial information - still needs clarification")
                        else:
                            logger.info("[LLM-IMAGE] Could not extract event details from search results")
                    else:
                        logger.info("[LLM-IMAGE] No search results returned - will ask user for clarification")
                except Exception as e:
                    logger.warning(f"[LLM-IMAGE] Web search failed, falling back to clarification: {e}")
        elif needs_clarification and not settings.ENABLE_WEB_SEARCH:
            logger.info("[LLM-IMAGE] Event information incomplete, but web search is disabled - will ask user for clarification")
        
        # Convert to ParsedEvent
        events = _convert_to_parsed_events(result, source_type="image")

        logger.info(f"LLM image parsing completed: {len(events)} event(s) extracted, needs_clarification={needs_clarification}")
        return ParseResult(
            events=events,
            needs_clarification=needs_clarification,
            clarification_question=clarification_question,
        )
    
    except Exception as e:
        elapsed = time.time() - start_time
        logger.error(f"LLM image parsing failed after {elapsed:.2f}s: {e}", exc_info=True)
        return ParseResult(events=[], needs_clarification=False, clarification_question=None)


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
            events.append(ParsedEvent(
                id=None,
                title=event_data["title"],
                start_time=datetime.fromisoformat(event_data["start_time"]),
                end_time=datetime.fromisoformat(event_data["end_time"]) if event_data.get("end_time") else None,
                location=event_data.get("location"),
                description=event_data.get("description"),
                source_type=source_type,
                is_followed=False,
            ))
            logger.debug(f"Parsed event {idx+1}: {event_data.get('title')} @ {event_data.get('start_time')}")
        except (KeyError, ValueError) as e:
            # Skip events with invalid format
            logger.warning(f"Skipping invalid event data at index {idx}: {e}")
            continue

    return events
