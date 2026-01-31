# Services 模块

使用 LangChain + OpenAI 进行智能日程解析。

## 目录结构

```
services/
├── __init__.py
├── README.md
├── llm_service.py      # LLM 服务：初始化、API 调用、响应转换
└── prompts/            # Prompts 目录：管理所有提示词
    ├── __init__.py
    └── event_extraction.py  # 事件提取相关的 prompts
```

## 配置

在 `.env` 文件中设置：

```bash
OPENAI_API_KEY=sk-xxx
OPENAI_MODEL=gpt-4o-mini  # 可选，默认使用 gpt-4o-mini
```

## 功能

### 文字解析 (`parse_text_with_llm`)

从自然语言文本中提取日程信息：

```python
from services.llm_service import parse_text_with_llm

events = parse_text_with_llm(
    text="明天下午3点在星巴克开会",
    additional_note="记得带电脑"
)
```

### 图片解析 (`parse_image_with_llm`)

从图片（海报、传单等）中识别日程信息：

```python
from services.llm_service import parse_image_with_llm

events = parse_image_with_llm(
    image_base64="iVBORw0KGgo...",  # Base64 编码的图片
    additional_note="朋友推荐"
)
```

## Prompts 管理

所有 LLM 提示词都放在 `prompts/` 目录下，便于维护和优化：

```python
# 导入 prompts
from services.prompts import TEXT_PARSE_PROMPT, IMAGE_PARSE_SYSTEM_PROMPT

# 使用 prompt
prompt = TEXT_PARSE_PROMPT.format_messages(
    current_time="2026-02-01T10:00:00",
    text="明天下午3点开会",
    additional_note=""
)
```

### 添加新的 Prompt

1. 在 `prompts/` 目录下创建新文件或在现有文件中添加
2. 在 `prompts/__init__.py` 中导出
3. 在 `llm_service.py` 中使用

## Fallback 机制

如果 LLM 不可用（API Key 未设置或调用失败），系统会自动使用简单的关键词匹配作为 fallback，确保服务始终可用。

## 依赖

- `langchain>=0.3.0`
- `langchain-openai>=0.2.0`

## 更新依赖

```bash
uv sync
# 或
pip install -U langchain langchain-openai
```
