"""
日程解析相关测试
"""
import pytest
from fastapi import status


def test_parse_text_success(client, test_user):
    """测试解析文字（成功）"""
    response = client.post(
        "/api/parse",
        json={
            "input_type": "text",
            "text_content": "明天下午3点开会",
            "additional_note": "在会议室",
        },
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "events" in data
    assert len(data["events"]) > 0
    assert "parse_id" in data
    event = data["events"][0]
    assert "title" in event
    assert "start_time" in event
    assert event["source_type"] == "text"


def test_parse_text_no_content(client, test_user):
    """测试解析文字（缺少内容）"""
    response = client.post(
        "/api/parse",
        json={
            "input_type": "text",
            "text_content": None,
        },
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_parse_image_success(client, test_user):
    """测试解析图片（API 正常响应）"""
    # 使用一个简单的 base64 图片（1x1 透明 PNG）
    # 注意：LLM 无法从这个空白图片中提取日程信息，会返回空列表
    # 这个测试只验证 API 能正常响应，不验证必须返回事件
    image_base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
    
    response = client.post(
        "/api/parse",
        json={
            "input_type": "image",
            "image_base64": image_base64,
            "additional_note": "朋友推荐",
        },
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "events" in data
    assert "parse_id" in data
    # 空白图片可能返回空列表，这是正常的
    assert isinstance(data["events"], list)


def test_parse_image_no_content(client, test_user):
    """测试解析图片（缺少内容）"""
    response = client.post(
        "/api/parse",
        json={
            "input_type": "image",
            "image_base64": None,
        },
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_parse_invalid_type(client, test_user):
    """测试解析（无效类型）"""
    response = client.post(
        "/api/parse",
        json={
            "input_type": "invalid_type",
            "text_content": "测试",
        },
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    # Pydantic 验证失败返回 422，API 逻辑验证失败返回 400
    assert response.status_code in [status.HTTP_400_BAD_REQUEST, status.HTTP_422_UNPROCESSABLE_ENTITY]


def test_parse_no_auth(client):
    """测试解析（无认证）"""
    response = client.post(
        "/api/parse",
        json={
            "input_type": "text",
            "text_content": "测试",
        },
    )
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
