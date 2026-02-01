#!/usr/bin/env python3
"""
Create 10 test events for testing environment
"""
import sys

try:
    import requests
except ImportError:
    print("[ERROR] requests library is required")
    print("   Run: pip install requests")
    sys.exit(1)

from datetime import datetime, timedelta

# Configuration
# BASE_URL = "https://web-production-d2e00.up.railway.app"  # Production URL
BASE_URL = "http://localhost:8000"  # Local URL
USERNAME = "alice"
PASSWORD = "alice123"

# 10 different event data
EVENTS = [
    {
        "title": "Team Weekly Meeting",
        "start_time": (datetime.now() + timedelta(days=1)).replace(hour=10, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=1)).replace(hour=11, minute=30, second=0, microsecond=0).isoformat(),
        "location": "Conference Room A",
        "description": "Weekly team sync meeting to discuss project progress",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "Hamburg Philharmonic Concert",
        "start_time": (datetime.now() + timedelta(days=15)).replace(hour=19, minute=30, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=15)).replace(hour=22, minute=0, second=0, microsecond=0).isoformat(),
        "location": "Elbphilharmonie, Hamburg",
        "description": "Beethoven Symphony No. 9\nConductor: Alan Gilbert",
        "source_type": "image",
        "is_followed": True,
    },
    {
        "title": "College Reunion Dinner",
        "start_time": (datetime.now() + timedelta(days=5)).replace(hour=19, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": None,
        "location": "Old Place Sichuan Restaurant",
        "description": "College classmates gathering, remember to bring a gift",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "Project Review Meeting",
        "start_time": (datetime.now() + timedelta(days=3)).replace(hour=14, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=3)).replace(hour=16, minute=0, second=0, microsecond=0).isoformat(),
        "location": "Company Conference Room B",
        "description": "Q1 project progress review, prepare PPT",
        "source_type": "text",
        "is_followed": False,
    },
    {
        "title": "Gym Training",
        "start_time": (datetime.now() + timedelta(days=2)).replace(hour=18, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=2)).replace(hour=19, minute=30, second=0, microsecond=0).isoformat(),
        "location": "Fitness Center",
        "description": "Strength training + cardio exercise",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "Tech Sharing Session",
        "start_time": (datetime.now() + timedelta(days=7)).replace(hour=15, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=7)).replace(hour=17, minute=0, second=0, microsecond=0).isoformat(),
        "location": "Online Meeting",
        "description": "Share Flutter development experience",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "Weekend Outing",
        "start_time": (datetime.now() + timedelta(days=6)).replace(hour=9, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=6)).replace(hour=17, minute=0, second=0, microsecond=0).isoformat(),
        "location": "Forest Park",
        "description": "Hiking and picnic with friends",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "Movie Premiere",
        "start_time": (datetime.now() + timedelta(days=10)).replace(hour=20, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=10)).replace(hour=22, minute=30, second=0, microsecond=0).isoformat(),
        "location": "Wanda Cinema",
        "description": "Long-awaited new movie premiere",
        "source_type": "text",
        "is_followed": False,
    },
    {
        "title": "Doctor Appointment",
        "start_time": (datetime.now() + timedelta(days=4)).replace(hour=10, minute=30, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=4)).replace(hour=11, minute=0, second=0, microsecond=0).isoformat(),
        "location": "City Hospital",
        "description": "Annual health checkup",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "Birthday Party",
        "start_time": (datetime.now() + timedelta(days=12)).replace(hour=18, minute=30, second=0, microsecond=0).isoformat(),
        "end_time": None,
        "location": "Friend's House",
        "description": "Celebrate friend's birthday, prepare cake",
        "source_type": "text",
        "is_followed": True,
    },
]


def main():
    print(f"[START] Creating events at: {BASE_URL}")
    print("-" * 50)

    # 1. Login to get token
    print("1. Logging in...")
    login_url = f"{BASE_URL}/api/auth/login"
    login_data = {"username": USERNAME, "password": PASSWORD}

    try:
        response = requests.post(login_url, json=login_data)
        response.raise_for_status()
        login_result = response.json()
        token = login_result["access_token"]
        print(f"[OK] Login successful! Token: {token[:10]}...")
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] Login failed: {e}")
        if hasattr(e.response, 'text'):
            print(f"   Response: {e.response.text}")
        return

    print("-" * 50)

    # 2. Create events
    created_count = 0
    failed_count = 0

    events_url = f"{BASE_URL}/api/events"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    for i, event_data in enumerate(EVENTS, 1):
        print(f"{i}. Creating event: {event_data['title']}...")
        try:
            # Remove None values
            payload = {k: v for k, v in event_data.items() if v is not None}
            response = requests.post(events_url, json=payload, headers=headers)
            response.raise_for_status()
            result = response.json()
            print(f"   [OK] Success! ID: {result['id']}")
            created_count += 1
        except requests.exceptions.RequestException as e:
            print(f"   [ERROR] Failed: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"      Response: {e.response.text}")
            failed_count += 1

    print("-" * 50)
    print(f"[SUMMARY] Completed! Success: {created_count}, Failed: {failed_count}")

    # 3. Verify: Get event list
    print("\n[VERIFY] Checking event list...")
    try:
        response = requests.get(events_url, headers=headers)
        response.raise_for_status()
        result = response.json()
        print(f"[OK] Total events: {len(result['events'])}")
        for event in result['events'][:5]:  # Show first 5 only
            print(f"   - [{event['id']}] {event['title']} @ {event['start_time']}")
        if len(result['events']) > 5:
            print(f"   ... and {len(result['events']) - 5} more events")
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] Failed to get event list: {e}")


if __name__ == "__main__":
    main()
