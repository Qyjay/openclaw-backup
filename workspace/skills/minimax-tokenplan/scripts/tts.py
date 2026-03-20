#!/usr/bin/env python3
"""
MiniMax Token Plan — 同步语音合成 (TTS)
POST /v1/t2a_v2
支持最长 10,000 字符文本
"""
import argparse, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import BASE_URL, get_api_key, save_hex_audio

import requests

def tts(
    text: str,
    voice_id: str,
    model: str = "speech-2.8-hd",
    speed: float = 1.0,
    pitch: float = 0.0,
    vol: float = 1.0,
    emotion: str = None,
    output: str = "output.mp3",
    format: str = "mp3",
    sample_rate: int = 32000,
    bitrate: int = 128000,
    stream: bool = False,
):
    url = f"{BASE_URL}/v1/t2a_v2"
    headers = {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json"
    }

    voice_setting = {
        "voice_id": voice_id,
        "speed": float(speed),
        "vol": float(vol),
        "pitch": int(pitch),
    }
    if emotion:
        voice_setting["emotion"] = emotion

    payload = {
        "model": model,
        "text": text,
        "stream": stream,
        "voice_setting": voice_setting,
        "audio_setting": {
            "sample_rate": sample_rate,
            "bitrate": bitrate,
            "format": format,
            "channel": 1
        }
    }

    resp = requests.post(url, headers=headers, json=payload, timeout=60)
    resp.raise_for_status()
    result = resp.json()

    if stream:
        print("流式模式暂不支持直接保存")
        return

    data = result.get("data", {})
    status = data.get("status")

    if status == 2:
        hex_audio = data.get("audio", "")
        save_hex_audio(hex_audio, output)
        extra = data.get("extra_info", {})
        print(f"  时长: {extra.get('audio_length', '?')}ms | 采样率: {extra.get('audio_sample_rate', '?')}Hz | 大小: {extra.get('audio_size', '?')} bytes")
    else:
        print(f"状态: {status} | 响应: {result}")


def main():
    p = argparse.ArgumentParser(description="MiniMax 同步 TTS（≤1万字）")
    p.add_argument("--text", "-t", required=True, help="要合成的文本（≤10000字）")
    p.add_argument("--voice-id", "-v", required=True, help="音色 ID，如 male-qn-qingse")
    p.add_argument("--model", "-m", default="speech-2.8-hd",
                   choices=["speech-2.8-hd","speech-2.8-turbo","speech-2.6-hd",
                             "speech-2.6-turbo","speech-02-hd","speech-02-turbo",
                             "speech-01-hd","speech-01-tu"],
                   help="语音模型（默认 speech-2.8-hd）")
    p.add_argument("--speed", "-s", type=float, default=1.0, help="语速 0.5-2.0（默认 1.0）")
    p.add_argument("--pitch", "-p", type=float, default=0.0, help="音调 -12-12（默认 0）")
    p.add_argument("--vol", type=float, default=1.0, help="音量 0.5-2.0（默认 1.0）")
    p.add_argument("--emotion", "-e", default=None,
                   choices=["happy","sad","neutral","angry","fearful","disgusted","surprised"],
                   help="情绪")
    p.add_argument("--output", "-o", default="output.mp3", help="输出文件路径")
    p.add_argument("--format", "-f", default="mp3", choices=["mp3","pcm","wav"], help="音频格式")
    p.add_argument("--sample-rate", type=int, default=32000, choices=[16000,32000,44100], help="采样率")
    args = p.parse_args()

    if len(args.text) > 10000:
        print(f"⚠️ 文本超过 10000 字（当前 {len(args.text)} 字），建议使用异步版本：tts_async.py")
    elif len(args.text) > 5000:
        print(f"⚠️ 长文本（{len(args.text)} 字），处理中...")

    tts(
        text=args.text,
        voice_id=args.voice_id,
        model=args.model,
        speed=args.speed,
        pitch=args.pitch,
        vol=args.vol,
        emotion=args.emotion,
        output=args.output,
        format=args.format,
        sample_rate=args.sample_rate,
    )


if __name__ == "__main__":
    main()
