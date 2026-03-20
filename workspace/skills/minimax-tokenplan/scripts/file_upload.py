#!/usr/bin/env python3
"""
MiniMax Token Plan — 文件上传
POST /v1/files
支持：mp3, m4a, wav, jpg, jpeg, png, mp4 等
"""
import argparse, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import upload_file

def main():
    p = argparse.ArgumentParser(description="MiniMax 文件上传（返回 file_id）")
    p.add_argument("--file", "-f", required=True, help="要上传的文件路径")
    args = p.parse_args()
    result = upload_file(args.file)
    print(f"✅ 文件上传成功:")
    print(f"   file_id: {result.get('file_id')}")
    print(f"   url: {result.get('url')}")
    print(f"   完整响应: {result}")

if __name__ == "__main__":
    main()
