"""
开发环境启动脚本

使用此脚本启动开发服务器，会自动配置 reload_excludes 来避免频繁重载
"""
import uvicorn
import os

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=True,
        reload_excludes=[
            "*.db",
            "*.db-wal",  # SQLite WAL 文件
            "*.db-shm",  # SQLite 共享内存文件
            "*.sqlite3",
            "*.log",
            "logs/*",
            "__pycache__/*",
            ".venv/*",
            ".git/*",
            "*.pyc",
            "*.pyo",
            "*.pyd",
            ".pytest_cache/*",
            "uv.lock",
            ".env",
        ],
        reload_includes=["*.py"],  # 只监控 Python 文件
    )
