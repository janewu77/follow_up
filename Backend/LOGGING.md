# 日志配置说明

## 概述

FollowUP Backend 使用 Python 标准 `logging` 模块进行日志记录，提供详细的请求、响应、数据库操作和 LLM 调用日志。

## 日志级别

- **DEBUG**: 详细的调试信息（函数调用、参数值等）
- **INFO**: 一般信息（请求处理、操作成功等）
- **WARNING**: 警告信息（失败的操作、降级处理等）
- **ERROR**: 错误信息（异常、失败等）
- **CRITICAL**: 严重错误（系统级错误）

## 日志输出

### 控制台输出
- 格式：`时间 | 级别 | 消息`
- 级别：由 `LOG_LEVEL` 环境变量控制（默认：INFO）

### 文件输出
- 位置：`Backend/logs/app_YYYYMMDD.log`
- 格式：`时间 | 级别 | 模块名 | 函数名:行号 | 消息`
- 级别：DEBUG（记录所有日志）

## 环境变量配置

```bash
# 日志级别（DEBUG, INFO, WARNING, ERROR, CRITICAL）
LOG_LEVEL=INFO

# 日志文件路径（可选，默认：Backend/logs/app_YYYYMMDD.log）
LOG_FILE=/path/to/logfile.log

# 是否启用文件日志（true/false，默认：true）
LOG_FILE_ENABLED=true
```

## 日志内容

### 1. HTTP 请求日志
- 请求方法、路径、客户端 IP
- 查询参数
- 请求体（小于 1KB 的 POST/PUT 请求）
- 响应状态码和处理时间

### 2. 认证日志
- 登录尝试（成功/失败）
- Token 验证
- 用户认证状态

### 3. 数据库操作日志
- 数据库初始化
- 用户创建
- 事件 CRUD 操作
- 查询结果统计

### 4. LLM 调用日志
- LLM 服务可用性
- API 调用开始/完成
- 解析结果统计
- 错误和异常

### 5. 应用启动日志
- 数据库初始化
- 用户初始化
- 服务启动完成

## 示例日志

### 请求日志
```
2026-01-31 10:15:23 | INFO | main | log_requests:45 | Request: POST /api/parse | Client: 127.0.0.1 | Query: {}
2026-01-31 10:15:23 | INFO | routers.parse | parse_event:149 | Parse request from user moni: type=text, parse_id=abc-123
2026-01-31 10:15:24 | INFO | services.llm_service | parse_text_with_llm:98 | LLM API call completed in 1.23s
2026-01-31 10:15:24 | INFO | routers.parse | parse_event:175 | Parse completed: parse_id=abc-123, user=moni, events_count=1
2026-01-31 10:15:24 | INFO | main | log_requests:58 | Response: POST /api/parse | Status: 200 | Time: 1.245s
```

### 错误日志
```
2026-01-31 10:20:15 | ERROR | routers.events | create_event:89 | Failed to create event: IntegrityError(...)
2026-01-31 10:20:15 | ERROR | main | log_requests:70 | Error: POST /api/events | Exception: IntegrityError(...) | Time: 0.123s
```

## 日志文件管理

- 日志文件按日期自动创建：`app_20260131.log`
- 建议定期清理旧日志文件
- 生产环境可以使用日志轮转工具（如 `logrotate`）

## 开发建议

1. **开发环境**：使用 `LOG_LEVEL=DEBUG` 查看详细日志
2. **生产环境**：使用 `LOG_LEVEL=INFO` 或 `WARNING` 减少日志量
3. **调试问题**：查看 `logs/` 目录下的详细日志文件
4. **性能分析**：关注处理时间日志（`Time: X.XXXs`）
