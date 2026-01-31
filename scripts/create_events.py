#!/usr/bin/env python3
"""
创建10个测试事件到线上环境
"""
import sys

try:
    import requests
except ImportError:
    print("❌ 错误: 需要安装 requests 库")
    print("   运行: pip install requests")
    sys.exit(1)

from datetime import datetime, timedelta

# 配置
# BASE_URL = "https://web-production-d2e00.up.railway.app"  # 线上地址
BASE_URL = "http://localhost:8000"  # 本地地址
USERNAME = "alice"
PASSWORD = "alice123"

# 10个不同的事件数据
EVENTS = [
    {
        "title": "团队周会",
        "start_time": (datetime.now() + timedelta(days=1)).replace(hour=10, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=1)).replace(hour=11, minute=30, second=0, microsecond=0).isoformat(),
        "location": "会议室 A",
        "description": "每周团队同步会议，讨论项目进度",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "汉堡爱乐音乐会",
        "start_time": (datetime.now() + timedelta(days=15)).replace(hour=19, minute=30, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=15)).replace(hour=22, minute=0, second=0, microsecond=0).isoformat(),
        "location": "Elbphilharmonie, Hamburg",
        "description": "贝多芬第九交响曲\n指挥：Alan Gilbert",
        "source_type": "image",
        "is_followed": True,
    },
    {
        "title": "同学聚餐",
        "start_time": (datetime.now() + timedelta(days=5)).replace(hour=19, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": None,
        "location": "老地方川菜馆",
        "description": "大学同学聚会，记得带礼物",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "项目评审会议",
        "start_time": (datetime.now() + timedelta(days=3)).replace(hour=14, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=3)).replace(hour=16, minute=0, second=0, microsecond=0).isoformat(),
        "location": "公司会议室 B",
        "description": "Q1 项目进度评审，准备PPT",
        "source_type": "text",
        "is_followed": False,
    },
    {
        "title": "健身房训练",
        "start_time": (datetime.now() + timedelta(days=2)).replace(hour=18, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=2)).replace(hour=19, minute=30, second=0, microsecond=0).isoformat(),
        "location": "健身房",
        "description": "力量训练 + 有氧运动",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "技术分享会",
        "start_time": (datetime.now() + timedelta(days=7)).replace(hour=15, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=7)).replace(hour=17, minute=0, second=0, microsecond=0).isoformat(),
        "location": "线上会议",
        "description": "分享 Flutter 开发经验",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "周末郊游",
        "start_time": (datetime.now() + timedelta(days=6)).replace(hour=9, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=6)).replace(hour=17, minute=0, second=0, microsecond=0).isoformat(),
        "location": "森林公园",
        "description": "和朋友一起爬山、野餐",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "电影首映",
        "start_time": (datetime.now() + timedelta(days=10)).replace(hour=20, minute=0, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=10)).replace(hour=22, minute=30, second=0, microsecond=0).isoformat(),
        "location": "万达影城",
        "description": "期待已久的新片首映",
        "source_type": "text",
        "is_followed": False,
    },
    {
        "title": "医生预约",
        "start_time": (datetime.now() + timedelta(days=4)).replace(hour=10, minute=30, second=0, microsecond=0).isoformat(),
        "end_time": (datetime.now() + timedelta(days=4)).replace(hour=11, minute=0, second=0, microsecond=0).isoformat(),
        "location": "市医院",
        "description": "年度体检",
        "source_type": "text",
        "is_followed": True,
    },
    {
        "title": "生日派对",
        "start_time": (datetime.now() + timedelta(days=12)).replace(hour=18, minute=30, second=0, microsecond=0).isoformat(),
        "end_time": None,
        "location": "朋友家",
        "description": "庆祝朋友的生日，准备蛋糕",
        "source_type": "text",
        "is_followed": True,
    },
]


def main():
    print(f"🚀 开始创建事件到: {BASE_URL}")
    print("-" * 50)

    # 1. 登录获取 Token
    print("1️⃣ 登录中...")
    login_url = f"{BASE_URL}/api/auth/login"
    login_data = {"username": USERNAME, "password": PASSWORD}

    try:
        response = requests.post(login_url, json=login_data)
        response.raise_for_status()
        login_result = response.json()
        token = login_result["access_token"]
        print(f"✅ 登录成功! Token: {token[:10]}...")
    except requests.exceptions.RequestException as e:
        print(f"❌ 登录失败: {e}")
        if hasattr(e.response, 'text'):
            print(f"   响应: {e.response.text}")
        return

    print("-" * 50)

    # 2. 创建事件
    created_count = 0
    failed_count = 0

    events_url = f"{BASE_URL}/api/events"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    for i, event_data in enumerate(EVENTS, 1):
        print(f"{i}️⃣ 创建事件: {event_data['title']}...")
        try:
            # 移除 None 值
            payload = {k: v for k, v in event_data.items() if v is not None}
            response = requests.post(events_url, json=payload, headers=headers)
            response.raise_for_status()
            result = response.json()
            print(f"   ✅ 成功! ID: {result['id']}")
            created_count += 1
        except requests.exceptions.RequestException as e:
            print(f"   ❌ 失败: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"      响应: {e.response.text}")
            failed_count += 1

    print("-" * 50)
    print(f"📊 完成! 成功: {created_count}, 失败: {failed_count}")

    # 3. 验证：获取事件列表
    print("\n🔍 验证事件列表...")
    try:
        response = requests.get(events_url, headers=headers)
        response.raise_for_status()
        result = response.json()
        print(f"✅ 当前共有 {len(result['events'])} 个事件")
        for event in result['events'][:5]:  # 只显示前5个
            print(f"   - [{event['id']}] {event['title']} @ {event['start_time']}")
        if len(result['events']) > 5:
            print(f"   ... 还有 {len(result['events']) - 5} 个事件")
    except requests.exceptions.RequestException as e:
        print(f"❌ 获取事件列表失败: {e}")


if __name__ == "__main__":
    main()
