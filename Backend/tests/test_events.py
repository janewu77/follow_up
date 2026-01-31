"""
活动管理相关测试
"""
import pytest
from datetime import datetime, timedelta
from fastapi import status


@pytest.fixture
def event_data():
    """测试活动数据"""
    return {
        "title": "测试会议",
        "start_time": (datetime.now() + timedelta(days=1)).isoformat(),
        "end_time": (datetime.now() + timedelta(days=1, hours=2)).isoformat(),
        "location": "会议室 A",
        "description": "这是一个测试会议",
        "source_type": "text",
        "is_followed": True,
    }


def test_create_event_success(client, test_user, event_data):
    """测试创建活动（成功）"""
    response = client.post(
        "/api/events",
        json=event_data,
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["title"] == event_data["title"]
    assert data["location"] == event_data["location"]
    assert data["is_followed"] == event_data["is_followed"]
    assert "id" in data
    assert "created_at" in data


def test_create_event_no_auth(client, event_data):
    """测试创建活动（无认证）"""
    response = client.post("/api/events", json=event_data)
    assert response.status_code == status.HTTP_401_UNAUTHORIZED


def test_list_events_success(client, test_user, event_data):
    """测试获取活动列表（成功）"""
    # 先创建一个活动
    create_response = client.post(
        "/api/events",
        json=event_data,
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert create_response.status_code == status.HTTP_201_CREATED

    # 获取列表
    response = client.get(
        "/api/events",
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "events" in data
    assert len(data["events"]) >= 1


def test_list_events_followed_only(client, test_user, event_data):
    """测试获取已 Follow 的活动列表"""
    # 创建一个已 Follow 的活动
    event_data["is_followed"] = True
    create_response = client.post(
        "/api/events",
        json=event_data,
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert create_response.status_code == status.HTTP_201_CREATED

    # 创建一个未 Follow 的活动
    event_data["is_followed"] = False
    event_data["title"] = "未 Follow 的活动"
    create_response2 = client.post(
        "/api/events",
        json=event_data,
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert create_response2.status_code == status.HTTP_201_CREATED

    # 获取仅已 Follow 的活动
    response = client.get(
        "/api/events?followed_only=true",
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert all(event["is_followed"] for event in data["events"])


def test_get_event_by_id_success(client, test_user, event_data):
    """测试获取单个活动（成功）"""
    # 创建活动
    create_response = client.post(
        "/api/events",
        json=event_data,
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    event_id = create_response.json()["id"]

    # 获取活动
    response = client.get(
        f"/api/events/{event_id}",
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["id"] == event_id
    assert data["title"] == event_data["title"]


def test_get_event_not_found(client, test_user):
    """测试获取不存在的活动"""
    response = client.get(
        "/api/events/99999",
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_update_event_success(client, test_user, event_data):
    """测试更新活动（成功）"""
    # 创建活动
    create_response = client.post(
        "/api/events",
        json=event_data,
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    event_id = create_response.json()["id"]

    # 更新活动
    update_data = {
        "title": "更新后的标题",
        "is_followed": False,
    }
    response = client.put(
        f"/api/events/{event_id}",
        json=update_data,
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["title"] == update_data["title"]
    assert data["is_followed"] == update_data["is_followed"]


def test_delete_event_success(client, test_user, event_data):
    """测试删除活动（成功）"""
    # 创建活动
    create_response = client.post(
        "/api/events",
        json=event_data,
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    event_id = create_response.json()["id"]

    # 删除活动
    response = client.delete(
        f"/api/events/{event_id}",
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_204_NO_CONTENT

    # 验证已删除
    get_response = client.get(
        f"/api/events/{event_id}",
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert get_response.status_code == status.HTTP_404_NOT_FOUND


def test_download_ics_success(client, test_user, event_data):
    """测试下载 ICS 文件（成功）"""
    # 创建活动
    create_response = client.post(
        "/api/events",
        json=event_data,
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    event_id = create_response.json()["id"]

    # 下载 ICS
    response = client.get(
        f"/api/events/{event_id}/ics",
        headers={"Authorization": f"Bearer {test_user['token']}"},
    )
    assert response.status_code == status.HTTP_200_OK
    assert "text/calendar" in response.headers["content-type"]
    assert "attachment" in response.headers["content-disposition"]
    assert b"BEGIN:VCALENDAR" in response.content
