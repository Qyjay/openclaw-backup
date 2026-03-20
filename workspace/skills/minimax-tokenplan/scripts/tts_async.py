#!/usr/bin/env python3
"""
MiniMax Token Plan — 异步语音合成 (TTS Async)
POST /v1/t2a_async
支持最长 100,000 字符文本
"""
import argparse, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import BASE_URL, get_api_key, save_hex_audio, poll_task, download_file

import requests

def tts_async_create(text: str, voice_id: str, model: str = "speech-2.8-hd",
                     speed: float = 1.0, pitch: float = 0.0, vol: float = 1.0,
                     format: str = "mp3", sample_rate: int = 32000):
    """创建异步 TTS 任务"""
    url = f"{BASE_URL}/v1/t2a_async"
    headers = {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": model,
        "text": text,
        "voice_setting": {
            "voice_id": voice_id,
            "speed": speed,
            "vol": vol,
            "pitch": pitch,
        },
        "audio_setting": {
            "sample_rate": sample_rate,
            "format": format,
            "channel": 1
        }
    }
    resp = requests.post(url, headers=headers, json=payload, timeout=30)
    resp.raise_for_status()
    result = resp.json()
    task_id = result.get("task_id")
    print(f"✅ 任务已创建: {task_id}")
    return task_id


def tts_async_query(task_id: str) -> dict:
    """查询异步 TTS 任务状态"""
    url = f"{BASE_URL}/v1/t2a_async"
    headers = {"Authorization": f"Bearer {get_api_key()}"}
    payload = {"task_id": task_id}
    resp = requests.post(url, headers=headers, json=payload, timeout=30)
    resp.raise_for_status()
    return resp.json()


def tts_async(
    text: str,
    voice_id: str,
    model: str = "speech-2.8-hd",
    speed: float = 1.0,
    pitch: float = 0.0,
    vol: float = 1.0,
    output: str = "output.mp3",
    format: str = "mp3",
    sample_rate: int = 32000,
    poll_interval: int = 10,
    timeout: int = 600,
):
    task_id = tts_async_create(text, voice_id, model, speed, pitch, vol, format, sample_rate)

    print(f"⏳ 等待生成完成（轮询间隔 {poll_interval}s）...")
    start = __import__('time').time()
    while __import__('time').time() - start < timeout:
        result = tts_async_query(task_id)
        status = result.get("status")
        if status == 2:
            data = result.get("data", {})
            file_url = data.get("audio_url") or data.get("audio")
            if file_url:
                if file_url.startswith("http"):
                    download_file(file_url, output)
                else:
                    save_hex_audio(file_url, output)
            print(f"✅ 异步 TTS 完成: {output}")
            return
        elif status == 3:
            raise RuntimeError(f"任务失败: {result}")
        print(f"  生成中... ({int(__import__('time').time()-start)}s) 状态={status}")
        __import__('time').sleep(poll_interval)
    raise TimeoutError(f"任务超时（{timeout}s）")


def main():
    p = argparse.ArgumentParser(description="MiniMax 异步 TTS（≤10万字）")
    p.add_argument("--text", "-t", required=True, help="要合成的文本（≤100000字）")
    p.add_argument("--voice-id", "-v", required=True, help="音色 ID")
    p.add_argument("--model", "-m", default="speech-2.8-hd",
                   choices=["speech-2.8-hd","speech-2.8-turbo","speech-2.6-hd",
                             "speech-2.6-turbo","speech-02-hd","speech-02-turbo"])
    p.add_argument("--speed", "-s", type=float, default=1.0)
    p.add_argument("--pitch", type=float, default=0.0)
    p.add_argument("--vol", type=float, default=1.0)
    p.add_argument("--output", "-o", default="output.mp3")
    p.add_argument("--format", "-f", default="mp3", choices=["mp3","pcm","wav"])
    p.add_argument("--sample-rate", type=int, default=32000)
    p.add_argument("--poll-interval", type=int, default=10)
    p.add_argument("--timeout", type=int, default=600)
    args = p.parse_args()
    tts_async(
        text=args.text, voice_id=args.voice_id, model=args.model,
        speed=args.speed, pitch=args.pitch, vol=args.vol,
        output=args.output, format=args.format, sample_rate=args.sample_rate,
        poll_interval=args.poll_interval, timeout=args.timeout,
    )

if __name__ == "__main__":
    main()
