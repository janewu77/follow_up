"""
Mock 日程解析路由 - /mock/parse

Mock 实现：不调用真实 LLM，返回模拟数据
"""
import uuid
import re
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status

from schemas import ParseRequest, ParseResponse, ParsedEvent
from auth import get_current_user

router = APIRouter(tags=["Mock-日程解析"])


def mock_parse_text(text: str, additional_note: str = None) -> list[ParsedEvent]:
    """
    模拟解析文字内容
    简单的关键词匹配，返回模拟活动
    """
    now = datetime.now()
    events = []
    
    # 简单的时间关键词识别
    if "明天" in text:
        event_date = now + timedelta(days=1)
    elif "后天" in text:
        event_date = now + timedelta(days=2)
    elif "下周" in text:
        event_date = now + timedelta(days=7)
    else:
        event_date = now + timedelta(days=3)
    
    # 简单的时间点识别
    hour = 14  # 默认下午2点
    if "上午" in text or "早上" in text:
        hour = 10
    elif "下午" in text:
        hour = 14
    elif "晚上" in text:
        hour = 19
    
    # 尝试提取具体时间
    time_match = re.search(r'(\d{1,2})[点时]', text)
    if time_match:
        hour = int(time_match.group(1))
        if hour < 12 and ("下午" in text or "晚上" in text):
            hour += 12
    
    # 构造事件时间
    start_time = event_date.replace(hour=hour, minute=0, second=0, microsecond=0)
    
    # 提取标题（简单处理）
    title = "会议"
    if "开会" in text:
        title = "会议"
    elif "聚餐" in text or "吃饭" in text:
        title = "聚餐"
    elif "音乐会" in text:
        title = "音乐会"
    elif "演出" in text:
        title = "演出"
    elif "面试" in text:
        title = "面试"
    elif "约会" in text:
        title = "约会"
    else:
        # 取前10个字符作为标题
        title = text[:10].strip() if len(text) > 10 else text.strip()
    
    # 地点
    location = additional_note if additional_note else None
    
    events.append(ParsedEvent(
        id=None,
        title=title,
        start_time=start_time,
        end_time=None,
        location=location,
        description=text,
        source_type="text",
        is_followed=False,
    ))
    
    return events


def mock_parse_image(image_base64: str, additional_note: str = None) -> list[ParsedEvent]:
    """
    模拟解析图片内容
    直接返回预设的音乐会活动
    """
    now = datetime.now()
    
    # 模拟识别出的音乐会海报
    next_month = now.month + 1 if now.month < 12 else 1
    next_year = now.year if now.month < 12 else now.year + 1
    
    events = [
        ParsedEvent(
            id=None,
            title="汉堡爱乐乐团音乐会",
            start_time=datetime(next_year, next_month, 15, 19, 30),
            end_time=datetime(next_year, next_month, 15, 22, 0),
            location="Elbphilharmonie, Hamburg",
            description="贝多芬第九交响曲\n指挥：Alan Gilbert\n\n" + (additional_note or ""),
            source_type="image",
            is_followed=False,
        )
    ]
    
    return events


@router.post("/parse", response_model=ParseResponse)
async def parse_event(
    request: ParseRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    [Mock] 解析日程信息
    
    支持文字和图片两种输入类型：
    - text: 从文字描述中提取日程
    - image: 从图片（海报等）中识别日程
    
    Mock 实现：返回模拟数据，不调用真实 LLM
    """
    if request.input_type == "text":
        if not request.text_content:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="text_content is required for text input type",
            )
        events = mock_parse_text(request.text_content, request.additional_note)
    
    elif request.input_type == "image":
        if not request.image_base64:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="image_base64 is required for image input type",
            )
        events = mock_parse_image(request.image_base64, request.additional_note)
    
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="input_type must be 'text' or 'image'",
        )
    
    return ParseResponse(
        events=events,
        parse_id=str(uuid.uuid4()),
    )
