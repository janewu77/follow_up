"""
Event Extraction Prompts

Contains prompt templates for text parsing and image parsing.
"""
from typing import List, Optional
from langchain_core.prompts import ChatPromptTemplate

try:
    from langchain_core.pydantic_v1 import BaseModel, Field
except ImportError:
    from pydantic import BaseModel, Field


# ============================================================================
# Pydantic Models for Structured Output
# ============================================================================

class EventExtraction(BaseModel):
    """Event extraction result"""
    title: str = Field(description="Event title")
    start_time: Optional[str] = Field(None, description="Start time, ISO 8601 format, e.g.: 2026-02-01T15:00:00. Can be null if unknown.")
    end_time: Optional[str] = Field(None, description="End time, ISO 8601 format, optional")
    location: Optional[str] = Field(None, description="Location")
    description: Optional[str] = Field(None, description="Event description")


class EventExtractionList(BaseModel):
    """Event list"""
    events: List[EventExtraction] = Field(description="List of extracted events")
    needs_clarification: bool = Field(
        default=False,
        description="Whether clarification is needed from user"
    )
    clarification_question: Optional[str] = Field(
        None,
        description="Clarification question to ask user"
    )
    search_keywords: Optional[List[str]] = Field(
        None,
        description="Keywords that could be used to search for this event online (e.g., ['Hamburg Philharmonic', 'Beethoven Symphony', 'February 2026'])"
    )
    confidence: Optional[float] = Field(
        None,
        description="Confidence level in extracted information (0.0-1.0)"
    )
    date_hint: Optional[str] = Field(
        None,
        description="Partial date information (e.g., 'February', 'next month', '2026')"
    )


# ============================================================================
# Text Parsing Prompt
# ============================================================================

TEXT_PARSE_SYSTEM = """You are a smart calendar assistant, skilled at extracting event information from natural language text.

Please carefully analyze the user's input text and extract all possible event information. For each event, you need to:
1. Extract event title
2. Infer start time (if no explicit time in text, use current time as reference)
3. Infer end time (if possible)
4. Extract location information (if available)
5. Extract event description

Current time: {current_time}

**Important: Ask user when information is incomplete**
If the following key information is missing or ambiguous, set needs_clarification=true and ask a clarification question:
- Time is unclear (e.g., "next week" but no specific day, "evening" but no specific hour)
- Event type is unclear
- Multiple possible interpretations

Clarification questions should be concise and friendly, ask only one most important question at a time.

Please return results in JSON format:
- events: Event array, each event contains title, start_time, end_time, location, description
- needs_clarification: Whether clarification is needed (boolean)
- clarification_question: Clarification question (only when needs_clarification=true)
- search_keywords: List of keywords that could be used to search for this event online (e.g., ["Hamburg Philharmonic", "Beethoven", "February 2026"])
- confidence: Confidence level in extracted information (0.0-1.0)
- date_hint: Partial date information (e.g., "February", "next month", "2026")

Example 1 - Complete information:
{{"events": [...], "needs_clarification": false, "clarification_question": null, "search_keywords": null, "confidence": 0.9, "date_hint": null}}

Example 2 - Needs clarification:
{{"events": [], "needs_clarification": true, "clarification_question": "What day next week is the meeting? What time does it start?", "search_keywords": ["meeting"], "confidence": 0.3, "date_hint": "next week"}}

Example 3 - Partial information extractable, but still needs clarification:
{{"events": [{{"title": "Meeting", "start_time": "2026-02-03T14:00:00", ...}}], "needs_clarification": true, "clarification_question": "I'm assuming it's next Monday at 2 PM, is that correct?", "search_keywords": ["meeting", "next week"], "confidence": 0.6, "date_hint": "next week"}}"""

TEXT_PARSE_USER = "User input: {text}\nAdditional note: {additional_note}"

TEXT_PARSE_PROMPT = ChatPromptTemplate.from_messages([
    ("system", TEXT_PARSE_SYSTEM),
    ("user", TEXT_PARSE_USER),
])


# ============================================================================
# Image Parsing Prompt
# ============================================================================

IMAGE_PARSE_SYSTEM_PROMPT = """You are a smart calendar assistant, skilled at recognizing event information from images (such as posters, flyers, screenshots).

Please carefully analyze the image content and extract all possible event information. For each event, you need to:
1. Identify event title (ALWAYS extract this if visible)
2. Extract start time (date and time) - can be null if not visible
3. Extract end time (if available)
4. Extract location information
5. Extract event description and other relevant information

Current time: {current_time}

**IMPORTANT: Be DECISIVE and always extract what you can see**

1. ALWAYS extract the event title if you can see any event name/title in the image
2. If you can see partial date info (like "February" or "15th"), include it in date_hint
3. ALWAYS provide search_keywords for any recognizable event - we will search online to complete missing info
4. Set start_time to null if you cannot determine the exact date/time - DO NOT skip the event
5. DO NOT ask for clarification - instead, extract what you can and provide search_keywords

Please return results in JSON format:
- events: Event array, each event contains title (REQUIRED), start_time (null if unknown), end_time, location, description
- needs_clarification: Set to false (we will search instead of asking)
- clarification_question: null (we don't ask, we search)
- search_keywords: ALWAYS provide keywords if you found any event info (e.g., ["Cursor AI Hackathon", "Hamburg", "2026"])
- confidence: How confident you are in the extracted information (0.0-1.0)
- date_hint: Any partial date information (e.g., "February 15-16", "next month", "2026")

Example 1 - Complete information:
{{"events": [{{"title": "Cursor AI Hackathon", "start_time": "2026-02-15T09:00:00", "end_time": "2026-02-16T18:00:00", "location": "Hamburg", "description": "2-day AI coding hackathon"}}], "needs_clarification": false, "clarification_question": null, "search_keywords": null, "confidence": 0.9, "date_hint": null}}

Example 2 - Event found but time unknown (we will search):
{{"events": [{{"title": "Berlin Tech Meetup", "start_time": null, "end_time": null, "location": "Berlin", "description": "Monthly tech meetup"}}], "needs_clarification": false, "clarification_question": null, "search_keywords": ["Berlin Tech Meetup", "2026", "date time"], "confidence": 0.4, "date_hint": null}}

Example 3 - Event found with partial date:
{{"events": [{{"title": "Hamburg Marathon", "start_time": null, "end_time": null, "location": "Hamburg", "description": "Annual marathon"}}], "needs_clarification": false, "clarification_question": null, "search_keywords": ["Hamburg Marathon", "April 2026"], "confidence": 0.6, "date_hint": "April 2026"}}"""
