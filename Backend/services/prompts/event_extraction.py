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
    start_time: str = Field(description="Start time, ISO 8601 format, e.g.: 2026-02-01T15:00:00")
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
1. Identify event title
2. Extract start time (date and time)
3. Extract end time (if available)
4. Extract location information
5. Extract event description and other relevant information

Current time: {current_time}

**Important: Ask user when information is incomplete**
If the following key information is missing or unrecognizable in the image, set needs_clarification=true and ask a clarification question:
- Date or time is unclear (e.g., only time without date, or year is unclear)
- Location information is ambiguous
- Image quality is poor and cannot be fully recognized

Clarification questions should be concise and friendly, ask only one most important question at a time.

Please return results in JSON format:
- events: Event array, each event contains title, start_time, end_time, location, description
- needs_clarification: Whether clarification is needed (boolean)
- clarification_question: Clarification question (only when needs_clarification=true)
- search_keywords: List of keywords that could be used to search for this event online (e.g., ["Hamburg Philharmonic", "Beethoven Symphony", "February 2026"])
- confidence: How confident you are in the extracted information (0.0-1.0)
- date_hint: Any partial date information (e.g., "February", "next month", "2026")

Example 1 - Complete information:
{{"events": [...], "needs_clarification": false, "clarification_question": null, "search_keywords": null, "confidence": 0.9, "date_hint": null}}

Example 2 - Needs clarification:
{{"events": [], "needs_clarification": true, "clarification_question": "Is the event in the image happening this year or next year?", "search_keywords": ["Elbphilharmonie", "Beethoven", "concert"], "confidence": 0.3, "date_hint": null}}

Example 3 - Partial information extractable, but still needs clarification:
{{"events": [{{"title": "Concert", "start_time": "2026-03-15T19:30:00", ...}}], "needs_clarification": true, "clarification_question": "The image doesn't show the year, I'm assuming it's 2026, is that correct?", "search_keywords": ["Concert", "March 2026"], "confidence": 0.6, "date_hint": "March 2026"}}"""
