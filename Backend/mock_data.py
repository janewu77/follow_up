"""
Mock Data - 内存存储用于开发测试
"""
from datetime import datetime, timedelta
from typing import Dict, List, Any

# 预置用户
USERS: Dict[str, Dict[str, Any]] = {
    "alice": {
        "id": 1,
        "username": "alice",
        "password": "alice123",
        "created_at": datetime(2026, 1, 1, 10, 0, 0),
    },
    "bob": {
        "id": 2,
        "username": "bob",
        "password": "bob123",
        "created_at": datetime(2026, 1, 1, 10, 0, 0),
    },
    "jane": {
        "id": 3,
        "username": "jane",
        "password": "jane123",
        "created_at": datetime(2026, 1, 1, 10, 0, 0),
    },
    "xiao": {
        "id": 4,
        "username": "xiao",
        "password": "xiao123",
        "created_at": datetime(2026, 1, 1, 10, 0, 0),
    },
}

# 内存活动存储 (user_id -> list of events)
EVENTS_STORE: Dict[int, List[Dict[str, Any]]] = {}

# 活动 ID 计数器
_event_id_counter = 0


def get_next_event_id() -> int:
    """获取下一个活动 ID"""
    global _event_id_counter
    _event_id_counter += 1
    return _event_id_counter


def get_user_by_username(username: str) -> Dict[str, Any] | None:
    """根据用户名获取用户"""
    return USERS.get(username)


def get_user_by_id(user_id: int) -> Dict[str, Any] | None:
    """根据 ID 获取用户"""
    for user in USERS.values():
        if user["id"] == user_id:
            return user
    return None


def get_events_by_user(user_id: int, followed_only: bool = False) -> List[Dict[str, Any]]:
    """获取用户的活动列表"""
    events = EVENTS_STORE.get(user_id, [])
    if followed_only:
        return [e for e in events if e.get("is_followed", False)]
    return events


def add_event(user_id: int, event_data: Dict[str, Any]) -> Dict[str, Any]:
    """添加活动"""
    if user_id not in EVENTS_STORE:
        EVENTS_STORE[user_id] = []
    
    event = {
        "id": get_next_event_id(),
        "user_id": user_id,
        "created_at": datetime.utcnow(),
        **event_data,
    }
    EVENTS_STORE[user_id].append(event)
    return event


def get_event_by_id(user_id: int, event_id: int) -> Dict[str, Any] | None:
    """获取单个活动"""
    events = EVENTS_STORE.get(user_id, [])
    for event in events:
        if event["id"] == event_id:
            return event
    return None


def update_event(user_id: int, event_id: int, update_data: Dict[str, Any]) -> Dict[str, Any] | None:
    """更新活动"""
    events = EVENTS_STORE.get(user_id, [])
    for i, event in enumerate(events):
        if event["id"] == event_id:
            events[i] = {**event, **update_data}
            return events[i]
    return None


def delete_event(user_id: int, event_id: int) -> bool:
    """删除活动"""
    events = EVENTS_STORE.get(user_id, [])
    for i, event in enumerate(events):
        if event["id"] == event_id:
            events.pop(i)
            return True
    return False


# 初始化一些示例活动
def init_sample_events():
    """初始化示例活动数据"""
    # Alice 的示例活动
    add_event(1, {
        "title": "汉堡爱乐音乐会",
        "start_time": datetime(2026, 2, 15, 19, 30),
        "end_time": datetime(2026, 2, 15, 22, 0),
        "location": "Elbphilharmonie, Hamburg",
        "description": "贝多芬第九交响曲",
        "source_type": "image",
        "is_followed": True,
    })
    add_event(1, {
        "title": "同学聚餐",
        "start_time": datetime(2026, 2, 8, 19, 0),
        "end_time": None,
        "location": "老地方川菜馆",
        "description": "大学同学聚会",
        "source_type": "text",
        "is_followed": True,
    })
    add_event(1, {
        "title": "项目评审会议",
        "start_time": datetime(2026, 2, 5, 14, 0),
        "end_time": datetime(2026, 2, 5, 16, 0),
        "location": "公司会议室 A",
        "description": "Q1 项目进度评审",
        "source_type": "text",
        "is_followed": False,
    })


# 应用启动时初始化示例数据
init_sample_events()
