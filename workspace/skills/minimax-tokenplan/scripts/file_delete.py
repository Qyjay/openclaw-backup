#!/usr/bin/env python3
"""
MiniMax Token Plan — 删除文件
DELETE /v1/files
"""
import argparse, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import BASE_URL, get_api_key

import requests

def main():
    p = argparse.ArgumentParser(description="删除 MiniMax 上的文件")
    p.add_argument("--file-id", "-f", required=True, help="要删除的 file_id")
    args = p.parse_args()

    url = f"{BASE_URL}/v1/files"
    headers = {"Authorization": f"Bearer {get_api_key()}"}
    resp = requests.delete(url, headers=headers, json={"file_id": int(args.file_id)}, timeout=30)
    resp.raise_for_status()
    result = resp.json()
    base = result.get("base_resp", {})
    if base.get("status_code") == 0 or base.get("status_code") is None:
        print(f"✅ 文件已删除: {args.file_id}")
    else:
        print(f"❌ 删除失败: {base.get('status_msg')}")

if __name__ == "__main__":
    main()
