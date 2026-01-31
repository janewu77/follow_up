"""
FollowUP Backend - FastAPI Application

路由结构：
- /api/*   - 真实 API（使用数据库 + LLM）
- /mock/*  - Mock API（内存存储 + 模拟数据，用于前端开发）
"""
import os
from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

# 导入路由
from routers import api_router, mock_router

app = FastAPI(
    title="FollowUP API",
    description="智能日程助手 - 从任意输入智能提取日程",
    version="0.1.0"
)

# CORS 配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境应限制具体域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册真实 API 路由 (/api/*)
app.include_router(api_router)

# 注册 Mock API 路由 (/mock/*)
app.include_router(mock_router)


@app.get("/api/health")
async def health_check():
    """健康检查端点"""
    return {"status": "healthy"}


# Flutter Web 静态文件托管
# 构建后的文件在 Frontend/followup/build/web 目录
FLUTTER_WEB_DIR = Path(__file__).parent.parent / "Frontend" / "followup" / "build" / "web"

if FLUTTER_WEB_DIR.exists():
    # 挂载静态文件（CSS, JS, images 等）
    app.mount("/static", StaticFiles(directory=FLUTTER_WEB_DIR), name="static")
    
    @app.get("/{full_path:path}")
    async def serve_flutter(full_path: str):
        """提供 Flutter Web 页面"""
        # 如果是 API 路由，跳过
        if full_path.startswith("api/"):
            return {"error": "Not found"}
        
        # 尝试返回请求的文件
        file_path = FLUTTER_WEB_DIR / full_path
        if file_path.exists() and file_path.is_file():
            return FileResponse(file_path)
        
        # 否则返回 index.html（SPA 路由支持）
        return FileResponse(FLUTTER_WEB_DIR / "index.html")
else:
    @app.get("/")
    async def root():
        """API 根路径 - Flutter Web 未构建时的提示"""
        return {
            "status": "ok",
            "message": "FollowUP API is running!",
            "docs": "/docs",
            "note": "Flutter Web not built yet. Run: cd Frontend/followup && flutter build web",
            "version": "0.1.0",
            "api_endpoints": {
                "auth": "POST /api/auth/login",
                "user": "GET /api/user/me",
                "parse": "POST /api/parse",
                "events": "GET/POST /api/events",
                "health": "GET /api/health",
            },
            "mock_endpoints": {
                "auth": "POST /mock/auth/login",
                "user": "GET /mock/user/me",
                "parse": "POST /mock/parse",
                "events": "GET/POST /mock/events",
            },
        }


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
