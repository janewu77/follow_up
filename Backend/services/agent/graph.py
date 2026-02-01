"""
LangGraph Agent Implementation - Smart Calendar Assistant

Uses LangGraph to build state graph for intent recognition and multi-turn conversation.
"""
import json
from datetime import datetime
from typing import TypedDict, Optional, List

from langgraph.graph import StateGraph, END
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage
from sqlalchemy.orm import Session

from config import settings
from models import Event
from logging_config import get_logger
from .prompts.intent import (
    INTENT_CLASSIFIER_PROMPT,
    CHAT_PROMPT,
    EVENT_EXTRACTION_PROMPT,
    EVENT_MATCH_PROMPT,
    EVENT_UPDATE_PROMPT,
    EVENT_QUERY_PROMPT,
)

logger = get_logger(__name__)


# ============================================================================
# Agent State Definition
# ============================================================================

class AgentState(TypedDict):
    """Agent state"""
    # Input
    message: str
    image_base64: Optional[str]
    images_base64: Optional[List[str]]  # Support for multiple images
    user_id: int
    conversation_history: str
    
    # Processing results
    intent: str
    confidence: float
    response: str
    action_result: Optional[dict]
    
    # Progress messages for streaming (list of status messages)
    progress_messages: Optional[List[str]]
    
    # Database session (not serialized)
    db: Session


# ============================================================================
# Node Implementation
# ============================================================================

def get_llm() -> ChatOpenAI:
    """Get LLM instance"""
    import os
    api_key = settings.OPENAI_API_KEY or os.getenv("OPENAI_API_KEY")
    return ChatOpenAI(
        model=settings.OPENAI_MODEL,
        temperature=0.3,
        api_key=api_key,
    )


def classify_intent(state: AgentState) -> AgentState:
    """Intent classification node"""
    logger.debug(f"Classifying intent for message: {state['message'][:50]}...")
    
    llm = get_llm()
    current_time = datetime.now().isoformat()
    
    # Build image note
    image_note = ""
    images_count = 0
    if state.get("images_base64"):
        images_count = len(state["images_base64"])
        image_note = f"(User attached {images_count} image(s))"
    elif state.get("image_base64"):
        images_count = 1
        image_note = "(User attached an image)"
    
    # Call LLM for intent classification
    prompt = INTENT_CLASSIFIER_PROMPT.format_messages(
        current_time=current_time,
        message=state["message"],
        image_note=image_note,
        conversation_history=state.get("conversation_history", ""),
    )
    
    # Use multimodal if image is present
    if state.get("image_base64"):
        content = [
            {"type": "text", "text": prompt[1].content},
            {
                "type": "image_url",
                "image_url": {"url": f"data:image/jpeg;base64,{state['image_base64']}"},
            },
        ]
        messages = [prompt[0], HumanMessage(content=content)]
    else:
        messages = prompt
    
    response = llm.invoke(messages)
    
    # Parse JSON result
    try:
        # Try to extract JSON
        content = response.content
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0]
        elif "```" in content:
            content = content.split("```")[1].split("```")[0]
        
        result = json.loads(content.strip())
        intent = result.get("intent", "chat")
        confidence = result.get("confidence", 0.5)
        logger.info(f"Intent classified: {intent} (confidence={confidence})")
    except (json.JSONDecodeError, IndexError) as e:
        logger.warning(f"Failed to parse intent result: {e}, defaulting to chat")
        intent = "chat"
        confidence = 0.5
    
    return {
        **state,
        "intent": intent,
        "confidence": confidence,
    }


def handle_chat(state: AgentState) -> AgentState:
    """Handle chat conversation"""
    logger.debug("Handling chat...")
    
    llm = get_llm()
    current_time = datetime.now().isoformat()
    
    prompt = CHAT_PROMPT.format_messages(
        current_time=current_time,
        message=state["message"],
        conversation_history=state.get("conversation_history", ""),
    )
    
    response = llm.invoke(prompt)
    
    return {
        **state,
        "response": response.content,
        "action_result": None,
    }


async def handle_chat_stream(state: AgentState):
    """Handle chat conversation (streaming)"""
    logger.debug("Handling chat (streaming)...")
    
    llm = get_llm()
    current_time = datetime.now().isoformat()
    
    prompt = CHAT_PROMPT.format_messages(
        current_time=current_time,
        message=state["message"],
        conversation_history=state.get("conversation_history", ""),
    )
    
    # Stream LLM call
    full_response = ""
    async for chunk in llm.astream(prompt):
        if hasattr(chunk, 'content') and chunk.content:
            full_response += chunk.content
            yield {"type": "token", "token": chunk.content}
    
    # Update state
    state["response"] = full_response
    state["action_result"] = None


def check_duplicate_event(db: Session, user_id: int, title: str, start_time: datetime) -> Event | None:
    """
    Check if duplicate event exists (same title + same start time)
    
    Args:
        db: Database session
        user_id: User ID
        title: Event title
        start_time: Start time
        
    Returns:
        If duplicate event exists, return it; otherwise return None
    """
    existing = db.query(Event).filter(
        Event.user_id == user_id,
        Event.title == title,
        Event.start_time == start_time,
    ).first()
    return existing


def handle_create_event(state: AgentState) -> AgentState:
    """Handle event creation (supports multiple images)"""
    logger.debug("Handling create event...")
    
    db = state["db"]
    message = state.get("message", "").lower().strip()
    conversation_history = state.get("conversation_history", "")
    
    # Check if user is requesting search to complete previous event info
    search_keywords = ["search", "帮我search", "帮我搜索", "搜索", "查一下", "查找", "find", "look up"]
    is_search_request = any(kw in message for kw in search_keywords)
    
    if is_search_request and settings.ENABLE_WEB_SEARCH:
        # Extract event title from conversation history
        # Look for patterns like "Cursor 2-Day AI Hackathon" or event names mentioned in previous messages
        import re
        
        # Try to find quoted event names or common patterns
        title_patterns = [
            r'"([^"]+)"',  # Quoted text
            r'"([^"]+)"',  # Chinese quotes
            r'「([^」]+)」',  # Japanese quotes
            r'Cursor[^"]*Hackathon',  # Specific event pattern
            r'([A-Z][a-zA-Z0-9\s\-]+(?:Hackathon|Conference|Concert|Meeting|Event|Festival|Summit))',
        ]
        
        event_title = None
        for pattern in title_patterns:
            match = re.search(pattern, conversation_history, re.IGNORECASE)
            if match:
                event_title = match.group(1) if match.lastindex else match.group(0)
                break
        
        if event_title:
            logger.info(f"User requested search for event: {event_title}")
            progress_messages = [f"Searching for: {event_title}..."]
            
            try:
                from services.search_service import (
                    search_event_info_sync,
                    extract_event_details_from_search_sync,
                )
                
                progress_messages.append("Querying search engine...")
                search_results = search_event_info_sync(query=event_title)
                
                if search_results:
                    progress_messages.append(f"Found {len(search_results)} results, extracting details...")
                    completed_info = extract_event_details_from_search_sync(
                        search_results,
                        partial_event={"title": event_title},
                    )
                    
                    if completed_info and completed_info.start_time:
                        progress_messages.append("Event information found! Creating event...")
                        
                        # Directly create event - be decisive, don't ask for confirmation
                        try:
                            db = state["db"]
                            title = completed_info.event_name or event_title
                            start_time = datetime.fromisoformat(completed_info.start_time)
                            end_time = datetime.fromisoformat(completed_info.end_time) if completed_info.end_time else None
                            location = completed_info.location or completed_info.venue_address
                            description = completed_info.description or ""
                            if completed_info.source_url:
                                description += f"\n\n🔗 Source: {completed_info.source_url}"
                            
                            # Check for duplicates
                            duplicate = check_duplicate_event(db, state["user_id"], title, start_time)
                            if duplicate:
                                return {
                                    **state,
                                    "response": f"⚠️ This event already exists: **{duplicate.title}** ({duplicate.start_time.strftime('%Y-%m-%d %H:%M')})",
                                    "progress_messages": progress_messages,
                                    "action_result": {"action": "create_event", "duplicate": True, "existing_event_id": duplicate.id},
                                }
                            
                            # Create event
                            event = Event(
                                user_id=state["user_id"],
                                title=title,
                                start_time=start_time,
                                end_time=end_time,
                                location=location,
                                description=description,
                                source_type="agent",
                                is_followed=True,
                            )
                            db.add(event)
                            db.commit()
                            db.refresh(event)
                            
                            logger.info(f"Created event from search: {event.title} (id={event.id})")
                            
                            # Build success response
                            response_msg = f"✅ Event created from web search:\n\n"
                            response_msg += f"📅 **{event.title}**\n"
                            response_msg += f"⏰ Time: {event.start_time.strftime('%Y-%m-%d %H:%M')}"
                            if event.end_time:
                                response_msg += f" - {event.end_time.strftime('%H:%M')}"
                            response_msg += "\n"
                            if event.location:
                                response_msg += f"📍 Location: {event.location}\n"
                            
                            from services.ics_service import generate_ics_content
                            return {
                                **state,
                                "response": response_msg,
                                "progress_messages": progress_messages,
                                "action_result": {
                                    "action": "create_event",
                                    "event_id": event.id,
                                    "events": [{
                                        "id": event.id,
                                        "title": event.title,
                                        "start_time": event.start_time.isoformat(),
                                        "end_time": event.end_time.isoformat() if event.end_time else None,
                                        "location": event.location,
                                        "ics_content": generate_ics_content(event),
                                        "ics_download_url": f"/api/events/{event.id}/ics",
                                    }],
                                },
                            }
                        except Exception as e:
                            logger.error(f"Failed to create event from search: {e}")
                            progress_messages.append(f"Failed to create event: {str(e)}")
                    else:
                        progress_messages.append("Could not extract complete event details from search results")
                else:
                    progress_messages.append("No search results found")
                
                return {
                    **state,
                    "response": f"I searched for **{event_title}** but couldn't find specific event details. Please provide the date and time manually.",
                    "progress_messages": progress_messages,
                    "action_result": {"action": "create_event", "search_failed": True},
                }
            except Exception as e:
                logger.warning(f"Search failed: {e}")
                return {
                    **state,
                    "response": f"I tried to search for event information but encountered an error: {str(e)}. Please provide the details manually.",
                    "action_result": {"action": "create_event", "search_error": str(e)},
                }
    
    images_base64 = []
    
    # Collect all images
    if state.get("images_base64"):
        images_base64 = state["images_base64"]
    elif state.get("image_base64"):
        images_base64 = [state["image_base64"]]
    
    # Process multiple images individually to ensure correct thumbnail assignment
    if len(images_base64) > 1:
        logger.info(f"Processing {len(images_base64)} images for event creation")
        try:
            from services.llm_service import parse_image_with_llm
            from services.image_utils import generate_thumbnail
            
            # Process each image individually to assign correct thumbnails
            created_events = []
            duplicate_events = []
            
            for idx, image_base64 in enumerate(images_base64):
                try:
                    # Parse each image individually
                    result = parse_image_with_llm(image_base64, state.get("message", ""))
                    parsed_events = result.events
                    
                    if not parsed_events:
                        logger.debug(f"No events parsed from image {idx+1}/{len(images_base64)}")
                        continue
                    
                    # Generate thumbnail for this specific image
                    thumbnail = generate_thumbnail(image_base64)
                    
                    # Create database records for each parsed event from this image
                    for parsed_event in parsed_events:
                        # Check for duplicates
                        duplicate = check_duplicate_event(
                            db, state["user_id"], parsed_event.title, parsed_event.start_time
                        )
                        if duplicate:
                            duplicate_events.append(duplicate)
                            logger.info(f"Duplicate event detected: {parsed_event.title} at {parsed_event.start_time}")
                            continue
                        
                        # Use thumbnail from the current image
                        event = Event(
                            user_id=state["user_id"],
                            title=parsed_event.title,
                            start_time=parsed_event.start_time,
                            end_time=parsed_event.end_time,
                            location=parsed_event.location,
                            description=parsed_event.description,
                            source_type="agent",
                            source_thumbnail=thumbnail or parsed_event.source_thumbnail,
                            is_followed=True,
                        )
                        db.add(event)
                        created_events.append(event)
                        
                except Exception as img_error:
                    logger.warning(f"Failed to process image {idx+1}/{len(images_base64)}: {img_error}")
                    continue
            
            db.commit()
            for event in created_events:
                db.refresh(event)
            
            logger.info(f"Created {len(created_events)} event(s) from {len(images_base64)} image(s)")
            
            
            # Build response
            response_text = ""
            
            # If there are duplicate events, notify user first
            if duplicate_events:
                if len(duplicate_events) == 1:
                    dup = duplicate_events[0]
                    response_text += f"⚠️ This event already exists: **{dup.title}** ({dup.start_time.strftime('%Y-%m-%d %H:%M')}). Would you like me to modify it?\n\n"
                else:
                    response_text += f"⚠️ Found {len(duplicate_events)} duplicate event(s), skipped.\n\n"
            
            # If there are newly created events, show creation results
            if created_events:
                if len(created_events) == 1:
                    event = created_events[0]
                    response_text += f"Event created:\n\n"
                    response_text += f"📅 **{event.title}**\n"
                    response_text += f"⏰ Time: {event.start_time.strftime('%Y-%m-%d %H:%M')}"
                    if event.end_time:
                        response_text += f" - {event.end_time.strftime('%H:%M')}"
                    response_text += "\n"
                    if event.location:
                        response_text += f"📍 Location: {event.location}\n"
                    if event.description:
                        response_text += f"📝 Notes: {event.description}\n"
                else:
                    response_text += f"Created {len(created_events)} event(s) from {len(images_base64)} image(s):\n\n"
                    for idx, event in enumerate(created_events, 1):
                        response_text += f"{idx}. **{event.title}** - {event.start_time.strftime('%Y-%m-%d %H:%M')}\n"
            
            # If neither created nor duplicate, couldn't extract event info
            if not created_events and not duplicate_events:
                response_text = "I looked at the image(s) you uploaded, but I couldn't find any event-related information (like dates, times, or event details).\n\nWhat would you like me to help you with?\n📅 Create a new event - just tell me the details\n🔍 View your existing events\n💬 Or describe what you see in the image and I'll try to help"
            
            # Generate ICS content for each created event
            from services.ics_service import generate_ics_content
            events_with_ics = []
            for e in created_events:
                events_with_ics.append({
                    "id": e.id,
                    "title": e.title,
                    "start_time": e.start_time.isoformat(),
                    "end_time": e.end_time.isoformat() if e.end_time else None,
                    "location": e.location,
                    "ics_content": generate_ics_content(e),
                    "ics_download_url": f"/api/events/{e.id}/ics",
                })
            
            return {
                **state,
                "response": response_text,
                "action_result": {
                    "action": "create_event",
                    "event_ids": [e.id for e in created_events],
                    "events_count": len(created_events),
                    "events": events_with_ics,
                },
            }
        except Exception as e:
            logger.error(f"Failed to parse multiple images: {e}", exc_info=True)
            # Fallback to single image processing
    
    # Single image or text processing
    # Use dedicated image parsing service if image is present
    if images_base64 and len(images_base64) == 1:
        logger.info("Using image parsing service for single image")
        try:
            from services.llm_service import parse_image_with_llm
            from services.image_utils import generate_thumbnail
            
            # Use dedicated image parsing service
            parse_result = parse_image_with_llm(
                images_base64[0],
                additional_note=state.get("message", "")
            )
            
            # Use parsed events directly if available
            if parse_result.events:
                logger.info(f"Image parsing service extracted {len(parse_result.events)} event(s)")
                parsed_event = parse_result.events[0]  # Use first event
                
                # Check for duplicates
                duplicate = check_duplicate_event(
                    db, state["user_id"], parsed_event.title, parsed_event.start_time
                )
                if duplicate:
                    logger.info(f"Duplicate event detected: {parsed_event.title} at {parsed_event.start_time}")
                    return {
                        **state,
                        "response": f"⚠️ This event already exists: **{duplicate.title}** ({duplicate.start_time.strftime('%Y-%m-%d %H:%M')}). Would you like me to modify it?",
                        "action_result": {
                            "action": "create_event",
                            "duplicate": True,
                            "existing_event_id": duplicate.id,
                            "existing_event_title": duplicate.title,
                        },
                    }
                
                # Create event
                event = Event(
                    user_id=state["user_id"],
                    title=parsed_event.title,
                    start_time=parsed_event.start_time,
                    end_time=parsed_event.end_time,
                    location=parsed_event.location,
                    description=parsed_event.description,
                    source_type="image",
                    source_thumbnail=generate_thumbnail(images_base64[0]),
                    is_followed=True,
                )
                db.add(event)
                db.commit()
                db.refresh(event)
                
                logger.info(f"Created event from image: {event.title} (id={event.id})")
                
                # Generate ICS file content
                from services.ics_service import generate_ics_content
                ics_content = generate_ics_content(event)
                
                # Build response
                response_text = f"Event created:\n\n"
                response_text += f"📅 **{event.title}**\n"
                response_text += f"⏰ Time: {event.start_time.strftime('%Y-%m-%d %H:%M')}"
                if event.end_time:
                    response_text += f" - {event.end_time.strftime('%H:%M')}"
                response_text += "\n"
                if event.location:
                    response_text += f"📍 Location: {event.location}\n"
                if event.description:
                    response_text += f"📝 Description: {event.description}\n"
                
                return {
                    **state,
                    "response": response_text,
                    "action_result": {
                        "action": "create_event",
                        "event_id": event.id,
                        "event_title": event.title,
                        "ics_content": ics_content,
                        "ics_download_url": f"/api/events/{event.id}/ics",
                    },
                }
            
            # If we have partial events (title but no time), try web search to complete
            if parse_result.partial_events and settings.ENABLE_WEB_SEARCH:
                logger.info(f"Found {len(parse_result.partial_events)} partial event(s), attempting web search")
                progress_messages = ["Found event in image, searching for time information..."]
                
                partial_event = parse_result.partial_events[0]
                event_title = partial_event.get("title", "")
                
                try:
                    from services.search_service import (
                        search_event_info_sync,
                        extract_event_details_from_search_sync,
                    )
                    
                    # Build search query
                    search_query = event_title
                    if parse_result.search_keywords:
                        search_query = " ".join(parse_result.search_keywords)
                    
                    progress_messages.append(f"Searching for: {search_query}")
                    search_results = search_event_info_sync(
                        query=search_query,
                        location_hint=partial_event.get("location"),
                    )
                    
                    if search_results:
                        progress_messages.append(f"Found {len(search_results)} results, extracting details...")
                        completed_info = extract_event_details_from_search_sync(
                            search_results,
                            partial_event={"title": event_title, "location_hint": partial_event.get("location")},
                        )
                        
                        if completed_info and completed_info.start_time:
                            progress_messages.append("Event information found! Creating event...")
                            
                            # Create event with completed info
                            try:
                                start_time = datetime.fromisoformat(completed_info.start_time)
                                end_time = datetime.fromisoformat(completed_info.end_time) if completed_info.end_time else None
                                location = completed_info.location or completed_info.venue_address or partial_event.get("location")
                                description = completed_info.description or partial_event.get("description", "")
                                if completed_info.source_url:
                                    description += f"\n\n🔗 Source: {completed_info.source_url}"
                                
                                # Check for duplicates
                                duplicate = check_duplicate_event(db, state["user_id"], completed_info.event_name or event_title, start_time)
                                if duplicate:
                                    return {
                                        **state,
                                        "response": f"⚠️ This event already exists: **{duplicate.title}** ({duplicate.start_time.strftime('%Y-%m-%d %H:%M')})",
                                        "progress_messages": progress_messages,
                                        "action_result": {"action": "create_event", "duplicate": True, "existing_event_id": duplicate.id},
                                    }
                                
                                event = Event(
                                    user_id=state["user_id"],
                                    title=completed_info.event_name or event_title,
                                    start_time=start_time,
                                    end_time=end_time,
                                    location=location,
                                    description=description,
                                    source_type="image",
                                    source_thumbnail=generate_thumbnail(images_base64[0]),
                                    is_followed=True,
                                )
                                db.add(event)
                                db.commit()
                                db.refresh(event)
                                
                                logger.info(f"Created event from image+search: {event.title} (id={event.id})")
                                
                                from services.ics_service import generate_ics_content
                                response_text = f"✅ Event created (info from web search):\n\n"
                                response_text += f"📅 **{event.title}**\n"
                                response_text += f"⏰ Time: {event.start_time.strftime('%Y-%m-%d %H:%M')}"
                                if event.end_time:
                                    response_text += f" - {event.end_time.strftime('%H:%M')}"
                                response_text += "\n"
                                if event.location:
                                    response_text += f"📍 Location: {event.location}\n"
                                
                                return {
                                    **state,
                                    "response": response_text,
                                    "progress_messages": progress_messages,
                                    "action_result": {
                                        "action": "create_event",
                                        "event_id": event.id,
                                        "events": [{
                                            "id": event.id,
                                            "title": event.title,
                                            "start_time": event.start_time.isoformat(),
                                            "end_time": event.end_time.isoformat() if event.end_time else None,
                                            "location": event.location,
                                            "ics_content": generate_ics_content(event),
                                            "ics_download_url": f"/api/events/{event.id}/ics",
                                        }],
                                    },
                                }
                            except Exception as create_error:
                                logger.error(f"Failed to create event from search: {create_error}")
                                progress_messages.append(f"Failed to create event: {str(create_error)}")
                        else:
                            progress_messages.append("Could not find complete event details")
                    else:
                        progress_messages.append("No search results found")
                    
                    # Search failed or incomplete - return with partial info
                    return {
                        **state,
                        "response": f"I found **{event_title}** in the image but couldn't find the date/time. Please provide the event time.",
                        "progress_messages": progress_messages,
                        "action_result": {
                            "action": "create_event",
                            "need_more_info": True,
                            "partial_data": {"title": event_title, "location": partial_event.get("location")},
                        },
                    }
                except Exception as e:
                    logger.warning(f"Search failed for partial event: {e}")
                    return {
                        **state,
                        "response": f"I found **{event_title}** in the image. When is this event happening?",
                        "action_result": {"action": "create_event", "need_more_info": True, "partial_data": {"title": event_title}},
                    }
            
            # Return clarification question if needed
            if parse_result.needs_clarification and parse_result.clarification_question:
                logger.info("Image parsing requires clarification")
                return {
                    **state,
                    "response": parse_result.clarification_question,
                    "action_result": {"action": "create_event", "need_more_info": True},
                }
            
            # If no events and no clarification question, ask user what they want to do
            logger.warning("Image parsing service returned no events")
            return {
                **state,
                "response": "I analyzed the image you uploaded, but I couldn't identify any event information (like dates, times, or event details).\n\nHow can I help you?\n📅 **Create an event** - Tell me the event details and I'll create it for you\n🔍 **View events** - See your upcoming schedule\n💬 **Describe the image** - Tell me what's in the image and what you'd like to do with it",
                "action_result": {"action": "create_event", "no_event_found": True},
            }
        except Exception as e:
            logger.warning(f"Image parsing service failed: {e}, falling back to text extraction", exc_info=True)
            # Continue with text extraction logic
    
    # Text extraction logic (fallback when no image or image parsing failed)
    llm = get_llm()
    current_time = datetime.now().isoformat()
    
    # Build image note
    image_note = ""
    if images_base64:
        image_note = "(User attached image(s), please extract event information from images)"
    
    # Extract event information
    prompt = EVENT_EXTRACTION_PROMPT.format_messages(
        current_time=current_time,
        message=state["message"],
        image_note=image_note,
    )
    
    # Use multimodal if images are present
    if images_base64:
        content = [{"type": "text", "text": prompt[1].content}]
        for img_base64 in images_base64:
            content.append({
                "type": "image_url",
                "image_url": {"url": f"data:image/jpeg;base64,{img_base64}"},
            })
        messages = [prompt[0], HumanMessage(content=content)]
    else:
        messages = prompt
    
    response = llm.invoke(messages)
    
    # Parse event information
    try:
        content = response.content
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0]
        elif "```" in content:
            content = content.split("```")[1].split("```")[0]
        
        event_data = json.loads(content.strip())
        
        # Initialize progress messages
        progress_messages = state.get("progress_messages") or []
        
        # Check if LLM indicates information is incomplete
        if not event_data.get("complete", True):
            clarification = event_data.get("clarification_question")
            missing = event_data.get("missing_info", [])
            
            logger.info(f"Event info incomplete, missing: {missing}")
            
            # Try web search to complete missing info
            if settings.ENABLE_WEB_SEARCH:
                title = event_data.get("title")
                location = event_data.get("location")
                
                # Build search keywords
                search_keywords = []
                if title and title != "Unknown":
                    search_keywords.append(title)
                if location:
                    search_keywords.append(location)
                
                if search_keywords:
                    progress_messages.append(f"Searching for event information: {' '.join(search_keywords)}...")
                    logger.info(f"Attempting web search for incomplete event: {search_keywords}")
                    
                    try:
                        from services.search_service import (
                            search_event_info_sync,
                            extract_event_details_from_search_sync,
                        )
                        
                        # Search web
                        progress_messages.append("Querying search engine...")
                        search_results = search_event_info_sync(
                            query=" ".join(search_keywords),
                            location_hint=location,
                        )
                        
                        if search_results:
                            progress_messages.append(f"Found {len(search_results)} results, extracting details...")
                            logger.info(f"Web search returned {len(search_results)} results")
                            
                            # Extract event details
                            completed_info = extract_event_details_from_search_sync(
                                search_results,
                                partial_event={
                                    "title": title or "",
                                    "location_hint": location or "",
                                },
                            )
                            
                            if completed_info:
                                progress_messages.append("Event information found, updating...")
                                logger.info(f"Search completed event info: {completed_info.event_name}")
                                
                                # Merge search results with event_data
                                if completed_info.event_name and (not title or len(completed_info.event_name) > len(title)):
                                    event_data["title"] = completed_info.event_name
                                if completed_info.start_time and not event_data.get("start_time"):
                                    event_data["start_time"] = completed_info.start_time
                                if completed_info.end_time and not event_data.get("end_time"):
                                    event_data["end_time"] = completed_info.end_time
                                if completed_info.location and not event_data.get("location"):
                                    event_data["location"] = completed_info.location
                                if completed_info.venue_address:
                                    if event_data.get("location"):
                                        event_data["location"] = f"{event_data['location']}, {completed_info.venue_address}"
                                    else:
                                        event_data["location"] = completed_info.venue_address
                                if completed_info.description and not event_data.get("description"):
                                    event_data["description"] = completed_info.description
                                
                                # If we have required fields, directly create event - be decisive
                                if event_data.get("title") and event_data.get("start_time"):
                                    progress_messages.append("Event information found! Creating event...")
                                    logger.info("Web search completed, directly creating event")
                                    
                                    # Add source URL to description
                                    if completed_info.source_url:
                                        desc = event_data.get("description", "") or ""
                                        event_data["description"] = f"{desc}\n\n🔗 Source: {completed_info.source_url}".strip()
                                    
                                    # event_data is now complete, let the normal creation flow handle it
                                    # Mark as complete so we don't ask for clarification
                                    event_data["complete"] = True
                            else:
                                progress_messages.append("Could not extract event details from search results")
                                logger.info("Failed to extract event details from search results")
                        else:
                            progress_messages.append("No search results found")
                            logger.info("Web search returned no results")
                    except Exception as e:
                        progress_messages.append(f"Search failed: {str(e)}")
                        logger.warning(f"Web search failed: {e}")
            
            # If still incomplete after search, ask for clarification
            if not event_data.get("complete", True) and clarification:
                logger.info(f"Event info still incomplete after search, asking for clarification")
                return {
                    **state,
                    "response": clarification,
                    "progress_messages": progress_messages,
                    "action_result": {
                        "action": "create_event",
                        "need_more_info": True,
                        "missing_info": missing,
                        "partial_data": {
                            "title": event_data.get("title"),
                            "start_time": event_data.get("start_time"),
                            "location": event_data.get("location"),
                            "description": event_data.get("description"),
                        },
                        "search_attempted": len(progress_messages) > 0,
                    },
                }
        
        # Check required fields
        if "start_time" not in event_data or not event_data["start_time"]:
            raise ValueError("Missing required field: start_time")
        
        title = event_data.get("title", "New Event")
        start_time = datetime.fromisoformat(event_data["start_time"])
        
        # Check for duplicates
        duplicate = check_duplicate_event(db, state["user_id"], title, start_time)
        if duplicate:
            logger.info(f"Duplicate event detected: {title} at {start_time}")
            return {
                **state,
                "response": f"⚠️ This event already exists: **{duplicate.title}** ({duplicate.start_time.strftime('%Y-%m-%d %H:%M')}). Would you like me to modify it?",
                "action_result": {
                    "action": "create_event",
                    "duplicate": True,
                    "existing_event_id": duplicate.id,
                    "existing_event_title": duplicate.title,
                },
            }
        
        # Parse recurrence information if present
        recurrence_rule = event_data.get("recurrence_rule")
        recurrence_end = None
        if event_data.get("recurrence_end"):
            recurrence_end = datetime.fromisoformat(event_data["recurrence_end"])
        
        # Create event
        event = Event(
            user_id=state["user_id"],
            title=title,
            start_time=start_time,
            end_time=datetime.fromisoformat(event_data["end_time"]) if event_data.get("end_time") else None,
            location=event_data.get("location"),
            description=event_data.get("description"),
            source_type="agent",
            is_followed=True,
            recurrence_rule=recurrence_rule,
            recurrence_end=recurrence_end,
        )
        db.add(event)
        db.commit()
        db.refresh(event)
        
        logger.info(f"Created event: {event.title} (id={event.id})")
        
        # Generate recurrence instances if recurrence_rule is provided
        recurrence_count = 0
        if recurrence_rule:
            from services.recurrence_service import generate_recurrence_instances
            
            logger.info(f"Generating recurrence instances for event {event.id} with rule: {recurrence_rule}")
            
            instances = generate_recurrence_instances(
                start_time=start_time,
                recurrence_rule=recurrence_rule,
                recurrence_end=recurrence_end,
                max_instances=100,
            )
            
            # Create recurrence instances (skip first one as it's the parent)
            for instance_time in instances[1:]:
                # Calculate end_time offset if original event has end_time
                instance_end_time = None
                if event.end_time:
                    duration = event.end_time - start_time
                    instance_end_time = instance_time + duration
                
                instance = Event(
                    user_id=state["user_id"],
                    title=title,
                    start_time=instance_time,
                    end_time=instance_end_time,
                    location=event.location,
                    description=event.description,
                    source_type="agent",
                    is_followed=True,
                    parent_event_id=event.id,
                )
                db.add(instance)
                recurrence_count += 1
            
            db.commit()
            logger.info(f"Created {recurrence_count} recurrence instances for event {event.id}")
        
        # Generate ICS file content
        from services.ics_service import generate_ics_content
        ics_content = generate_ics_content(event)
        
        # Build response
        response_text = f"Event created:\n\n"
        response_text += f"📅 **{event.title}**\n"
        response_text += f"⏰ Time: {event.start_time.strftime('%Y-%m-%d %H:%M')}"
        if event.end_time:
            response_text += f" - {event.end_time.strftime('%H:%M')}"
        response_text += "\n"
        if event.location:
            response_text += f"📍 Location: {event.location}\n"
        if event.description:
            response_text += f"📝 Notes: {event.description}\n"
        if recurrence_rule and recurrence_count > 0:
            response_text += f"🔄 Recurring: {recurrence_count} additional instance(s) created\n"
        
        return {
            **state,
            "response": response_text,
            "progress_messages": progress_messages,
            "action_result": {
                "action": "create_event",
                "event_id": event.id,
                "event_title": event.title,
                "ics_content": ics_content,
                "ics_download_url": f"/api/events/{event.id}/ics",
                "recurrence_count": recurrence_count,
                "search_used": len(progress_messages) > 0,
            },
        }
        
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse JSON from LLM response: {e}")
        logger.debug(f"LLM response content: {response.content[:500] if 'response' in locals() else 'N/A'}")
        
        has_image = state.get("image_base64") or state.get("images_base64")
        if has_image:
            response_text = "I see you uploaded an image! I wasn't able to extract complete event information from it.\n\nWhat would you like me to do?\n📅 **Create an event** - Tell me the details (when, what, where)\n🔍 **View your events** - Check your schedule\n💬 **Describe the image** - Tell me what it shows and I'll help"
        else:
            response_text = "I'd like to help you create an event, but I need more information.\n\nPlease tell me:\n📅 When? (e.g., tomorrow at 3 PM)\n📝 What event? (e.g., team meeting)\n📍 Where? (optional)"
        
        return {
            **state,
            "response": response_text,
            "action_result": {"action": "create_event", "need_more_info": True},
        }
    except (KeyError, ValueError) as e:
        logger.error(f"Failed to extract event data: {e}")
        logger.debug(f"Event data: {event_data if 'event_data' in locals() else 'N/A'}")
        
        has_image = state.get("image_base64") or state.get("images_base64")
        if has_image:
            response_text = "I see you uploaded an image, but some required information is missing to create the event.\n\nPlease tell me:\n📅 When is this event? (required)\n📍 Where is it?\n📝 Any other information to record?"
        else:
            response_text = "I'd like to help you create an event, but required information is missing.\n\nPlease tell me:\n📅 When? (required, e.g., tomorrow at 3 PM)\n📝 What event? (e.g., team meeting)\n📍 Where? (optional)"
        
        return {
            **state,
            "response": response_text,
            "action_result": {"action": "create_event", "need_more_info": True},
        }
    except Exception as e:
        logger.error(f"Failed to create event: {e}", exc_info=True)
        
        has_image = state.get("image_base64") or state.get("images_base64")
        if has_image:
            response_text = "I see you uploaded an image, but I had trouble processing it.\n\nHow can I help you?\n📅 **Create an event** - Just describe it (when, what, where)\n🔍 **View your events** - Check your schedule\n💬 **Try again** - Upload a different image or describe what you need"
        else:
            response_text = "I'd like to help you create an event, but I need more information.\n\nPlease tell me:\n📅 When? (e.g., tomorrow at 3 PM)\n📝 What event? (e.g., team meeting)\n📍 Where? (optional)"
        
        return {
            **state,
            "response": response_text,
            "action_result": {"action": "create_event", "need_more_info": True},
        }


def handle_update_event(state: AgentState) -> AgentState:
    """Handle event update"""
    logger.debug("Handling update event...")
    
    db = state["db"]
    user_id = state["user_id"]
    
    # Get user's event list
    events = db.query(Event).filter(Event.user_id == user_id).order_by(Event.start_time).all()
    
    if not events:
        return {
            **state,
            "response": "You don't have any events to update.",
            "action_result": {"action": "update_event", "error": "no_events"},
        }
    
    # Use LLM to match target event
    llm = get_llm()
    events_list = json.dumps([
        {
            "id": e.id,
            "title": e.title,
            "start_time": e.start_time.isoformat(),
            "location": e.location,
        }
        for e in events
    ], ensure_ascii=False)
    
    match_prompt = EVENT_MATCH_PROMPT.format_messages(
        events_list=events_list,
        user_description=state["message"],
        conversation_history=state.get("conversation_history", ""),
    )
    
    match_response = llm.invoke(match_prompt)
    
    try:
        content = match_response.content
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0]
        elif "```" in content:
            content = content.split("```")[1].split("```")[0]
        
        match_result = json.loads(content.strip())
        matched_id = match_result.get("matched_event_id")
        
        if not matched_id:
            return {
                **state,
                "response": "Sorry, I couldn't find a matching event. Please describe the event you want to update in more detail.",
                "action_result": {"action": "update_event", "error": "no_match"},
            }
        
        # Get target event
        event = db.query(Event).filter(Event.id == matched_id, Event.user_id == user_id).first()
        if not event:
            return {
                **state,
                "response": "Sorry, event not found.",
                "action_result": {"action": "update_event", "error": "event_not_found"},
            }
        
        # Extract update information
        original_event = json.dumps({
            "title": event.title,
            "start_time": event.start_time.isoformat(),
            "end_time": event.end_time.isoformat() if event.end_time else None,
            "location": event.location,
            "description": event.description,
        }, ensure_ascii=False)
        
        update_prompt = EVENT_UPDATE_PROMPT.format_messages(
            original_event=original_event,
            user_message=state["message"],
        )
        
        update_response = llm.invoke(update_prompt)
        
        content = update_response.content
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0]
        elif "```" in content:
            content = content.split("```")[1].split("```")[0]
        
        update_data = json.loads(content.strip())
        
        # Update event
        if "title" in update_data and update_data["title"]:
            event.title = update_data["title"]
        if "start_time" in update_data and update_data["start_time"]:
            event.start_time = datetime.fromisoformat(update_data["start_time"])
        if "end_time" in update_data and update_data["end_time"]:
            event.end_time = datetime.fromisoformat(update_data["end_time"])
        if "location" in update_data and update_data["location"]:
            event.location = update_data["location"]
        if "description" in update_data and update_data["description"]:
            event.description = update_data["description"]
        
        db.commit()
        db.refresh(event)
        
        logger.info(f"Updated event: {event.title} (id={event.id})")
        
        response_text = f"Event updated: **{event.title}**\n"
        response_text += f"⏰ Time: {event.start_time.strftime('%Y-%m-%d %H:%M')}\n"
        if event.location:
            response_text += f"📍 Location: {event.location}\n"
        
        return {
            **state,
            "response": response_text,
            "action_result": {"action": "update_event", "event_id": event.id},
        }
        
    except Exception as e:
        logger.error(f"Failed to update event: {e}")
        return {
            **state,
            "response": "Sorry, an error occurred while updating the event. Please try again later.",
            "action_result": {"action": "update_event", "error": str(e)},
        }


def handle_delete_event(state: AgentState) -> AgentState:
    """Handle event deletion"""
    logger.debug("Handling delete event...")
    
    db = state["db"]
    user_id = state["user_id"]
    
    # Get user's event list
    events = db.query(Event).filter(Event.user_id == user_id).order_by(Event.start_time).all()
    
    if not events:
        return {
            **state,
            "response": "You currently have no events to delete.",
            "action_result": {"action": "delete_event", "error": "no_events"},
        }
    
    # Use LLM to match target event
    llm = get_llm()
    events_list = json.dumps([
        {
            "id": e.id,
            "title": e.title,
            "start_time": e.start_time.isoformat(),
            "location": e.location,
        }
        for e in events
    ], ensure_ascii=False)
    
    match_prompt = EVENT_MATCH_PROMPT.format_messages(
        events_list=events_list,
        user_description=state["message"],
        conversation_history=state.get("conversation_history", ""),
    )
    
    match_response = llm.invoke(match_prompt)
    
    try:
        content = match_response.content
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0]
        elif "```" in content:
            content = content.split("```")[1].split("```")[0]
        
        match_result = json.loads(content.strip())
        matched_id = match_result.get("matched_event_id")
        
        if not matched_id:
            return {
                **state,
                "response": "Sorry, I couldn't find a matching event. Please describe the event you want to delete in more detail.",
                "action_result": {"action": "delete_event", "error": "no_match"},
            }
        
        # Get and delete target event
        event = db.query(Event).filter(Event.id == matched_id, Event.user_id == user_id).first()
        if not event:
            return {
                **state,
                "response": "Sorry, event not found.",
                "action_result": {"action": "delete_event", "error": "event_not_found"},
            }
        
        event_title = event.title
        db.delete(event)
        db.commit()
        
        logger.info(f"Deleted event: {event_title} (id={matched_id})")
        
        return {
            **state,
            "response": f"Event deleted: **{event_title}**",
            "action_result": {"action": "delete_event", "event_id": matched_id},
        }
        
    except Exception as e:
        logger.error(f"Failed to delete event: {e}")
        return {
            **state,
            "response": "Sorry, an error occurred while deleting the event. Please try again later.",
            "action_result": {"action": "delete_event", "error": str(e)},
        }


def handle_query_event(state: AgentState) -> AgentState:
    """Handle event query"""
    logger.debug("Handling query event...")
    
    db = state["db"]
    user_id = state["user_id"]
    message = state["message"]
    
    # Use regular query
    events = db.query(Event).filter(Event.user_id == user_id).order_by(Event.start_time).all()
    
    if not events:
        return {
            **state,
            "response": "You currently have no events. Would you like me to create one for you?",
            "action_result": {"action": "query_event", "events_count": 0, "events": []},
        }
    
    # Use LLM to intelligently respond based on user request
    llm = get_llm()
    current_time = datetime.now().isoformat()
    
    events_list = json.dumps([
        {
            "id": e.id,
            "title": e.title,
            "start_time": e.start_time.isoformat(),
            "end_time": e.end_time.isoformat() if e.end_time else None,
            "location": e.location,
            "description": e.description,
        }
        for e in events
    ], ensure_ascii=False, indent=2)
    
    prompt = EVENT_QUERY_PROMPT.format_messages(
        current_time=current_time,
        message=message,
        events_list=events_list,
    )
    
    response = llm.invoke(prompt)
    
    logger.info(f"Query event completed: found {len(events)} events")
    
    return {
        **state,
        "response": response.content,
        "action_result": {
            "action": "query_event",
            "events_count": len(events),
            "events": [
                {
                    "id": e.id,
                    "title": e.title,
                    "start_time": e.start_time.isoformat(),
                    "end_time": e.end_time.isoformat() if e.end_time else None,
                    "location": e.location,
                }
                for e in events
            ],
        },
    }


def handle_enrich_event(state: AgentState) -> AgentState:
    """Handle event enrichment - search for and add more information to existing event"""
    logger.debug("Handling enrich event...")
    
    db = state["db"]
    user_id = state["user_id"]
    
    # Check if web search is enabled
    if not settings.ENABLE_WEB_SEARCH:
        return {
            **state,
            "response": "Web search is currently disabled. Please configure SERPAPI_KEY or TAVILY_API_KEY to enable event enrichment.",
            "action_result": {"action": "enrich_event", "error": "search_disabled"},
        }
    
    # Get user's event list
    events = db.query(Event).filter(Event.user_id == user_id).order_by(Event.start_time).all()
    
    if not events:
        return {
            **state,
            "response": "You don't have any events to enrich. Would you like me to create one for you?",
            "action_result": {"action": "enrich_event", "error": "no_events"},
        }
    
    # Use LLM to match target event
    llm = get_llm()
    events_list = json.dumps([
        {
            "id": e.id,
            "title": e.title,
            "start_time": e.start_time.isoformat(),
            "location": e.location,
        }
        for e in events
    ], ensure_ascii=False)
    
    match_prompt = EVENT_MATCH_PROMPT.format_messages(
        events_list=events_list,
        user_description=state["message"],
        conversation_history=state.get("conversation_history", ""),
    )
    
    match_response = llm.invoke(match_prompt)
    
    try:
        content = match_response.content
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0]
        elif "```" in content:
            content = content.split("```")[1].split("```")[0]
        
        match_result = json.loads(content.strip())
        matched_id = match_result.get("matched_event_id")
        
        if not matched_id:
            return {
                **state,
                "response": "Sorry, I couldn't find a matching event to enrich. Please describe the event you want to search for in more detail.",
                "action_result": {"action": "enrich_event", "error": "no_match"},
            }
        
        # Get target event
        event = db.query(Event).filter(Event.id == matched_id, Event.user_id == user_id).first()
        if not event:
            return {
                **state,
                "response": "Sorry, event not found.",
                "action_result": {"action": "enrich_event", "error": "event_not_found"},
            }
        
        logger.info(f"Enriching event: {event.title} (id={event.id})")
        
        # Initialize progress messages
        progress_messages = state.get("progress_messages") or []
        
        # Build search query from event information
        search_keywords = [event.title]
        if event.location:
            search_keywords.append(event.location)
        if event.start_time:
            search_keywords.append(event.start_time.strftime("%Y-%m-%d"))
        
        # Search for event information
        from services.search_service import (
            search_event_info_sync,
            extract_event_details_from_search_sync,
            merge_event_info,
        )
        
        progress_messages.append(f"Searching for: {event.title}...")
        logger.info(f"Searching web for event: {' '.join(search_keywords)}")
        
        try:
            progress_messages.append("Querying search engine...")
            
            # Call sync search function directly
            search_results = search_event_info_sync(
                query=" ".join(search_keywords),
                location_hint=event.location,
                date_hint=event.start_time.strftime("%Y-%m-%d") if event.start_time else None,
            )
            
            if not search_results:
                progress_messages.append("No search results found")
                return {
                    **state,
                    "response": f"I searched for more information about **{event.title}**, but couldn't find additional details online. The event information remains unchanged.",
                    "progress_messages": progress_messages,
                    "action_result": {"action": "enrich_event", "event_id": event.id, "enriched": False},
                }
            
            progress_messages.append(f"Found {len(search_results)} results, extracting details...")
            
            # Extract event details from search results
            partial_event = {
                "title": event.title,
                "date_hint": event.start_time.strftime("%Y-%m-%d") if event.start_time else None,
                "location_hint": event.location or "",
            }
            
            # Call sync extraction function directly
            completed_info = extract_event_details_from_search_sync(
                search_results,
                partial_event=partial_event,
            )
            
            if not completed_info:
                progress_messages.append("Could not extract event details from search results")
                return {
                    **state,
                    "response": f"I searched for more information about **{event.title}**, but couldn't extract structured details from the search results. The event information remains unchanged.",
                    "progress_messages": progress_messages,
                    "action_result": {"action": "enrich_event", "event_id": event.id, "enriched": False},
                }
            
            progress_messages.append("Event information found, updating...")
            
            # Merge search results with existing event
            original_data = {
                "title": event.title,
                "start_time": event.start_time.isoformat() if event.start_time else None,
                "end_time": event.end_time.isoformat() if event.end_time else None,
                "location": event.location,
                "description": event.description,
            }
            
            merged_data = merge_event_info(original_data, completed_info)
            
            # Update event with enriched information
            updated_fields = []
            if merged_data.get("title") and merged_data["title"] != event.title:
                event.title = merged_data["title"]
                updated_fields.append("title")
            
            if merged_data.get("location") and merged_data["location"] != (event.location or ""):
                event.location = merged_data["location"]
                updated_fields.append("location")
            
            if merged_data.get("description") and merged_data["description"] != (event.description or ""):
                # Merge descriptions if both exist
                if event.description:
                    event.description = f"{event.description}\n\nAdditional information: {merged_data['description']}"
                else:
                    event.description = merged_data["description"]
                updated_fields.append("description")
            
            # Update venue address if available
            if completed_info.venue_address and completed_info.venue_address != (event.location or ""):
                if event.location:
                    event.location = f"{event.location}, {completed_info.venue_address}"
                else:
                    event.location = completed_info.venue_address
                updated_fields.append("venue_address")
            
            db.commit()
            db.refresh(event)
            
            logger.info(f"Enriched event: {event.title} (id={event.id}), updated fields: {updated_fields}")
            
            # Build response
            response_text = f"I've enriched **{event.title}** with additional information from the web:\n\n"
            
            if "title" in updated_fields:
                response_text += f"📝 **Title**: {event.title}\n"
            if "location" in updated_fields or "venue_address" in updated_fields:
                response_text += f"📍 **Location**: {event.location}\n"
            if "description" in updated_fields:
                response_text += f"📄 **Description**: {event.description[:100]}{'...' if len(event.description) > 100 else ''}\n"
            
            if completed_info.ticket_url:
                response_text += f"🎫 **Ticket URL**: {completed_info.ticket_url}\n"
            if completed_info.price_range:
                response_text += f"💰 **Price**: {completed_info.price_range}\n"
            
            if not updated_fields:
                progress_messages.append("Existing information is already complete")
                response_text = f"I searched for more information about **{event.title}**, but the existing information is already complete. No updates were made."
            else:
                progress_messages.append(f"Updated {len(updated_fields)} field(s): {', '.join(updated_fields)}")
            
            response_text += f"\n🔗 Source: {completed_info.source_url}"
            
            return {
                **state,
                "response": response_text,
                "progress_messages": progress_messages,
                "action_result": {
                    "action": "enrich_event",
                    "event_id": event.id,
                    "enriched": True,
                    "updated_fields": updated_fields,
                },
            }
            
        except Exception as search_error:
            logger.error(f"Web search failed during enrichment: {search_error}", exc_info=True)
            progress_messages.append(f"Search failed: {str(search_error)}")
            return {
                **state,
                "response": f"I tried to search for more information about **{event.title}**, but encountered an error. The event information remains unchanged.",
                "progress_messages": progress_messages,
                "action_result": {"action": "enrich_event", "event_id": event.id, "error": str(search_error)},
            }
        
    except Exception as e:
        logger.error(f"Failed to enrich event: {e}", exc_info=True)
        return {
            **state,
            "response": "Sorry, an error occurred while enriching the event. Please try again later.",
            "action_result": {"action": "enrich_event", "error": str(e)},
        }


def handle_reject(state: AgentState) -> AgentState:
    """Handle unclear requests - friendly user inquiry"""
    logger.debug("Handling unclear request with friendly response...")
    
    message = state.get("message", "")
    has_image = state.get("image_base64") or state.get("images_base64")
    
    if has_image:
        # Ask user what they want to do when image is present
        response = "I see you uploaded an image! How would you like me to handle it?\n\nI can help you:\n📅 Extract event information from the image and create an event\n🔍 Understand the content in the image\n\nPlease tell me what you need~"
    else:
        # Friendly inquiry for more information when no image
        response = f"Hello! I noticed your message: 「{message[:50]}{'...' if len(message) > 50 else ''}」\n\nAre you looking to:\n📅 Create a new event\n🔍 View my events\n✏️ Update an event\n\nCan you tell me more details?"
    
    return {
        **state,
        "response": response,
        "action_result": None,
    }


# ============================================================================
# Routing Functions
# ============================================================================

def route_by_intent(state: AgentState) -> str:
    """Route to different processing nodes based on intent"""
    intent = state.get("intent", "chat")
    
    if intent == "create_event":
        return "create_event"
    elif intent == "query_event":
        return "query_event"
    elif intent == "update_event":
        return "update_event"
    elif intent == "delete_event":
        return "delete_event"
    elif intent == "enrich_event":
        return "enrich_event"
    elif intent == "reject":
        return "reject"
    else:
        return "chat"


# ============================================================================
# Graph Construction
# ============================================================================

def create_agent_graph() -> StateGraph:
    """Create Agent state graph"""
    
    # Create graph
    graph = StateGraph(AgentState)
    
    # Add nodes
    graph.add_node("intent_classifier", classify_intent)
    graph.add_node("chat", handle_chat)
    graph.add_node("create_event", handle_create_event)
    graph.add_node("query_event", handle_query_event)
    graph.add_node("update_event", handle_update_event)
    graph.add_node("delete_event", handle_delete_event)
    graph.add_node("enrich_event", handle_enrich_event)
    graph.add_node("reject", handle_reject)
    
    # Set entry point
    graph.set_entry_point("intent_classifier")
    
    # Add conditional edges (route based on intent)
    graph.add_conditional_edges(
        "intent_classifier",
        route_by_intent,
        {
            "chat": "chat",
            "create_event": "create_event",
            "query_event": "query_event",
            "update_event": "update_event",
            "delete_event": "delete_event",
            "enrich_event": "enrich_event",
            "reject": "reject",
        }
    )
    
    # All processing nodes end here
    graph.add_edge("chat", END)
    graph.add_edge("create_event", END)
    graph.add_edge("query_event", END)
    graph.add_edge("update_event", END)
    graph.add_edge("delete_event", END)
    graph.add_edge("enrich_event", END)
    graph.add_edge("reject", END)
    
    return graph.compile()


# ============================================================================
# Run Agent
# ============================================================================

def run_agent(
    message: str,
    user_id: int,
    db: Session,
    image_base64: Optional[str] = None,
    images_base64: Optional[List[str]] = None,
    conversation_history: str = "",
) -> dict:
    """
    Run Agent to process user request
    
    Args:
        message: User message
        user_id: User ID
        db: Database session
        image_base64: Optional single image base64 (backward compatibility)
        images_base64: Optional list of multiple image base64
        conversation_history: Conversation history
        
    Returns:
        Dictionary containing intent, response, action_result
    """
    logger.info(f"Running agent for user {user_id}: {message[:50]}...")
    
    # Create and run graph
    agent = create_agent_graph()
    
    initial_state = AgentState(
        message=message,
        image_base64=image_base64,
        images_base64=images_base64,
        user_id=user_id,
        conversation_history=conversation_history,
        intent="",
        confidence=0.0,
        response="",
        action_result=None,
        db=db,
    )
    
    # Run graph
    result = agent.invoke(initial_state)
    
    logger.info(f"Agent completed: intent={result['intent']}")
    
    return {
        "intent": result["intent"],
        "response": result["response"],
        "action_result": result["action_result"],
    }


async def run_agent_stream(
    message: str,
    user_id: int,
    db: Session,
    image_base64: Optional[str] = None,
    images_base64: Optional[List[str]] = None,
    conversation_history: str = "",
):
    """
    Run Agent to process user request (streaming)
    
    Args:
        message: User message
        user_id: User ID
        db: Database session
        image_base64: Optional image base64
        conversation_history: Conversation history
        
    Yields:
        Streaming event dictionary containing type and corresponding data:
        - {"type": "thinking", "message": "Thinking..."} - Thinking state
        - {"type": "intent", "intent": "chat"} - Intent classification completed
        - {"type": "token", "token": "word"} - Streaming text token (chat intent only)
        - {"type": "content", "content": "Full response"} - Full response (non-chat intent)
        - {"type": "action", "action_result": {...}} - Action result (e.g., created events)
        - {"type": "done"} - Done
        - {"type": "error", "error": "Error message"} - Error
    """
    logger.info(f"Running agent (streaming) for user {user_id}: {message[:50]}...")
    
    try:
        # Send thinking event - start understanding request
        yield {"type": "thinking", "message": "Understanding your request..."}
        
        initial_state = AgentState(
            message=message,
            image_base64=image_base64,
            images_base64=images_base64,
            user_id=user_id,
            conversation_history=conversation_history,
            intent="",
            confidence=0.0,
            response="",
            action_result=None,
            db=db,
        )
        
        # Step 1: Intent classification (non-streaming, quick judgment)
        llm = get_llm()
        current_time = datetime.now().isoformat()
        
        image_note = ""
        if images_base64:
            image_note = f"(User attached {len(images_base64)} image(s))"
        elif image_base64:
            image_note = "(User attached an image)"
        
        prompt = INTENT_CLASSIFIER_PROMPT.format_messages(
            current_time=current_time,
            message=message,
            image_note=image_note,
            conversation_history=conversation_history,
        )
        
        if images_base64:
            # Multiple images: add all images
            content = [{"type": "text", "text": prompt[1].content}]
            for img_base64 in images_base64:
                content.append({
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{img_base64}"},
                })
            messages = [prompt[0], HumanMessage(content=content)]
        elif image_base64:
            # Single image (backward compatibility)
            content = [
                {"type": "text", "text": prompt[1].content},
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{image_base64}"},
                },
            ]
            messages = [prompt[0], HumanMessage(content=content)]
        else:
            messages = prompt
        
        intent_response = llm.invoke(messages)
        
        # Parse intent
        try:
            content = intent_response.content
            if "```json" in content:
                json_str = content.split("```json")[1].split("```")[0].strip()
            elif "```" in content:
                json_str = content.split("```")[1].split("```")[0].strip()
            else:
                json_str = content.strip()
            
            intent_data = json.loads(json_str)
            intent = intent_data.get("intent", "chat")
            logger.info(f"Intent classified: {intent}")
        except Exception as e:
            logger.warning(f"Failed to parse intent, defaulting to chat: {e}")
            intent = "chat"
        
        yield {"type": "intent", "intent": intent}
        
        # Step 2: Generate response based on intent
        if intent == "chat":
            # Chat: send thinking event, then stream response
            yield {"type": "thinking", "message": "Thinking of a response..."}
            async for chunk in handle_chat_stream(initial_state):
                yield chunk
        else:
            # Other intents (create_event/query_event/update_event/delete_event/reject)
            # Send thinking event indicating operation in progress
            thinking_messages = {
                "create_event": "Creating event...",
                "query_event": "Querying events...",
                "update_event": "Updating event...",
                "delete_event": "Deleting event...",
                "reject": "Understanding your needs...",
                "enrich_event": "Searching for event information...",
            }
            yield {"type": "thinking", "message": thinking_messages.get(intent, "Processing...")}
            
            # Add progress_messages to initial state
            initial_state["progress_messages"] = []
            
            agent = create_agent_graph()
            result = agent.invoke(initial_state)
            
            # Send progress messages (e.g., search progress)
            progress_messages = result.get("progress_messages", [])
            for msg in progress_messages:
                yield {"type": "status", "message": msg}
            
            # Send action result if available
            if result.get("action_result"):
                yield {"type": "action", "action_result": result.get("action_result")}
            
            # Send full response directly (non-streaming operations, direct result is clearer)
            full_response = result.get("response", "")
            if full_response:
                yield {"type": "content", "content": full_response}
        
        yield {"type": "done"}
        
    except Exception as e:
        logger.error(f"Stream agent error: {e}", exc_info=True)
        yield {"type": "error", "error": str(e)}
