#!/usr/bin/env python3
"""
Nano Banana — 图像生成 CLI
通过 MiniMax 代理节点调用 Gemini 图像生成 API
支持文生图、参考图生图、批量并行
"""

import argparse
import base64
import json
import os
import sys
import mimetypes
from pathlib import Path
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

try:
    from urllib.request import Request, urlopen
    from urllib.error import HTTPError, URLError
except ImportError:
    print("需要 Python 3.x")
    sys.exit(1)

# MiniMax 代理节点
DEFAULT_BASE_URL = "https://api.minimax.io/v1/gemini"
DEFAULT_MODEL = "g3-pro-image-preview"
API_PATH_TEMPLATE = "/v1beta/models/{model}:generateContent"


def load_config():
    """从 .env 文件加载配置"""
    config = {}
    env_paths = [
        Path.home() / ".openclaw" / "workspace" / ".env",
        Path(".env"),
    ]
    for env_path in env_paths:
        if env_path.exists():
            for line in env_path.read_text().splitlines():
                line = line.strip()
                if "=" in line and not line.startswith("#"):
                    key, val = line.split("=", 1)
                    config[key.strip()] = val.strip().strip('"').strip("'")
    return config


def get_api_key(cli_key=None):
    """加载 API Key：CLI > 环境变量 > .env"""
    if cli_key:
        return cli_key
    key = os.environ.get("GEMINI_API_KEY")
    if key:
        return key
    config = load_config()
    return config.get("GEMINI_API_KEY")


def get_base_url(cli_url=None):
    """加载 Base URL：CLI > 环境变量 > .env > 默认值"""
    if cli_url:
        return cli_url
    url = os.environ.get("NANO_BANANA_BASE_URL")
    if url:
        return url
    config = load_config()
    return config.get("NANO_BANANA_BASE_URL", DEFAULT_BASE_URL)


def encode_image(image_path):
    """将图片文件编码为 base64"""
    path = Path(image_path)
    if not path.exists():
        raise FileNotFoundError(f"图片不存在: {image_path}")
    mime_type = mimetypes.guess_type(str(path))[0] or "image/png"
    with open(path, "rb") as f:
        data = base64.b64encode(f.read()).decode("utf-8")
    return {"mimeType": mime_type, "data": data}


def build_payload(prompt, ref_images=None, aspect_ratio="4:3", image_size="1K"):
    """构建 API 请求体"""
    parts = [{"text": prompt}]
    if ref_images:
        for img_path in ref_images:
            img_data = encode_image(img_path)
            parts.append({"inlineData": img_data})
    return {
        "contents": [{"parts": parts, "role": "user"}],
        "generationConfig": {
            "responseModalities": ["TEXT", "IMAGE"],
            "imageConfig": {
                "aspectRatio": aspect_ratio,
                "imageSize": image_size,
            },
        },
    }


def call_api(api_key, payload, base_url, model):
    """调用 API（通过 MiniMax 代理）"""
    path = API_PATH_TEMPLATE.format(model=model)
    url = base_url.rstrip("/") + path

    data = json.dumps(payload).encode("utf-8")
    req = Request(url, data=data, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Authorization", f"Bearer {api_key}")
    req.add_header("X-Biz-Id", "op")

    try:
        with urlopen(req, timeout=120) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except HTTPError as e:
        error_body = e.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"API 错误 {e.code}: {error_body}")
    except URLError as e:
        raise RuntimeError(f"网络错误: {e.reason}")


def extract_image(response):
    """从 API 响应中提取图像数据"""
    if not response or "candidates" not in response:
        return None, None
    candidate = response["candidates"][0]
    parts = candidate.get("content", {}).get("parts", [])
    image_data = None
    text_response = None
    for part in parts:
        if "inlineData" in part:
            image_data = part["inlineData"]["data"]
        if "text" in part:
            text_response = part["text"]
    return image_data, text_response


def save_image(image_data, output_dir, prefix="banana", index=0):
    """保存图片到文件"""
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{prefix}_{timestamp}_{index + 1}.png"
    filepath = output_path / filename
    with open(filepath, "wb") as f:
        f.write(base64.b64decode(image_data))
    return str(filepath)


def generate_one(api_key, payload, output_dir, prefix, index, base_url, model):
    """生成单张图片"""
    try:
        response = call_api(api_key, payload, base_url, model)
        image_data, text = extract_image(response)
        if not image_data:
            return {"index": index, "success": False, "error": "API 未返回图像数据"}
        filepath = save_image(image_data, output_dir, prefix, index)
        result = {"index": index, "success": True, "path": filepath}
        if text:
            result["text"] = text
        return result
    except Exception as e:
        return {"index": index, "success": False, "error": str(e)}


def main():
    parser = argparse.ArgumentParser(description="Nano Banana — 图像生成（MiniMax 代理）")
    parser.add_argument("--prompt", "-p", required=True, help="图像描述提示词")
    parser.add_argument("--ref-image", "-r", action="append", help="参考图片路径（可多次指定）")
    parser.add_argument("--aspect-ratio", "-a", default="4:3",
                        choices=["1:1", "4:3", "3:4", "16:9", "9:16"], help="纵横比")
    parser.add_argument("--size", "-s", default="1K",
                        choices=["512", "1K", "2K"], help="图像尺寸")
    parser.add_argument("--count", "-c", type=int, default=1, help="生成数量 (1-10)")
    parser.add_argument("--output", "-o", default="./generated", help="输出目录")
    parser.add_argument("--api-key", "-k", help="API Key（覆盖 .env）")
    parser.add_argument("--base-url", help=f"API 基础 URL（默认: {DEFAULT_BASE_URL}）")
    parser.add_argument("--model", "-m", default=DEFAULT_MODEL, help=f"模型名称（默认: {DEFAULT_MODEL}）")
    parser.add_argument("--json", action="store_true", help="输出 JSON 格式")

    args = parser.parse_args()

    api_key = get_api_key(args.api_key)
    if not api_key:
        print("❌ 未找到 API Key。请通过以下方式之一提供：", file=sys.stderr)
        print("   1. --api-key 参数", file=sys.stderr)
        print("   2. GEMINI_API_KEY 环境变量", file=sys.stderr)
        print("   3. ~/.openclaw/workspace/.env 文件中设置 GEMINI_API_KEY", file=sys.stderr)
        sys.exit(1)

    base_url = get_base_url(args.base_url)
    count = max(1, min(10, args.count))
    payload = build_payload(args.prompt, args.ref_image, args.aspect_ratio, args.size)

    print(f"🍌 Nano Banana — 开始生成 {count} 张图片")
    print(f"   代理: {base_url}")
    print(f"   模型: {args.model}")
    print(f"   提示词: {args.prompt[:60]}{'...' if len(args.prompt) > 60 else ''}")
    print(f"   比例: {args.aspect_ratio} | 尺寸: {args.size}")
    if args.ref_image:
        print(f"   参考图: {len(args.ref_image)} 张")
    print()

    results = []
    with ThreadPoolExecutor(max_workers=min(count, 5)) as executor:
        futures = {
            executor.submit(generate_one, api_key, payload, args.output, "banana", i, base_url, args.model): i
            for i in range(count)
        }
        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            idx = result["index"] + 1
            if result["success"]:
                print(f"   ✅ [{idx}/{count}] 已保存: {result['path']}")
                print(f"   MEDIA:{result['path']}")
            else:
                print(f"   ❌ [{idx}/{count}] 失败: {result['error']}")

    results.sort(key=lambda r: r["index"])
    success_count = sum(1 for r in results if r["success"])
    print(f"\n🍌 完成: {success_count}/{count} 张成功")

    if args.json:
        print(json.dumps(results, ensure_ascii=False, indent=2))

    if success_count > 0:
        print("\n生成的文件：")
        for r in results:
            if r["success"]:
                print(r["path"])

    sys.exit(0 if success_count > 0 else 1)


if __name__ == "__main__":
    main()
