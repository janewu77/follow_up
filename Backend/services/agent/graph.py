"""
LangGraph Agent 实现 - 智能日程助手

使用 LangGraph 构建状态图，实现意图识别和多轮对话。
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
    
    # Database session (not serialized)
    db: Session


# ============================================================================
# 节点实现
# ============================================================================

def get_llm() -> ChatOpenAI:
    """获取 LLM 实例"""
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
    
    # 如果有图片，使用多模态
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
    """处理闲聊对话"""
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
    检查是否存在重复事件（相同标题 + 相同开始时间）
    
    Args:
        db: 数据库会话
        user_id: 用户 ID
        title: 事件标题
        start_time: 开始时间
        
    Returns:
        如果存在重复事件，返回该事件；否则返回 None
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
    images_base64 = []
    
    # Collect all images
    if state.get("images_base64"):
        images_base64 = state["images_base64"]
    elif state.get("image_base64"):
        images_base64 = [state["image_base64"]]
    
    # Use batch parsing if multiple images
    if len(images_base64) > 1:
        logger.info(f"Processing {len(images_base64)} images for event creation")
        try:
            from services.llm_service import parse_images_with_llm
            from services.image_utils import generate_thumbnail
            
            # 批量解析多张图片
            parsed_events = parse_images_with_llm(images_base64, state.get("message", ""))
            
            if not parsed_events:
                # 如果没有解析出事件，降级到单图片/文本处理
                logger.warning(f"No events parsed from {len(images_base64)} images, falling back to text extraction")
                images_base64 = images_base64[:1]  # 只使用第一张图片
            
            # 为每个解析出的事件创建数据库记录
            created_events = []
            duplicate_events = []
            for parsed_event in parsed_events:
                # Check for duplicates
                duplicate = check_duplicate_event(
                    db, state["user_id"], parsed_event.title, parsed_event.start_time
                )
                if duplicate:
                    duplicate_events.append(duplicate)
                    logger.info(f"Duplicate event detected: {parsed_event.title} at {parsed_event.start_time}")
                    continue
                
                # Generate thumbnail (using first image)
                thumbnail = None
                if images_base64:
                    thumbnail = generate_thumbnail(images_base64[0])
                
                # parsed_event is a ParsedEvent object
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
            
            db.commit()
            for event in created_events:
                db.refresh(event)
            
            logger.info(f"Created {len(created_events)} event(s) from {len(images_base64)} image(s)")
            
            
            # 构建响应
            response_text = ""
            
            # 如果有重复事件，先提示用户
            if duplicate_events:
                if len(duplicate_events) == 1:
                    dup = duplicate_events[0]
                    response_text += f"⚠️ 这个日程已经存在了：**{dup.title}**（{dup.start_time.strftime('%Y年%m月%d日 %H:%M')}）。需要我帮您修改吗？\n\n"
                else:
                    response_text += f"⚠️ 发现 {len(duplicate_events)} 个重复的日程，已跳过。\n\n"
            
            # 如果有新创建的事件，显示创建结果
            if created_events:
                if len(created_events) == 1:
                    event = created_events[0]
                    response_text += f"好的，我已经为您创建了日程：\n\n"
                    response_text += f"📅 **{event.title}**\n"
                    response_text += f"⏰ 时间：{event.start_time.strftime('%Y年%m月%d日 %H:%M')}"
                    if event.end_time:
                        response_text += f" - {event.end_time.strftime('%H:%M')}"
                    response_text += "\n"
                    if event.location:
                        response_text += f"📍 地点：{event.location}\n"
                    if event.description:
                        response_text += f"📝 备注：{event.description}\n"
                else:
                    response_text += f"好的，我已经从 {len(images_base64)} 张图片中为您创建了 {len(created_events)} 个日程：\n\n"
                    for idx, event in enumerate(created_events, 1):
                        response_text += f"{idx}. **{event.title}** - {event.start_time.strftime('%Y年%m月%d日 %H:%M')}\n"
            
            # 如果既没有创建也没有重复，说明所有事件都重复了
            if not created_events and not duplicate_events:
                response_text = "抱歉，无法从图片中提取到有效的日程信息。"
            
            # 为每个创建的事件生成 ICS 内容
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
            
            # Return clarification question if needed
            if parse_result.needs_clarification and parse_result.clarification_question:
                logger.info("Image parsing requires clarification")
                return {
                    **state,
                    "response": parse_result.clarification_question,
                    "action_result": {"action": "create_event", "need_more_info": True},
                }
            
            # Continue with text extraction if no events parsed and no clarification needed
            logger.warning("Image parsing service returned no events, falling back to text extraction")
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
        
        # Check if LLM indicates information is incomplete
        if not event_data.get("complete", True):
            clarification = event_data.get("clarification_question")
            missing = event_data.get("missing_info", [])
            
            if clarification:
                logger.info(f"Event info incomplete, asking for clarification. Missing: {missing}")
                return {
                    **state,
                    "response": clarification,
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
            "action_result": {
                "action": "create_event",
                "event_id": event.id,
                "event_title": event.title,
                "ics_content": ics_content,
                "ics_download_url": f"/api/events/{event.id}/ics",
                "recurrence_count": recurrence_count,
            },
        }
        
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse JSON from LLM response: {e}")
        logger.debug(f"LLM response content: {response.content[:500] if 'response' in locals() else 'N/A'}")
        
        has_image = state.get("image_base64") or state.get("images_base64")
        if has_image:
            response_text = "I see you uploaded an image, but I couldn't extract complete event information from it.\n\nPlease tell me:\n📅 When is this event? (e.g., tomorrow at 3 PM)\n📍 Where is it? (optional)\n📝 Any other information to record?"
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
            response_text = "I see you uploaded an image, but encountered an error while processing it.\n\nPlease tell me:\n📅 When is this event?\n📍 Where is it?\n📝 Any other information to record?"
        else:
            response_text = "I'd like to help you create an event, but I need more information.\n\nPlease tell me:\n📅 When? (e.g., tomorrow at 3 PM)\n📝 What event? (e.g., team meeting)\n📍 Where? (optional)"
        
        return {
            **state,
            "response": response_text,
            "action_result": {"action": "create_event", "need_more_info": True},
        }


def handle_update_event(state: AgentState) -> AgentState:
    """处理修改日程"""
    logger.debug("Handling update event...")
    
    db = state["db"]
    user_id = state["user_id"]
    
    # 获取用户的日程列表
    events = db.query(Event).filter(Event.user_id == user_id).order_by(Event.start_time).all()
    
    if not events:
        return {
            **state,
            "response": "您目前没有任何日程，无法进行修改。",
            "action_result": {"action": "update_event", "error": "no_events"},
        }
    
    # 使用 LLM 匹配目标日程
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
# 路由函数
# ============================================================================

def route_by_intent(state: AgentState) -> str:
    """根据意图路由到不同的处理节点"""
    intent = state.get("intent", "chat")
    
    if intent == "create_event":
        return "create_event"
    elif intent == "query_event":
        return "query_event"
    elif intent == "update_event":
        return "update_event"
    elif intent == "delete_event":
        return "delete_event"
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
            "reject": "reject",
        }
    )
    
    # All processing nodes end here
    graph.add_edge("chat", END)
    graph.add_edge("create_event", END)
    graph.add_edge("query_event", END)
    graph.add_edge("update_event", END)
    graph.add_edge("delete_event", END)
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
            }
            yield {"type": "thinking", "message": thinking_messages.get(intent, "Processing...")}
            agent = create_agent_graph()
            result = agent.invoke(initial_state)
            
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
