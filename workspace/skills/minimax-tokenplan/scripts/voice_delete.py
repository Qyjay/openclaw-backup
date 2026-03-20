#!/usr/bin/env python3
"""
MiniMax Token Plan — 删除音色
POST /v1/voice_delete
"""
import argparse, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import BASE_URL, get_api_key

import requests

def delete_voice(voice_id: str):
    url = f"{BASE_URL}/v1/voice_delete"
    headers = {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json"
    }
    payload = {"voice_id": voice_id}
    resp = requests.post(url, headers=headers, json=payload, timeout=30)
    resp.raise_for_status()
    result = resp.json()
    base = result.get("base_resp", {})
    if base.get("status_code") == 0 or base.get("status_code") is None:
        print(f"✅ 音色已删除: {voice_id}")
    else:
        print(f"❌ 删除失败: {base.get('status_msg')}")


def main():
    p = argparse.ArgumentParser(description="删除 MiniMax 音色")
    p.add_argument("--voice-id", "-v", required=True, help="要删除的 voice_id")
    args = p.parse_args()
    delete_voice(args.voice_id)

if __name__ == "__main__":
    main()
