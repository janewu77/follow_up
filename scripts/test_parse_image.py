#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试图像识别功能
"""
import requests
import base64
import os
from pathlib import Path

BASE_URL = "http://localhost:8000"
DOCS_DIR = Path(__file__).parent.parent / "Docs"


def get_image_base64(image_path: str) -> str:
    """读取图片并转换为 base64"""
    with open(image_path, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")


def test_parse_image():
    """测试图像解析功能"""
    print("\n" + "=" * 60)
    print("  Test Image Recognition")
    print("=" * 60)
    
    # 1. Login
    print("\n1. Login...")
    response = requests.post(
        f"{BASE_URL}/api/auth/login",
        json={"username": "moni", "password": "moni123"},
        timeout=5
    )
    if response.status_code != 200:
        print(f"   [FAIL] Login failed: {response.status_code}")
        return
    token = response.json()["access_token"]
    print(f"   [OK] Login success, Token: {token[:10]}...")
    
    # 2. Find test images
    print("\n2. Finding test images...")
    test_images = []
    for ext in ["*.png", "*.jpg", "*.jpeg"]:
        test_images.extend(DOCS_DIR.glob(ext))
    
    if not test_images:
        print("   [FAIL] No test images found in Docs folder")
        return
    
    print(f"   Found {len(test_images)} image(s)")
    
    # 3. Test image parsing
    print("\n3. Testing image parsing...")
    
    for i, image_path in enumerate(test_images[:3], 1):  # Test first 3 images
        print(f"\n   Test {i}: {image_path.name}")
        print(f"   File size: {image_path.stat().st_size / 1024:.1f} KB")
        
        try:
            image_base64 = get_image_base64(str(image_path))
            print(f"   Base64 length: {len(image_base64)} chars")
            
            response = requests.post(
                f"{BASE_URL}/api/parse",
                headers={"Authorization": f"Bearer {token}"},
                json={
                    "input_type": "image",
                    "image_base64": image_base64,
                    "additional_note": f"Test image: {image_path.name}"
                },
                timeout=30  # Vision API may take longer
            )
            
            if response.status_code == 200:
                data = response.json()
                events = data.get("events", [])
                print(f"   [OK] Parsed successfully, found {len(events)} event(s)")
                
                for j, event in enumerate(events, 1):
                    print(f"\n   Event {j}:")
                    print(f"     Title: {event.get('title')}")
                    print(f"     Start: {event.get('start_time')}")
                    print(f"     End: {event.get('end_time', 'N/A')}")
                    print(f"     Location: {event.get('location', 'N/A')}")
                    desc = event.get('description', '')
                    if desc:
                        print(f"     Description: {desc[:80]}...")
                    print(f"     Source: {event.get('source_type')}")
            else:
                print(f"   [FAIL] Parse failed: {response.status_code}")
                print(f"   Error: {response.text[:200]}")
                
        except Exception as e:
            print(f"   [FAIL] Error: {e}")
    
    print("\n" + "=" * 60)
    print("  Test Completed")
    print("=" * 60)


def test_with_custom_image(image_path: str):
    """Test with a custom image path"""
    print("\n" + "=" * 60)
    print(f"  Test Custom Image: {image_path}")
    print("=" * 60)
    
    if not os.path.exists(image_path):
        print(f"   [FAIL] Image not found: {image_path}")
        return
    
    # Login
    response = requests.post(
        f"{BASE_URL}/api/auth/login",
        json={"username": "moni", "password": "moni123"},
        timeout=5
    )
    if response.status_code != 200:
        print(f"   [FAIL] Login failed")
        return
    token = response.json()["access_token"]
    
    # Parse image
    image_base64 = get_image_base64(image_path)
    print(f"   Image size: {os.path.getsize(image_path) / 1024:.1f} KB")
    
    response = requests.post(
        f"{BASE_URL}/api/parse",
        headers={"Authorization": f"Bearer {token}"},
        json={
            "input_type": "image",
            "image_base64": image_base64,
            "additional_note": ""
        },
        timeout=60
    )
    
    if response.status_code == 200:
        data = response.json()
        events = data.get("events", [])
        print(f"\n   [OK] Found {len(events)} event(s)")
        
        for j, event in enumerate(events, 1):
            print(f"\n   Event {j}:")
            print(f"     Title: {event.get('title')}")
            print(f"     Start: {event.get('start_time')}")
            print(f"     End: {event.get('end_time', 'N/A')}")
            print(f"     Location: {event.get('location', 'N/A')}")
            print(f"     Description: {event.get('description', 'N/A')}")
    else:
        print(f"   [FAIL] {response.status_code}: {response.text}")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        # Test with custom image
        test_with_custom_image(sys.argv[1])
    else:
        # Test with default images
        test_parse_image()
