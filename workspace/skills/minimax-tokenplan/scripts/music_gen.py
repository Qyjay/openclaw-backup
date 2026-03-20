#!/usr/bin/env python3
"""
MiniMax Token Plan — 音乐生成
POST /v1/music_generation
"""
import argparse, sys, os, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import BASE_URL, get_api_key, download_file

import requests

def music_gen(
    model: str = "music-2.5+",
    prompt: str = None,
    lyrics: str = None,
    is_instrumental: bool = False,
    auto_lyrics: bool = False,
    output: str = "output.mp3",
    lyrics_optimizer: bool = True,
    poll_interval: int = 30,
    timeout: int = 600,
):
    url = f"{BASE_URL}/v1/music_generation"
    headers = {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": model,
        "stream": False,
        "output_format": "url",
        "aigc_watermark": False,
    }

    if is_instrumental:
        payload["is_instrumental"] = True
        if not prompt:
            raise ValueError("纯音乐模式需要提供 --prompt")
    else:
        if auto_lyrics:
            payload["lyrics_optimizer"] = lyrics_optimizer
            if not prompt:
                raise ValueError("自动生成歌词需要提供 --prompt")
        elif lyrics:
            payload["lyrics"] = lyrics
        else:
            raise ValueError("需要提供 --lyrics 或使用 --auto-lyrics")

    if prompt:
        payload["prompt"] = prompt

    print(f"🎵 创建音乐生成任务...")
    print(f"   模型: {model} | 纯音乐: {is_instrumental} | 自动歌词: {auto_lyrics}")
    if prompt:
        print(f"   风格: {prompt[:60]}{'...' if len(prompt)>60 else ''}")

    resp = requests.post(url, headers=headers, json=payload, timeout=60)
    resp.raise_for_status()
    result = resp.json()

    base = result.get("base_resp", {})
    if base.get("status_code") != 0 and base.get("status_code") is not None:
        print(f"❌ 创建失败: {base.get('status_msg')}")
        print(f"   响应: {result}")
        return

    task_id = result.get("task_id")
    print(f"✅ 任务已创建: {task_id}")
    print(f"⏳ 等待生成完成（轮询间隔 {poll_interval}s）...")

    start = time.time()
    query_url = f"{BASE_URL}/v1/music_generation"

    while time.time() - start < timeout:
        resp = requests.get(query_url, headers=headers, params={"task_id": task_id}, timeout=30)
        resp.raise_for_status()
        result = resp.json()

        base = result.get("base_resp", {})
        status = base.get("status")

        if status == 2:
            data = result.get("data", {})
            music_url = data.get("music_url") or data.get("audio_url")
            if music_url:
                download_file(music_url, output)
            print(f"✅ 音乐已保存: {output}")
            return
        elif status == 3:
            raise RuntimeError(f"音乐生成失败: {result}")

        print(f"  生成中... ({int(time.time()-start)}s)")
        time.sleep(poll_interval)

    raise TimeoutError(f"音乐生成超时（{timeout}s）")


def main():
    p = argparse.ArgumentParser(description="MiniMax 音乐生成")
    p.add_argument("--model", "-m", default="music-2.5+",
                   choices=["music-2.5+","music-2.5"],
                   help="音乐模型（默认 music-2.5+）")
    p.add_argument("--prompt", help="音乐风格描述（≤2000字），纯音乐必填")
    p.add_argument("--lyrics", help="歌词（\\n 分隔行）")
    p.add_argument("--is-instrumental", action="store_true", help="纯音乐模式")
    p.add_argument("--auto-lyrics", action="store_true", help="根据 prompt 自动生成歌词")
    p.add_argument("--output", "-o", default="output.mp3")
    p.add_argument("--no-lyrics-optimizer", action="store_true", help="禁用歌词自动优化")
    p.add_argument("--poll-interval", type=int, default=30)
    p.add_argument("--timeout", type=int, default=600)
    args = p.parse_args()

    music_gen(
        model=args.model,
        prompt=args.prompt,
        lyrics=args.lyrics,
        is_instrumental=args.is_instrumental,
        auto_lyrics=args.auto_lyrics,
        output=args.output,
        lyrics_optimizer=not args.no_lyrics_optimizer,
        poll_interval=args.poll_interval,
        timeout=args.timeout,
    )

if __name__ == "__main__":
    main()
