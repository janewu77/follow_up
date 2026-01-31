"""
数据库相关测试
"""
import pytest
from datetime import datetime
from sqlalchemy.orm import Session

from models import User, Event
from init_db import init_users


def test_create_user(db: Session):
    """测试创建用户"""
    user = User(
        username="test_user",
        password="test_password",
        created_at=datetime.utcnow(),
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    assert user.id is not None
    assert user.username == "test_user"
    assert user.password == "test_password"


def test_create_event(db: Session):
    """测试创建活动"""
    # 先创建用户
    user = User(
        username="test_user",
        password="test_password",
        created_at=datetime.utcnow(),
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # 创建活动
    event = Event(
        user_id=user.id,
        title="测试活动",
        start_time=datetime(2026, 2, 1, 15, 0),
        end_time=datetime(2026, 2, 1, 17, 0),
        location="测试地点",
        description="测试描述",
        source_type="text",
        is_followed=True,
    )
    db.add(event)
    db.commit()
    db.refresh(event)

    assert event.id is not None
    assert event.user_id == user.id
    assert event.title == "测试活动"
    assert event.is_followed is True


def test_user_event_relationship(db: Session):
    """测试用户和活动的关联关系"""
    # 创建用户
    user = User(
        username="test_user",
        password="test_password",
        created_at=datetime.utcnow(),
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # 创建多个活动
    for i in range(3):
        event = Event(
            user_id=user.id,
            title=f"活动 {i+1}",
            start_time=datetime(2026, 2, 1, 10 + i, 0),
            source_type="text",
        )
        db.add(event)
    db.commit()

    # 验证关联
    assert len(user.events) == 3
    assert all(event.user_id == user.id for event in user.events)


def test_init_users(db: Session):
    """测试初始化预置用户"""
    init_users(db)

    users = db.query(User).all()
    assert len(users) == 5

    usernames = {user.username for user in users}
    assert usernames == {"alice", "bob", "jane", "xiao", "moni"}

    # 验证密码
    alice = db.query(User).filter(User.username == "alice").first()
    assert alice.password == "alice123"


def test_query_events_by_user(db: Session):
    """测试按用户查询活动"""
    # 创建两个用户
    user1 = User(username="user1", password="pass1", created_at=datetime.utcnow())
    user2 = User(username="user2", password="pass2", created_at=datetime.utcnow())
    db.add_all([user1, user2])
    db.commit()
    db.refresh(user1)
    db.refresh(user2)

    # 为每个用户创建活动
    event1 = Event(
        user_id=user1.id,
        title="User1 的活动",
        start_time=datetime(2026, 2, 1, 10, 0),
        source_type="text",
    )
    event2 = Event(
        user_id=user2.id,
        title="User2 的活动",
        start_time=datetime(2026, 2, 1, 11, 0),
        source_type="text",
    )
    db.add_all([event1, event2])
    db.commit()

    # 查询 user1 的活动
    user1_events = db.query(Event).filter(Event.user_id == user1.id).all()
    assert len(user1_events) == 1
    assert user1_events[0].title == "User1 的活动"
