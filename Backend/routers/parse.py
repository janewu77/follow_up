"""
日程解析路由 - /api/parse

TODO: 实现真实的 LangChain + OpenAI 调用
"""
from fastapi import APIRouter, Depends, HTTPException, status

from schemas import ParseRequest, ParseResponse
from auth import get_current_user

router = APIRouter(tags=["日程解析"])


@router.post("/parse", response_model=ParseResponse)
async def parse_event(
    request: ParseRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    解析日程信息
    
    支持文字和图片两种输入类型：
    - text: 从文字描述中提取日程
    - image: 从图片（海报等）中识别日程
    
    TODO: 实现 LangChain + OpenAI 调用
    """
    # TODO: 实现 LangChain 文字解析
    # TODO: 实现 OpenAI Vision 图片解析
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="API not implemented yet. Use /mock/parse for development.",
    )
