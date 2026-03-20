#!/usr/bin/env python3
"""
MiniMax Token Plan — 歌词生成
POST /v1/lyrics_generation
"""
import argparse, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import BASE_URL, get_api_key

import requests

def lyrics_gen(
    model: str = "lyrics-01",
    prompt: str = None,
    genre: str = None,
    mood: str = None,
    output: str = None,
):
    url = f"{BASE_URL}/v1/lyrics_generation"
    headers = {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json"
    }
    payload = {"model": model}

    if prompt:
        payload["prompt"] = prompt
    if genre:
        payload["genre"] = genre
    if mood:
        payload["mood"] = mood

    print(f"📝 生成歌词中...")
    resp = requests.post(url, headers=headers, json=payload, timeout=60)
    resp.raise_for_status()
    result = resp.json()

    base = result.get("base_resp", {})
    if base.get("status_code") != 0 and base.get("status_code") is not None:
        print(f"❌ 生成失败: {base.get('status_msg')}")
        return

    lyrics = result.get("lyrics") or result.get("data", {}).get("lyrics", "")
    if not lyrics:
        print(f"响应: {result}")
        return

    if output:
        os.makedirs(os.path.dirname(output) or ".", exist_ok=True)
        with open(output, "w", encoding="utf-8") as f:
            f.write(lyrics)
        print(f"✅ 歌词已保存: {output}")
    else:
        print(f"\n📝 生成的歌词:\n{lyrics}")


def main():
    p = argparse.ArgumentParser(description="MiniMax 歌词生成")
    p.add_argument("--model", "-m", default="lyrics-01", help="歌词模型（默认 lyrics-01）")
    p.add_argument("--prompt", "-p", required=True, help="歌词主题描述")
    p.add_argument("--genre", "-g", help="音乐流派，如 流行/摇滚/民谣/R&B")
    p.add_argument("--mood", help="情绪，如 伤感/欢快/浪漫/励志")
    p.add_argument("--output", "-o", help="输出文件路径（可选）")
    args = p.parse_args()
    lyrics_gen(model=args.model, prompt=args.prompt, genre=args.genre,
               mood=args.mood, output=args.output)

if __name__ == "__main__":
    main()
