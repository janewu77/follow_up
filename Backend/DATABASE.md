# 数据库使用说明

## 概述

项目已实现 SQLite + SQLAlchemy 数据库存储，替代了之前的内存存储方案。

## 文件结构

```
Backend/
├── config.py          # 配置管理（数据库 URL）
├── database.py        # SQLAlchemy 连接和会话管理
├── models.py          # 数据库模型（User, Event）
├── init_db.py         # 数据库初始化脚本
└── routers/          # 路由（已更新为使用数据库）
```

## 数据库模型

### User（用户）
- `id`: 主键
- `username`: 用户名（唯一）
- `password`: 密码（固定 Token 方案）
- `created_at`: 创建时间

### Event（活动）
- `id`: 主键
- `user_id`: 外键 -> users.id
- `title`: 活动标题
- `start_time`: 开始时间
- `end_time`: 结束时间（可空）
- `location`: 地点（可空）
- `description`: 描述（可空）
- `source_type`: 来源类型（text/image/voice/manual）
- `source_content`: 原始输入内容（可空）
- `is_followed`: 是否已 Follow
- `created_at`: 创建时间

## 初始化数据库

### 方式一：自动初始化（推荐）

应用启动时会自动创建表和预置用户：

```bash
uv run uvicorn main:app --reload
```

### 方式二：手动初始化

```bash
cd Backend
python init_db.py
```

## 配置

数据库 URL 在 `config.py` 中配置：

```python
DATABASE_URL = "sqlite:///./followup.db"  # SQLite（本地）
# DATABASE_URL = "postgresql://..."      # PostgreSQL（生产）
```

可以通过环境变量覆盖：

```bash
export DATABASE_URL="sqlite:///./followup.db"
```

## 使用数据库会话

在路由中使用 `Depends(get_db)` 获取数据库会话：

```python
from fastapi import Depends
from database import get_db
from sqlalchemy.orm import Session

@router.get("/items")
async def get_items(db: Session = Depends(get_db)):
    return db.query(Item).all()
```

## 预置用户

| Username | Password | Token |
|----------|----------|-------|
| alice | alice123 | alice123 |
| bob | bob123 | bob123 |
| jane | jane123 | jane123 |
| xiao | xiao123 | xiao123 |

## 迁移说明

### 数据存储

1. **数据持久化**：数据存储在 SQLite 文件中，重启后不会丢失
2. **API 接口**：`/api/*` 路由使用数据库存储

### 数据库文件位置

- 本地开发：`Backend/followup.db`
- 生产环境：根据 `DATABASE_URL` 配置

## 注意事项

1. **数据库文件**：`.gitignore` 已配置忽略 `*.db` 文件
2. **迁移到 PostgreSQL**：修改 `DATABASE_URL` 即可，无需修改代码
3. **数据备份**：定期备份 `followup.db` 文件

## 测试

```bash
# 测试数据库连接
python -c "from database import SessionLocal; print('OK')"

# 测试初始化
python init_db.py

# 启动服务
uv run uvicorn main:app --reload
```
