#!/usr/bin/env python3
"""
Nano Banana — 代理服务器
为 Web 界面提供 CORS 代理，转发请求到 Gemini API
"""

import json
import os
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
from pathlib import Path

PORT = int(os.environ.get("BANANA_PORT", 8000))
DEFAULT_BASE_URL = "https://api.minimax.io/v1/gemini"
DEFAULT_MODEL = "g3-pro-image-preview"

# Web 资源目录（assets 目录）
ASSETS_DIR = str(Path(__file__).parent.parent / "assets")


class BananaProxyHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ASSETS_DIR, **kwargs)

    def do_POST(self):
        if self.path == "/api/generate":
            self.handle_generate()
        else:
            self.send_error(404, "Not Found")

    def handle_generate(self):
        try:
            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length)
            data = json.loads(body)

            api_key = data.get("apiKey", "")
            payload = data.get("payload", {})

            if not api_key:
                self.send_json_error(400, "缺少 API Key")
                return

            base_url = os.environ.get("NANO_BANANA_BASE_URL", DEFAULT_BASE_URL).rstrip("/")
            model = os.environ.get("NANO_BANANA_MODEL", DEFAULT_MODEL)
            url = f"{base_url}/v1beta/models/{model}:generateContent"
            req_data = json.dumps(payload).encode("utf-8")
            req = Request(url, data=req_data, method="POST")
            req.add_header("Content-Type", "application/json")
            req.add_header("Authorization", f"Bearer {api_key}")
            req.add_header("X-Biz-Id", "op")

            with urlopen(req, timeout=120) as resp:
                result = resp.read()

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(result)

        except HTTPError as e:
            error_body = e.read().decode("utf-8", errors="replace")
            self.send_json_error(e.code, error_body)
        except URLError as e:
            self.send_json_error(502, f"网络错误: {e.reason}")
        except Exception as e:
            self.send_json_error(500, str(e))

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def send_json_error(self, code, message):
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps({"error": message}).encode("utf-8"))

    def log_message(self, format, *args):
        print(f"[Banana] {args[0]}" if args else "")


def main():
    server = HTTPServer(("127.0.0.1", PORT), BananaProxyHandler)
    print(f"🍌 Nano Banana 代理服务器已启动")
    print(f"   访问: http://localhost:{PORT}/client.html")
    print(f"   按 Ctrl+C 停止")
    print()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n🍌 服务器已停止")
        server.server_close()


if __name__ == "__main__":
    main()
p://localhost:{PORT}/client.html")
    print(f"   按 Ctrl+C 停止")
    print()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n🍌 服务器已停止")
        server.server_close()


if __name__ == "__main__":
    main()
