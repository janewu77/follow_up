# Session ID 维护机制

## 概述

Session ID 用于维护用户与智能 Agent 之间的多轮对话上下文。每个会话都有独立的对话历史，支持用户在不同设备或时间继续之前的对话。

## 工作机制

### 1. Session ID 生成

**首次请求（无 session_id）**：
- 如果请求中未提供 `session_id`，系统会自动生成一个 UUID v4 格式的 session_id
- 生成代码：`session_id = str(uuid.uuid4())`
- 示例：`"550e8400-e29b-41d4-a716-446655440000"`

**后续请求（有 session_id）**：
- 如果请求中提供了 `session_id`，系统会使用该 session_id 加载已有的对话历史

### 2. Session ID 存储

Session ID 存储在 `conversations` 表中：

```sql
CREATE TABLE conversations (
    id INTEGER PRIMARY KEY,
    session_id VARCHAR(100) UNIQUE NOT NULL,  -- 会话ID，全局唯一
    user_id INTEGER NOT NULL,                  -- 用户ID
    messages JSON NOT NULL,                     -- 对话消息列表
    created_at DATETIME NOT NULL,               -- 创建时间
    updated_at DATETIME NOT NULL                -- 更新时间
);
```

**关键特性**：
- `session_id` 在数据库中全局唯一（UNIQUE 约束）
- 每个用户可以有多个会话（通过 `user_id` 区分）
- 对话历史以 JSON 格式存储在 `messages` 字段中

### 3. 对话历史管理

**消息格式**：
```json
{
  "role": "user" | "assistant",
  "content": "消息内容",
  "timestamp": "2026-01-31T10:00:00.000000"
}
```

**存储逻辑**：
- 每次用户发送消息时，会先添加到对话历史
- Agent 回复后，也会添加到对话历史
- 对话历史按时间顺序存储，最多保留最近的 10 条消息（用于 prompt）

### 4. 代码流程

```python
# 1. 初始化对话记忆（routers/chat.py）
memory = ConversationMemory(
    db=db,
    user_id=current_user.id,
    session_id=request.session_id,  # 如果为 None，会自动生成
)

# 2. ConversationMemory 内部逻辑（services/agent/memory.py）
def __init__(self, db: Session, user_id: int, session_id: Optional[str] = None):
    self.session_id = session_id or str(uuid.uuid4())  # 自动生成
    self._load_or_create()  # 加载或创建会话

def _load_or_create(self):
    # 尝试加载现有会话
    self._conversation = self.db.query(Conversation).filter(
        Conversation.session_id == self.session_id,
        Conversation.user_id == self.user_id,
    ).first()
    
    # 如果不存在，创建新会话
    if self._conversation is None:
        self._conversation = Conversation(
            session_id=self.session_id,
            user_id=self.user_id,
            messages=[],
        )
        self.db.add(self._conversation)
        self.db.commit()
```

## 使用场景

### 场景 1：新对话（首次请求）

```bash
# 请求：不提供 session_id
POST /api/chat
{
  "message": "你好"
}

# 响应：返回新生成的 session_id
{
  "message": "你好！我是你的智能日程助手...",
  "intent": "chat",
  "session_id": "abc123-def456-...",  # 新生成的
  "action_result": null
}
```

### 场景 2：继续对话（多轮对话）

```bash
# 第一轮：创建日程
POST /api/chat
{
  "message": "下周三下午2点开会"
}
# 响应：session_id = "abc123-def456-..."

# 第二轮：修改日程（使用相同的 session_id）
POST /api/chat
{
  "message": "改成下午3点",
  "session_id": "abc123-def456-..."  # 使用第一轮的 session_id
}
# Agent 会理解上下文，知道要修改刚才创建的日程
```

### 场景 3：清除对话历史

```bash
DELETE /api/chat/{session_id}
# 清除指定会话的所有对话历史，但会话记录仍保留
```

## 前端维护建议

### 方案 1：本地存储（推荐）

```javascript
// 首次对话：不传 session_id
let sessionId = localStorage.getItem('chat_session_id');

if (!sessionId) {
  // 首次请求，不传 session_id
  const response = await fetch('/api/chat', {
    method: 'POST',
    body: JSON.stringify({ message: '你好' })
  });
  const data = await response.json();
  sessionId = data.session_id;
  
  // 保存到本地存储
  localStorage.setItem('chat_session_id', sessionId);
} else {
  // 后续请求：使用保存的 session_id
  const response = await fetch('/api/chat', {
    method: 'POST',
    body: JSON.stringify({ 
      message: '继续对话',
      session_id: sessionId 
    })
  });
}
```

### 方案 2：状态管理

```javascript
// React 示例
const [sessionId, setSessionId] = useState(
  localStorage.getItem('chat_session_id')
);

const sendMessage = async (message) => {
  const response = await fetch('/api/chat', {
    method: 'POST',
    body: JSON.stringify({
      message,
      session_id: sessionId || undefined  // 首次为 undefined
    })
  });
  
  const data = await response.json();
  
  // 保存 session_id（如果是新的）
  if (!sessionId && data.session_id) {
    setSessionId(data.session_id);
    localStorage.setItem('chat_session_id', data.session_id);
  }
};
```

### 方案 3：多会话管理

```javascript
// 支持多个对话会话
const sessions = {
  'default': null,      // 默认会话
  'work': null,         // 工作相关
  'personal': null      // 个人相关
};

// 切换会话时，使用对应的 session_id
const currentSession = 'work';
const sessionId = sessions[currentSession];

// 如果会话不存在，首次请求不传 session_id，然后保存返回的 session_id
```

## 安全考虑

1. **用户隔离**：每个 session_id 都与 `user_id` 绑定，用户只能访问自己的会话
2. **权限验证**：所有请求都需要认证（Bearer Token）
3. **会话验证**：系统会验证 session_id 是否属于当前用户

```python
# 自动验证用户权限（services/agent/memory.py）
self._conversation = self.db.query(Conversation).filter(
    Conversation.session_id == self.session_id,
    Conversation.user_id == self.user_id,  # 确保用户匹配
).first()
```

## 数据库查询示例

```sql
-- 查询用户的所有会话
SELECT * FROM conversations WHERE user_id = 1;

-- 查询特定会话的对话历史
SELECT messages FROM conversations 
WHERE session_id = 'abc123-def456-...' AND user_id = 1;

-- 查询最近活跃的会话
SELECT * FROM conversations 
WHERE user_id = 1 
ORDER BY updated_at DESC 
LIMIT 10;
```

## 注意事项

1. **Session ID 格式**：使用 UUID v4 格式，确保全局唯一性
2. **对话历史限制**：用于 prompt 的对话历史最多保留 10 条消息（可配置）
3. **存储大小**：JSON 字段理论上无限制，但建议定期清理旧会话
4. **会话过期**：当前实现不会自动过期，需要手动清除或实现过期策略

## 未来优化建议

1. **会话过期**：实现自动清理超过 N 天未更新的会话
2. **会话列表**：提供 API 查询用户的所有会话
3. **会话重命名**：允许用户为会话命名，方便管理
4. **消息数量限制**：限制单个会话的最大消息数量，防止数据库过大
