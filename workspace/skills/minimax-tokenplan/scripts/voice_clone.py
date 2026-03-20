#!/usr/bin/env python3
"""
MiniMax Token Plan — 音色快速复刻
POST /v1/voice_clone
"""
import argparse, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import BASE_URL, get_api_key

import requests

def voice_clone(
    file_id: str,
    voice_id: str,
    text: str = None,
    model: str = None,
    clone_prompt_file_id: str = None,
):
    url = f"{BASE_URL}/v1/voice_clone"
    headers = {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json"
    }
    payload = {
        "file_id": int(file_id),
        "voice_id": voice_id,
    }

    if clone_prompt_file_id:
        payload["clone_prompt"] = {"file_id": int(clone_prompt_file_id)}

    if text:
        if not model:
            model = "speech-2.8-hd"
        payload["text"] = text
        payload["model"] = model

    resp = requests.post(url, headers=headers, json=payload, timeout=60)
    resp.raise_for_status()
    result = resp.json()

    base = result.get("base_resp", {})
    if base.get("status_code") == 0 or base.get("status_code") is None:
        print(f"✅ 音色克隆成功！")
        print(f"   voice_id: {voice_id}")
        if text:
            preview = result.get("preview_audio_url") or result.get("data", {}).get("audio_url")
            if preview:
                print(f"   试听链接: {preview}")
        else:
            print("   提示：调用一次后音色将变为已激活状态")
    else:
        print(f"❌ 克隆失败: {base.get('status_msg', str(result))}")
    return result


def main():
    p = argparse.ArgumentParser(description="MiniMax 音色快速复刻")
    p.add_argument("--file-id", "-f", required=True, help="上传音频后获得的 file_id")
    p.add_argument("--voice-id", "-v", required=True, help="自定义音色 ID（8-256字符，以字母开头）")
    p.add_argument("--text", "-t", help="复刻试听文本（≤1000字）")
    p.add_argument("--model", "-m",
                   choices=["speech-2.8-hd","speech-2.8-turbo","speech-2.6-hd",
                             "speech-2.6-turbo","speech-02-hd","speech-02-turbo"],
                   help="试听使用的语音模型（提供 --text 时必填）")
    p.add_argument("--clone-prompt-file-id", help="示例音频 file_id（增强相似度）")
    args = p.parse_args()

    if args.text and not args.model:
        print("⚠️ 提供 --text 时建议同时指定 --model（默认 speech-2.8-hd）")

    voice_clone(
        file_id=args.file_id,
        voice_id=args.voice_id,
        text=args.text,
        model=args.model,
        clone_prompt_file_id=args.clone_prompt_file_id,
    )

if __name__ == "__main__":
    main()
