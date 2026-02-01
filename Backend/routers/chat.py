"""
Smart Chat Routes - /api/chat

LangGraph-based intelligent Agent supporting:
- Intent classification (chat/create/update/delete events)
- Image + text input
- Conversation memory
- Streaming responses (SSE)
"""
import json
from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from schemas import ChatRequest, ChatResponse
from auth import get_current_user
from database import get_db, SessionLocal
from models import User
from logging_config import get_logger
from services.agent import run_agent, run_agent_stream, ConversationMemory

logger = get_logger(__name__)

router = APIRouter(tags=["Smart Chat"])


@router.post("/chat")
async def chat(
    request: ChatRequest,
    stream: bool = Query(False, description="Whether to use streaming response (SSE)"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Smart chat interface
    
    Supports intent classification and multi-turn conversations:
    - Chat: Direct LLM response
    - Create event: Parse input and create event
    - Update event: Match by description and update event
    - Delete event: Match by description and delete event
    
    Supports image input, uses Vision model to analyze image content.
    
    Parameters:
    - stream: Whether to use streaming response (SSE), default false
    
    Requires authentication: Authorization: Bearer <token>
    """
    logger.info(f"Chat request from user {current_user.username}: {request.message[:50]}... (stream={stream})")
    logger.debug(f"Chat request details: user_id={current_user.id}, session_id={request.session_id}, has_image={bool(request.image_base64)}, has_images={bool(request.images_base64)}")
    
    # Process images: support single or multiple images
    images_base64 = []
    if request.images_base64:
        images_base64 = request.images_base64
    elif request.image_base64:
        # Backward compatibility: single image
        images_base64 = [request.image_base64]
    
    # Image to pass to agent (chat interface currently only supports single image, multiple images will use the first one)
    image_base64_for_agent = images_base64[0] if images_base64 else None
    
    if stream:
        # Streaming response needs to get conversation history in generator
        # Pre-fetch conversation history (while original Session is valid)
        memory_for_history = ConversationMemory(
            db=db,
            user_id=current_user.id,
            session_id=request.session_id,
        )
        conversation_history = memory_for_history.get_formatted_history(limit=10)
        # Streaming response
        # Note: Need to create independent database session inside generator, because FastAPI's dependency injection will close the original Session after returning StreamingResponse
        
        # Pre-fetch required user info (avoid accessing closed Session in generator)
        user_id = current_user.id
        session_id = request.session_id
        message = request.message
        
        async def generate_stream():
            logger.info(f"Starting stream generation for user {user_id}, session {session_id}")
            # Create independent database session inside generator
            stream_db = SessionLocal()
            try:
                # Re-initialize conversation memory (using new Session)
                stream_memory = ConversationMemory(
                    db=stream_db,
                    user_id=user_id,
                    session_id=session_id,
                )
                
                # Add user message to memory
                stream_memory.add_message("user", message)
                
                full_response = ""
                intent = ""
                action_result = None
                
                # Send initial event (intent classification)
                yield f"data: {json.dumps({'type': 'status', 'message': 'Identifying intent...'}, ensure_ascii=False)}\n\n"
                
                chunk_count = 0
                async for chunk in run_agent_stream(
                    message=message,
                    user_id=user_id,
                    db=stream_db,
                    image_base64=image_base64_for_agent,
                    images_base64=images_base64 if len(images_base64) > 1 else None,
                    conversation_history=conversation_history,
                ):
                    chunk_count += 1
                    if chunk["type"] == "thinking":
                        yield f"data: {json.dumps({'type': 'thinking', 'message': chunk['message']}, ensure_ascii=False)}\n\n"
                    elif chunk["type"] == "intent":
                        intent = chunk["intent"]
                        logger.info(f"Intent identified: {intent}")
                        yield f"data: {json.dumps({'type': 'intent', 'intent': intent}, ensure_ascii=False)}\n\n"
                    elif chunk["type"] == "token":
                        token = chunk["token"]
                        full_response += token
                        yield f"data: {json.dumps({'type': 'token', 'token': token}, ensure_ascii=False)}\n\n"
                    elif chunk["type"] == "content":
                        # Non-streaming full content
                        full_response = chunk.get("content", "")
                        yield f"data: {json.dumps({'type': 'content', 'content': full_response}, ensure_ascii=False)}\n\n"
                    elif chunk["type"] == "action":
                        action_result = chunk["action_result"]
                        yield f"data: {json.dumps({'type': 'action', 'action_result': action_result}, ensure_ascii=False)}\n\n"
                    elif chunk["type"] == "done":
                        # Save full response to memory
                        if full_response:
                            stream_memory.add_message("assistant", full_response)
                        logger.info(f"Chat completed: intent={intent}, session_id={stream_memory.conversation_id}, response_len={len(full_response)}")
                        yield f"data: {json.dumps({'type': 'done', 'session_id': stream_memory.conversation_id}, ensure_ascii=False)}\n\n"
                        break
                    elif chunk["type"] == "error":
                        error_msg = chunk.get("error", "Unknown error")
                        logger.error(f"Error chunk received: {error_msg}")
                        yield f"data: {json.dumps({'type': 'error', 'error': error_msg}, ensure_ascii=False)}\n\n"
                        break
                logger.info(f"Stream loop completed: processed {chunk_count} chunks")
            except Exception as e:
                logger.error(f"Stream chat error: {e}", exc_info=True)
                yield f"data: {json.dumps({'type': 'error', 'error': str(e)}, ensure_ascii=False)}\n\n"
            finally:
                # Ensure database session is closed
                stream_db.close()
        
        logger.info("Returning StreamingResponse")
        return StreamingResponse(
            generate_stream(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
                "X-Accel-Buffering": "no",  # Disable Nginx buffering
            }
        )
    else:
        # Non-streaming response
        # Initialize conversation memory
        memory = ConversationMemory(
            db=db,
            user_id=current_user.id,
            session_id=request.session_id,
        )
        
        # Get conversation history
        conversation_history = memory.get_formatted_history(limit=10)
        
        # Add user message to memory
        memory.add_message("user", request.message)
        
        try:
            result = run_agent(
                message=request.message,
                user_id=current_user.id,
                db=db,
                image_base64=image_base64_for_agent,
                images_base64=images_base64 if len(images_base64) > 1 else None,
                conversation_history=conversation_history,
            )
            
            # Add assistant reply to memory
            memory.add_message("assistant", result["response"])
            
            logger.info(f"Chat completed: intent={result['intent']}, session_id={memory.conversation_id}")
            
            return ChatResponse(
                message=result["response"],
                intent=result["intent"],
                session_id=memory.conversation_id,
                action_result=result["action_result"],
            )
            
        except Exception as e:
            logger.error(f"Chat error: {e}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error processing request: {str(e)}",
            )


@router.delete("/chat/{session_id}")
async def clear_conversation(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Clear conversation history
    
    Requires authentication: Authorization: Bearer <token>
    """
    logger.info(f"Clear conversation request from user {current_user.username}: session_id={session_id}")
    
    try:
        memory = ConversationMemory(
            db=db,
            user_id=current_user.id,
            session_id=session_id,
        )
        memory.clear()
        
        return {"message": "Conversation history cleared", "session_id": session_id}
        
    except Exception as e:
        logger.error(f"Clear conversation error: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error clearing conversation history: {str(e)}",
        )
