#!/bin/bash
# FollowUP 构建脚本

echo "=== Building Flutter Web ==="
cd Frontend/followup
flutter build web --release

echo "=== Build complete ==="
echo "Flutter Web build output: Frontend/followup/build/web"
