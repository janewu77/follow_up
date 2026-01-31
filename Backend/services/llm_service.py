"""
LLM Service - 使用 LangChain + OpenAI 进行日程解析

职责：
- 初始化和管理 LLM 实例
- 调用 LLM API 解析文本和图像
- 将 LLM 响应转换为业务模型
"""
import os
import time
from typing import List, Optional
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


# ============================================================================
# LLM Initialization
# ============================================================================

def get_llm() -> ChatOpenAI:
    """
    获取 OpenAI LLM 实例
    
    Returns:
        配置好的 ChatOpenAI 实例
        
    Raises:
        ValueError: 如果 API Key 未配置
    """
    api_key = settings.OPENAI_API_KEY or os.getenv("OPENAI_API_KEY")
    if not api_key:
        logger.error("OPENAI_API_KEY is not configured")
        raise ValueError("OPENAI_API_KEY is not configured. Set it in .env file or environment variable.")
    
    logger.debug(f"Initializing LLM: model={settings.OPENAI_MODEL}, temperature=0.3")
    return ChatOpenAI(
        model=settings.OPENAI_MODEL,
        temperature=0.3,  # 降低温度以获得更一致的结果
        api_key=api_key,
    )


# ============================================================================
# Text Parsing
# ============================================================================

def parse_text_with_llm(
    text: str,
    additional_note: Optional[str] = None,
) -> List[ParsedEvent]:
    """
    使用 LangChain + OpenAI 解析文字中的日程信息
    
    Args:
        text: 输入文字
        additional_note: 补充说明
        
    Returns:
        解析出的事件列表
    """
    start_time = time.time()
    logger.debug(f"Starting LLM text parsing (text_length={len(text)})")
    
    try:
        llm = get_llm()
        parser = JsonOutputParser(pydantic_object=EventExtractionList)
        
        # 构建 prompt
        current_time = datetime.now().isoformat()
        prompt = TEXT_PARSE_PROMPT.format_messages(
            current_time=current_time,
            text=text,
            additional_note=additional_note or "",
        )
        
        logger.debug(f"Calling LLM API (model={settings.OPENAI_MODEL})")
        
        # 调用 LLM
        chain = prompt | llm | parser
        result = chain.invoke({})
        
        elapsed = time.time() - start_time
        logger.info(f"LLM API call completed in {elapsed:.2f}s")
        
        # 转换为 ParsedEvent
        events = _convert_to_parsed_events(result, source_type="text")
        
        logger.info(f"LLM text parsing completed: {len(events)} event(s) extracted")
        return events
    
    except Exception as e:
        elapsed = time.time() - start_time
        logger.error(f"LLM text parsing failed after {elapsed:.2f}s: {e}", exc_info=True)
        return []


# ============================================================================
# Image Parsing
# ============================================================================

def parse_image_with_llm(
    image_base64: str,
    additional_note: Optional[str] = None,
) -> List[ParsedEvent]:
    """
    使用 LangChain + OpenAI Vision 解析图片中的日程信息
    
    Args:
        image_base64: Base64 编码的图片
        additional_note: 补充说明
        
    Returns:
        解析出的事件列表
    """
    start_time = time.time()
    logger.debug(f"Starting LLM image parsing (base64_length={len(image_base64)})")
    
    try:
        llm = get_llm()
        parser = JsonOutputParser(pydantic_object=EventExtractionList)
        
        # 构建系统消息
        current_time = datetime.now().isoformat()
        system_message = IMAGE_PARSE_SYSTEM_PROMPT.format(current_time=current_time)
        
        # 构建用户消息（多模态）
        user_content = [
            {
                "type": "image_url",
                "image_url": {
                    "url": f"data:image/jpeg;base64,{image_base64}",
                },
            },
            {
                "type": "text",
                "text": f"补充说明：{additional_note or '无'}",
            },
        ]
        
        # 创建消息
        messages = [
            ("system", system_message),
            HumanMessage(content=user_content),
        ]
        
        logger.debug(f"Calling LLM Vision API (model={settings.OPENAI_MODEL})")
        
        # 调用 LLM（支持 Vision）
        response = llm.invoke(messages)
        
        elapsed = time.time() - start_time
        logger.info(f"LLM Vision API call completed in {elapsed:.2f}s")
        
        # 解析 JSON 响应
        result = parser.parse(response.content)
        
        # 转换为 ParsedEvent
        events = _convert_to_parsed_events(result, source_type="image")
        
        logger.info(f"LLM image parsing completed: {len(events)} event(s) extracted")
        return events
    
    except Exception as e:
        elapsed = time.time() - start_time
        logger.error(f"LLM image parsing failed after {elapsed:.2f}s: {e}", exc_info=True)
        return []


# ============================================================================
# Helper Functions
# ============================================================================

def _convert_to_parsed_events(
    result: dict,
    source_type: str,
) -> List[ParsedEvent]:
    """
    将 LLM 响应转换为 ParsedEvent 列表
    
    Args:
        result: LLM 解析结果
        source_type: 来源类型 (text/image)
        
    Returns:
        ParsedEvent 列表
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
            # 跳过格式错误的事件
            logger.warning(f"Skipping invalid event data at index {idx}: {e}")
            continue
    
    return events
