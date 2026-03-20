#!/usr/bin/env python3
"""
MiniMax Token Plan — 音色设计（文生音色）
POST /v1/voice_design
"""
import argparse, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import BASE_URL, get_api_key

import requests

def voice_design(
    text: str,
    voice_id: str = None,
    gender: str = None,
    accent: str = None,
):
    url = f"{BASE_URL}/v1/voice_design"
    headers = {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json"
    }
    payload = {"text": text}
    if voice_id:
        payload["voice_id"] = voice_id
    if gender:
        payload["gender"] = gender
    if accent:
        payload["accent"] = accent

    print(f"🎙️ 创建音色设计方案...")
    resp = requests.post(url, headers=headers, json=payload, timeout=60)
    resp.raise_for_status()
    result = resp.json()

    base = result.get("base_resp", {})
    if base.get("status_code") != 0 and base.get("status_code") is not None:
        print(f"❌ 设计失败: {base.get('status_msg')}")
        return

    data = result.get("data", {})
    designed_voice_id = data.get("voice_id") or voice_id
    preview_url = data.get("preview_url") or data.get("audio_url")

    print(f"✅ 音色设计成功！")
    print(f"   voice_id: {designed_voice_id}")
    if preview_url:
        print(f"   试听: {preview_url}")


def main():
    p = argparse.ArgumentParser(description="MiniMax 文生音色（音色设计）")
    p.add_argument("--text", "-t", required=True, help="音色描述，如'温柔的女声，带有轻微的南方口音'")
    p.add_argument("--voice-id", "-v", help="自定义 voice_id")
    p.add_argument("--gender", "-g", choices=["male","female"], help="性别")
    p.add_argument("--accent", "-a", help="口音，如 chinese_mandarin")
    args = p.parse_args()
    voice_design(text=args.text, voice_id=args.voice_id, gender=args.gender, accent=args.accent)

if __name__ == "__main__":
    main()
