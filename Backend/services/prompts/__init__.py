"""
Prompts 模块 - 管理 LLM 提示词

将提示词与业务逻辑分离，便于维护和优化。
"""
from .event_extraction import (
    TEXT_PARSE_PROMPT,
    IMAGE_PARSE_SYSTEM_PROMPT,
    EventExtraction,
    EventExtractionList,
)

__all__ = [
    "TEXT_PARSE_PROMPT",
    "IMAGE_PARSE_SYSTEM_PROMPT",
    "EventExtraction",
    "EventExtractionList",
]
