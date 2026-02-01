"""
Configuration Management

Environment Variables:
    DATABASE_URL: Database connection string
        - Development (SQLite): sqlite:///./followup.db
        - Production (PostgreSQL): postgresql://user:password@host:port/database
        - Example: DATABASE_URL=postgresql://postgres:mypassword@db.example.com:5432/followup

    OPENAI_API_KEY: OpenAI API key
    OPENAI_MODEL: Model name to use (default: gpt-5.2)
"""
import os
from pathlib import Path
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application configuration"""

    # Database configuration
    # Development defaults to SQLite, production uses PostgreSQL via env var
    # PostgreSQL format: postgresql://user:password@host:port/database
    DATABASE_URL: str = "sqlite:///./followup.db"

    # OpenAI API configuration
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL: str = "gpt-5.2"  # Default model: GPT-5.2

    # Web Search Configuration
    SERPAPI_KEY: str = ""  # SerpAPI key for Google Search
    TAVILY_API_KEY: str = ""  # Tavily API key (alternative to SerpAPI)
    ENABLE_WEB_SEARCH: bool = True  # Feature flag to enable/disable web search
    WEB_SEARCH_TIMEOUT: int = 10  # Timeout in seconds for search requests

    # Read from environment variables, use defaults if not set
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False


# Global configuration instance
settings = Settings()

# Testing environment forces in-memory database (completely isolated from production)
# This must be checked immediately after settings creation to ensure tests don't affect production
if os.getenv("TESTING") == "1":
    settings.DATABASE_URL = "sqlite:///:memory:"

# Auto-disable web search if no API keys are configured
if not settings.SERPAPI_KEY and not settings.TAVILY_API_KEY:
    settings.ENABLE_WEB_SEARCH = False

# Ensure database file directory exists (for file databases only)
if settings.DATABASE_URL.startswith("sqlite") and not settings.DATABASE_URL.endswith(":memory:"):
    db_path = Path(settings.DATABASE_URL.replace("sqlite:///", ""))
    db_path.parent.mkdir(parents=True, exist_ok=True)
