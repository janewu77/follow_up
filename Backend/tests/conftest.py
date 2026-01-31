"""
Pytest 配置和共享 fixtures

测试使用独立的内存数据库，完全隔离生产数据库
"""
import os
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

# 设置测试环境变量（在导入任何模块之前）
os.environ["TESTING"] = "1"

# 创建测试专用引擎（使用 StaticPool 确保所有连接共享同一个内存数据库）
TEST_DATABASE_URL = "sqlite:///:memory:"
test_engine = create_engine(
    TEST_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,  # 关键：确保所有连接共享同一个内存数据库
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)

# 导入模型的 Base（在创建引擎之后）
from database import Base, get_db
from main import app
from models import User, Event


@pytest.fixture(scope="function")
def db():
    """
    创建测试数据库会话
    """
    # 创建表
    Base.metadata.create_all(bind=test_engine)
    
    db = TestingSessionLocal()
    
    # 创建测试用户
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
    """
    创建测试客户端
    """
    def override_get_db():
        try:
            yield db
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    
    with TestClient(app) as client:
        yield client
    
    app.dependency_overrides.clear()


@pytest.fixture
def test_user():
    """测试用户数据"""
    return {
        "username": "alice",
        "password": "alice123",
        "token": "alice123",
    }
