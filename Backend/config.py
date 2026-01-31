"""
配置管理

环境变量配置:
    DATABASE_URL: 数据库连接字符串
        - 开发环境 (SQLite): sqlite:///./followup.db
        - 生产环境 (PostgreSQL): postgresql://user:password@host:port/database
        - 示例: DATABASE_URL=postgresql://postgres:mypassword@db.example.com:5432/followup
    
    OPENAI_API_KEY: OpenAI API 密钥
    OPENAI_MODEL: 使用的模型名称 (默认: gpt-4o-mini)
"""
import os
from pathlib import Path
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """应用配置"""
    
    # 数据库配置
    # 开发环境默认使用 SQLite，生产环境通过环境变量设置 PostgreSQL
    # PostgreSQL 格式: postgresql://user:password@host:port/database
    DATABASE_URL: str = "sqlite:///./followup.db"
    
    # OpenAI API 配置
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL: str = "gpt-5.2"  # 默认使用 GPT-5.2 模型
    
    # 从环境变量读取，如果没有则使用默认值
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False


# 全局配置实例
settings = Settings()

# 测试环境强制使用内存数据库（完全隔离生产数据库）
# 这必须在 settings 创建后立即检查，确保测试不会影响生产数据库
if os.getenv("TESTING") == "1":
    settings.DATABASE_URL = "sqlite:///:memory:"

# 确保数据库文件目录存在（仅对文件数据库）
if settings.DATABASE_URL.startswith("sqlite") and not settings.DATABASE_URL.endswith(":memory:"):
    db_path = Path(settings.DATABASE_URL.replace("sqlite:///", ""))
    db_path.parent.mkdir(parents=True, exist_ok=True)
