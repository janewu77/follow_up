"""
事件提取相关的 Prompts

包含文本解析和图像解析的提示词模板。
"""
from typing import List, Optional
from langchain_core.prompts import ChatPromptTemplate

try:
    from langchain_core.pydantic_v1 import BaseModel, Field
except ImportError:
    from pydantic import BaseModel, Field


# ============================================================================
# Pydantic Models for Structured Output
# ============================================================================

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


# ============================================================================
# Text Parsing Prompt
# ============================================================================

TEXT_PARSE_SYSTEM = """你是一个智能日程助手，擅长从自然语言文本中提取日程信息。

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

如果文本中没有明确的日程信息，返回空数组。"""

TEXT_PARSE_USER = "用户输入：{text}\n补充说明：{additional_note}"

TEXT_PARSE_PROMPT = ChatPromptTemplate.from_messages([
    ("system", TEXT_PARSE_SYSTEM),
    ("user", TEXT_PARSE_USER),
])


# ============================================================================
# Image Parsing Prompt
# ============================================================================

IMAGE_PARSE_SYSTEM_PROMPT = """你是一个智能日程助手，擅长从图片（如海报、传单、截图）中识别日程信息。

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

如果图片中没有明确的日程信息，返回空数组。"""
