# FollowUP - 产品说明文档

> Hackathon 2026 · Hamburg

---

## 🎯 品牌定位

### 中文版

| 项目 | 内容 |
|------|------|
| **产品名称** | FollowUP |
| **Slogan** | 让生活中的每一个重要时刻都不被遗忘 |
| **核心理念** | Work Life Balance — 工作与生活，都值得被认真对待 |

### English Version

| Item | Content |
|------|---------|
| **Product Name** | FollowUP |
| **Slogan** | Never miss a moment that matters. |
| **Core Value** | Work Life Balance — Every meeting, every gathering, every concert deserves your presence. |
| **Tagline** | Capture any event. Add to calendar. Stay on track. |

---

## 📋 产品概述

### 一句话描述
**FollowUP — 从任意输入智能提取日程，让你专注生活，轻松实现 Work Life Balance。**

### 核心价值
现代人的生活节奏越来越快，工作会议与私人活动交织在一起。朋友发来的聚餐截图、公司的活动海报、群里的语音消息……这些重要时刻散落在各处，手动录入日历既繁琐又容易遗漏。

**FollowUP 的使命是：让你不再错过生活中的每一个重要时刻。**

我们利用 LLM 多模态能力，自动识别并提取日程信息，生成标准 ICS 文件。无论是工作还是生活，一键添加到日历，让你真正实现 Work Life Balance。

### 支持的输入类型
- 📝 文字（复制粘贴、手动输入）
- 🖼️ 图片（截图、海报、照片）
- 🎤 语音（录音、语音消息）
- 💬 平台消息（WhatsApp、Claude Bot）

### 输出形式
- 📅 ICS 日历文件（标准格式，支持所有主流日历应用）
- 🖼️ 可视化邀请图片
- 📋 邀请信息文本（方便分享）
- 🔊 背景介绍语音（针对特定活动如音乐会）

---

## 👥 目标用户画像

### 用户群体 1：繁忙的职场人士（25-40岁）

| 特征 | 描述 |
|------|------|
| **身份** | 互联网/金融/咨询行业从业者，经常加班 |
| **痛点** | 工作会议与私人活动混杂，经常漏掉朋友聚会、家庭纪念日 |
| **典型场景** | 微信群里的聚餐通知、公司团建海报、客户发来的会议邀请截图 |
| **核心需求** | 快速将碎片化的日程信息整理到日历，减少手动输入 |

### 用户群体 2：留学生 / 海外华人

| 特征 | 描述 |
|------|------|
| **身份** | 在德国/欧洲的中国留学生、工作者 |
| **痛点** | 德语/英语活动海报看不懂，欧洲日期格式（DD.MM.YYYY）不熟悉 |
| **典型场景** | 音乐会海报、大学讲座通知、社区活动传单 |
| **核心需求** | 自动识别多语言日程，转换为熟悉的格式 |

### 用户群体 3：社交活跃的年轻人（18-30岁）

| 特征 | 描述 |
|------|------|
| **身份** | 喜欢参加各种活动、派对、展览的年轻人 |
| **痛点** | 活动信息散落在 Instagram、微信、WhatsApp 等各种平台 |
| **典型场景** | 朋友发来的派对邀请截图、展览海报、演唱会信息 |
| **核心需求** | 一键保存所有感兴趣的活动，不错过任何精彩 |

---

## 🎬 使用场景故事

### 场景 1：音乐会海报识别

> **Lisa** 是一名在汉堡工作的软件工程师。朋友给她发来一张汉堡爱乐乐团的音乐会海报，全是德语，她完全看不懂。
>
> 她打开 FollowUP，拍照上传这张海报。**3 秒后**，AI 自动识别出：
> - 活动：贝多芬第九交响曲
> - 时间：2026年2月15日 19:30
> - 地点：Elbphilharmonie
>
> Lisa 点击"添加到日历"，一个 ICS 文件自动下载。她再也不用担心错过这场音乐会了。

### 场景 2：微信群聚餐通知

> 大学同学群里，有人说："**周六晚上 7 点老地方聚餐，记得来！**"
>
> **小明**截图这条消息，发给 FollowUP。AI 自动识别出：
> - 活动：大学同学聚餐
> - 时间：本周六 19:00
> - 地点：（待补充）
>
> 小明补充了餐厅地址，点击下载 ICS。再也不会因为工作太忙而忘记老同学的聚会了。

### 场景 3：语音快速记录

> **Mark** 刚结束一通电话，对方约他下周三下午讨论合作方案。
>
> 他对着手机说："**下周三下午 2 点，和张总在星巴克聊合作，记得带 PPT**"
>
> FollowUP 自动将语音转换为日程：
> - 活动：与张总聊合作
> - 时间：下周三 14:00
> - 地点：星巴克
> - 备注：记得带 PPT
>
> 一键导出，Mark 继续忙其他工作，完全不用担心遗忘这个重要会议。

### 场景 4：公司活动海报

> 公司 HR 在企业微信发了一张团建活动海报，密密麻麻写满了信息。
>
> **小王**截图上传到 FollowUP，AI 准确提取出：
> - 活动：2026 年度团建
> - 时间：3月20日 09:00 - 18:00
> - 地点：XX 度假村
> - 备注：请携带运动装备
>
> 小王不用再仔细阅读海报，日程已经妥妥地加到日历里了。

### 场景 5：模糊海报 + 智能搜索补全

> **小李**在地铁站拍了一张音乐节海报，但照片有点模糊，只能看清"Hamburg Summer Music Festival"和"August"。
>
> 她上传到 FollowUP，AI 识别出关键词后，**自动联网搜索**补全信息：
> - 活动：Hamburg Summer Music Festival 2026
> - 时间：2026年8月15-17日
> - 地点：Stadtpark Hamburg
> - 官网：https://example.com/festival
> - 票价：€49 起
>
> 小李点击"Follow 这个活动"，活动被加入她的关注列表。之后无论在手机 App 还是 Web 端，她都能随时查看这个活动的详情和更新。

### 场景 6：Follow 并持续追踪活动

> **阿杰**是个演唱会爱好者，他在 FollowUP 上 Follow 了好几个即将举办的音乐会。
>
> 每次打开 FollowUP App 或 Web，他都能看到自己关注的所有活动：
> - 按时间排序的活动列表
> - 每个活动的倒计时
> - 活动详情和相关信息
>
> 某天，他 Follow 的某个乐队演唱会更新了开票信息，FollowUP 推送提醒他："你关注的 Coldplay 演唱会明天 10:00 开票！"
>
> 阿杰再也不会错过任何他感兴趣的活动了。

---

## 🔍 竞品分析

### 现有解决方案的痛点

| 方案 | 描述 | 痛点 |
|------|------|------|
| **手动输入日历** | 用户自己打开日历 App，逐字段填写 | 繁琐、耗时、容易漏填或填错 |
| **iOS 图片识别日程** | iPhone 自带的图片文字识别 | 仅支持标准格式，无法处理复杂海报、聊天截图 |
| **Notion / 待办应用** | 手动复制粘贴到 Notion | 不能直接生成 ICS，需要手动同步到日历 |
| **智能助手（Siri/Google）** | 语音命令添加日程 | 需要用户自己组织语言，无法识别图片 |

### FollowUP 的差异化优势

| 维度 | FollowUP 优势 |
|------|---------------|
| **输入方式** | 多模态：文字 + 图片 + 语音，一个入口搞定 |
| **智能程度** | LLM 驱动，能理解复杂海报、聊天截图、口语化表达 |
| **信息补全** | 图片模糊/信息不全时，自动联网搜索补全活动详情 |
| **输出标准** | 直接生成 ICS 文件，兼容所有主流日历应用 |
| **Follow & Sync** | 主动关注活动，App/Web 端统一查看、实时同步 |
| **简单易用** | 预置账号直接体验，无需配置 API Key |
| **多语言支持** | 自动识别德语、英语、中文等多语言日程 |
| **灵活修改** | 识别后可直接编辑、选择器选择、或语音描述修改 |

---

## 🎯 功能优先级

### ⭐⭐⭐ P0 - 核心 MVP（必须完成）
> 这是最小可交付产品，确保有一个完整可演示的核心流程
>
> **开发方式：使用 Cursor / Claude Code 辅助生成代码**

| 功能 | 描述 |
|------|------|
| 文字输入识别 | 用户输入文字 → LLM 提取日程 |
| 图片输入识别 | 支持上传图片 + 附加文字补充说明，Vision API 提取 |
| 日程信息结构化 | 提取：标题、时间、地点、描述 |
| 用户局部修改 | 识别后允许用户修改：直接输入 / 日期选择器 / 语音输入自动填入 |
| ICS 文件生成 | 生成标准 iCalendar 格式文件 |
| 用户登录 | 预置账号（alice/bob/jane/xiao）登录验证 |
| 后端 LLM 调用 | 通过后端 LangChain 调用 OpenAI API |
| 客户端展示与下载 | 预览日程 + 下载 ICS 按钮 |
| 基础 UI | Flutter 简洁界面（三端适配） |

---

### ⭐⭐ P1 - 增强功能（优先完成）
> 提升产品完整度和用户体验

| 功能 | 描述 |
|------|------|
| 多条日程识别 | 一次输入识别多个日程事件，批量处理 |
| 语音输入 | 录音 → STT 转文字 → LLM 提取日程 |
| **Follow Event** | 用户可主动关注活动，在 App/Web 端统一查看已关注的活动列表 |
| **活动列表同步** | 已关注活动在客户端和 Web 端实时同步，支持倒计时展示 |

---

### ⭐ P2 - 扩展功能（时间允许再做）
> 差异化亮点，提升竞争力

| 功能 | 描述 |
|------|------|
| **智能搜索补全** | 当图片/文字信息不完整时，自动联网搜索补全活动详情（时间、地点、票价等） |
| 智能地址补全 | 模糊地址（如"XX附近的图书馆"）→ 查询具体门牌地址 |
| 图片元信息提取 | 当缺少地址/时间时，从照片 EXIF 元数据提取参考信息（拍摄时间、GPS位置） |
| 邀请图片生成 | 根据日程自动生成精美邀请图 |
| 背景介绍生成 | 音乐会等活动自动生成背景信息 |
| TTS 朗读 | 背景介绍语音版（ElevenLabs） |
| Discord 集成 | 通过 Discord Bot 接收消息并提取日程 |
| **活动更新提醒** | 当已 Follow 的活动有更新（开票、时间变更等），推送通知用户 |

---

### 💫 P3 - 未来愿景（Hackathon 后）
> 记录但不在本次实现

```mermaid
flowchart LR
    subgraph Phase1["阶段 1：智能 Follow UP"]
        Bot[后台机器人 Agent]
        Monitor[活动监控]
        Notify[实时通知]
        Bot --> Monitor --> Notify
    end

    subgraph Phase2["阶段 2：语音体验"]
        VoiceIn[语音输入]
        VoiceOut[TTS 输出]
        VoiceEdit[语音编辑]
    end

    subgraph Phase3["阶段 3：社交功能"]
        Invite[邀请朋友]
        Share[共享活动]
        Collab[协作 Follow-up]
    end

    Phase1 --> Phase2 --> Phase3
```

#### 未来路线图

| 功能 | 描述 | 备注 |
|------|------|------|
| **真正的 Follow UP** | 后台机器人 Agent 自动监控你关注的活动，自动抓取更新（开票、时间变更、新信息），发送实时通知 | 需要后台自动化基础设施，可能产生 API/计算成本 |
| **语音能力** | 完整语音交互 - 语音输入创建日程、语音编辑（"改成下午3点"）、TTS 日程摘要和提醒 | 集成 Whisper STT 和 ElevenLabs TTS |
| **邀请朋友** | 邀请朋友一起关注活动、共享活动列表、协作日历规划、群组通知 | 协调参与的社交功能 |
| WhatsApp 集成 | 通过 WhatsApp Bot 直接接收消息 | |
| Claude Bot 集成 | 对话式日程管理 | |
| 团队日历同步 | 多人协作日程 | |
| 智能提醒 | 基于日程类型的个性化提醒 | |
| 日历平台直连 | 一键同步到 Google Calendar / Outlook | |

---

## 🏗️ 技术架构

### 整体架构图

```mermaid
flowchart TB
    subgraph Frontend["Flutter 前端 (iOS/Android/Web)"]
        Landing[Landing Page 首页]
        Login[用户登录]
        InputProc["输入处理 (文字/图片/语音)"]
        Preview[日程预览与编辑]
        ICS[ICS 下载]
        FollowList[Follow Event 列表]
    end

    subgraph Backend["Python 后端 - FastAPI"]
        subgraph APILayer["API 层"]
            REST["REST API\n/api/parse\n/api/events\n/api/auth"]
            WS["WebSocket\n流式响应"]
            Auth["用户认证模块\n预置账号"]
        end

        subgraph LangChainLayer["LangChain 层"]
            Extract[日程信息提取]
            Multimodal["多模态处理\n(文字 + 图片 Vision)"]
            Prompts[Prompt 模板管理]
        end

        OpenAI["OpenAI API\n(GPT-4o / GPT-4o-mini / Whisper)"]

        subgraph ORM["SQLAlchemy ORM"]
            Users[(users 表)]
            Events[(events 表)]
        end
    end

    subgraph Database["数据库"]
        SQLite["SQLite (开发)"]
        PostgreSQL["PostgreSQL (生产)"]
    end

    subgraph Deploy["部署"]
        Railway[Railway]
    end

    Frontend -->|"REST API + WebSocket"| APILayer
    APILayer --> LangChainLayer
    LangChainLayer --> OpenAI
    LangChainLayer --> ORM
    ORM --> Database
    Backend --> Deploy
```

### 技术栈详情

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| **前端** | Flutter | 一套代码，三端运行（iOS/Android/Web），包含 Landing Page |
| **前后端通信** | REST + WebSocket | REST 处理请求，WS 用于流式响应 |
| **后端框架** | Python + FastAPI | 异步、高性能、自动 API 文档 |
| **ORM** | SQLAlchemy | 支持多数据库，开发/生产环境无缝切换 |
| **数据库** | SQLite / PostgreSQL | 本地开发用 SQLite，生产环境用 PostgreSQL |
| **LLM 框架** | LangChain | Prompt 管理、结构化输出、多模态处理 |
| **LLM 服务** | OpenAI API | GPT-4o（Vision）、GPT-4o-mini、Whisper STT |
| **用户认证** | JWT Token | 预置账号，简单 Token 验证 |
| **ICS 生成** | Python icalendar 库 | 后端生成，前端下载 |
| **部署** | Railway | 后端服务 + PostgreSQL 数据库 |
| **代码管理** | GitHub | 版本控制 |

### 🗄️ 数据库配置

```python
# config.py - 数据库配置
import os

# 环境变量控制数据库选择
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "sqlite:///./followup.db"  # 默认使用 SQLite（本地开发）
)

# 生产环境设置 DATABASE_URL 为 PostgreSQL 连接字符串
# postgresql://user:password@host:port/database
```

### 🔑 前后端通信设计

```mermaid
flowchart LR
    subgraph REST["REST API"]
        Auth["POST /api/auth/login\n用户登录，返回 JWT"]
        User["GET /api/user/me\n获取当前用户信息"]
        Parse["POST /api/parse\n解析日程"]
        EventsGet["GET /api/events\n获取活动列表"]
        EventsFollow["POST /api/events/follow\nFollow 活动"]
        EventsDelete["DELETE /api/events/{id}\n取消 Follow"]
        EventsICS["GET /api/events/{id}/ics\n下载 ICS 文件"]
    end

    subgraph WS["WebSocket"]
        WSParse["WS /ws/parse\n流式返回解析进度"]
    end

    subgraph AuthMethod["认证方式"]
        Header["Header: Authorization: Bearer token"]
        WSAuth["WS: 连接时传递 token"]
    end
```

| 方法 | 端点 | 说明 |
|------|------|------|
| POST | `/api/auth/login` | 用户登录，返回 JWT Token |
| GET | `/api/user/me` | 获取当前用户信息 |
| POST | `/api/parse` | 解析日程（文字/图片） |
| GET | `/api/events` | 获取用户的活动列表 |
| POST | `/api/events/follow` | Follow 一个活动 |
| DELETE | `/api/events/{id}` | 取消 Follow |
| GET | `/api/events/{id}/ics` | 下载 ICS 文件 |
| WS | `/ws/parse` | 流式返回解析进度和结果 |

### 👤 用户认证设计

**预置用户账号（Hackathon 简化版）：**

| 用户名 | 密码 | 说明 |
|--------|------|------|
| alice | alice123 | 测试用户 1 |
| bob | bob123 | 测试用户 2 |
| jane | jane123 | 测试用户 3 |
| xiao | xiao123 | 测试用户 4 |
| moni | moni123 | 测试用户 5 |

**认证流程：**

```mermaid
sequenceDiagram
    participant 用户
    participant 前端
    participant 后端
    participant 数据库

    用户->>前端: 输入用户名 + 密码
    前端->>后端: POST /api/auth/login
    后端->>数据库: 验证凭据
    数据库-->>后端: 用户数据
    后端-->>前端: JWT Token（有效期 24h）
    前端->>前端: 本地存储 Token
    
    Note over 前端,后端: 后续请求
    前端->>后端: 请求携带 Authorization header
    后端->>后端: 验证 Token
    后端-->>前端: 响应数据
    
    Note over 用户,前端: Token 24h 后过期
    前端->>用户: 重定向到登录页
```

### 📦 数据库设计（SQLAlchemy 模型）

```python
# models.py
from sqlalchemy import Column, Integer, String, DateTime, Boolean, Text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # 关联
    events = relationship("Event", back_populates="user")


class Event(Base):
    __tablename__ = "events"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=True)
    location = Column(String(500), nullable=True)
    description = Column(Text, nullable=True)
    source_type = Column(String(50), nullable=True)  # 'text', 'image', 'voice'
    source_content = Column(Text, nullable=True)
    is_followed = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # 关联
    user = relationship("User", back_populates="events")


# 预置用户数据（在应用启动时初始化）
PRESET_USERS = [
    {"username": "alice", "password": "alice123"},
    {"username": "bob", "password": "bob123"},
    {"username": "jane", "password": "jane123"},
    {"username": "xiao", "password": "xiao123"},
    {"username": "moni", "password": "moni123"},
]
```

### 🔗 LangChain 集成

```python
# 示例：日程提取 Chain
from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate
from langchain.output_parsers import PydanticOutputParser

# 初始化 OpenAI 模型
llm = ChatOpenAI(
    model="gpt-4o-mini",
    api_key=os.getenv("OPENAI_API_KEY")
)

# 结构化输出
class EventInfo(BaseModel):
    title: str
    start_time: datetime
    end_time: Optional[datetime]
    location: Optional[str]
    description: Optional[str]

parser = PydanticOutputParser(pydantic_object=EventInfo)

# Prompt 模板
prompt = ChatPromptTemplate.from_messages([
    ("system", "你是一个日程信息提取助手..."),
    ("user", "{input}")
])

# 构建 Chain
chain = prompt | llm | parser
```

---

## 📱 核心用户流程

### 主流程

```mermaid
flowchart TD
    subgraph Input["1. 用户输入"]
        Text[粘贴文字]
        Image["上传图片 + 补充说明"]
        Voice["录制语音 (P1)"]
    end

    subgraph AIProcess["2. AI 处理"]
        Vision["Vision API 识别"]
        STT["STT 转文字 (P1)"]
        LLM["LLM 提取日程信息"]
        Address["智能地址查询 (P2)"]
    end

    subgraph Confirm["3. 用户确认与修改"]
        Display[展示提取结果]
        Edit["修改方式:\n- 直接输入\n- 日期/时间选择器\n- 语音自动填入"]
        ConfirmBtn[确认生成]
    end

    subgraph Output["4. 生成输出"]
        ICSFile[ICS 文件]
        InviteImg["邀请图片 (P2)"]
        TTS["背景介绍 + TTS (P2)"]
    end

    subgraph Actions["5. 用户操作"]
        Download[下载 ICS]
        SaveImg[保存图片]
        PlayRead[播放/阅读背景介绍]
    end

    Input --> AIProcess
    AIProcess --> Confirm
    Confirm --> Output
    Output --> Actions

    Image --> Vision
    Voice --> STT
    Text --> LLM
    STT --> LLM
    Vision --> LLM
```

### 日程数据结构

```json
{
  "events": [
    {
      "title": "汉堡爱乐乐团音乐会",
      "start_time": "2026-02-15T19:30:00+01:00",
      "end_time": "2026-02-15T22:00:00+01:00",
      "location": "Elbphilharmonie, Platz der Deutschen Einheit 1, Hamburg",
      "description": "贝多芬第九交响曲",
      "url": "https://example.com/event",
      "reminder": 60,
      "background_info": "汉堡爱乐乐团成立于1828年..."
    }
  ]
}
```

---

## 🚀 开发计划建议

### 开发阶段（使用 Cursor / Claude Code）

```mermaid
flowchart LR
    subgraph Phase1["阶段 1：环境搭建"]
        P1A[Flutter 项目初始化]
        P1B[FastAPI + SQLAlchemy]
        P1C[GitHub 仓库创建]
    end

    subgraph Phase2["阶段 2：P0 核心功能"]
        P2A[用户登录]
        P2B[Landing Page]
        P2C["输入模块 (文字/图片)"]
        P2D[LangChain + OpenAI]
        P2E[LLM 日程提取]
        P2F[用户修改界面]
        P2G[ICS 生成]
        P2H[前后端联调]
    end

    subgraph Phase3["阶段 3：P1 增强"]
        P3A[多条日程识别]
        P3B[语音输入]
        P3C[Follow Event]
        P3D[活动列表同步]
    end

    subgraph Phase4["阶段 4：收尾"]
        P4A[Bug 修复 + UI 美化]
        P4B[Railway 部署]
        P4C[演示准备]
    end

    Phase1 --> Phase2 --> Phase3 --> Phase4
```

### 灵活裁剪策略（24 小时版）

| 进度状态 | 建议策略 |
|----------|----------|
| **时间紧张**（12h 后 P0 未完成） | 极简 MVP：文字输入 + 后端 LLM + ICS 生成 |
| **正常进度**（12h 内 P0 完成） | 完整 P0：文字 + 图片 + 用户修改 + 登录 |
| **进度顺利**（18h 内一切就绪） | P0 + 简单优化：UI 美化、多条日程识别 |
| **超预期顺利** | 可尝试 P1 的 Follow Event 简化版 |

> **24 小时核心原则**：宁可功能少但稳定，不要功能多但崩溃。Demo 效果 > 功能数量。

---

## 🌐 Landing Page（集成在 Flutter 中）

### 页面目标
产品首页，作为 Flutter Web 应用的入口页面，用于 Hackathon 展示和用户引流。

> **注意**：Landing Page 集成在 Flutter 项目中，不单独创建项目。用户访问 Web 应用首先看到 Landing Page，点击 CTA 按钮后进入登录/主功能页面。

### 页面结构

```mermaid
flowchart TD
    subgraph Hero["Hero Section - 首屏"]
        Name[产品名称 + Slogan]
        Value[一句话价值描述]
        CTA["CTA 按钮：开始使用 / Try Now"]
        Screenshots[产品截图 / 动画演示]
    end

    subgraph Features["Features Section - 功能亮点"]
        F1["多模态输入\n(图片 + 文字 + 语音)"]
        F2[AI 智能识别]
        F3[一键导出 ICS]
        F4[跨平台同步]
    end

    subgraph HowItWorks["How It Works - 使用流程"]
        S1["Step 1: 上传 / 粘贴 / 说话"]
        S2["Step 2: AI 提取日程信息"]
        S3["Step 3: 编辑与确认"]
        S4["Step 4: 添加到日历"]
        S1 --> S2 --> S3 --> S4
    end

    subgraph Footer["Footer"]
        GitHub[GitHub 链接]
        Team[团队信息]
        Hackathon[Hackathon 2026 Hamburg]
    end

    Hero --> Features --> HowItWorks --> Footer
```

### 实现方式

由于 Landing Page 集成在 Flutter 中：
- 使用 Flutter 的 `ScrollView` + `Column` 布局
- 响应式设计使用 `LayoutBuilder` 或 `MediaQuery`
- 动画效果使用 Flutter 内置动画
- 点击 CTA 按钮后使用 `Navigator` 跳转到登录页

### 关键要素

- **响应式设计**：适配手机和电脑（Flutter 原生支持）
- **快速加载**：Flutter Web 首屏优化
- **CTA 突出**：引导用户登录使用
- **视觉吸引**：简洁现代，配合产品截图/GIF

---

## 🎨 界面设计要点

### 输入页
- 文字输入框（支持粘贴）
- 图片上传区 + 补充说明输入框
- 录音按钮（P1）
- LLM 选择（下拉菜单：OpenAI / Gemini / Claude）
- API Key 输入（可选，折叠显示）

### 结果编辑页
- 日程卡片式展示
- 每个字段可点击编辑：
  - **标题**：直接输入
  - **日期**：日期选择器 或 语音输入
  - **时间**：时间选择器 或 语音输入
  - **地点**：输入框 + 智能补全建议 或 语音输入
  - **描述**：文本输入
- 🎤 语音修改按钮（点击后说话，自动识别并填入对应字段）
- 地址智能提示（模糊地址 → 显示具体门牌建议）（P2）

### 操作按钮组
- 📥 下载 ICS
- 🖼️ 生成邀请图（P2）
- 📋 复制邀请文本
- 🔊 播放背景介绍（P2）

---

## 💡 差异化亮点

1. **开箱即用** — 预置账号直接体验，无需配置 API Key
2. **多模态输入** — 文字、图片（+补充说明）、语音（P1），一个入口搞定
3. **多平台支持** — Flutter 构建，iOS/Android/Web 三端统一体验
4. **灵活的修改方式** — 识别后可直接输入、选择器选择、或语音描述自动填入
5. **LangChain 驱动** — 结构化输出，识别准确稳定
6. **实时反馈** — WebSocket 流式返回，体验流畅
7. **Follow Event** — 主动关注感兴趣的活动，App/Web 端统一查看，不再遗忘（P1）
8. **智能搜索补全** — 图片模糊/信息不全？自动联网搜索补全活动详情（P2）
9. **智能地址补全** — 模糊描述（如"XX附近的图书馆"）→ 自动查询具体门牌（P2）
10. **图片元数据利用** — 缺少信息时，从照片 EXIF 提取拍摄时间、GPS 位置作为参考（P2）
11. **一键生成邀请** — 社交分享友好（P2）
12. **活动更新提醒** — Follow 的活动有更新时，主动推送通知（P2）

---

## 🎤 演示与 Pitch

### Elevator Pitch（30 秒）

> "你有没有这样的经历？朋友发来一张活动海报，你想加到日历，但又懒得一个个字段去输入。FollowUP 解决的就是这个问题——拍照、粘贴、或者直接说一句话，AI 自动提取日程，一键添加到日历。让你专注于生活本身，不再错过任何重要时刻。"

### 完整 Pitch（2 分钟）

**开场：痛点共鸣（20秒）**
> "现代人的生活节奏越来越快。工作会议、朋友聚会、音乐会、家庭纪念日……这些重要时刻散落在微信群、邮件、海报各处。我们想加到日历，但手动输入太麻烦，结果就是——很多活动，我们说好了要去，最后却忘了。"

**解决方案：产品介绍（30秒）**
> "FollowUP 是一个智能日程助手。无论是德语海报、微信群截图、还是语音消息，只需要上传或说一句话，AI 就能自动识别日程信息，生成标准的 ICS 文件，一键导入到任何日历应用。"

**技术亮点（30秒）**
> "我们的产品有几个独特之处：
> 1. **多模态输入**：文字、图片、语音，一个入口搞定
> 2. **开箱即用**：预置账号直接体验，无需任何配置
> 3. **三端统一**：Flutter 构建，iOS、Android、Web 体验一致
> 4. **灵活修改**：识别后可以直接编辑，或者用语音说'改成下午 3 点'，自动更新"

**愿景与价值（20秒）**
> "我们的愿景是帮助用户实现真正的 Work Life Balance。工作会议要准时参加，朋友聚会也不能错过。FollowUP 让你专注于生活本身，我们来负责记住那些重要时刻。"

**收尾（20秒）**
> "FollowUP——让生活中的每一个重要时刻都不被遗忘。谢谢大家！"

### Demo 演示脚本（3 分钟）

```
【开场：展示问题】（30秒）
├── 展示一张真实的德语音乐会海报截图
├── "这是一张汉堡爱乐乐团的音乐会海报，全是德语"
├── "如果我想把它加到日历，传统方式需要：翻译 → 理解日期格式 → 手动输入"
└── "现在，让我用 FollowUP 来解决这个问题"

【核心流程演示】（1分30秒）
├── 打开 FollowUP Web 应用
├── 上传刚才的海报图片
├── 点击"识别日程"按钮
├── 【等待 2-3 秒】展示 AI 正在处理的动画
├── 展示识别结果：
│   ├── 活动：贝多芬第九交响曲
│   ├── 时间：2026-02-15 19:30
│   ├── 地点：Elbphilharmonie, Hamburg
│   └── 描述：汉堡爱乐乐团演出
├── 【语音修改演示】点击麦克风，说"改成晚上 8 点"
├── 展示时间自动更新为 20:00
├── 点击"下载 ICS"
└── 打开手机日历，展示日程已成功导入

【亮点功能展示】（30秒）
├── 切换 LLM 模型（OpenAI → Claude）
├── 展示 API Key 设置界面
├── "用户可以使用自己的 API Key，数据完全私有"
└── 展示多条日程批量识别（如果时间允许）

【收尾】（30秒）
├── 回到首页
├── "这就是 FollowUP"
├── 展示未来愿景：WhatsApp Bot 集成、团队日历同步
└── "让你专注于生活，我们负责记住。谢谢！"
```

### 演示注意事项

| 环节 | 风险点 | 应对策略 |
|------|--------|----------|
| 网络问题 | API 调用失败 | 准备离线录屏作为备份 |
| 识别效果 | 识别结果不准确 | 提前测试，选择效果最好的海报 |
| 语音识别 | 现场嘈杂影响识别 | 准备文字输入作为 Plan B |
| 时间控制 | 演示超时 | 提前多次练习，控制在 3 分钟内 |

---

## 👥 团队分工

### 推荐分工（2-3 人团队）

| 角色 | 主要职责 | 技能要求 |
|------|----------|----------|
| **全栈/前端工程师** | Flutter UI 开发、LLM API 对接、ICS 生成 | Flutter/Dart、REST API |
| **后端/AI 工程师** | FastAPI 后台、Prompt 工程、语音处理（STT/TTS） | Python、LLM API、Prompt 设计 |
| **产品/设计**（可兼任） | UI/UX 设计、演示准备、Pitch 文案、用户测试 | Figma、演讲能力 |

### 24 小时时间分配

```
第 1-3 小时：环境搭建 + P0 骨架
├── Flutter 项目初始化（含 Landing Page 页面）
├── FastAPI 后端初始化 + SQLAlchemy + SQLite
├── GitHub 仓库创建
├── 基础 UI 框架 + 路由设置
└── 后端 API 连通性测试

第 4-12 小时：P0 核心功能开发（重点冲刺）
├── [后端] 用户登录 API + LangChain 日程提取
├── [前端] Landing Page + 登录页
├── [前端] 文字/图片输入界面
├── [前端] 日程预览与编辑界面
├── [后端] ICS 文件生成
└── 前后端联调，端到端流程打通

第 13-18 小时：P0 完善 + Bug 修复
├── 核心流程优化
├── Bug 修复
├── UI 细节调整
└── 多设备快速测试

第 19-21 小时：收尾 + 美化
├── UI 视觉美化（保持简洁即可）
├── 关键边缘情况处理
└── 确保 Demo 流程稳定

第 22-24 小时：演示准备（非常重要！）
├── 准备演示素材（海报、截图等）
├── 录制备份演示视频
├── Pitch 文案定稿
├── 多次演练 Demo（至少 3 遍）
└── 休息调整状态

（部署到 Railway 可在 Hackathon 后进行，本地演示即可）
```

### 协作建议

- **每 2-3 小时同步一次进度**，快速调整方向
- **前 12 小时全力冲刺 P0**，确保核心流程跑通
- **第 12 小时检查点**：如果 P0 未完成，立即砍功能，保证有可演示的产品
- **最后 3 小时必须停止开发**，全力准备演示
- **P1 功能（Follow Event 等）留到 Hackathon 后再做**，24 小时内专注 MVP

---

## ⚠️ 风险与备份方案

### 技术风险

| 风险 | 影响 | 应对策略 |
|------|------|----------|
| **LLM API 故障** | 核心功能无法使用 | 支持多 LLM 切换；准备离线 mock 数据用于演示 |
| **API 响应慢** | 用户体验差、演示卡顿 | 增加 loading 动画；设置合理超时；选择响应快的模型 |
| **图片识别不准** | 演示效果不佳 | 提前测试多张图片，选择识别效果最好的作为演示素材 |
| **语音识别失败** | P1 功能无法展示 | 准备文字输入作为 fallback；语音功能作为加分项而非核心 |
| **ICS 格式问题** | 导入日历失败 | 充分测试 iOS/Android/Google Calendar 兼容性 |

### 演示风险

| 风险 | 影响 | 应对策略 |
|------|------|----------|
| **网络不稳定** | API 调用失败 | 录制完整的备份演示视频 |
| **现场设备问题** | 无法展示 | 准备多个设备（手机 + 电脑）；提前测试投屏 |
| **时间超时** | 被打断、扣分 | 严格控制在 3 分钟内；多次练习计时 |
| **紧张忘词** | Pitch 效果差 | 准备提词卡；队友互相提醒 |

### 备份演示方案

```
方案 A（首选）：现场实时演示
├── 使用真实 API 调用
├── 展示完整流程
└── 实时语音修改

方案 B（网络故障）：预录视频 + 讲解
├── 提前录制 3 分钟完整演示视频
├── 现场播放视频 + 同步讲解
└── 视频中途可暂停说明细节

方案 C（极端情况）：PPT + 截图
├── 准备 5-6 页关键截图
├── 配合 Pitch 文案讲解
└── 强调技术方案和愿景
```

---

## 📎 附录

### 相关账号清单

| 工具 | 状态 | 用途 |
|------|------|------|
| Railway | ✅ 已有 | FastAPI 后端 + PostgreSQL 数据库部署（生产环境） |
| Cursor | ✅ 已有 | 代码开发 |
| GitHub | ✅ 已有 | 代码管理 |
| OpenAI | ✅ 已申请 | LLM（GPT-4o / GPT-4o-mini / Whisper） |
| v0 | ✅ 已申请 | UI 原型 |
| ElevenLabs | ✅ 已申请 | TTS 语音（P2） |

### 参考资源
- [iCalendar 规范](https://icalendar.org/)
- [LangChain 文档](https://python.langchain.com/)
- [Flutter 官方文档](https://flutter.dev/)
- [FastAPI 官方文档](https://fastapi.tiangolo.com/)
- [Railway 文档](https://docs.railway.app/)

---

*文档版本：v2.6*
*最后更新：2026-01-31*
*更新内容：v2.0-v2.5 详见历史；v2.6 简化为单体项目架构，Landing Page 集成到 Flutter，新增 SQLAlchemy ORM，本地开发使用 SQLite*
