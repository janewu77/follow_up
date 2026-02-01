"""
Tests for Web Search Service
"""
import pytest
from unittest.mock import patch, MagicMock
from services.search_service import (
    SearchResult,
    EventSearchResult,
    search_event_info,
    extract_event_details_from_search,
    merge_event_info,
    is_event_complete,
)


@pytest.fixture
def mock_search_results():
    """Mock search results"""
    return [
        SearchResult(
            title="Beethoven at Elbphilharmonie",
            link="https://www.elbphilharmonie.de/event/123",
            snippet="February 15, 2026 at 7:30 PM. Beethoven Symphony No. 9 performed by Hamburg Philharmonic Orchestra..."
        ),
        SearchResult(
            title="Elbphilharmonie Concert Schedule",
            link="https://www.elbphilharmonie.de/schedule",
            snippet="Upcoming concerts at Elbphilharmonie Hamburg..."
        ),
    ]


@pytest.fixture
def mock_event_search_result():
    """Mock event search result"""
    return EventSearchResult(
        event_name="Beethoven Symphony No. 9",
        start_time="2026-02-15T19:30:00",
        end_time="2026-02-15T22:00:00",
        location="Elbphilharmonie",
        venue_address="Platz der Deutschen Einheit 1, Hamburg",
        description="Hamburg Philharmonic Orchestra performs Beethoven's Symphony No. 9",
        ticket_url="https://tickets.example.com",
        price_range="€49 - €120",
        source_url="https://www.elbphilharmonie.de/event/123",
    )


@pytest.mark.asyncio
@patch("services.search_service.settings")
@patch("services.search_service._search_with_serpapi")
async def test_search_event_info_serpapi(
    mock_serpapi_search,
    mock_settings,
    mock_search_results
):
    """Test web search using SerpAPI"""
    mock_settings.ENABLE_WEB_SEARCH = True
    mock_settings.SERPAPI_KEY = "test_key"
    mock_settings.TAVILY_API_KEY = ""
    
    mock_serpapi_search.return_value = [
        SearchResult(
            title="Beethoven at Elbphilharmonie",
            link="https://www.elbphilharmonie.de/event/123",
            snippet="February 15, 2026 at 7:30 PM..."
        )
    ]
    
    results = await search_event_info("Elbphilharmonie Beethoven")
    
    assert len(results) == 1
    assert "Beethoven" in results[0].title
    assert results[0].link.startswith("https://")


@pytest.mark.asyncio
@patch("services.search_service.settings")
@patch("services.search_service._search_with_tavily")
async def test_search_event_info_tavily(
    mock_tavily_search,
    mock_settings,
    mock_search_results
):
    """Test web search using Tavily"""
    mock_settings.ENABLE_WEB_SEARCH = True
    mock_settings.SERPAPI_KEY = ""
    mock_settings.TAVILY_API_KEY = "test_key"
    
    mock_tavily_search.return_value = [
        SearchResult(
            title="Beethoven Concert",
            link="https://example.com",
            snippet="Beethoven Symphony No. 9..."
        )
    ]
    
    results = await search_event_info("Beethoven concert")
    
    assert len(results) >= 1


@pytest.mark.asyncio
@patch("services.search_service.settings")
async def test_search_disabled(mock_settings):
    """Test that search is skipped when disabled"""
    mock_settings.ENABLE_WEB_SEARCH = False
    
    results = await search_event_info("test query")
    
    assert len(results) == 0


@pytest.mark.asyncio
@patch("services.llm_service.get_llm")
async def test_extract_event_details_from_search(mock_get_llm, mock_search_results):
    """Test extracting event details from search results"""
    mock_llm = MagicMock()
    mock_response = MagicMock()
    mock_response.content = '''{
        "event_name": "Beethoven Symphony No. 9",
        "start_time": "2026-02-15T19:30:00",
        "end_time": "2026-02-15T22:00:00",
        "location": "Elbphilharmonie",
        "venue_address": "Platz der Deutschen Einheit 1, Hamburg",
        "description": "Hamburg Philharmonic Orchestra",
        "ticket_url": "https://tickets.example.com",
        "price_range": "€49 - €120",
        "source_url": "https://www.elbphilharmonie.de/event/123"
    }'''
    mock_llm.invoke.return_value = mock_response
    mock_get_llm.return_value = mock_llm
    
    result = await extract_event_details_from_search(
        mock_search_results,
        partial_event={
            "title": "Beethoven",
            "date_hint": "February",
            "location_hint": "Hamburg",
        }
    )
    
    assert result is not None
    assert result.event_name == "Beethoven Symphony No. 9"
    assert result.start_time == "2026-02-15T19:30:00"
    assert result.location == "Elbphilharmonie"


def test_merge_event_info(mock_event_search_result):
    """Test merging original result with search results"""
    original = {
        "events": [{
            "title": "Beethoven",  # Shorter title, should be replaced
            "start_time": None,
            "location": None,
        }],
        "needs_clarification": True,
    }
    
    merged = merge_event_info(original, mock_event_search_result)
    
    # Title should be updated to longer, more complete version
    assert merged["events"][0]["title"] == "Beethoven Symphony No. 9"
    assert merged["events"][0]["start_time"] == "2026-02-15T19:30:00"
    assert merged["events"][0]["location"] == "Elbphilharmonie"


def test_is_event_complete():
    """Test checking if event is complete"""
    # Complete event
    complete_result = {
        "events": [{
            "title": "Test Event",
            "start_time": "2026-02-15T19:30:00",
        }]
    }
    assert is_event_complete(complete_result) is True
    
    # Incomplete event (missing title)
    incomplete_result1 = {
        "events": [{
            "title": "",
            "start_time": "2026-02-15T19:30:00",
        }]
    }
    assert is_event_complete(incomplete_result1) is False
    
    # Incomplete event (missing start_time)
    incomplete_result2 = {
        "events": [{
            "title": "Test Event",
            "start_time": None,
        }]
    }
    assert is_event_complete(incomplete_result2) is False
    
    # Empty events
    empty_result = {
        "events": []
    }
    assert is_event_complete(empty_result) is False
