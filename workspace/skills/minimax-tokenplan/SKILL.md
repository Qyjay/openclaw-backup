---
name: minimax-tokenplan
description: "MiniMax Token Plan 全模态能力 skill。覆盖：语音合成（TTS）、音色克隆、视频生成、图片生成（由 nano-banana 提供）、音乐生成、歌词生成。使用 minimax-tokenplan provider 的 API Key（sk-cp-xxx）。"
---

# MiniMax Token Plan — 全模态生成 Skill

通过 MiniMax Token Plan API 调用所有模态能力：语音合成、音色克隆、视频生成、图片生成、音乐生成。

> **图像生成**：由独立的 [nano-banana skill](../nano-banana/SKILL.md) 提供，暂不迁移至此。

## 前置条件

- API Key 已在 OpenClaw 配置中设置（provider: `minimax-tokenplan`）
- Python 3.8+
- `requests` 库：`pip install requests`

## 能力总览

| 模态 | 能力 | 端点 | 脚本 |
|------|------|------|------|
| 🎙️ 语音合成 | 同步 TTS（≤1万字） | `POST /v1/t2a_v2` | `tts.py` |
| 🎙️ 语音合成 | 异步 TTS（≤10万字） | `POST /v1/t2a_async` | `tts_async.py` |
| 🎙️ 音色克隆 | 上传音频复刻音色 | `POST /v1/voice_clone` | `voice_clone.py` |
| 🎙️ 音色管理 | 查询/删除音色 | `POST /v1/get_voice` | `voice_list.py` |
| 🎙️ 音色设计 | 文生音色 | `POST /v1/voice_design` | `voice_design.py` |
| 🎬 视频生成 | 文生视频 | `POST /v1/video_generation` | `video_gen.py` |
| 🎬 视频生成 | 图生视频 | `POST /v1/video_generation` | `video_gen.py` |
| 🎬 视频生成 | 首尾帧生成 | `POST /v1/video_generation` | `video_gen.py` |
| 🎬 视频生成 | 主体参考视频 | `POST /v1/video_generation` | `video_gen.py` |
| 🎵 音乐生成 | 歌词歌曲生成 | `POST /v1/music_generation` | `music_gen.py` |
| 📝 歌词生成 | 自动写词 | `POST /v1/lyrics_generation` | `lyrics_gen.py` |
| 🖼️ 图片生成 | — | 由 nano-banana skill 提供 | — |

## API 配置

- **Base URL**: `https://api.minimaxi.com`
- **认证**: `Authorization: Bearer {API_KEY}`
- **模型别名**: `m2.7-tp`（M2.7）、`m2.7-hs`（M2.7-highspeed）

---

## 🎙️ 语音合成（TTS）

### 同步 TTS

```bash
python3 scripts/tts.py --text "你好，欢迎使用 MiniMax 语音合成" --voice-id "male-qn-qingse" --model "speech-2.8-hd" --output ./output.mp3
```

### 异步 TTS（长文本）

```bash
python3 scripts/tts_async.py --text "长文本内容..." --voice-id "male-qn-qingse" --model "speech-2.8-hd" --output ./output.mp3
```

### TTS 参数

| 参数 | 说明 | 可选值 |
|------|------|--------|
| `--text` | 要合成的文本（≤1万字，同步）/ ≤10万字（异步） | 必填 |
| `--voice-id` | 音色 ID | 必填，可用 `voice_list.py` 查询 |
| `--model` | 语音模型 | `speech-2.8-hd`, `speech-2.8-turbo`, `speech-2.6-hd`, `speech-2.6-turbo`, `speech-02-hd`, `speech-02-turbo`, `speech-01-hd`, `speech-01-tu` |
| `--speed` | 语速 | 0.5–2.0，默认 1.0 |
| `--pitch` | 音调 | -12–12，默认 0 |
| `--vol` | 音量 | 0.5–2.0，默认 1.0 |
| `--emotion` | 情绪 | `happy`, `sad`, `neutral`, `angry`, `fearful`, `disgusted`, `surprised` |
| `--output` | 输出文件路径 | 必填 |
| `--format` | 音频格式 | `mp3`（默认）, `pcm`, `wav` |
| `--sample-rate` | 采样率 | 16000, 32000（默认）, 44100 |

### 情绪标签（仅 speech-2.8-hd/turbo）

在文本中插入标签可添加音效：
`(laughs)`, `(chuckle)`, `(coughs)`, `(clear-throat)`, `(groans)`, `(breath)`, `(pant)`, `(inhale)`, `(exhale)`, `(gasps)`, `(sniffs)`, `(sighs)`, `(snorts)`, `(burps)`, `(lip-smacking)`, `(humming)`, `(hissing)`, `(emm)`, `(whistles)`, `(sneezes)`, `(crying)`, `(applause)`

---

## 🎙️ 音色克隆

### 步骤 1：上传待克隆音频

```bash
python3 scripts/file_upload.py --file ./my_voice.mp3
# 返回 file_id，例如：1234567890
```

### 步骤 2：克隆音色

```bash
python3 scripts/voice_clone.py --file-id 1234567890 --voice-id "MyVoice001" --text "复刻试听文本"
```

### 参数

| 参数 | 说明 |
|------|------|
| `--file-id` | 上传后获得的 file_id（必填） |
| `--voice-id` | 自定义音色 ID，长度 8-256，以字母开头，允许字母/数字/`-`/`_`，末位不可为 `-`/`_` |
| `--clone-prompt-file-id` | 示例音频 file_id（可选，有助于增强相似度） |
| `--text` | 复刻试听文本（≤1000字），模型会用克隆音色朗读并返回试听链接 |
| `--model` | 试听用的语音模型（提供 text 时必填）|

> ⚠️ 克隆音色 7 天内未正式调用会被系统删除。

---

## 🎙️ 音色管理

### 查询可用音色

```bash
python3 scripts/voice_list.py --type all
# --type: system | voice_cloning | voice_generation | all
```

### 删除音色

```bash
python3 scripts/voice_delete.py --voice-id "MyVoice001"
```

---

## 🎙️ 音色设计（文生音色）

根据文本描述生成新音色：

```bash
python3 scripts/voice_design.py --text "一个温柔的年轻女性声音，说中文时带有轻微的南方口音" --voice-id "MyDesignedVoice001"
```

---

## 🎬 视频生成

### 文生视频

```bash
python3 scripts/video_gen.py --model "MiniMax-Hailuo-2.3" --prompt "一只橘猫在草地上奔跑，阳光明媚" --duration 6 --resolution "768P" --output ./video.mp4
```

### 图生视频

```bash
python3 scripts/video_gen.py --model "MiniMax-Hailuo-2.3" --prompt "图片中的猫开始走动，回头看镜头" --image ./cat.jpg --duration 6 --resolution "768P" --output ./video.mp4
```

### 首尾帧生成视频

```bash
python3 scripts/video_gen.py --model "MiniMax-Hailuo-2.3" --prompt "场景从开始过渡到结束" --first-frame ./start.jpg --last-frame ./end.jpg --duration 6 --resolution "768P" --output ./video.mp4
```

### 主体参考视频生成

```bash
python3 scripts/video_gen.py --model "MiniMax-Hailuo-02" --prompt "这个人走进办公室，坐到工位上" --subject-image ./person.jpg --duration 6 --resolution "768P" --output ./video.mp4
```

### 视频生成参数

| 参数 | 说明 | 可选值 |
|------|------|--------|
| `--model` | 视频模型 | `MiniMax-Hailuo-2.3`, `MiniMax-Hailuo-02`, `T2V-01-Director`, `T2V-01` |
| `--prompt` | 视频描述（≤2000字） | 必填 |
| `--duration` | 时长（秒） | `6`（默认）或 `10`（部分模型支持） |
| `--resolution` | 分辨率 | `720P`, `768P`, `1080P` |
| `--first-frame` | 首帧图片路径 | 图生视频/首尾帧用 |
| `--last-frame` | 尾帧图片路径 | 首尾帧用 |
| `--subject-image` | 人物主体图片路径 | 主体参考用 |
| `--image` | 输入图片路径 | 图生视频用 |
| `--output` | 输出文件路径 | 必填 |
| `--poll-interval` | 轮询间隔（秒） | 默认 10 |

#### 运镜指令

在 prompt 中使用 `[指令]` 语法控制镜头：
`[左移]`, `[右移]`, `[左摇]`, `[右摇]`, `[推进]`, `[拉远]`, `[上升]`, `[下降]`, `[上摇]`, `[下摇]`, `[变焦推近]`, `[变焦拉远]`, `[晃动]`, `[跟随]`, `[固定]`

#### Token Plan 消耗

| 模型 | 每 6 秒视频 | 每 10 秒视频 |
|------|------------|-------------|
| `MiniMax-Hailuo-2.3-Fast` | 3000 请求 | — |
| `MiniMax-Hailuo-2.3` | 4500 请求 | 4500 请求 |
| `MiniMax-Hailuo-02` | 1500 请求 | 2250 请求 |

---

## 🎵 音乐生成

### 带歌词的歌曲

```bash
python3 scripts/music_gen.py --model "music-2.5+" --prompt "流行音乐，明快节奏，适合恋爱主题" --lyrics "第一段verse\n[Hook] 副歌歌词\n第二段verse" --output ./song.mp3
```

### 纯音乐

```bash
python3 scripts/music_gen.py --model "music-2.5+" --prompt "抒情的钢琴曲，适合深夜独处" --is-instrumental --output ./instrumental.mp3
```

### 根据描述自动生成歌词

```bash
python3 scripts/music_gen.py --model "music-2.5+" --prompt "伤感的流行音乐，关于失去和思念" --auto-lyrics --output ./song.mp3
```

### 参数

| 参数 | 说明 | 可选值 |
|------|------|--------|
| `--model` | 音乐模型 | `music-2.5+`（推荐）, `music-2.5` |
| `--prompt` | 音乐风格描述（≤2000字） | 纯音乐必填 |
| `--lyrics` | 歌词（`\n` 分隔行） | 非纯音乐必填 |
| `--is-instrumental` | 纯音乐模式 | flag |
| `--auto-lyrics` | 根据 prompt 自动生成歌词 | flag |
| `--output` | 输出文件路径 | 必填 |
| `--lyrics-optimizer` | 自动优化歌词 | 默认 true |

#### 歌词结构标签

`[Intro]`, `[Verse]`, `[Pre Chorus]`, `[Chorus]`, `[Interlude]`, `[Bridge]`, `[Outro]`, `[Hook]`, `[Break]`, `[Solo]`

#### Token Plan 消耗

- `Music-2.5+` / `Music-2.5`: 3000 请求/每首 5 分钟音乐

---

## 📝 歌词生成

根据主题自动生成歌词：

```bash
python3 scripts/lyrics_gen.py --model "lyrics-01" --prompt "关于雨中告别的抒情歌词" --genre "流行" --mood "伤感" --output ./lyrics.txt
```

---

## 📁 文件管理

### 上传文件

```bash
python3 scripts/file_upload.py --file ./audio.mp3
# 返回 {"file_id": "xxx"}
```

### 列出文件

```bash
python3 scripts/file_list.py
```

### 删除文件

```bash
python3 scripts/file_delete.py --file-id 1234567890
```

---

## Agent 使用指南

当 Master 要求以下操作时，使用对应脚本：

1. **语音合成** → `tts.py` 或 `tts_async.py`
2. **音色克隆** → 先 `file_upload.py` 获取 file_id，再 `voice_clone.py`
3. **查音色** → `voice_list.py`
4. **视频生成** → `video_gen.py`
5. **音乐生成** → `music_gen.py`
6. **歌词生成** → `lyrics_gen.py`

> 注意：脚本路径相对于 skill 目录 `~/.openclaw/workspace/skills/minimax-tokenplan/`

## 安全注意

- API Key 来自 OpenClaw 配置（已通过 `models.providers.minimax-tokenplan.apiKey` 管理）
- 脚本不直接接收 API Key，通过环境变量 `MINIMAX_API_KEY` 或 OpenClaw 配置读取
- 克隆音色 7 天不调用会被删除
- 视频/音乐生成消耗 Token Plan 请求配额
