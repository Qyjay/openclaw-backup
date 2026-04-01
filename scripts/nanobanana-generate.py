#!/usr/bin/env python3
"""
Nano Banana 直接调用脚本 — 无需启动 Web 代理服务器
调用 MiniMax 代理的 Gemini 图像生成 API
"""

import json
import urllib.request
import urllib.error
import ssl
import base64
import sys
import os
from datetime import datetime

# API 配置
API_URL = "https://api.minimax.io/v1/gemini/v1beta/models/g3-pro-image-preview:generateContent"
API_KEY = os.environ.get("NANOBANANA_API_KEY", "")

def generate_image(prompt, aspect_ratio="1:1", image_size="1K", output_path=None):
    """生成单张图片"""
    if not API_KEY:
        print("❌ 未设置 API Key。请设置环境变量 NANOBANANA_API_KEY")
        sys.exit(1)
    
    payload = {
        "contents": [{
            "parts": [{"text": prompt}],
            "role": "user"
        }],
        "generationConfig": {
            "responseModalities": ["TEXT", "IMAGE"],
            "imageConfig": {
                "aspectRatio": aspect_ratio,
                "imageSize": image_size
            }
        }
    }
    
    headers = {
        "X-Biz-Id": "op",
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_KEY}"
    }
    
    req = urllib.request.Request(
        API_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST"
    )
    
    # SSL context — 跳过证书验证（MiniMax 代理端点）
    ssl_context = ssl._create_unverified_context()
    
    print(f"🚀 正在生成图片...")
    print(f"   提示词: {prompt[:80]}...")
    print(f"   比例: {aspect_ratio} | 尺寸: {image_size}")
    
    try:
        with urllib.request.urlopen(req, timeout=600, context=ssl_context) as response:
            response_data = response.read()
            result = json.loads(response_data.decode("utf-8"))
            
            # 提取图片数据
            image_data = None
            text_response = None
            
            if "candidates" in result:
                for candidate in result["candidates"]:
                    if "content" in candidate and "parts" in candidate["content"]:
                        for part in candidate["content"]["parts"]:
                            if "inlineData" in part:
                                image_data = part["inlineData"].get("data", "")
                            elif "text" in part:
                                text_response = part["text"]
            
            if not image_data:
                print("❌ API 返回中未找到图像数据")
                print(f"   响应: {json.dumps(result, indent=2, ensure_ascii=False)[:500]}")
                return None
            
            # 保存图片
            if not output_path:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                output_path = f"generated_{timestamp}.png"
            
            # 确保输出目录存在
            os.makedirs(os.path.dirname(output_path) if os.path.dirname(output_path) else ".", exist_ok=True)
            
            with open(output_path, "wb") as f:
                f.write(base64.b64decode(image_data))
            
            print(f"✅ 图片已保存: {output_path}")
            if text_response:
                print(f"📝 模型回复: {text_response}")
            
            return output_path
            
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8") if e.fp else str(e)
        print(f"❌ API 错误 {e.code}: {error_body}")
        return None
    except urllib.error.URLError as e:
        print(f"❌ 网络错误: {e.reason}")
        return None
    except Exception as e:
        print(f"❌ 未知错误: {type(e).__name__}: {e}")
        return None


if __name__ == "__main__":
    prompt = sys.argv[1] if len(sys.argv) > 1 else "A cute water drop mascot"
    aspect = sys.argv[2] if len(sys.argv) > 2 else "1:1"
    size = sys.argv[3] if len(sys.argv) > 3 else "1K"
    output = sys.argv[4] if len(sys.argv) > 4 else None
    
    generate_image(prompt, aspect, size, output)
