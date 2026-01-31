#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试文本识别功能
"""
import requests
import json
from datetime import datetime

BASE_URL = "http://localhost:8000"

def test_parse_text():
    """测试文本解析功能"""
    print("\n" + "=" * 60)
    print("  测试文本识别功能")
    print("=" * 60)
    
    # 1. 登录获取 token
    print("\n1. 登录...")
    response = requests.post(
        f"{BASE_URL}/api/auth/login",
        json={"username": "moni", "password": "moni123"},
        timeout=5
    )
    if response.status_code != 200:
        print(f"   [FAIL] 登录失败: {response.status_code}")
        return
    token = response.json()["access_token"]
    print(f"   [OK] 登录成功，Token: {token[:10]}...")
    
    # 2. 测试不同的文本输入
    test_cases = [
        {
            "name": "明天下午3点开会",
            "text": "明天下午3点在星巴克开会",
            "note": "记得带电脑"
        },
        {
            "name": "后天晚上7点聚餐",
            "text": "后天晚上7点和朋友聚餐",
            "note": "在市中心"
        },
        {
            "name": "下周音乐会",
            "text": "下周六晚上8点去听音乐会",
            "note": "Elbphilharmonie"
        },
        {
            "name": "明天上午10点面试",
            "text": "明天上午10点有面试",
            "note": "准备简历"
        }
    ]
    
    print("\n2. 测试文本解析...")
    for i, test_case in enumerate(test_cases, 1):
        print(f"\n   测试 {i}: {test_case['name']}")
        print(f"   输入文本: {test_case['text']}")
        print(f"   附加备注: {test_case['note']}")
        
        response = requests.post(
            f"{BASE_URL}/api/parse",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "input_type": "text",
                "text_content": test_case["text"],
                "additional_note": test_case["note"]
            },
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            events = data.get("events", [])
            print(f"   [OK] 解析成功，识别到 {len(events)} 个事件")
            
            for j, event in enumerate(events, 1):
                print(f"\n   事件 {j}:")
                print(f"     标题: {event.get('title')}")
                print(f"     开始时间: {event.get('start_time')}")
                print(f"     结束时间: {event.get('end_time', '未设置')}")
                print(f"     地点: {event.get('location', '未设置')}")
                print(f"     描述: {event.get('description', '')[:50]}...")
                print(f"     来源类型: {event.get('source_type')}")
        else:
            print(f"   [FAIL] 解析失败: {response.status_code}")
            print(f"   错误: {response.text}")
    
    print("\n" + "=" * 60)
    print("  测试完成")
    print("=" * 60)

if __name__ == "__main__":
    try:
        test_parse_text()
    except Exception as e:
        print(f"\n[ERROR] 测试出错: {e}")
        import traceback
        traceback.print_exc()
