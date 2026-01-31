"""
Pytest 配置和共享 fixtures
"""
import os
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# 设置测试环境变量（在导入 app 之前）
os.environ["TESTING"] = "1"

from main import app
from database import Base, get_db

# 使用内存 SQLite 数据库进行测试
TEST_DATABASE_URL = "sqlite:///:memory:"
test_engine = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


@pytest.fixture(scope="function")
def db():
    """创建测试数据库会话"""
    # 创建表
    Base.metadata.create_all(bind=test_engine)
    db = TestingSessionLocal()
    
    # 创建测试用户
    from models import User
    from datetime import datetime
    
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
    
    try:
        yield db
    finally:
        db.close()
        # 清理表
        Base.metadata.drop_all(bind=test_engine)


@pytest.fixture(scope="function")
def client(db):
    """创建测试客户端"""
    # 覆盖 get_db 依赖，返回测试数据库会话
    def override_get_db():
        try:
            yield db
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db

    yield TestClient(app)

    # 清理
    app.dependency_overrides.clear()


@pytest.fixture
def test_user():
    """测试用户数据"""
    return {
        "username": "alice",
        "password": "alice123",
        "token": "alice123",
    }
