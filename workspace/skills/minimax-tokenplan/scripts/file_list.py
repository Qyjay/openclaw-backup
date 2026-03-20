#!/usr/bin/env python3
"""
MiniMax Token Plan — 文件列表
GET /v1/files
"""
import argparse, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import BASE_URL, get_api_key

import requests

def main():
    p = argparse.ArgumentParser(description="列出 MiniMax 已上传文件")
    p.add_argument("--type", "-t", default="audio",
                   choices=["audio","video","image"],
                   help="文件类型筛选")
    args = p.parse_args()

    url = f"{BASE_URL}/v1/files"
    headers = {"Authorization": f"Bearer {get_api_key()}"}
    resp = requests.get(url, headers=headers, params={"purpose": args.type}, timeout=30)
    resp.raise_for_status()
    result = resp.json()

    files = result.get("files", [])
    print(f"\n📁 文件列表（{args.type}，共 {len(files)} 个）:")
    for f in files:
        print(f"  file_id: {f.get('file_id')} | {f.get('bytes', '?')} bytes | {f.get('created_at', '')}")

if __name__ == "__main__":
    main()
