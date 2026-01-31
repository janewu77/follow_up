# FollowUP - Multi-stage build
# Stage 1: 构建 Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build

WORKDIR /app
COPY Frontend/followup ./Frontend/followup

WORKDIR /app/Frontend/followup
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Python 运行环境
FROM python:3.11-slim

WORKDIR /app

# 复制后端代码
COPY Backend ./Backend

# 复制 Flutter Web 构建产物
COPY --from=flutter-build /app/Frontend/followup/build/web ./Frontend/followup/build/web

# 安装 Python 依赖
RUN pip install --no-cache-dir -r Backend/requirements.txt

# 设置环境变量
ENV PORT=8000

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["sh", "-c", "cd Backend && uvicorn main:app --host 0.0.0.0 --port $PORT"]
