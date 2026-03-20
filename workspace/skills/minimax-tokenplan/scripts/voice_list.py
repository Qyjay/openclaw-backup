#!/usr/bin/env python3
"""
MiniMax Token Plan — 查询可用音色
POST /v1/get_voice
"""
import argparse, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import BASE_URL, get_api_key

import requests

def list_voices(voice_type: str = "all"):
    url = f"{BASE_URL}/v1/get_voice"
    headers = {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json"
    }
    payload = {"voice_type": voice_type}
    resp = requests.post(url, headers=headers, json=payload, timeout=30)
    resp.raise_for_status()
    result = resp.json()

    base = result.get("base_resp", {})
    if base.get("status_code") != 0 and base.get("status_code") is not None:
        print(f"❌ 查询失败: {base.get('status_msg')}")
        return

    # 系统音色
    system = result.get("system_voice", [])
    if system:
        print(f"\n🎙️ 系统音色（共 {len(system)} 个）:")
        print(f"{'voice_id':<45} {'voice_name':<20}")
        print("-" * 65)
        for v in system[:30]:
            vid = v.get("voice_id", "")
            name = (v.get("voice_name") or [""])[0] if v.get("voice_name") else ""
            print(f"  {vid:<43} {name}")

    # 克隆音色
    cloned = result.get("voice_cloning", [])
    if cloned:
        print(f"\n🎙️ 已克隆音色（共 {len(cloned)} 个）:")
        for v in cloned:
            vid = v.get("voice_id", "")
            desc = (v.get("description") or [])[:50]
            print(f"  • {vid} — {desc}")

    # 文生音色
    generated = result.get("voice_generation", [])
    if generated:
        print(f"\n🎙️ 文生音色（共 {len(generated)} 个）:")
        for v in generated:
            vid = v.get("voice_id", "")
            name = (v.get("voice_name") or [""])[0] if v.get("voice_name") else ""
            print(f"  • {vid} — {name}")


def main():
    p = argparse.ArgumentParser(description="查询 MiniMax 可用音色")
    p.add_argument("--type", "-t", default="all",
                   choices=["system", "voice_cloning", "voice_generation", "all"],
                   help="音色类型（默认 all）")
    args = p.parse_args()
    list_voices(args.type)

if __name__ == "__main__":
    main()
