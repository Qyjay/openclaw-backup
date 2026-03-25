# 日迹 App — 后端开发规范文档

> **版本**: v1.0
> **日期**: 2026-03-24
> **产品名**: 日迹（大学生 AI 生活伙伴 App）
> **面向读者**: 后端开发者（无需任何项目上下文即可开工）

---

## 一、项目概述

### 1.1 产品简介
「日迹」是一款面向大学生的 AI 生活伙伴 App。核心闭环：**记录 → 创作 → 理解 → 陪伴 → 连接**。

用户拍照/写文字 → AI 帮你扩写日记 → AI 分析情绪/生成漫画/配乐 → AI 对话陪伴 → AI 匹配兴趣搭子。

### 1.2 技术栈要求
| 层级 | 技术选型 | 说明 |
|------|---------|------|
| **框架** | FastAPI (Python 3.11+) | 异步高性能，原生支持 SSE |
| **数据库** | SQLite (开发) / PostgreSQL (生产) | SQLAlchemy ORM + Alembic 迁移 |
| **AI** | MiniMax API (TokenPlan) | 大模型对话/文本生成 |
| **图片生成** | MiniMax 图片 API | 漫画/分享卡片 |
| **语音** | MiniMax TTS API | 文本转语音 |
| **认证** | JWT (HS256) | 无需第三方 OAuth，自注册 |
| **文件存储** | 本地磁盘 (开发) / OSS (生产) | 头像/日记图片 |
| **部署** | Mac 本地 + 内网穿透 (开发) | 后续迁移云服务器 |

### 1.3 项目结构（推荐）
```
backend/
├── app/
│   ├── main.py              # FastAPI 入口
│   ├── config.py            # 配置（环境变量/API Key）
│   ├── database.py          # 数据库连接 + Session
│   ├── auth/
│   │   ├── router.py        # 注册/登录路由
│   │   ├── service.py       # JWT 生成/验证
│   │   ├── models.py        # User 模型
│   │   └── schemas.py       # Pydantic 请求/响应
│   ├── diary/
│   │   ├── router.py
│   │   ├── service.py
│   │   ├── models.py
│   │   └── schemas.py
│   ├── ai/
│   │   ├── router.py
│   │   ├── service.py       # MiniMax API 调用封装
│   │   └── schemas.py
│   ├── study/
│   │   ├── router.py
│   │   ├── service.py
│   │   ├── models.py
│   │   └── schemas.py
│   ├── social/
│   │   ├── router.py
│   │   ├── service.py
│   │   ├── models.py
│   │   └── schemas.py
│   ├── user/
│   │   ├── router.py
│   │   ├── service.py
│   │   ├── models.py
│   │   └── schemas.py
│   └── upload/
│       ├── router.py        # 文件上传
│       └── service.py
├── alembic/                  # 数据库迁移
├── tests/                    # 测试
├── requirements.txt
├── .env.example
└── README.md
```

---

## 二、全局约定

### 2.1 API 基础路径
```
Base URL: http://{host}:8000/api
```

### 2.2 认证方式
- 所有 API（除 `/api/auth/register` 和 `/api/auth/login`）均需 JWT 认证
- 请求头: `Authorization: Bearer <token>`
- Token 有效期: 7 天
- 刷新策略: 每次请求自动延长（可选）

### 2.3 统一响应格式

```json
// 成功
{
  "code": 0,
  "data": { ... },
  "message": "ok"
}

// 失败
{
  "code": 40001,
  "data": null,
  "message": "用户名已存在"
}
```

### 2.4 错误码规范
| 范围 | 含义 |
|------|------|
| 0 | 成功 |
| 40001-40099 | 认证/权限错误 |
| 40101-40199 | 参数校验错误 |
| 40201-40299 | 业务逻辑错误 |
| 50001-50099 | 服务器内部错误 |
| 50101-50199 | 第三方 API 错误（MiniMax 等） |

### 2.5 分页约定
```
GET /api/xxx?page=1&pageSize=10

Response:
{
  "code": 0,
  "data": {
    "list": [...],
    "total": 127,
    "page": 1,
    "pageSize": 10
  }
}
```

### 2.6 时间格式
- 所有时间戳使用 **毫秒级 Unix 时间戳**（前端 `Date.now()` 格式）
- 数据库内部可用 ISO 8601，API 输出统一转毫秒时间戳

---

## 三、数据模型

### 3.1 User（用户）
```sql
CREATE TABLE users (
  id          TEXT PRIMARY KEY,     -- UUID
  username    TEXT UNIQUE NOT NULL,  -- 用户名（登录用）
  password    TEXT NOT NULL,         -- bcrypt 哈希
  name        TEXT DEFAULT '',       -- 昵称（展示用）
  school      TEXT DEFAULT '',
  major       TEXT DEFAULT '',
  grade       TEXT DEFAULT '',       -- 大一/大二/大三/大四/研一/研二/研三
  avatar      TEXT DEFAULT '',       -- 头像 URL
  signature   TEXT DEFAULT '',       -- 个性签名
  level       INTEGER DEFAULT 1,
  xp          INTEGER DEFAULT 0,
  diary_count INTEGER DEFAULT 0,
  streak_days INTEGER DEFAULT 0,
  pomodoro_count INTEGER DEFAULT 0,
  created_at  INTEGER NOT NULL,      -- 毫秒时间戳
  updated_at  INTEGER NOT NULL
);
```

### 3.2 Diary（日记）
```sql
CREATE TABLE diaries (
  id          TEXT PRIMARY KEY,
  user_id     TEXT NOT NULL REFERENCES users(id),
  content     TEXT NOT NULL,          -- 日记正文
  images      TEXT DEFAULT '[]',      -- JSON 数组，图片 URL 列表
  emotion     TEXT DEFAULT '{}',      -- JSON: { emoji, label, score }
  tags        TEXT DEFAULT '[]',      -- JSON 数组
  location    TEXT DEFAULT '',
  weather     TEXT DEFAULT '',
  style       TEXT DEFAULT '日记式',   -- 文风（治愈系/日记式/故事型/热血型/活力型）
  has_comic   INTEGER DEFAULT 0,
  has_bgm     INTEGER DEFAULT 0,
  comic_url   TEXT DEFAULT '',
  bgm_url     TEXT DEFAULT '',
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL
);
CREATE INDEX idx_diaries_user ON diaries(user_id, created_at DESC);
```

### 3.3 ChatMessage（AI 对话）
```sql
CREATE TABLE chat_messages (
  id          TEXT PRIMARY KEY,
  user_id     TEXT NOT NULL REFERENCES users(id),
  role        TEXT NOT NULL,          -- 'user' | 'assistant'
  content     TEXT NOT NULL,
  timestamp   INTEGER NOT NULL
);
CREATE INDEX idx_chat_user ON chat_messages(user_id, timestamp DESC);
```

### 3.4 Pomodoro（番茄钟）
```sql
CREATE TABLE pomodoros (
  id           TEXT PRIMARY KEY,
  user_id      TEXT NOT NULL REFERENCES users(id),
  task         TEXT NOT NULL,
  subject      TEXT DEFAULT '',
  duration     INTEGER DEFAULT 25,    -- 分钟
  completed_at INTEGER,               -- NULL = 进行中
  created_at   INTEGER NOT NULL
);
```

### 3.5 Todo（待办）
```sql
CREATE TABLE todos (
  id          TEXT PRIMARY KEY,
  user_id     TEXT NOT NULL REFERENCES users(id),
  content     TEXT NOT NULL,
  completed   INTEGER DEFAULT 0,
  priority    TEXT DEFAULT 'medium',  -- low / medium / high
  created_at  INTEGER NOT NULL
);
```

### 3.6 Match（搭子匹配）
```sql
CREATE TABLE matches (
  id           TEXT PRIMARY KEY,
  user_id      TEXT NOT NULL REFERENCES users(id),
  target_id    TEXT NOT NULL REFERENCES users(id),
  common_tags  TEXT DEFAULT '[]',     -- JSON 数组
  status       TEXT DEFAULT 'pending', -- pending / accepted / rejected
  created_at   INTEGER NOT NULL
);
```

### 3.7 Achievement（成就）
```sql
CREATE TABLE user_achievements (
  id             TEXT PRIMARY KEY,
  user_id        TEXT NOT NULL REFERENCES users(id),
  achievement_id TEXT NOT NULL,        -- 对应成就定义 ID
  unlocked_at    INTEGER NOT NULL,
  UNIQUE(user_id, achievement_id)
);
```

成就定义为静态配置（代码常量），不存数据库：
```python
ACHIEVEMENTS = [
  {"id": "a1",  "title": "初次书写", "desc": "写下第一篇日记",     "condition": "diary_count >= 1"},
  {"id": "a2",  "title": "连续7天",  "desc": "连续写日记7天",     "condition": "streak_days >= 7"},
  {"id": "a3",  "title": "情绪大师", "desc": "记录10种不同情绪",   "condition": "unique_emotions >= 10"},
  {"id": "a4",  "title": "番茄达人", "desc": "完成50个番茄钟",     "condition": "pomodoro_count >= 50"},
  {"id": "a5",  "title": "百篇日记", "desc": "写满100篇日记",     "condition": "diary_count >= 100"},
  {"id": "a6",  "title": "社交达人", "desc": "与AI对话超过100次",  "condition": "chat_count >= 100"},
  {"id": "a7",  "title": "连续30天", "desc": "连续写日记30天",     "condition": "streak_days >= 30"},
  {"id": "a8",  "title": "自传作者", "desc": "生成AI小说章节",     "condition": "novel_chapters >= 1"},
]
```

---

## 四、API 接口详细定义

### 模块 A：认证模块 (auth)

#### A1. 用户注册
```
POST /api/auth/register
无需认证

Request Body:
{
  "username": "kylin",          // 4-20 字符，字母数字下划线
  "password": "123456",         // 6-32 字符
  "name": "Kylin",              // 可选，昵称
  "school": "南开大学",          // 可选
  "major": "软件工程"            // 可选
}

Response 200:
{
  "code": 0,
  "data": {
    "token": "eyJhbGciOi...",
    "user": {
      "id": "uuid-xxx",
      "username": "kylin",
      "name": "Kylin",
      "school": "南开大学",
      "major": "软件工程",
      "avatar": "",
      "level": 1
    }
  }
}

Error 40001: "用户名已存在"
Error 40101: "用户名格式不正确"
```

#### A2. 用户登录
```
POST /api/auth/login

Request Body:
{
  "username": "kylin",
  "password": "123456"
}

Response 200:
{
  "code": 0,
  "data": {
    "token": "eyJhbGciOi...",
    "user": { ... }              // 同注册返回的 user 结构
  }
}

Error 40002: "用户名或密码错误"
```

---

### 模块 B：用户模块 (user)

#### B1. 获取用户资料
```
GET /api/user/profile
需要认证

Response:
{
  "code": 0,
  "data": {
    "name": "Kylin",
    "school": "南开大学",
    "major": "软件工程",
    "grade": "大三",
    "signature": "记录每一天",
    "level": 12,
    "xp": 2450,
    "diaryCount": 127,
    "streakDays": 23,
    "pomodoroCount": 247,
    "avatar": "http://xxx/avatar.jpg"
  }
}
```

#### B2. 更新用户资料
```
POST /api/user/profile
需要认证

Request Body（所有字段可选）:
{
  "name": "新昵称",
  "school": "南开大学",
  "major": "计算机科学",
  "grade": "大三",
  "signature": "新的个性签名"
}

Response: 返回更新后的完整 profile（同 B1）
```

#### B3. 上传头像
```
POST /api/user/avatar
需要认证
Content-Type: multipart/form-data

Form Field: file (image/jpeg | image/png, 最大 5MB)

Response:
{
  "code": 0,
  "data": {
    "avatar": "http://xxx/avatars/uuid-xxx.jpg"
  }
}
```

#### B4. 获取成长数据
```
GET /api/user/growth
需要认证

Response:
{
  "code": 0,
  "data": {
    "diaries": [
      { "date": "2026-03-01", "count": 2 },
      { "date": "2026-03-05", "count": 1 }
    ],
    "emotions": [
      { "label": "开心", "count": 45 },
      { "label": "平静", "count": 32 }
    ],
    "tags": [
      { "label": "学习", "count": 48 },
      { "label": "心情", "count": 35 }
    ],
    "pomodoros": [
      { "date": "2026-03-01", "count": 5 }
    ],
    "streak": [1, 2, 3, ..., 23]
  }
}
```

#### B5. 获取成就列表
```
GET /api/user/achievements
需要认证

Response:
{
  "code": 0,
  "data": [
    {
      "id": "a1",
      "title": "初次书写",
      "description": "写下第一篇日记",
      "icon": "✏️",
      "unlocked": true,
      "unlockedAt": 1711267200000
    },
    {
      "id": "a9",
      "title": "成就达人",
      "description": "解锁10个成就",
      "icon": "🏆",
      "unlocked": false,
      "unlockedAt": null
    }
  ]
}
```

#### B6. 获取/更新设置
```
GET /api/user/settings
POST /api/user/settings
需要认证

Settings 结构:
{
  "theme": "light",             // light | dark
  "notifications": true,
  "autoBGM": false,
  "diaryPrivacy": "private",   // private | friends | public
  "language": "zh-CN"
}
```

#### B7. 获取学期报告
```
GET /api/user/semester-report
需要认证

Response:
{
  "code": 0,
  "data": {
    "totalDiaries": 127,
    "totalPomodoros": 247,
    "topEmotions": [{ "label": "开心", "count": 45 }],
    "topTags": [{ "label": "学习", "count": 48 }],
    "writingTime": 38,          // 小时
    "avgEmotion": 72,           // 平均情绪分 0-100
    "streak": 23,
    "achievements": 8,
    "highlights": ["连续写日记23天，打破个人记录！"]
  }
}
```

#### B8. 获取 AI 画像
```
GET /api/user/agent-portrait
需要认证

Response:
{
  "code": 0,
  "data": {
    "portrait": "http://xxx/portraits/uuid-xxx.jpg"
  }
}
```

---

### 模块 C：日记模块 (diary)

#### C1. 获取日记列表（分页）
```
GET /api/diaries?page=1&pageSize=10
需要认证

Response:
{
  "code": 0,
  "data": {
    "list": [
      {
        "id": "uuid-xxx",
        "content": "今天终于把雅思阅读真题做完了！...",
        "images": ["http://xxx/1.jpg", "http://xxx/2.jpg"],
        "emotion": { "emoji": "😊", "label": "开心", "score": 92 },
        "tags": ["学习", "美食"],
        "location": "南开大学图书馆",
        "weather": "☀️ 晴",
        "style": "治愈系",
        "createdAt": 1711267200000,
        "hasComic": true,
        "hasBGM": false
      }
    ],
    "total": 127,
    "page": 1,
    "pageSize": 10
  }
}
```

#### C2. 获取日记详情
```
GET /api/diaries/{id}
需要认证（只能查自己的日记）

Response: 单个 Diary 对象（同 C1 列表项结构，额外包含 comicUrl / bgmUrl）
```

#### C3. 创建日记
```
POST /api/diaries
需要认证

Request Body:
{
  "content": "今天阳光很好...",
  "images": ["http://xxx/1.jpg"],     // 可选
  "emotion": { "emoji": "😊", "label": "开心", "score": 85 },  // 可选，后端可 AI 自动分析
  "tags": ["学习"],                    // 可选，后端可 AI 自动提取
  "location": "南开大学",              // 可选
  "weather": "☀️ 晴",                  // 可选
  "style": "治愈系"                    // 可选，默认 "日记式"
}

Response: 创建的 Diary 对象

业务逻辑:
1. 保存日记
2. 更新用户 diary_count + xp
3. 计算连续天数 streak_days
4. 检查成就解锁条件（异步）
5. 如果 content 为空但 images 不为空，可调 AI 根据图片生成文字（可选）
```

#### C4. 上传日记图片
```
POST /api/upload/diary-image
需要认证
Content-Type: multipart/form-data

Form Field: file (image/jpeg | image/png, 最大 10MB)

Response:
{
  "code": 0,
  "data": {
    "url": "http://xxx/diary-images/uuid-xxx.jpg"
  }
}
```

---

### 模块 D：AI 模块 (ai)

> **关键模块**——这是 AIGC 比赛的核心评分项。

#### D1. AI 对话（流式/SSE）
```
POST /api/ai/chat
需要认证

Request Body:
{
  "messages": [
    { "role": "user", "content": "最近压力好大", "timestamp": 1711267200000 },
    { "role": "assistant", "content": "我理解...", "timestamp": 1711267201000 },
    { "role": "user", "content": "雅思考了7分！", "timestamp": 1711267202000 }
  ]
}

Response (SSE 流式):
event: message
data: {"content": "太"}

event: message
data: {"content": "棒了"}

event: message
data: {"content": "！"}

event: done
data: {"fullContent": "太棒了！这是你努力的回报！"}

非流式备用 Response:
{
  "code": 0,
  "data": "太棒了！这是你努力的回报！"
}

MiniMax API 调用要点:
- system prompt 需包含用户画像（从日记/标签中提取）
- 对话历史带上最近 20 条
- temperature: 0.8（有温度的回复）
- 角色：温暖、鼓励、理解的 AI 伙伴，了解用户的大学生活
```

#### D2. AI 扩写日记
```
POST /api/ai/generate-diary
需要认证

Request Body:
{
  "images": ["http://xxx/1.jpg"],   // 图片 URL（可选）
  "text": "今天去吃了火锅",          // 用户简短输入
  "style": "治愈系"                  // 文风
}

Response:
{
  "code": 0,
  "data": "今天和室友去了学校旁边那家新开的火锅店..."
}

MiniMax API 调用要点:
- 根据 style 调整 prompt 风格
- 如果有图片，先用多模态理解图片内容，再结合文字扩写
- 输出 200-500 字
```

#### D3. AI 生成运势
```
GET /api/ai/fortune
需要认证

Response:
{
  "code": 0,
  "data": {
    "overall": 4,          // 1-5 星
    "study": 4,
    "social": 5,
    "health": 3,
    "tip": "今天适合去图书馆",
    "luckyColor": "天空蓝",
    "luckyNumber": 7
  }
}

逻辑:
- 根据用户最近日记/情绪/标签，结合日期生成个性化运势
- 每天缓存一次（同一天多次请求返回相同结果）
```

#### D4. AI 生成漫画
```
POST /api/ai/comic
需要认证

Request Body:
{
  "diaryId": "uuid-xxx",
  "style": "水彩"           // 水彩 | 像素 | 简笔画 | 复古漫画
}

Response:
{
  "code": 0,
  "data": "http://xxx/comics/uuid-xxx.jpg"
}

逻辑:
1. 读取日记内容
2. 提取关键场景描述
3. 调用 MiniMax 图片生成 API
4. 保存图片，更新日记 has_comic = true + comic_url
```

#### D5. AI 生成分享卡片
```
POST /api/ai/share-card
需要认证

Request Body:
{
  "diaryId": "uuid-xxx",
  "template": "simple"      // simple | polaroid | postcard | artistic
}

Response:
{
  "code": 0,
  "data": "http://xxx/share-cards/uuid-xxx.jpg"
}
```

#### D6. AI 生成 BGM
```
POST /api/ai/bgm
需要认证

Request Body:
{
  "diaryId": "uuid-xxx"
}

Response:
{
  "code": 0,
  "data": "http://xxx/bgm/uuid-xxx.mp3"
}

逻辑:
- 分析日记情绪，匹配预设 BGM 库
- 或调用 MiniMax 音乐生成 API（如有）
- 更新日记 has_bgm = true + bgm_url
```

#### D7. 文本转语音 (TTS)
```
POST /api/ai/tts
需要认证

Request Body:
{
  "text": "今天阳光很好...",
  "voice": "warm_female"     // 预设音色 ID
}

Response:
{
  "code": 0,
  "data": "http://xxx/tts/uuid-xxx.mp3"
}
```

#### D8. AI 生成小说章节
```
POST /api/ai/novel-chapter
需要认证

Response:
{
  "code": 0,
  "data": "清晨的阳光透过窗帘洒进房间..."
}

逻辑:
- 从用户所有日记中提取关键事件
- 以第一人称自传体写作
- 每次生成约 800-1500 字
- 保持前后章节连贯（需传入之前章节摘要）
```

---

### 模块 E：学习模块 (study)

#### E1. 番茄钟 CRUD
```
GET    /api/study/pomodoros                    // 获取列表
POST   /api/study/pomodoros                    // 创建
POST   /api/study/pomodoros/{id}/complete      // 标记完成

Pomodoro 结构:
{
  "id": "uuid-xxx",
  "task": "雅思阅读真题",
  "subject": "雅思阅读",
  "duration": 25,
  "completedAt": 1711267200000,     // null = 进行中
  "createdAt": 1711267200000
}

完成番茄钟后更新用户 pomodoro_count + xp
```

#### E2. 待办 CRUD
```
GET    /api/study/todos                        // 获取列表
POST   /api/study/todos                        // 创建
POST   /api/study/todos/{id}/toggle            // 切换完成状态

Todo 结构:
{
  "id": "uuid-xxx",
  "content": "完成留学文书",
  "completed": false,
  "priority": "high",              // low | medium | high
  "createdAt": 1711267200000
}
```

---

### 模块 F：社交模块 (social)

#### F1. 获取搭子列表
```
GET /api/social/matches
需要认证

Response:
{
  "code": 0,
  "data": [
    {
      "id": "uuid-xxx",
      "nickname": "小鹿",
      "avatar": "http://xxx/avatar.jpg",
      "school": "天津大学",
      "commonTags": ["学习", "留学"],
      "matchedAt": 1711267200000
    }
  ]
}
```

#### F2. 发起匹配请求
```
POST /api/social/match-requests
需要认证

Request Body:
{
  "targetId": "uuid-xxx"
}
```

#### F3. 获取消息列表
```
GET /api/social/messages?matchId=xxx
需要认证
```

---

## 五、MiniMax API 集成指南

### 5.1 API 配置
```python
# .env
MINIMAX_API_KEY=your_token_plan_key
MINIMAX_API_BASE=https://api.minimax.chat/v1
MINIMAX_MODEL=abab6.5-chat      # 或最新可用模型
```

### 5.2 对话 API 调用示例
```python
import httpx

async def chat_with_minimax(messages: list, system_prompt: str) -> str:
    async with httpx.AsyncClient() as client:
        resp = await client.post(
            f"{MINIMAX_API_BASE}/text/chatcompletion_v2",
            headers={"Authorization": f"Bearer {MINIMAX_API_KEY}"},
            json={
                "model": MINIMAX_MODEL,
                "messages": [
                    {"role": "system", "content": system_prompt},
                    *messages
                ],
                "temperature": 0.8,
                "max_tokens": 2048,
                "stream": True,     # SSE 流式
            },
            timeout=60,
        )
        # 处理 SSE 流...
```

### 5.3 System Prompt 模板
```
你是「日迹」App 的 AI 伙伴。你了解用户 {name} 的生活：
- 学校：{school}，专业：{major}，年级：{grade}
- 最近写了 {diary_count} 篇日记，连续 {streak_days} 天
- 常见话题标签：{top_tags}
- 最近情绪：{recent_emotions}

你的性格：温暖、鼓励、理解，像一个了解对方生活的好朋友。
- 记住用户之前说过的话
- 给出具体、有用的建议（不要空洞的鸡汤）
- 适当使用 emoji 表达情感
- 回复长度 50-200 字
```

---

## 六、并行开发分组

> 以下模块之间**完全独立**，可由不同开发者同时开发，互不干扰。

### 第一层：基础设施（串行，必须先完成）

```
[Group 0] 基础设施
├── database.py          数据库连接 + 建表
├── config.py            环境变量 / API Key
├── main.py              FastAPI 入口 + CORS + 路由注册
├── auth/                JWT 认证中间件
└── upload/              文件上传服务

预计: 2-3 小时
依赖: 无
产出: 可运行的空 FastAPI 服务 + 认证 + 文件上传
```

### 第二层：核心业务（并行，互不依赖）

```
[Group 1] 用户模块           [Group 2] 日记模块           [Group 3] AI 对话模块
├── user/models.py        ├── diary/models.py         ├── ai/service.py (MiniMax)
├── user/schemas.py       ├── diary/schemas.py        ├── ai/schemas.py
├── user/service.py       ├── diary/service.py        ├── ai/router.py
├── user/router.py        ├── diary/router.py         │   ├── POST /ai/chat
│   ├── GET  profile      │   ├── GET  /diaries       │   └── POST /ai/generate-diary
│   ├── POST profile      │   ├── GET  /diaries/:id   │
│   ├── POST avatar       │   └── POST /diaries       └── 依赖: Group 0
│   ├── GET  growth       │
│   ├── GET  achievements └── 依赖: Group 0            预计: 3-4 小时
│   ├── GET/POST settings
│   └── GET  semester-report
│
└── 依赖: Group 0         └── 依赖: Group 0
预计: 3-4 小时             预计: 2-3 小时
```

```
[Group 4] 学习模块           [Group 5] 社交模块
├── study/models.py       ├── social/models.py
├── study/schemas.py      ├── social/schemas.py
├── study/service.py      ├── social/service.py
├── study/router.py       ├── social/router.py
│   ├── 番茄钟 CRUD       │   ├── GET  matches
│   └── 待办 CRUD         │   ├── POST match-requests
│                         │   └── GET  messages
└── 依赖: Group 0         │
预计: 1-2 小时             └── 依赖: Group 0
                           预计: 2-3 小时
```

### 第三层：AI 增值功能（并行，互不依赖，依赖 Group 0 + Group 2）

```
[Group 6] AI 漫画生成        [Group 7] AI 运势            [Group 8] AI 语音/音乐
├── POST /ai/comic          ├── GET /ai/fortune          ├── POST /ai/tts
├── POST /ai/share-card     │                            ├── POST /ai/bgm
│                           └── 依赖: Group 0,2          │
└── 依赖: Group 0,2         预计: 1-2 小时               └── 依赖: Group 0,2
预计: 2-3 小时                                            预计: 2-3 小时
```

```
[Group 9] AI 小说生成
├── POST /ai/novel-chapter
│
└── 依赖: Group 0,2
预计: 2-3 小时
```

### 依赖关系图

```
                    [Group 0 基础设施]
                    /    |    |    \    \
                   v     v    v     v    v
              [G1用户] [G2日记] [G3对话] [G4学习] [G5社交]
                         |
                    ┌────┼────┬────┐
                    v    v    v    v
                 [G6漫画] [G7运势] [G8语音] [G9小说]
```

### 最大并行度

| 阶段 | 可并行任务数 | 具体模块 |
|------|------------|---------|
| 阶段 1 | 1 | Group 0（基础设施） |
| 阶段 2 | **5** | Group 1-5（用户/日记/AI对话/学习/社交） |
| 阶段 3 | **4** | Group 6-9（漫画/运势/语音/小说） |

---

## 七、测试要求

### 7.1 每个模块需提供
1. **API 测试**：用 pytest + httpx.AsyncClient 测试所有端点
2. **Mock MiniMax**：AI 模块测试时 mock 外部 API，不消耗 token
3. **认证测试**：无 token / 过期 token / 非法 token 均返回 401

### 7.2 测试文件命名
```
tests/
├── test_auth.py
├── test_user.py
├── test_diary.py
├── test_ai.py
├── test_study.py
└── test_social.py
```

---

## 八、部署配置

### 8.1 开发环境
```bash
# 安装依赖
pip install -r requirements.txt

# 创建 .env
cp .env.example .env
# 编辑 .env 填入 MINIMAX_API_KEY

# 初始化数据库
alembic upgrade head

# 启动开发服务器
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 8.2 前端对接
前端 `src/services/config.ts` 中：
```ts
export const USE_MOCK = false
export const API_BASE_URL = 'http://192.168.x.x:8000/api'  // 本地 IP
```

### 8.3 .env.example
```env
# 数据库
DATABASE_URL=sqlite:///./data.db

# JWT
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRE_DAYS=7

# MiniMax API
MINIMAX_API_KEY=your_token_plan_key
MINIMAX_API_BASE=https://api.minimax.chat/v1
MINIMAX_MODEL=abab6.5-chat

# 文件上传
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760

# 服务器
HOST=0.0.0.0
PORT=8000
```

---

## 九、注意事项

1. **所有时间戳用毫秒**——前端 `Date.now()` 返回毫秒，后端统一用毫秒存储和输出
2. **JSON 字段用 TEXT 存储**——SQLite 不支持原生 JSON 类型，用 TEXT 存 JSON 字符串，读取时 `json.loads()`
3. **文件上传路径隔离**——按用户 ID 分目录：`uploads/{user_id}/avatars/`、`uploads/{user_id}/diary-images/`
4. **MiniMax API 限流**——TokenPlan 有 QPS 限制，需加请求队列或重试机制
5. **CORS 配置**——开发环境允许所有来源，生产环境限定前端域名
6. **SSE 流式**——AI 对话使用 Server-Sent Events，前端需要 EventSource 或手动解析
7. **成就检查异步化**——创建日记/完成番茄钟后异步检查成就解锁，不阻塞主流程
8. **数据库迁移**——使用 Alembic 管理 schema 变更，不手动改表

---

*文档版本: v1.0 | 更新日期: 2026-03-24 | 作者: Babette Lucy (BB)*
