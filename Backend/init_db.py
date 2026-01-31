"""
数据库初始化脚本

创建表并插入预置用户数据
"""
from datetime import datetime
from sqlalchemy.orm import Session

from database import init_db, SessionLocal
from models import User, Event


def init_users(db: Session):
    """初始化预置用户"""
    # 检查用户是否已存在
    existing_users = db.query(User).count()
    if existing_users > 0:
        print("用户已存在，跳过初始化")
        return

    # 预置用户
    users_data = [
        {"username": "alice", "password": "alice123"},
        {"username": "bob", "password": "bob123"},
        {"username": "jane", "password": "jane123"},
        {"username": "xiao", "password": "xiao123"},
        {"username": "moni", "password": "moni123"},
    ]

    for user_data in users_data:
        user = User(
            username=user_data["username"],
            password=user_data["password"],
            created_at=datetime(2026, 1, 1, 10, 0, 0),
        )
        db.add(user)

    db.commit()
    print(f"✅ 已创建 {len(users_data)} 个预置用户")


def init_sample_events(db: Session):
    """初始化示例活动（可选）"""
    alice = db.query(User).filter(User.username == "alice").first()
    if not alice:
        return

    # 检查是否已有活动
    existing_events = db.query(Event).filter(Event.user_id == alice.id).count()
    if existing_events > 0:
        print("示例活动已存在，跳过初始化")
        return

    # 示例活动
    events_data = [
        {
            "title": "汉堡爱乐音乐会",
            "start_time": datetime(2026, 2, 15, 19, 30),
            "end_time": datetime(2026, 2, 15, 22, 0),
            "location": "Elbphilharmonie, Hamburg",
            "description": "贝多芬第九交响曲",
            "source_type": "image",
            "is_followed": True,
        },
        {
            "title": "同学聚餐",
            "start_time": datetime(2026, 2, 8, 19, 0),
            "end_time": None,
            "location": "老地方川菜馆",
            "description": "大学同学聚会",
            "source_type": "text",
            "is_followed": True,
        },
        {
            "title": "项目评审会议",
            "start_time": datetime(2026, 2, 5, 14, 0),
            "end_time": datetime(2026, 2, 5, 16, 0),
            "location": "公司会议室 A",
            "description": "Q1 项目进度评审",
            "source_type": "text",
            "is_followed": False,
        },
    ]

    for event_data in events_data:
        event = Event(user_id=alice.id, **event_data)
        db.add(event)

    db.commit()
    print(f"✅ 已创建 {len(events_data)} 个示例活动")


def main():
    """主函数"""
    print("🚀 初始化数据库...")
    
    # 创建表
    init_db()
    print("✅ 数据库表已创建")

    # 初始化数据
    db = SessionLocal()
    try:
        init_users(db)
        init_sample_events(db)
    finally:
        db.close()

    print("✅ 数据库初始化完成")


if __name__ == "__main__":
    main()
