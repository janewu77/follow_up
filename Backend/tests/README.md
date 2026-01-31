# 测试说明

## 测试数据库隔离

**重要：测试使用独立的内存数据库，完全不影响生产数据库。**

### 测试数据库配置

- **测试环境**：使用内存数据库 `sqlite:///:memory:`
- **生产环境**：使用文件数据库 `sqlite:///./followup.db`

### 隔离机制

测试数据库完全隔离，通过以下三层保护：

1. **环境变量检测**：`conftest.py` 在导入任何模块之前设置 `TESTING=1`
2. **配置覆盖**：`config.py` 检测到 `TESTING=1` 时，自动将 `DATABASE_URL` 设置为 `sqlite:///:memory:`
3. **依赖注入覆盖**：`conftest.py` 中的 `client` fixture 覆盖 `get_db()` 依赖，强制所有 API 调用使用测试数据库会话

### 测试流程

```python
# 1. conftest.py 设置 TESTING=1（在导入任何模块之前）
os.environ["TESTING"] = "1"

# 2. config.py 检测到 TESTING=1，使用内存数据库
settings.DATABASE_URL = "sqlite:///:memory:"

# 3. conftest.py 创建独立的测试数据库引擎
test_engine = create_engine("sqlite:///:memory:")

# 4. db fixture 创建测试数据库表和测试数据
Base.metadata.create_all(bind=test_engine)
# ... 创建测试用户 ...

# 5. client fixture 覆盖 get_db()，确保所有 API 调用使用测试数据库
app.dependency_overrides[get_db] = override_get_db
```

### 运行测试

```bash
# 运行所有测试
cd Backend
python -m pytest tests/ -v

# 或使用脚本
python ../scripts/run_tests.py

# 运行特定测试
python -m pytest tests/test_parse.py -v
```

### 隔离保证

- ✅ **内存数据库**：测试使用 `sqlite:///:memory:`，数据仅存在于内存中
- ✅ **自动清理**：每个测试函数结束后，数据库表自动删除
- ✅ **独立实例**：每个测试函数都有全新的数据库实例
- ✅ **无文件操作**：测试不会创建或修改任何文件数据库
- ✅ **生产保护**：生产数据库 `followup.db` 完全不受影响

### 验证测试隔离

可以通过以下方式验证测试不会影响生产数据库：

1. **检查生产数据库文件**：
   ```bash
   # 运行测试前
   ls -lh Backend/followup.db
   
   # 运行测试
   python scripts/run_tests.py
   
   # 运行测试后，文件大小和修改时间应该不变
   ls -lh Backend/followup.db
   ```

2. **检查数据库内容**：
   ```bash
   # 使用 sqlite3 查看生产数据库
   sqlite3 Backend/followup.db "SELECT COUNT(*) FROM users;"
   
   # 运行测试后，用户数量应该不变
   ```

3. **环境变量验证**：
   ```python
   # 测试环境
   import os
   os.environ["TESTING"] = "1"
   from config import settings
   print(settings.DATABASE_URL)  # 输出: sqlite:///:memory:
   
   # 生产环境
   import os
   if "TESTING" in os.environ:
       del os.environ["TESTING"]
   from config import settings
   print(settings.DATABASE_URL)  # 输出: sqlite:///./followup.db
   ```

### 测试数据库结构

测试数据库会在每个测试函数开始时自动创建以下表：
- `users` - 用户表（包含测试用户：alice, bob, jane, xiao, moni）
- `events` - 活动表

所有测试数据在测试结束后自动清理，不会影响生产数据库。
