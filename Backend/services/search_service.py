"""
Web Search Service - Search for event information using Google/SerpAPI

When event information is incomplete, automatically search the web
to find missing details.
"""
import json
from typing import List, Optional, Dict, NamedTuple

from config import settings
from logging_config import get_logger

logger = get_logger(__name__)


class SearchResult(NamedTuple):
    """Single search result"""
    title: str
    link: str
    snippet: str


class EventSearchResult(NamedTuple):
    """Structured event information extracted from search results"""
    event_name: str
    start_time: Optional[str]
    end_time: Optional[str]
    location: Optional[str]
    venue_address: Optional[str]
    description: Optional[str]
    ticket_url: Optional[str]
    price_range: Optional[str]
    source_url: str


async def search_event_info(
    query: str,
    location_hint: Optional[str] = None,
    date_hint: Optional[str] = None,
) -> List[SearchResult]:
    """
    Search web for event information
    
    Args:
        query: Search query (e.g., "Hamburg Philharmonic Concert February 2026")
        location_hint: Optional location context
        date_hint: Optional date context
    
    Returns:
        List of search results
    """
    logger.info(f"[SEARCH] Starting web search process")
    logger.info(f"[SEARCH] Query: {query}")
    logger.info(f"[SEARCH] Location hint: {location_hint or 'None'}")
    logger.info(f"[SEARCH] Date hint: {date_hint or 'None'}")
    
    if not settings.ENABLE_WEB_SEARCH:
        logger.info("[SEARCH] Web search is disabled (ENABLE_WEB_SEARCH=False)")
        return []

    # Check API keys availability
    has_serpapi = bool(settings.SERPAPI_KEY)
    has_tavily = bool(settings.TAVILY_API_KEY)
    logger.info(f"[SEARCH] API keys status - SerpAPI: {'configured' if has_serpapi else 'not configured'}, Tavily: {'configured' if has_tavily else 'not configured'}")
    
    if not has_serpapi and not has_tavily:
        logger.warning("[SEARCH] No search API keys configured (SERPAPI_KEY and TAVILY_API_KEY are both empty)")
        logger.info("[SEARCH] Search aborted - returning empty results")
        return []

    # Build optimized query
    full_query = query
    if location_hint:
        full_query += f" {location_hint}"
    if date_hint:
        full_query += f" {date_hint}"

    logger.info(f"[SEARCH] Full search query: {full_query}")
    
    try:
        # Try Tavily first (preferred - AI-optimized search)
        if has_tavily:
            logger.info("[SEARCH] Attempting search with Tavily (preferred)...")
            results = await _search_with_tavily(full_query)
            logger.info(f"[SEARCH] Tavily search completed - returned {len(results)} results")
            return results
        
        # Fallback to SerpAPI
        if has_serpapi:
            logger.info("[SEARCH] Attempting search with SerpAPI (fallback)...")
            results = await _search_with_serpapi(full_query)
            logger.info(f"[SEARCH] SerpAPI search completed - returned {len(results)} results")
            return results

        logger.warning("[SEARCH] No search API key available (both keys are empty)")
        logger.info("[SEARCH] Search aborted - returning empty results")
        return []

    except Exception as e:
        logger.error(f"[SEARCH] Web search failed with error: {e}", exc_info=True)
        logger.info("[SEARCH] Returning empty results due to error")
        return []


async def _search_with_serpapi(query: str) -> List[SearchResult]:
    """Search using SerpAPI (Google Search)"""
    try:
        from serpapi import GoogleSearch
        
        params = {
            "q": query,
            "api_key": settings.SERPAPI_KEY,
            "num": 5,
            "hl": "en",  # Language
        }
        
        search = GoogleSearch(params)
        results = search.get_dict()
        
        search_results = []
        for r in results.get("organic_results", []):
            search_results.append(SearchResult(
                title=r.get("title", ""),
                link=r.get("link", ""),
                snippet=r.get("snippet", ""),
            ))
        
        logger.info(f"SerpAPI returned {len(search_results)} results")
        return search_results
        
    except ImportError:
        logger.error("serpapi package not installed. Install with: pip install google-search-results")
        return []
    except Exception as e:
        logger.error(f"SerpAPI search failed: {e}", exc_info=True)
        return []


async def _search_with_tavily(query: str) -> List[SearchResult]:
    """Search using Tavily (AI-optimized search)"""
    logger.info(f"[SEARCH-Tavily] Starting Tavily search for: {query}")
    try:
        from tavily import TavilyClient

        logger.info("[SEARCH-Tavily] Initializing Tavily client...")
        client = TavilyClient(api_key=settings.TAVILY_API_KEY)
        
        logger.info("[SEARCH-Tavily] Sending search request (search_depth=advanced, max_results=5)...")
        response = client.search(
            query=query,
            search_depth="advanced",
            max_results=5,
        )

        logger.debug(f"[SEARCH-Tavily] Received response from Tavily")
        
        search_results = []
        results = response.get("results", [])
        logger.info(f"[SEARCH-Tavily] Found {len(results)} results")
        
        for idx, r in enumerate(results, 1):
            search_results.append(SearchResult(
                title=r.get("title", ""),
                link=r.get("url", ""),
                snippet=r.get("content", ""),
            ))
            logger.debug(f"[SEARCH-Tavily] Result {idx}: {r.get('title', 'No title')[:50]}...")

        logger.info(f"[SEARCH-Tavily] Successfully processed {len(search_results)} results")
        return search_results

    except ImportError:
        logger.error(
            "tavily package not installed. "
            "Install with: pip install tavily-python"
        )
        return []
    except Exception as e:
        logger.error(f"Tavily search failed: {e}", exc_info=True)
        return []


async def extract_event_details_from_search(
    search_results: List[SearchResult],
    partial_event: Dict,
) -> Optional[EventSearchResult]:
    """
    Use LLM to extract structured event info from search results

    Args:
        search_results: List of search results from web
        partial_event: Partial event information from initial parsing

    Returns:
        EventSearchResult with complete information, or None if fails
    """
    if not search_results:
        return None

    try:
        from services.llm_service import get_llm

        llm = get_llm()

        # Format search results for LLM
        context = "\n\n".join([
            f"Source: {r.link}\nTitle: {r.title}\nSnippet: {r.snippet}"
            for r in search_results[:5]  # Limit to top 5 results
        ])

        prompt = f"""I have partial event information that needs to be completed for a calendar entry:
- Title: {partial_event.get('title', 'Unknown')}
- Date hint: {partial_event.get('date_hint', 'Unknown')}
- Location hint: {partial_event.get('location_hint', 'Unknown')}

Here are web search results about this event:
{context}

IMPORTANT: Focus on extracting information for a calendar event. Priority:
1. **TIME** (MOST IMPORTANT): Extract exact start date and time. Look for dates, times, schedules.
2. **LOCATION**: Extract venue name and full address for navigation.
3. **DESCRIPTION**: Provide a helpful summary about the event.

Extract complete event details in JSON format:
{{
    "event_name": "Full official event name",
    "start_time": "ISO 8601 datetime (e.g., 2026-02-15T09:00:00) - REQUIRED if found",
    "end_time": "ISO 8601 datetime or null",
    "location": "Venue/Place name (e.g., Hamburg Congress Center)",
    "venue_address": "Full street address for navigation (e.g., Marseiller Str. 1, 20355 Hamburg)",
    "description": "Brief description of what the event is about, who it's for, what to expect",
    "ticket_url": "URL to register or buy tickets, or null",
    "price_range": "Price information or 'Free' if applicable, or null",
    "source_url": "Most authoritative source URL (official event page preferred)"
}}

Notes:
- For start_time, if only date is available without time, use the date with T00:00:00 for all-day events
- For multi-day events, set end_time to the last day
- If you cannot find specific information, return null for that field
- Include organizer name in description if available"""

        response = llm.invoke(prompt)

        # Parse JSON response
        content = response.content
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0]
        elif "```" in content:
            content = content.split("```")[1].split("```")[0]

        result_data = json.loads(content.strip())

        default_title = partial_event.get("title", "Unknown Event")
        event_name = result_data.get("event_name", default_title)
        source_url = result_data.get(
            "source_url",
            search_results[0].link
        )

        return EventSearchResult(
            event_name=event_name,
            start_time=result_data.get("start_time"),
            end_time=result_data.get("end_time"),
            location=result_data.get("location"),
            venue_address=result_data.get("venue_address"),
            description=result_data.get("description"),
            ticket_url=result_data.get("ticket_url"),
            price_range=result_data.get("price_range"),
            source_url=source_url,
        )

    except Exception as e:
        logger.error(
            f"Failed to extract event details from search: {e}",
            exc_info=True
        )
        return None


def merge_event_info(
    original_result: Dict,
    search_result: EventSearchResult,
) -> Dict:
    """
    Merge original LLM parsing result with web search results
    
    Priority for event information:
    1. Time (start_time, end_time) - MOST IMPORTANT
    2. Location (location, venue_address)
    3. Description - enrich with additional details

    Args:
        original_result: Original parsing result from LLM
        search_result: Complete information from web search

    Returns:
        Merged result dictionary
    """
    merged = original_result.copy()

    # Merge events - use search result to complete missing fields
    if merged.get("events") and len(merged["events"]) > 0:
        event = merged["events"][0]

        # Priority 1: TIME (most important for calendar events)
        # Always fill in missing time from search
        if not event.get("start_time") and search_result.start_time:
            event["start_time"] = search_result.start_time
            logger.info(f"[MERGE] Added start_time from search: {search_result.start_time}")
        
        if not event.get("end_time") and search_result.end_time:
            event["end_time"] = search_result.end_time
            logger.info(f"[MERGE] Added end_time from search: {search_result.end_time}")

        # Priority 2: LOCATION
        if not event.get("location"):
            # Combine location and venue address for completeness
            location_parts = []
            if search_result.location:
                location_parts.append(search_result.location)
            if search_result.venue_address and search_result.venue_address != search_result.location:
                location_parts.append(search_result.venue_address)
            if location_parts:
                event["location"] = ", ".join(location_parts)
                logger.info(f"[MERGE] Added location from search: {event['location']}")
        elif search_result.venue_address and search_result.venue_address not in event.get("location", ""):
            # Append venue address if not already included
            event["location"] = f"{event['location']}, {search_result.venue_address}"
            logger.info(f"[MERGE] Enhanced location with address: {event['location']}")

        # Priority 3: TITLE (prefer more complete title)
        if (not event.get("title") or
                event.get("title") == "Unknown" or
                (search_result.event_name and len(search_result.event_name) > len(event.get("title", "")))):
            event["title"] = search_result.event_name
            logger.info(f"[MERGE] Updated title from search: {search_result.event_name}")

        # Priority 4: DESCRIPTION - enrich with additional details
        description_parts = []
        
        # Keep original description if exists
        if event.get("description"):
            description_parts.append(event["description"])
        
        # Add search result description if different from original
        if search_result.description:
            original_desc = event.get("description", "").lower()
            search_desc = search_result.description.lower()
            # Only add if it provides new information
            if search_desc not in original_desc and len(search_result.description) > 20:
                if description_parts:
                    description_parts.append(f"\n---\n{search_result.description}")
                else:
                    description_parts.append(search_result.description)
        
        # Add ticket URL if available
        if search_result.ticket_url:
            description_parts.append(f"\n🎫 Tickets: {search_result.ticket_url}")
        
        # Add price range if available
        if search_result.price_range:
            description_parts.append(f"\n💰 Price: {search_result.price_range}")
        
        # Add source URL for reference
        if search_result.source_url:
            description_parts.append(f"\n🔗 More info: {search_result.source_url}")
        
        if description_parts:
            event["description"] = "".join(description_parts)
            logger.info(f"[MERGE] Enriched description (length: {len(event['description'])})")

    return merged


def is_event_complete(result: Dict) -> bool:
    """
    Check if event information is complete enough to create an event

    Args:
        result: Parsing result dictionary

    Returns:
        True if event has required fields (title and start_time)
    """
    if not result.get("events") or len(result["events"]) == 0:
        return False

    event = result["events"][0]

    # Required fields
    if not event.get("title") or event.get("title") == "Unknown":
        return False

    if not event.get("start_time"):
        return False

    return True


# ============================================================================
# Synchronous versions for use in non-async contexts
# ============================================================================

def search_event_info_sync(
    query: str,
    location_hint: Optional[str] = None,
    date_hint: Optional[str] = None,
) -> List[SearchResult]:
    """
    Synchronous version of search_event_info
    """
    logger.info(f"[SEARCH-SYNC] Starting web search")
    logger.info(f"[SEARCH-SYNC] Query: {query}")
    
    if not settings.ENABLE_WEB_SEARCH:
        logger.info("[SEARCH-SYNC] Web search is disabled")
        return []

    has_serpapi = bool(settings.SERPAPI_KEY)
    has_tavily = bool(settings.TAVILY_API_KEY)
    
    if not has_serpapi and not has_tavily:
        logger.warning("[SEARCH-SYNC] No search API keys configured")
        return []

    full_query = query
    if location_hint:
        full_query += f" {location_hint}"
    if date_hint:
        full_query += f" {date_hint}"

    logger.info(f"[SEARCH-SYNC] Full query: {full_query}")
    
    try:
        # Try Tavily first (preferred - AI-optimized search)
        if has_tavily:
            logger.info("[SEARCH-SYNC] Using Tavily (preferred)...")
            return _search_with_tavily_sync(full_query)
        
        # Fallback to SerpAPI
        if has_serpapi:
            logger.info("[SEARCH-SYNC] Using SerpAPI (fallback)...")
            return _search_with_serpapi_sync(full_query)

        return []

    except Exception as e:
        logger.error(f"[SEARCH-SYNC] Search failed: {e}", exc_info=True)
        return []


def _search_with_serpapi_sync(query: str) -> List[SearchResult]:
    """Synchronous SerpAPI search"""
    try:
        from serpapi import GoogleSearch
        
        params = {
            "q": query,
            "api_key": settings.SERPAPI_KEY,
            "num": 5,
            "hl": "en",
        }
        
        search = GoogleSearch(params)
        results = search.get_dict()
        
        search_results = []
        for r in results.get("organic_results", []):
            search_results.append(SearchResult(
                title=r.get("title", ""),
                link=r.get("link", ""),
                snippet=r.get("snippet", ""),
            ))
        
        logger.info(f"[SEARCH-SYNC] SerpAPI returned {len(search_results)} results")
        return search_results
        
    except ImportError:
        logger.error("[SEARCH-SYNC] serpapi not installed")
        return []
    except Exception as e:
        logger.error(f"[SEARCH-SYNC] SerpAPI failed: {e}")
        return []


def _search_with_tavily_sync(query: str) -> List[SearchResult]:
    """Synchronous Tavily search"""
    logger.info(f"[SEARCH-SYNC-Tavily] Searching: {query}")
    try:
        from tavily import TavilyClient

        client = TavilyClient(api_key=settings.TAVILY_API_KEY)
        
        response = client.search(
            query=query,
            search_depth="advanced",
            max_results=5,
        )
        
        search_results = []
        for r in response.get("results", []):
            search_results.append(SearchResult(
                title=r.get("title", ""),
                link=r.get("url", ""),
                snippet=r.get("content", ""),
            ))
        
        logger.info(f"[SEARCH-SYNC] Tavily returned {len(search_results)} results")
        return search_results
        
    except ImportError:
        logger.error("[SEARCH-SYNC] tavily not installed")
        return []
    except Exception as e:
        logger.error(f"[SEARCH-SYNC] Tavily failed: {e}")
        return []


def extract_event_details_from_search_sync(
    search_results: List[SearchResult],
    partial_event: Dict,
) -> Optional[EventSearchResult]:
    """
    Synchronous version of extract_event_details_from_search
    """
    if not search_results:
        return None

    try:
        from services.llm_service import get_llm

        llm = get_llm()

        context = "\n\n".join([
            f"Source: {r.link}\nTitle: {r.title}\nSnippet: {r.snippet}"
            for r in search_results[:5]
        ])

        prompt = f"""I have partial event information that needs to be completed:
- Title: {partial_event.get('title', 'Unknown')}
- Date hint: {partial_event.get('date_hint', 'Unknown')}
- Location hint: {partial_event.get('location_hint', 'Unknown')}

Web search results:
{context}

Extract event details in JSON:
{{
    "event_name": "Full event name",
    "start_time": "ISO 8601 (e.g., 2026-02-15T09:00:00)",
    "end_time": "ISO 8601 or null",
    "location": "Venue name",
    "venue_address": "Full address",
    "description": "Brief description",
    "ticket_url": "URL or null",
    "price_range": "Price or null",
    "source_url": "Source URL"
}}

Use T00:00:00 for all-day events if only date is available."""

        response = llm.invoke(prompt)

        content = response.content
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0]
        elif "```" in content:
            content = content.split("```")[1].split("```")[0]

        result_data = json.loads(content.strip())

        return EventSearchResult(
            event_name=result_data.get("event_name", partial_event.get("title", "Unknown")),
            start_time=result_data.get("start_time"),
            end_time=result_data.get("end_time"),
            location=result_data.get("location"),
            venue_address=result_data.get("venue_address"),
            description=result_data.get("description"),
            ticket_url=result_data.get("ticket_url"),
            price_range=result_data.get("price_range"),
            source_url=result_data.get("source_url", search_results[0].link if search_results else ""),
        )

    except Exception as e:
        logger.error(f"[SEARCH-SYNC] Failed to extract event details: {e}")
        return None
