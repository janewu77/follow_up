"""
LLM Service - 使用 LangChain + OpenAI 进行日程解析
"""
import os
import base64
import time
from typing import List, Optional
from datetime import datetime
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import JsonOutputParser
from langchain_core.pydantic_v1 import BaseModel, Field

from schemas import ParsedEvent
from config import settings
from logging_config import get_logger

logger = get_logger(__name__)


class EventExtraction(BaseModel):
    """事件提取结果"""
    title: str = Field(description="事件标题")
    start_time: str = Field(description="开始时间，ISO 8601 格式，例如：2026-02-01T15:00:00")
    end_time: Optional[str] = Field(None, description="结束时间，ISO 8601 格式，可选")
    location: Optional[str] = Field(None, description="地点")
    description: Optional[str] = Field(None, description="事件描述")


class EventExtractionList(BaseModel):
    """事件列表"""
    events: List[EventExtraction] = Field(description="提取的事件列表")


# 初始化 LLM
def get_llm() -> ChatOpenAI:
    """获取 OpenAI LLM 实例"""
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


# 文字解析 Prompt
TEXT_PARSE_PROMPT = ChatPromptTemplate.from_messages([
    ("system", """你是一个智能日程助手，擅长从自然语言文本中提取日程信息。

请仔细分析用户输入的文字，提取出所有可能的日程事件。对于每个事件，你需要：
1. 提取事件标题
2. 推断开始时间（如果文本中没有明确时间，使用当前时间作为参考）
3. 推断结束时间（如果可能）
4. 提取地点信息（如果有）
5. 提取事件描述

当前时间：{current_time}

请以 JSON 格式返回结果，包含 events 数组，每个事件包含：
- title: 事件标题
- start_time: ISO 8601 格式的开始时间
- end_time: ISO 8601 格式的结束时间（可选）
- location: 地点（可选）
- description: 描述（可选）

如果文本中没有明确的日程信息，返回空数组。"""),
    ("user", "用户输入：{text}\n补充说明：{additional_note}"),
])




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
                    source_type="text",
                    is_followed=False,
                ))
                logger.debug(f"Parsed event {idx+1}: {event_data.get('title')} @ {event_data.get('start_time')}")
            except (KeyError, ValueError) as e:
                # 跳过格式错误的事件
                logger.warning(f"Skipping invalid event data at index {idx}: {e}")
                continue
        
        logger.info(f"LLM text parsing completed: {len(events)} event(s) extracted")
        return events
    
    except Exception as e:
        elapsed = time.time() - start_time
        logger.error(f"LLM text parsing failed after {elapsed:.2f}s: {e}", exc_info=True)
        return []


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
    try:
        llm = get_llm()
        parser = JsonOutputParser(pydantic_object=EventExtractionList)
        
        # 构建 prompt（使用多模态）
        from langchain_core.prompts import ChatPromptTemplate
        from langchain_core.messages import HumanMessage
        
        current_time = datetime.now().isoformat()
        system_message = """你是一个智能日程助手，擅长从图片（如海报、传单、截图）中识别日程信息。

请仔细分析图片内容，提取出所有可能的日程事件信息。对于每个事件，你需要：
1. 识别事件标题
2. 提取开始时间（日期和时间）
3. 提取结束时间（如果有）
4. 提取地点信息
5. 提取事件描述和其他相关信息

当前时间：{current_time}

请以 JSON 格式返回结果，包含 events 数组，每个事件包含：
- title: 事件标题
- start_time: ISO 8601 格式的开始时间
- end_time: ISO 8601 格式的结束时间（可选）
- location: 地点（可选）
- description: 描述（可选）

如果图片中没有明确的日程信息，返回空数组。""".format(current_time=current_time)
        
        user_content = [
            {
                "type": "image_url",
                "image_url": {
                    "url": f"data:image/jpeg;base64,{image_base64}",
                },
            },
            {
                "type": "text",
                "text": f"补充说明：{additional_note or ''}",
            },
        ]
        
        # 创建消息
        messages = [
            ("system", system_message),
            HumanMessage(content=user_content),
        ]
        
        # 调用 LLM（支持 Vision）
        response = llm.invoke(messages)
        
        # 解析 JSON 响应
        result = parser.parse(response.content)
        
        # 转换为 ParsedEvent
        events = []
        for event_data in result.get("events", []):
            try:
                events.append(ParsedEvent(
                    id=None,
                    title=event_data["title"],
                    start_time=datetime.fromisoformat(event_data["start_time"]),
                    end_time=datetime.fromisoformat(event_data["end_time"]) if event_data.get("end_time") else None,
                    location=event_data.get("location"),
                    description=event_data.get("description"),
                    source_type="image",
                    is_followed=False,
                ))
            except (KeyError, ValueError) as e:
                # 跳过格式错误的事件
                continue
        
        return events
    
    except Exception as e:
        # 如果 LLM 调用失败，返回空列表或使用 fallback
        print(f"LLM Vision parsing failed: {e}")
        return []
