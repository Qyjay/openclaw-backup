---
name: nano-banana
description: "通过 Google Gemini API 生成图像（文生图 & 参考图生图）。触发条件：(1) 用户要求生成图片/画图/文生图/图生图，(2) 用户说'nano banana'或'画一张'，(3) 需要批量生成图片。支持：文本描述生成、参考图编辑、批量并行生成、多种尺寸和比例。需要 Gemini API Key。"
---

# Nano Banana — 图像生成

通过 Google Gemini API 的图像生成能力，支持文生图和参考图生图。

## 前置条件

- Python 3.8+
- Gemini API Key（从 https://aistudio.google.com/apikey 获取）
- API Key 存储在 `~/.openclaw/workspace/.env` 中：`GEMINI_API_KEY=your_key`

## 快速使用

### 文生图（CLI）

```bash
python3 scripts/generate.py --prompt "一只橘猫在阳光下打盹" --aspect-ratio 4:3 --size 1K
```

### 参考图生图

```bash
python3 scripts/generate.py --prompt "把背景换成星空" --ref-image photo.jpg --aspect-ratio 1:1
```

### 批量生成

```bash
python3 scripts/generate.py --prompt "橘猫" --count 4 --aspect-ratio 16:9
```

### Web 界面

```bash
python3 scripts/proxy-server.py
# 访问 http://localhost:8000/client.html
```

## 参数说明

| 参数 | 选项 | 默认值 |
|------|------|--------|
| `--aspect-ratio` | `1:1`, `4:3`, `3:4`, `16:9`, `9:16` | `4:3` |
| `--size` | `512`, `1K`, `2K` | `1K` |
| `--count` | 1-10 | `1` |
| `--output` | 输出目录 | `./generated/` |
| `--ref-image` | 参考图片路径（可多个） | 无 |
| `--api-key` | 直接传入 API Key（优先于 .env） | 无 |

## Agent 使用指南

当用户要求生成图片时：

1. 确认描述内容（prompt）
2. 确认参数（比例、尺寸、数量），未指定则用默认值
3. 运行 `scripts/generate.py`，脚本路径相对于此 skill 目录
4. 将生成的图片发送给用户

路径解析：此 skill 目录为 `~/.openclaw/workspace/skills/nano-banana/`。
