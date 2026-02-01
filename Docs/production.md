# FollowUP - Product Specification

> Hackathon 2026 · Hamburg

---

## Brand Positioning

| Item | Content |
|------|---------|
| **Product Name** | FollowUP |
| **Slogan** | Never miss a moment that matters. |
| **Core Value** | Work-Life Balance — Every meeting, every gathering, every concert deserves your presence. |
| **Tagline** | Capture any event. Add to calendar. Stay on track. |

---

## Product Overview

### One-Line Description
**FollowUP — Intelligently extract events from any input, helping you focus on life and achieve Work-Life Balance.**

### Core Value Proposition
Modern life moves fast. Work meetings and personal activities intertwine. Screenshots of dinner plans from friends, company event posters, voice messages in group chats... Important moments are scattered everywhere. Manually entering them into calendars is tedious and error-prone.

**FollowUP's mission: Never let you miss an important moment in life.**

We leverage LLM multimodal capabilities to automatically recognize and extract event information, generating standard ICS files. Whether for work or personal life, add events to your calendar with one click and truly achieve Work-Life Balance.

### Supported Input Types
- Text (copy-paste, manual input)
- Images (screenshots, posters, photos)
- Voice (recordings, voice messages)
- Platform messages (WhatsApp, Claude Bot)

### Output Formats
- ICS calendar files (standard format, compatible with all major calendar apps)
- Visual invitation images
- Invitation text (easy to share)
- Background audio introductions (for specific events like concerts)

---

## Target User Personas

### User Group 1: Busy Professionals (25-40 years old)

| Attribute | Description |
|-----------|-------------|
| **Identity** | Tech/Finance/Consulting professionals who often work overtime |
| **Pain Points** | Work meetings and personal activities mixed up; often miss friend gatherings and family anniversaries |
| **Typical Scenarios** | Dinner notifications in WeChat groups, company team-building posters, meeting invitation screenshots from clients |
| **Core Need** | Quickly organize fragmented event information into calendar, reduce manual input |

### User Group 2: International Students / Expats

| Attribute | Description |
|-----------|-------------|
| **Identity** | Chinese students/workers in Germany/Europe |
| **Pain Points** | Cannot understand German/English event posters; unfamiliar with European date formats (DD.MM.YYYY) |
| **Typical Scenarios** | Concert posters, university lecture notices, community event flyers |
| **Core Need** | Automatically recognize multi-language events and convert to familiar format |

### User Group 3: Socially Active Young People (18-30 years old)

| Attribute | Description |
|-----------|-------------|
| **Identity** | Young people who enjoy attending various events, parties, and exhibitions |
| **Pain Points** | Event information scattered across Instagram, WeChat, WhatsApp, etc. |
| **Typical Scenarios** | Party invitation screenshots from friends, exhibition posters, concert information |
| **Core Need** | Save all interesting events with one click, never miss anything exciting |

---

## User Scenario Stories

### Scenario 1: Concert Poster Recognition

> **Lisa** is a software engineer working in Hamburg. A friend sends her a Hamburg Philharmonic concert poster entirely in German, which she cannot understand.
>
> She opens FollowUP and uploads the poster photo. **3 seconds later**, AI automatically recognizes:
> - Event: Beethoven's Ninth Symphony
> - Time: February 15, 2026, 19:30
> - Location: Elbphilharmonie
>
> Lisa clicks "Add to Calendar" and an ICS file downloads automatically. She no longer has to worry about missing this concert.

### Scenario 2: WeChat Group Dinner Notification

> In a university classmates group, someone says: "**Dinner at the usual place Saturday evening at 7, remember to come!**"
>
> **Xiaoming** screenshots this message and sends it to FollowUP. AI automatically recognizes:
> - Event: University classmates dinner
> - Time: This Saturday 19:00
> - Location: (to be added)
>
> Xiaoming adds the restaurant address and clicks download ICS. He will never forget his old classmates' gatherings due to being too busy with work.

### Scenario 3: Quick Voice Recording

> **Mark** just finished a phone call where someone scheduled a meeting to discuss a collaboration next Wednesday afternoon.
>
> He speaks to his phone: "**Next Wednesday at 2 PM, meet Mr. Zhang at Starbucks to discuss collaboration, remember to bring PPT**"
>
> FollowUP automatically converts the voice to an event:
> - Event: Discuss collaboration with Mr. Zhang
> - Time: Next Wednesday 14:00
> - Location: Starbucks
> - Notes: Remember to bring PPT
>
> One-click export, and Mark continues with other work without worrying about forgetting this important meeting.

### Scenario 4: Company Event Poster

> HR posts a team-building activity poster on company WeChat, filled with dense information.
>
> **Xiaowang** screenshots and uploads to FollowUP. AI accurately extracts:
> - Event: 2026 Annual Team Building
> - Time: March 20, 09:00 - 18:00
> - Location: XX Resort
> - Notes: Please bring sports equipment
>
> Xiaowang doesn't need to carefully read the poster - the event is already added to the calendar.

### Scenario 5: Blurry Poster + Smart Search Completion

> **Xiaoli** took a photo of a music festival poster at the subway station, but the photo is blurry - only "Hamburg Summer Music Festival" and "August" are legible.
>
> She uploads to FollowUP. After AI recognizes the keywords, it **automatically searches online** to complete the information:
> - Event: Hamburg Summer Music Festival 2026
> - Time: August 15-17, 2026
> - Location: Stadtpark Hamburg
> - Website: https://example.com/festival
> - Price: Starting from €49
>
> Xiaoli clicks "Follow this event" and it's added to her follow list. From now on, whether on mobile app or web, she can always view the event details and updates.

### Scenario 6: Follow and Track Events

> **Ajie** is a concert enthusiast who has followed several upcoming concerts on FollowUP.
>
> Every time he opens the FollowUP App or Web, he can see all his followed events:
> - Event list sorted by time
> - Countdown for each event
> - Event details and related information
>
> One day, a band concert he followed updates ticket sales information. FollowUP sends a push notification: "The Coldplay concert you're following goes on sale tomorrow at 10:00 AM!"
>
> Ajie never misses any events he's interested in.

---

## Competitive Analysis

### Pain Points of Existing Solutions

| Solution | Description | Pain Points |
|----------|-------------|-------------|
| **Manual Calendar Input** | Users open calendar app and fill in each field | Tedious, time-consuming, easy to miss or make mistakes |
| **iOS Image Recognition** | iPhone's built-in text recognition from images | Only supports standard formats; cannot handle complex posters or chat screenshots |
| **Notion / Todo Apps** | Manually copy-paste to Notion | Cannot directly generate ICS; requires manual sync to calendar |
| **Smart Assistants (Siri/Google)** | Voice commands to add events | Requires users to organize language themselves; cannot recognize images |

### FollowUP's Differentiators

| Dimension | FollowUP Advantage |
|-----------|-------------------|
| **Input Methods** | Multi-modal: Text + Images + Voice, one entry point |
| **Intelligence** | LLM-driven; understands complex posters, chat screenshots, colloquial expressions |
| **Information Completion** | Automatically searches online to complete event details when image is blurry or information is incomplete |
| **Output Standard** | Directly generates ICS files compatible with all major calendar apps |
| **Follow & Sync** | Proactively follow events; unified view and real-time sync across App/Web |
| **Easy to Use** | Preset accounts for immediate experience; no API Key configuration needed |
| **Multi-language Support** | Automatically recognizes German, English, Chinese, and other languages |
| **Flexible Editing** | Edit after recognition: direct input, selector, or voice description |

---

## Feature Priority

### P0 - Core MVP (Must Complete)
> This is the minimum viable product ensuring a complete, demonstrable core flow
>
> **Development Method: Use Cursor / Claude Code to assist code generation**

| Feature | Description |
|---------|-------------|
| Text Input Recognition | User inputs text → LLM extracts events |
| Image Input Recognition | Support image upload + optional text notes; Vision API extraction |
| Event Information Structuring | Extract: title, time, location, description |
| User Local Editing | Allow user modifications after recognition: direct input / date picker / voice input auto-fill |
| ICS File Generation | Generate standard iCalendar format files |
| User Login | Preset accounts (alice/bob/jane/xiao) for authentication |
| Backend LLM Calls | Call OpenAI API through backend LangChain |
| Client Display & Download | Preview events + Download ICS button |
| Basic UI | Clean Flutter interface (cross-platform) |

---

### P1 - Enhanced Features (Priority Completion)
> Improve product completeness and user experience

| Feature | Description |
|---------|-------------|
| Multi-event Recognition | Recognize multiple events from single input; batch processing |
| Voice Input | Recording → STT to text → LLM extracts events |
| **Follow Event** | Users can actively follow events; unified view of followed events across App/Web |
| **Event List Sync** | Followed events sync in real-time across client and web; countdown display support |

---

### P2 - Extended Features (If Time Permits)
> Differentiation highlights to improve competitiveness

| Feature | Description |
|---------|-------------|
| **Smart Search Completion** | Auto search online to complete event details (time, location, price) when image/text is incomplete |
| Smart Address Completion | Fuzzy address (e.g., "library near XX") → Query specific street address |
| Image Metadata Extraction | When address/time is missing, extract reference info from photo EXIF (capture time, GPS location) |
| Invitation Image Generation | Auto-generate beautiful invitation images based on events |
| Background Info Generation | Auto-generate background information for concerts and similar events |
| TTS Reading | Voice version of background intro (ElevenLabs) |
| Discord Integration | Receive and extract events through Discord Bot |
| **Event Update Notifications** | Push notifications when followed events are updated (ticket sales, time changes, etc.) |

---

### P3 - Future Vision (Post-Hackathon)
> Recorded but not implemented this time

```mermaid
flowchart LR
    subgraph Phase1["Phase 1: Smart Follow UP"]
        Bot[Background Bot Agent]
        Monitor[Event Monitoring]
        Notify[Real-time Notifications]
        Bot --> Monitor --> Notify
    end

    subgraph Phase2["Phase 2: Voice Experience"]
        VoiceIn[Voice Input]
        VoiceOut[TTS Output]
        VoiceEdit[Voice Editing]
    end

    subgraph Phase3["Phase 3: Social Features"]
        Invite[Invite Friends]
        Share[Shared Events]
        Collab[Collaborative Follow-up]
    end

    Phase1 --> Phase2 --> Phase3
```

#### Roadmap Highlights

| Feature | Description | Notes |
|---------|-------------|-------|
| **Real Follow UP** | Background bot agent that monitors events you follow, automatically fetches updates (ticket sales, time changes, new info), and sends real-time notifications | Requires backend automation infrastructure, may incur API/compute costs |
| **Voice Capabilities** | Full voice interaction - voice input for event creation, voice editing ("change to 3 PM"), TTS for event summaries and reminders | Integrates with Whisper STT and ElevenLabs TTS |
| **Friend Invitation** | Invite friends to follow events together, shared event lists, collaborative calendar planning, group notifications | Social features for coordinated attendance |
| WhatsApp Integration | Receive messages directly through WhatsApp Bot | |
| Claude Bot Integration | Conversational event management | |
| Team Calendar Sync | Multi-user collaborative scheduling | |
| Smart Reminders | Personalized reminders based on event type | |
| Calendar Platform Direct Connect | One-click sync to Google Calendar / Outlook | |

---

## Technical Architecture

### Overall Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        FollowUP Monolith Project                     │
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                    Flutter Frontend                          │   │
│   │                  (iOS / Android / Web)                       │   │
│   │                                                              │   │
│   │  • Landing Page (Product introduction)                       │   │
│   │  • User Login                                                │   │
│   │  • Input Processing (Text/Image/Voice)                       │   │
│   │  • Event Preview & Edit                                      │   │
│   │  • ICS Download                                              │   │
│   │  • Follow Event List                                         │   │
│   └──────────────────────────┬──────────────────────────────────┘   │
│                              │                                       │
│                              │ REST API + WebSocket                  │
│                              ▼                                       │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                   Python Backend (FastAPI)                   │   │
│   │                                                              │   │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │   │
│   │  │  REST API   │  │  WebSocket  │  │   Auth Module        │  │   │
│   │  │             │  │             │  │                     │  │   │
│   │  │ /api/parse  │  │ Streaming   │  │ Preset accounts:    │  │   │
│   │  │ /api/events │  │ responses   │  │ alice, bob,         │  │   │
│   │  │ /api/auth   │  │             │  │ jane, xiao          │  │   │
│   │  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │   │
│   │         │                │                    │              │   │
│   │         └────────────────┼────────────────────┘              │   │
│   │                          │                                    │   │
│   │                          ▼                                    │   │
│   │  ┌───────────────────────────────────────────────────────┐   │   │
│   │  │                   LangChain Layer                      │   │   │
│   │  │  • Event Information Extraction (Structured Output)   │   │   │
│   │  │  • Multimodal Processing (Text + Image Vision)        │   │   │
│   │  │  • Prompt Template Management                         │   │   │
│   │  └───────────────────────┬───────────────────────────────┘   │   │
│   │                          │                                    │   │
│   │                          ▼                                    │   │
│   │  ┌───────────────────────────────────────────────────────┐   │   │
│   │  │                   OpenAI API                           │   │   │
│   │  │         (GPT-4o / GPT-4o-mini / Whisper)               │   │   │
│   │  └───────────────────────────────────────────────────────┘   │   │
│   │                                                              │   │
│   │  ┌───────────────────────────────────────────────────────┐   │   │
│   │  │              SQLAlchemy ORM                            │   │   │
│   │  │  Local Dev: SQLite  |  Production: PostgreSQL          │   │   │
│   │  │                                                        │   │   │
│   │  │  • users table: User information                       │   │   │
│   │  │  • events table: Saved/Followed events                 │   │   │
│   │  └───────────────────────────────────────────────────────┘   │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│   Deployment: Railway (Backend service + PostgreSQL)                 │
└─────────────────────────────────────────────────────────────────────┘
```

### Tech Stack Details

| Layer | Technology | Description |
|-------|------------|-------------|
| **Frontend** | Flutter | One codebase, three platforms (iOS/Android/Web), includes Landing Page |
| **API Communication** | REST + WebSocket | REST for requests, WS for streaming responses |
| **Backend Framework** | Python + FastAPI | Async, high-performance, auto API documentation |
| **ORM** | SQLAlchemy | Multi-database support, seamless dev/prod switching |
| **Database** | SQLite / PostgreSQL | SQLite for local dev, PostgreSQL for production |
| **LLM Framework** | LangChain | Prompt management, structured output, multimodal processing |
| **LLM Service** | OpenAI API | GPT-4o (Vision), GPT-4o-mini, Whisper STT |
| **Authentication** | JWT Token | Preset accounts, simple token verification |
| **ICS Generation** | Python icalendar library | Backend generates, frontend downloads |
| **Deployment** | Railway | Backend service + PostgreSQL database |
| **Code Management** | GitHub | Version control |

### Database Configuration

```python
# config.py - Database configuration
import os

# Environment variable controls database selection
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "sqlite:///./followup.db"  # Default SQLite (local development)
)

# Production: Set DATABASE_URL to PostgreSQL connection string
# postgresql://user:password@host:port/database
```

### API Design

```mermaid
flowchart LR
    subgraph REST["REST API"]
        Auth["POST /api/auth/login\nUser login, returns JWT"]
        User["GET /api/user/me\nGet current user info"]
        Parse["POST /api/parse\nParse events"]
        EventsGet["GET /api/events\nGet user event list"]
        EventsFollow["POST /api/events/follow\nFollow an event"]
        EventsDelete["DELETE /api/events/{id}\nUnfollow/Delete"]
        EventsICS["GET /api/events/{id}/ics\nDownload ICS file"]
    end

    subgraph WS["WebSocket"]
        WSParse["WS /ws/parse\nStream parsing progress"]
    end

    subgraph AuthMethod["Authentication"]
        Header["Header: Authorization: Bearer token"]
        WSAuth["WS: Pass token parameter"]
    end
```

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | User login, returns JWT Token |
| GET | `/api/user/me` | Get current user info |
| POST | `/api/parse` | Parse events (text/image) |
| GET | `/api/events` | Get user's event list |
| POST | `/api/events/follow` | Follow an event |
| DELETE | `/api/events/{id}` | Unfollow/Delete event |
| GET | `/api/events/{id}/ics` | Download ICS file |
| WS | `/ws/parse` | Stream parsing progress/results |

### User Authentication Design

**Preset User Accounts (Hackathon Simplified):**

| Username | Password | Description |
|----------|----------|-------------|
| alice | alice123 | Test User 1 |
| bob | bob123 | Test User 2 |
| jane | jane123 | Test User 3 |
| xiao | xiao123 | Test User 4 |
| moni | moni123 | Test User 5 |

**Authentication Flow:**

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant Backend
    participant Database

    User->>Frontend: Enter username + password
    Frontend->>Backend: POST /api/auth/login
    Backend->>Database: Validate credentials
    Database-->>Backend: User data
    Backend-->>Frontend: JWT Token (24h validity)
    Frontend->>Frontend: Store token locally
    
    Note over Frontend,Backend: Subsequent requests
    Frontend->>Backend: Request with Authorization header
    Backend->>Backend: Validate token
    Backend-->>Frontend: Response data
    
    Note over User,Frontend: Token expires after 24h
    Frontend->>User: Redirect to login
```

### Database Design (SQLAlchemy Models)

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
    
    # Relationships
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
    
    # Relationships
    user = relationship("User", back_populates="events")


# Preset user data (initialized on app startup)
PRESET_USERS = [
    {"username": "alice", "password": "alice123"},
    {"username": "bob", "password": "bob123"},
    {"username": "jane", "password": "jane123"},
    {"username": "xiao", "password": "xiao123"},
    {"username": "moni", "password": "moni123"},
]
```

### LangChain Integration

```python
# Example: Event Extraction Chain
from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate
from langchain.output_parsers import PydanticOutputParser

# Initialize OpenAI model
llm = ChatOpenAI(
    model="gpt-4o-mini",
    api_key=os.getenv("OPENAI_API_KEY")
)

# Structured output
class EventInfo(BaseModel):
    title: str
    start_time: datetime
    end_time: Optional[datetime]
    location: Optional[str]
    description: Optional[str]

parser = PydanticOutputParser(pydantic_object=EventInfo)

# Prompt template
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are an event information extraction assistant..."),
    ("user", "{input}")
])

# Build Chain
chain = prompt | llm | parser
```

---

## Core User Flow

### Main Flow

```mermaid
flowchart TD
    subgraph Input["1. User Input"]
        Text[Paste text]
        Image["Upload image + notes"]
        Voice["Record voice (P1)"]
    end

    subgraph AIProcess["2. AI Processing"]
        Vision["Vision API recognition"]
        STT["STT to text (P1)"]
        LLM["LLM extracts event info"]
        Address["Smart address query (P2)"]
    end

    subgraph Confirm["3. User Confirmation"]
        Display[Display extraction results]
        Edit["Edit options:\n- Direct input\n- Date/time picker\n- Voice auto-fill"]
        ConfirmBtn[Confirm generation]
    end

    subgraph Output["4. Generate Output"]
        ICSFile[ICS file]
        InviteImg["Invitation image (P2)"]
        TTS["Background intro + TTS (P2)"]
    end

    subgraph Actions["5. User Actions"]
        Download[Download ICS]
        SaveImg[Save image]
        PlayRead[Play/read intro]
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

### Event Data Structure

```json
{
  "events": [
    {
      "title": "Hamburg Philharmonic Concert",
      "start_time": "2026-02-15T19:30:00+01:00",
      "end_time": "2026-02-15T22:00:00+01:00",
      "location": "Elbphilharmonie, Platz der Deutschen Einheit 1, Hamburg",
      "description": "Beethoven's Ninth Symphony",
      "url": "https://example.com/event",
      "reminder": 60,
      "background_info": "The Hamburg Philharmonic was founded in 1828..."
    }
  ]
}
```

---

## Development Plan

### Development Phases (Using Cursor / Claude Code)

```mermaid
flowchart LR
    subgraph Phase1["Phase 1: Environment Setup"]
        P1A[Flutter project init]
        P1B[FastAPI + SQLAlchemy]
        P1C[GitHub repo creation]
    end

    subgraph Phase2["Phase 2: P0 Core Features"]
        P2A[User login]
        P2B[Landing Page]
        P2C["Input module (text/image)"]
        P2D[LangChain + OpenAI]
        P2E[LLM event extraction]
        P2F[User editing UI]
        P2G[ICS generation]
        P2H[Frontend-backend integration]
    end

    subgraph Phase3["Phase 3: P1 Enhanced"]
        P3A[Multi-event recognition]
        P3B[Voice input]
        P3C[Follow Event feature]
        P3D[Event list sync]
    end

    subgraph Phase4["Phase 4: Wrap-up"]
        P4A[Bug fixes + UI polish]
        P4B[Railway deployment]
        P4C[Demo preparation]
    end

    Phase1 --> Phase2 --> Phase3 --> Phase4
```

### Flexible Scope Strategy (24-Hour Version)

| Progress Status | Recommended Strategy |
|-----------------|---------------------|
| **Time Pressure** (P0 not complete after 12h) | Minimal MVP: Text input + Backend LLM + ICS generation |
| **Normal Progress** (P0 complete within 12h) | Full P0: Text + Image + User editing + Login |
| **Smooth Progress** (All ready within 18h) | P0 + Simple optimizations: UI polish, multi-event recognition |
| **Exceeding Expectations** | Can attempt simplified P1 Follow Event |

> **24-Hour Core Principle**: Better to have fewer but stable features than many broken ones. Demo effect > Feature count.

---

## Landing Page (Integrated in Flutter)

### Page Objective
Product homepage as the entry page for the Flutter Web application, for Hackathon presentation and user acquisition.

> **Note**: Landing Page is integrated in the Flutter project, not a separate project. Users visiting the Web app first see the Landing Page, then click CTA button to enter login/main feature page.

### Page Structure

```mermaid
flowchart TD
    subgraph Hero["Hero Section - First Screen"]
        Name[Product name + Slogan]
        Value[One-line value description]
        CTA["CTA Button: Get Started / Try Now"]
        Screenshots[Product screenshots / demo]
    end

    subgraph Features["Features Section - Highlights"]
        F1["Multi-modal input\n(Image + Text + Voice)"]
        F2[AI Smart Recognition]
        F3[One-click ICS Export]
        F4[Cross-platform Sync]
    end

    subgraph HowItWorks["How It Works"]
        S1["Step 1: Upload / Paste / Speak"]
        S2["Step 2: AI extracts event info"]
        S3["Step 3: Edit and Confirm"]
        S4["Step 4: Add to Calendar"]
        S1 --> S2 --> S3 --> S4
    end

    subgraph Footer["Footer"]
        GitHub[GitHub link]
        Team[Team info]
        Hackathon[Hackathon 2026 Hamburg]
    end

    Hero --> Features --> HowItWorks --> Footer
```

### Implementation

Since Landing Page is integrated in Flutter:
- Use Flutter's `ScrollView` + `Column` layout
- Responsive design using `LayoutBuilder` or `MediaQuery`
- Animation effects using Flutter built-in animations
- Click CTA button, use `Navigator` to jump to login page

### Key Elements

- **Responsive Design**: Adapt to mobile and desktop (Flutter native support)
- **Fast Loading**: Flutter Web first-screen optimization
- **Prominent CTA**: Guide users to login and use
- **Visual Appeal**: Clean and modern, with product screenshots/GIFs

---

## UI Design Guidelines

### Input Page
- Text input field (supports paste)
- Image upload area + supplementary notes input field
- Record button (P1)
- LLM selection (dropdown: OpenAI / Gemini / Claude)
- API Key input (optional, collapsible)

### Result Editing Page
- Card-style event display
- Each field is click-to-edit:
  - **Title**: Direct input
  - **Date**: Date picker or voice input
  - **Time**: Time picker or voice input
  - **Location**: Input field + smart completion suggestions or voice input
  - **Description**: Text input
- Voice edit button (click and speak, auto-recognize and fill corresponding field)
- Smart address suggestions (fuzzy address → show specific address suggestions) (P2)

### Action Button Group
- Download ICS
- Generate invitation image (P2)
- Copy invitation text
- Play background intro (P2)

---

## Differentiating Highlights

1. **Ready to Use** — Preset accounts for immediate experience, no API Key configuration needed
2. **Multi-modal Input** — Text, image (+notes), voice (P1), one entry point
3. **Cross-platform Support** — Flutter-built, unified iOS/Android/Web experience
4. **Flexible Editing** — Edit after recognition: direct input, selector, or voice description auto-fill
5. **LangChain Driven** — Structured output, accurate and stable recognition
6. **Real-time Feedback** — WebSocket streaming responses, smooth experience
7. **Follow Event** — Proactively follow interesting events, unified view across App/Web (P1)
8. **Smart Search Completion** — Blurry image/incomplete info? Auto search online for event details (P2)
9. **Smart Address Completion** — Fuzzy description (e.g., "library near XX") → Auto query specific address (P2)
10. **Image Metadata Utilization** — When info is missing, extract capture time and GPS from photo EXIF as reference (P2)
11. **One-click Invitation Generation** — Social sharing friendly (P2)
12. **Event Update Notifications** — Push notifications when followed events are updated (P2)

---

## Demo & Pitch

### Elevator Pitch (30 seconds)

> "Have you ever had this experience? A friend sends you an event poster, and you want to add it to your calendar, but you're too lazy to fill in each field manually. FollowUP solves exactly this problem—take a photo, paste, or just say something, AI automatically extracts the event and adds it to your calendar with one click. Focus on life itself, never miss any important moment."

### Full Pitch (2 minutes)

**Opening: Pain Point Resonance (20 seconds)**
> "Modern life moves faster and faster. Work meetings, friend gatherings, concerts, family anniversaries... These important moments are scattered across WeChat groups, emails, and posters. We want to add them to our calendar, but manual input is too troublesome. The result? Many activities we said we'd attend, we end up forgetting."

**Solution: Product Introduction (30 seconds)**
> "FollowUP is an intelligent calendar assistant. Whether it's a German poster, WeChat group screenshot, or voice message, just upload or say something, and AI automatically recognizes the event information, generates a standard ICS file, and imports it to any calendar app with one click."

**Technical Highlights (30 seconds)**
> "Our product has several unique features:
> 1. **Multi-modal input**: Text, image, voice—one entry point
> 2. **Ready to use**: Preset accounts for immediate experience, no configuration needed
> 3. **Unified across platforms**: Flutter-built, consistent iOS, Android, Web experience
> 4. **Flexible editing**: After recognition, you can directly edit, or use voice to say 'change to 3 PM' and it updates automatically"

**Vision & Value (20 seconds)**
> "Our vision is to help users achieve true Work-Life Balance. Work meetings should be attended on time, and friend gatherings shouldn't be missed. FollowUP lets you focus on life itself—we'll remember those important moments."

**Closing (20 seconds)**
> "FollowUP—Never miss a moment that matters. Thank you!"

### Demo Script (3 minutes)

```
[Opening: Show the Problem] (30 seconds)
├── Show a real German concert poster screenshot
├── "This is a Hamburg Philharmonic concert poster, entirely in German"
├── "If I want to add it to my calendar, traditional way: translate → understand date format → manual input"
└── "Now, let me solve this with FollowUP"

[Core Flow Demo] (1 minute 30 seconds)
├── Open FollowUP Web app
├── Upload the poster image
├── Click "Recognize Event" button
├── [Wait 2-3 seconds] Show AI processing animation
├── Show recognition results:
│   ├── Event: Beethoven's Ninth Symphony
│   ├── Time: 2026-02-15 19:30
│   ├── Location: Elbphilharmonie, Hamburg
│   └── Description: Hamburg Philharmonic performance
├── [Voice Edit Demo] Click microphone, say "change to 8 PM"
├── Show time automatically updated to 20:00
├── Click "Download ICS"
└── Open phone calendar, show event successfully imported

[Feature Highlights] (30 seconds)
├── Switch LLM model (OpenAI → Claude)
├── Show API Key settings interface
├── "Users can use their own API Key, data completely private"
└── Show multi-event batch recognition (if time permits)

[Closing] (30 seconds)
├── Return to homepage
├── "This is FollowUP"
├── Show future vision: WhatsApp Bot integration, team calendar sync
└── "Focus on life, we'll remember. Thank you!"
```

### Demo Notes

| Stage | Risk | Mitigation |
|-------|------|------------|
| Network Issues | API call failure | Prepare offline screen recording as backup |
| Recognition Quality | Inaccurate recognition results | Test multiple images beforehand, choose the best for demo |
| Voice Recognition | Noisy venue affects recognition | Prepare text input as Plan B |
| Time Control | Demo overtime | Practice multiple times, keep within 3 minutes |

---

## Team Roles

### Recommended Division (2-3 Person Team)

| Role | Main Responsibilities | Skill Requirements |
|------|----------------------|-------------------|
| **Full-stack/Frontend Engineer** | Flutter UI development, LLM API integration, ICS generation | Flutter/Dart, REST API |
| **Backend/AI Engineer** | FastAPI backend, Prompt engineering, Voice processing (STT/TTS) | Python, LLM API, Prompt Design |
| **Product/Design** (Can be combined) | UI/UX design, Demo preparation, Pitch copy, User testing | Figma, Presentation skills |

### 24-Hour Time Allocation

```
Hours 1-3: Environment Setup + P0 Skeleton
├── Flutter project initialization (including Landing Page)
├── FastAPI backend initialization + SQLAlchemy + SQLite
├── GitHub repository creation
├── Basic UI framework + routing setup
└── Backend API connectivity test

Hours 4-12: P0 Core Feature Development (Sprint Focus)
├── [Backend] User login API + LangChain event extraction
├── [Frontend] Landing Page + Login page
├── [Frontend] Text/Image input interface
├── [Frontend] Event preview and editing interface
├── [Backend] ICS file generation
└── Frontend-backend integration, end-to-end flow complete

Hours 13-18: P0 Polish + Bug Fixes
├── Core flow optimization
├── Bug fixes
├── UI detail adjustments
└── Quick multi-device testing

Hours 19-21: Wrap-up + Polish
├── UI visual polish (keep it clean)
├── Key edge case handling
└── Ensure Demo flow is stable

Hours 22-24: Demo Preparation (Very Important!)
├── Prepare demo materials (posters, screenshots, etc.)
├── Record backup demo video
├── Finalize Pitch copy
├── Practice Demo multiple times (at least 3 times)
└── Rest and adjust state

(Railway deployment can be done post-Hackathon; local demo is sufficient)
```

### Collaboration Tips

- **Sync progress every 2-3 hours**, quickly adjust direction
- **Sprint P0 in first 12 hours**, ensure core flow works
- **12-hour checkpoint**: If P0 not complete, immediately cut features to ensure a demoable product
- **Must stop development in last 3 hours**, fully prepare for demo
- **P1 features (Follow Event, etc.) save for post-Hackathon**, focus on MVP in 24 hours

---

## Risks & Backup Plans

### Technical Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| **LLM API Outage** | Core functionality unusable | Support multiple LLM switching; prepare offline mock data for demo |
| **Slow API Response** | Poor UX, demo lag | Add loading animations; set reasonable timeouts; choose responsive models |
| **Poor Image Recognition** | Demo effect suffers | Test multiple images beforehand, choose best for demo |
| **Voice Recognition Failure** | P1 feature cannot be shown | Prepare text input as fallback; voice is bonus, not core |
| **ICS Format Issues** | Calendar import fails | Thoroughly test iOS/Android/Google Calendar compatibility |

### Demo Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Unstable Network** | API call failure | Record complete backup demo video |
| **On-site Device Issues** | Cannot present | Prepare multiple devices (phone + laptop); test screen mirroring beforehand |
| **Time Overrun** | Interrupted, point deduction | Strictly control within 3 minutes; practice with timer multiple times |
| **Stage Fright** | Poor Pitch effect | Prepare cue cards; teammates remind each other |

### Backup Demo Plans

```
Plan A (Preferred): Live real-time demo
├── Use real API calls
├── Show complete flow
└── Real-time voice editing

Plan B (Network Failure): Pre-recorded video + narration
├── Pre-record 3-minute complete demo video
├── Play video on-site + sync narration
└── Can pause video to explain details

Plan C (Extreme Situation): PPT + Screenshots
├── Prepare 5-6 key screenshots
├── Present with Pitch copy
└── Emphasize technical approach and vision
```

---

## Appendix

### Account Checklist

| Tool | Status | Purpose |
|------|--------|---------|
| Railway | Ready | FastAPI backend + PostgreSQL deployment (production) |
| Cursor | Ready | Code development |
| GitHub | Ready | Code management |
| OpenAI | Applied | LLM (GPT-4o / GPT-4o-mini / Whisper) |
| v0 | Applied | UI prototyping |
| ElevenLabs | Applied | TTS voice (P2) |

### Reference Resources
- [iCalendar Specification](https://icalendar.org/)
- [LangChain Documentation](https://python.langchain.com/)
- [Flutter Official Documentation](https://flutter.dev/)
- [FastAPI Official Documentation](https://fastapi.tiangolo.com/)
- [Railway Documentation](https://docs.railway.app/)

---

*Document Version: v2.6*
*Last Updated: 2026-01-31*
*Updates: v2.0-v2.5 see history; v2.6 simplified to monolith architecture, Landing Page integrated into Flutter, added SQLAlchemy ORM, local development uses SQLite*
