"""
LangGraph Agent 实现 - 智能日程助手

使用 LangGraph 构建状态图，实现意图识别和多轮对话。
"""
import json
from datetime import datetime
from typing import TypedDict, Optional, List, Literal, Annotated
from operator import add

from langgraph.graph import StateGraph, END
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage
from sqlalchemy.orm import Session

from config import settings
from models import Event, User
from logging_config import get_logger
from services.image_utils import generate_thumbnail
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
# Agent 状态定义
# ============================================================================

class AgentState(TypedDict):
    """Agent 状态"""
    # 输入
    message: str
    image_base64: Optional[str]
    user_id: int
    conversation_history: str
    
    # 处理结果
    intent: str
    confidence: float
    response: str
    action_result: Optional[dict]
    
    # 数据库会话（不序列化）
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
    """意图分类节点"""
    logger.debug(f"Classifying intent for message: {state['message'][:50]}...")
    
    llm = get_llm()
    current_time = datetime.now().isoformat()
    
    # 构建图片说明
    image_note = ""
    images_count = 0
    if state.get("images_base64"):
        images_count = len(state["images_base64"])
        image_note = f"（用户附带了 {images_count} 张图片）"
    elif state.get("image_base64"):
        images_count = 1
        image_note = "（用户附带了一张图片）"
    
    # 调用 LLM 进行意图分类
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
    
    # 解析 JSON 结果
    try:
        # 尝试提取 JSON
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
    """处理闲聊对话（流式）"""
    logger.debug("Handling chat (streaming)...")
    
    llm = get_llm()
    current_time = datetime.now().isoformat()
    
    prompt = CHAT_PROMPT.format_messages(
        current_time=current_time,
        message=state["message"],
        conversation_history=state.get("conversation_history", ""),
    )
    
    # 流式调用 LLM
    full_response = ""
    async for chunk in llm.astream(prompt):
        if hasattr(chunk, 'content') and chunk.content:
            full_response += chunk.content
            yield {"type": "token", "token": chunk.content}
    
    # 更新状态
    state["response"] = full_response
    state["action_result"] = None


def handle_create_event(state: AgentState) -> AgentState:
    """处理创建日程（支持多图片）"""
    logger.debug("Handling create event...")
    
    db = state["db"]
    images_base64 = []
    
    # 收集所有图片
    if state.get("images_base64"):
        images_base64 = state["images_base64"]
    elif state.get("image_base64"):
        images_base64 = [state["image_base64"]]
    
    # 如果有多张图片，使用批量解析
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
            for parsed_event in parsed_events:
                # 生成缩略图（使用第一张图片）
                thumbnail = None
                if images_base64:
                    thumbnail = generate_thumbnail(images_base64[0])
                
                # parsed_event 是 ParsedEvent 对象
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
            
            # 为创建的事件生成 embedding（仅 PostgreSQL）
            try:
                from services.embedding_service import generate_event_embedding, is_postgres
                from sqlalchemy import text
                
                if is_postgres():
                    for event in created_events:
                        embedding = generate_event_embedding(
                            title=event.title,
                            description=event.description,
                            location=event.location,
                        )
                        if embedding:
                            embedding_str = "[" + ",".join(map(str, embedding)) + "]"
                            db.execute(text("""
                                UPDATE events 
                                SET embedding = :embedding::vector 
                                WHERE id = :event_id
                            """), {"embedding": embedding_str, "event_id": event.id})
                    db.commit()
                    logger.debug(f"Generated embeddings for {len(created_events)} events")
            except Exception as e:
                logger.warning(f"Failed to generate embeddings: {e}")
            
            # 构建响应
            if len(created_events) == 1:
                event = created_events[0]
                response_text = f"好的，我已经为您创建了日程：\n\n"
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
                response_text = f"好的，我已经从 {len(images_base64)} 张图片中为您创建了 {len(created_events)} 个日程：\n\n"
                for idx, event in enumerate(created_events, 1):
                    response_text += f"{idx}. **{event.title}** - {event.start_time.strftime('%Y年%m月%d日 %H:%M')}\n"
            
            return {
                **state,
                "response": response_text,
                "action_result": {
                    "event_ids": [e.id for e in created_events],
                    "events_count": len(created_events),
                    "events": [
                        {
                            "id": e.id,
                            "title": e.title,
                            "start_time": e.start_time.isoformat(),
                            "end_time": e.end_time.isoformat() if e.end_time else None,
                            "location": e.location,
                        }
                        for e in created_events
                    ],
                },
            }
        except Exception as e:
            logger.error(f"Failed to parse multiple images: {e}", exc_info=True)
            # 降级到单图片处理
    
    # 单图片或文本处理（原有逻辑）
    llm = get_llm()
    current_time = datetime.now().isoformat()
    
    # 构建图片说明
    image_note = ""
    if images_base64:
        image_note = "（用户附带了图片，请从图片中提取日程信息）"
    
    # 提取日程信息
    prompt = EVENT_EXTRACTION_PROMPT.format_messages(
        current_time=current_time,
        message=state["message"],
        image_note=image_note,
    )
    
    # 如果有图片，使用多模态
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
    
    # 解析事件信息
    try:
        content = response.content
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0]
        elif "```" in content:
            content = content.split("```")[1].split("```")[0]
        
        event_data = json.loads(content.strip())
        
        # 创建事件
        event = Event(
            user_id=state["user_id"],
            title=event_data.get("title", "新日程"),
            start_time=datetime.fromisoformat(event_data["start_time"]),
            end_time=datetime.fromisoformat(event_data["end_time"]) if event_data.get("end_time") else None,
            location=event_data.get("location"),
            description=event_data.get("description"),
            source_type="agent",
            is_followed=True,
        )
        db.add(event)
        db.commit()
        db.refresh(event)
        
        logger.info(f"Created event: {event.title} (id={event.id})")
        
        # 生成 embedding（仅 PostgreSQL）
        try:
            from services.embedding_service import generate_event_embedding, is_postgres
            from sqlalchemy import text
            
            if is_postgres():
                embedding = generate_event_embedding(
                    title=event.title,
                    description=event.description,
                    location=event.location,
                )
                if embedding:
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
        
        # 构建响应
        response_text = f"好的，我已经为您创建了日程：\n\n"
        response_text += f"📅 **{event.title}**\n"
        response_text += f"⏰ 时间：{event.start_time.strftime('%Y年%m月%d日 %H:%M')}"
        if event.end_time:
            response_text += f" - {event.end_time.strftime('%H:%M')}"
        response_text += "\n"
        if event.location:
            response_text += f"📍 地点：{event.location}\n"
        if event.description:
            response_text += f"📝 备注：{event.description}\n"
        
        return {
            **state,
            "response": response_text,
            "action_result": {
                "action": "create_event",
                "event_id": event.id,
                "event_title": event.title,
            },
        }
        
    except Exception as e:
        logger.error(f"Failed to create event: {e}")
        
        has_image = state.get("image_base64") or state.get("images_base64")
        if has_image:
            response = "我看到了您上传的图片，但我需要更多信息来创建日程。\n\n请告诉我：\n📅 这个活动是什么时候？\n📍 在哪里举办？\n📝 还有其他需要记录的信息吗？"
        else:
            response = "我想帮您创建日程，但需要更多信息。\n\n请告诉我：\n📅 什么时候？（如：明天下午3点）\n📝 什么活动？（如：团队会议）\n📍 在哪里？（可选）"
        
        return {
            **state,
            "response": response,
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
                "response": "抱歉，我没有找到匹配的日程。请更详细地描述您想修改的日程。",
                "action_result": {"action": "update_event", "error": "no_match"},
            }
        
        # 获取目标事件
        event = db.query(Event).filter(Event.id == matched_id, Event.user_id == user_id).first()
        if not event:
            return {
                **state,
                "response": "抱歉，找不到该日程。",
                "action_result": {"action": "update_event", "error": "event_not_found"},
            }
        
        # 提取更新信息
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
        
        # 更新事件
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
        
        response_text = f"好的，我已经为您更新了日程「{event.title}」：\n"
        response_text += f"⏰ 时间：{event.start_time.strftime('%Y年%m月%d日 %H:%M')}\n"
        if event.location:
            response_text += f"📍 地点：{event.location}\n"
        
        return {
            **state,
            "response": response_text,
            "action_result": {"action": "update_event", "event_id": event.id},
        }
        
    except Exception as e:
        logger.error(f"Failed to update event: {e}")
        return {
            **state,
            "response": "抱歉，修改日程时出错了。请稍后重试。",
            "action_result": {"action": "update_event", "error": str(e)},
        }


def handle_delete_event(state: AgentState) -> AgentState:
    """处理删除日程"""
    logger.debug("Handling delete event...")
    
    db = state["db"]
    user_id = state["user_id"]
    
    # 获取用户的日程列表
    events = db.query(Event).filter(Event.user_id == user_id).order_by(Event.start_time).all()
    
    if not events:
        return {
            **state,
            "response": "您目前没有任何日程，无法进行删除。",
            "action_result": {"action": "delete_event", "error": "no_events"},
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
                "response": "抱歉，我没有找到匹配的日程。请更详细地描述您想删除的日程。",
                "action_result": {"action": "delete_event", "error": "no_match"},
            }
        
        # 获取并删除目标事件
        event = db.query(Event).filter(Event.id == matched_id, Event.user_id == user_id).first()
        if not event:
            return {
                **state,
                "response": "抱歉，找不到该日程。",
                "action_result": {"action": "delete_event", "error": "event_not_found"},
            }
        
        event_title = event.title
        db.delete(event)
        db.commit()
        
        logger.info(f"Deleted event: {event_title} (id={matched_id})")
        
        return {
            **state,
            "response": f"好的，我已经为您删除了日程「{event_title}」。",
            "action_result": {"action": "delete_event", "event_id": matched_id},
        }
        
    except Exception as e:
        logger.error(f"Failed to delete event: {e}")
        return {
            **state,
            "response": "抱歉，删除日程时出错了。请稍后重试。",
            "action_result": {"action": "delete_event", "error": str(e)},
        }


def handle_query_event(state: AgentState) -> AgentState:
    """处理查询日程（支持向量语义搜索）"""
    logger.debug("Handling query event...")
    
    db = state["db"]
    user_id = state["user_id"]
    message = state["message"]
    
    # 尝试使用向量搜索（仅 PostgreSQL）
    events = []
    used_vector_search = False
    
    try:
        from services.embedding_service import is_postgres, generate_embedding
        from sqlalchemy import text
        
        if is_postgres():
            # 生成查询的 embedding
            query_embedding = generate_embedding(message)
            
            if query_embedding:
                # 向量相似度搜索
                embedding_str = "[" + ",".join(map(str, query_embedding)) + "]"
                
                result = db.execute(text("""
                    SELECT 
                        id, title, start_time, end_time, location, description,
                        source_type, source_thumbnail, is_followed, created_at,
                        1 - (embedding <=> :embedding::vector) as similarity
                    FROM events
                    WHERE user_id = :user_id
                        AND embedding IS NOT NULL
                    ORDER BY embedding <=> :embedding::vector
                    LIMIT 20
                """), {
                    "embedding": embedding_str,
                    "user_id": user_id,
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
                        user_id=user_id,
                    ))
                
                if events:
                    used_vector_search = True
                    logger.info(f"Vector search found {len(events)} events")
    except Exception as e:
        logger.warning(f"Vector search failed, falling back to normal query: {e}")
    
    # 如果向量搜索没有结果，使用普通查询
    if not events:
        events = db.query(Event).filter(Event.user_id == user_id).order_by(Event.start_time).all()
    
    if not events:
        return {
            **state,
            "response": "您目前没有任何日程。需要我帮您创建一个吗？",
            "action_result": {"action": "query_event", "events_count": 0, "events": []},
        }
    
    # 使用 LLM 根据用户请求智能回复
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
    
    search_method = "vector" if used_vector_search else "normal"
    logger.info(f"Query event completed: found {len(events)} events (search={search_method})")
    
    return {
        **state,
        "response": response.content,
        "action_result": {
            "action": "query_event",
            "events_count": len(events),
            "search_method": search_method,
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
    """处理不确定的请求 - 友好询问用户"""
    logger.debug("Handling unclear request with friendly response...")
    
    message = state.get("message", "")
    has_image = state.get("image_base64") or state.get("images_base64")
    
    if has_image:
        # 有图片时，询问用户想要做什么
        response = "我看到您上传了图片！请问您希望我如何处理呢？\n\n我可以帮您：\n📅 从图片中提取活动信息并创建日程\n🔍 了解图片中的内容\n\n请告诉我您的需求~"
    else:
        # 没有图片，友好地询问更多信息
        response = f"您好！我注意到您的消息是：「{message[:50]}{'...' if len(message) > 50 else ''}」\n\n请问您是想要：\n📅 创建新日程\n🔍 查看我的日程\n✏️ 修改某个日程\n\n可以告诉我更多细节吗？"
    
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
# 构建图
# ============================================================================

def create_agent_graph() -> StateGraph:
    """创建 Agent 状态图"""
    
    # 创建图
    graph = StateGraph(AgentState)
    
    # 添加节点
    graph.add_node("intent_classifier", classify_intent)
    graph.add_node("chat", handle_chat)
    graph.add_node("create_event", handle_create_event)
    graph.add_node("query_event", handle_query_event)
    graph.add_node("update_event", handle_update_event)
    graph.add_node("delete_event", handle_delete_event)
    graph.add_node("reject", handle_reject)
    
    # 设置入口
    graph.set_entry_point("intent_classifier")
    
    # 添加条件边（根据意图路由）
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
    
    # 所有处理节点都结束
    graph.add_edge("chat", END)
    graph.add_edge("create_event", END)
    graph.add_edge("query_event", END)
    graph.add_edge("update_event", END)
    graph.add_edge("delete_event", END)
    graph.add_edge("reject", END)
    
    return graph.compile()


# ============================================================================
# 运行 Agent
# ============================================================================

def run_agent(
    message: str,
    user_id: int,
    db: Session,
    image_base64: Optional[str] = None,
    conversation_history: str = "",
) -> dict:
    """
    运行 Agent 处理用户请求
    
    Args:
        message: 用户消息
        user_id: 用户 ID
        db: 数据库会话
        image_base64: 可选的图片 base64
        conversation_history: 对话历史
        
    Returns:
        包含 intent, response, action_result 的字典
    """
    logger.info(f"Running agent for user {user_id}: {message[:50]}...")
    
    # 创建并运行图
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
    
    # 运行图
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
    运行 Agent 处理用户请求（流式）
    
    Args:
        message: 用户消息
        user_id: 用户 ID
        db: 数据库会话
        image_base64: 可选的图片 base64
        conversation_history: 对话历史
        
    Yields:
        流式事件字典，包含 type 和相应数据：
        - {"type": "thinking", "message": "正在思考..."} - 思考中状态
        - {"type": "intent", "intent": "chat"} - 意图识别完成
        - {"type": "token", "token": "字"} - 流式文本 token（仅 chat 意图）
        - {"type": "content", "content": "完整回复"} - 完整回复（非 chat 意图）
        - {"type": "action", "action_result": {...}} - 操作结果（如创建的日程）
        - {"type": "done"} - 完成
        - {"type": "error", "error": "错误信息"} - 错误
    """
    logger.info(f"Running agent (streaming) for user {user_id}: {message[:50]}...")
    
    try:
        # 发送 thinking 事件 - 开始理解请求
        yield {"type": "thinking", "message": "正在理解您的请求..."}
        
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
        
        # 第一步：意图识别（非流式，快速判断）
        llm = get_llm()
        current_time = datetime.now().isoformat()
        
        image_note = ""
        if images_base64:
            image_note = f"（用户附带了 {len(images_base64)} 张图片）"
        elif image_base64:
            image_note = "（用户附带了一张图片）"
        
        prompt = INTENT_CLASSIFIER_PROMPT.format_messages(
            current_time=current_time,
            message=message,
            image_note=image_note,
            conversation_history=conversation_history,
        )
        
        if images_base64:
            # 多张图片：添加所有图片
            content = [{"type": "text", "text": prompt[1].content}]
            for img_base64 in images_base64:
                content.append({
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{img_base64}"},
                })
            messages = [prompt[0], HumanMessage(content=content)]
        elif image_base64:
            # 单张图片（向后兼容）
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
        
        # 解析意图
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
        except Exception as e:
            logger.warning(f"Failed to parse intent, defaulting to chat: {e}")
            intent = "chat"
        
        yield {"type": "intent", "intent": intent}
        
        # 第二步：根据意图生成回复
        if intent == "chat":
            # 闲聊：发送 thinking 事件，然后流式生成回复
            yield {"type": "thinking", "message": "正在思考回复..."}
            async for chunk in handle_chat_stream(initial_state):
                yield chunk
        else:
            # 其他意图（create_event/query_event/update_event/delete_event/reject）
            # 发送 thinking 事件，说明正在执行操作
            thinking_messages = {
                "create_event": "正在创建日程...",
                "query_event": "正在查询日程...",
                "update_event": "正在修改日程...",
                "delete_event": "正在删除日程...",
                "reject": "正在理解您的需求...",
            }
            yield {"type": "thinking", "message": thinking_messages.get(intent, "正在处理...")}
            
            agent = create_agent_graph()
            result = agent.invoke(initial_state)
            
            # 发送操作结果（如果有）
            if result.get("action_result"):
                yield {"type": "action", "action_result": result.get("action_result")}
            
            # 直接发送完整回复（非流式操作，直接返回结果更清晰）
            full_response = result.get("response", "")
            if full_response:
                yield {"type": "content", "content": full_response}
        
        yield {"type": "done"}
        
    except Exception as e:
        logger.error(f"Stream agent error: {e}", exc_info=True)
        yield {"type": "error", "error": str(e)}
