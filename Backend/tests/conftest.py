"""
Pytest 配置和共享 fixtures

测试使用独立的内存数据库，完全隔离生产数据库
"""
import os
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# 设置测试环境变量（在导入任何模块之前）
# 这确保 config.py 会使用内存数据库
os.environ["TESTING"] = "1"

# 使用内存 SQLite 数据库进行测试（完全隔离，不影响生产数据库）
TEST_DATABASE_URL = "sqlite:///:memory:"
test_engine = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)

# 导入主应用和数据库（此时 config.py 已经检测到 TESTING=1，会使用内存数据库）
from main import app
from database import get_db, Base

# 导入模型（它们使用主应用的 Base）
from models import User, Event


@pytest.fixture(scope="function")
def db():
    """
    创建测试数据库会话
    
    使用独立的内存数据库，完全隔离生产数据库。
    每个测试函数都会获得一个全新的数据库实例。
    """
    # 先清理旧表（如果存在）
    Base.metadata.drop_all(bind=test_engine)
    # 创建表（使用测试引擎，不影响生产数据库）
    Base.metadata.create_all(bind=test_engine)
    
    db = TestingSessionLocal()
    
    # 创建测试用户（仅在测试数据库中存在）
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
    # 刷新以确保数据已写入
    db.flush()
    
    try:
        yield db
    finally:
        db.rollback()
        db.close()
        # 清理表（测试结束后自动清理，不影响生产数据库）
        Base.metadata.drop_all(bind=test_engine)


@pytest.fixture(scope="function")
def client(db):
    """
    创建测试客户端
    
    覆盖 get_db 依赖，确保所有 API 调用都使用测试数据库，
    而不是生产数据库。
    """
    # 覆盖 get_db 依赖，返回测试数据库会话
    # 注意：必须使用闭包捕获 db，确保每次调用都返回同一个会话
    def override_get_db():
        # 直接返回 db 会话，它已经绑定到 test_engine（内存数据库）
        # 这确保所有数据库操作都在测试数据库中，不影响生产数据库
        try:
            yield db
        finally:
            # 不关闭 db，因为它在 fixture 的 finally 中关闭
            pass

    # 覆盖依赖注入，强制使用测试数据库
    app.dependency_overrides[get_db] = override_get_db

    yield TestClient(app)

    # 清理：移除依赖覆盖，恢复默认行为
    app.dependency_overrides.clear()


@pytest.fixture
def test_user():
    """测试用户数据"""
    return {
        "username": "alice",
        "password": "alice123",
        "token": "alice123",
    }
