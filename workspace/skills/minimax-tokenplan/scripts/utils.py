#!/usr/bin/env python3
"""
MiniMax Token Plan — 通用工具模块
"""
import os
import json

BASE_URL = "https://api.minimaxi.com"

def get_api_key():
    """从 .env 文件读取 minimax-tokenplan API Key（OPENCLAW_REDACTED 无法通过 CLI 读取）"""
    # 环境变量优先级最高
    key = os.environ.get("MINIMAX_TOKENPLAN_API_KEY")
    if key:
        return key

    # 从 .env 读取（已被 .gitignore 忽略，安全）
    env_path = os.path.expanduser("~/.openclaw/workspace/.env")
    if os.path.exists(env_path):
        with open(env_path) as f:
            for line in f:
                if line.startswith("MINIMAX_TOKENPLAN_API_KEY="):
                    val = line.split("=", 1)[1].strip()
                    if val and val not in ("", "__OPENCLAW_REDACTED__"):
                        return val
                if line.startswith("MINIMAX_API_KEY=") and not line.startswith("MINIMAX_TOKENPLAN"):
                    val = line.split("=", 1)[1].strip()
                    if val and val not in ("", "__OPENCLAW_REDACTED__"):
                        return val

    raise ValueError(
        "未找到 MiniMax API Key。"
        "请在 ~/.openclaw/workspace/.env 中设置 MINIMAX_TOKENPLAN_API_KEY=sk-cp-xxx"
    )


def api_headers():
    """返回标准的 API 请求头"""
    return {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json"
    }


def upload_file(file_path: str) -> dict:
    """上传文件到 MiniMax，返回 file_id"""
    import requests

    if not os.path.exists(file_path):
        raise FileNotFoundError(f"文件不存在: {file_path}")

    file_size = os.path.getsize(file_path)
    mime_types = {
        ".mp3": "audio/mpeg",
        ".m4a": "audio/mp4",
        ".wav": "audio/wav",
        ".jpg": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".png": "image/png",
    }
    ext = os.path.splitext(file_path.lower())[1]
    mime = mime_types.get(ext, "application/octet-stream")

    url = f"{BASE_URL}/v1/files"
    headers = {
        "Authorization": f"Bearer {get_api_key()}"
    }
    files = {
        "file": (os.path.basename(file_path), open(file_path, "rb"), mime)
    }
    data = {
        "purpose": "audio" if ext in [".mp3", ".m4a", ".wav"] else "video"
    }

    resp = requests.post(url, headers=headers, files=files, data=data, timeout=60)
    resp.raise_for_status()
    result = resp.json()
    return result


def poll_task(task_id: str, endpoint: str, interval: int = 10, timeout: int = 300) -> dict:
    """轮询任务状态直到完成"""
    import requests, time

    url = f"{BASE_URL}{endpoint}/{task_id}"
    headers = {"Authorization": f"Bearer {get_api_key()}"}

    start = time.time()
    while time.time() - start < timeout:
        resp = requests.get(url, headers=headers, timeout=30)
        resp.raise_for_status()
        result = resp.json()

        status = result.get("status") or result.get("base_resp", {}).get("status")
        if status == 2 or status == "completed":
            return result
        elif status == 3 or status == "failed":
            raise RuntimeError(f"任务失败: {result}")

        print(f"  等待中... ({int(time.time()-start)}s)", flush=True)
        time.sleep(interval)

    raise TimeoutError(f"任务超时（{timeout}s）")


def save_hex_audio(hex_data: str, output_path: str):
    """将 hex 编码的音频保存为二进制文件"""
    audio_bytes = bytes.fromhex(hex_data)
    os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
    with open(output_path, "wb") as f:
        f.write(audio_bytes)
    print(f"✅ 音频已保存: {output_path} ({len(audio_bytes):,} bytes)")


def download_file(url: str, output_path: str):
    """下载文件到本地"""
    import requests

    os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
    resp = requests.get(url, timeout=120, stream=True)
    resp.raise_for_status()
    with open(output_path, "wb") as f:
        for chunk in resp.iter_content(chunk_size=8192):
            f.write(chunk)
    print(f"✅ 文件已下载: {output_path}")
