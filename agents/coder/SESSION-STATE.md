# SESSION-STATE.md — BB 热内存

## 当前任务
日迹 App v2 大改造 — 前后端同步改造

## Active Sessions
- **后端改造** — Claude Code（进行中）
- **前端改造** — Claude Code（进行中）

## 改造范围
### 后端（Step 1-7）
1. 数据模型扩展（material, anniversary, user_profile, derivative + 扩展 diary/user/social）
2. Alembic 迁移
3. 素材模块 CRUD + AI（情绪提取、文字润色）
4. 日记模块重写（AI 生成、修改限制、情绪趋势、信息提取、衍生内容）
5. 纪念日 + 衍生内容 + 用户画像
6. 社交扩展 + AI 对话 SSE + MiniMax 客户端扩展
7. 集成验证 + 测试 + 种子数据

### 前端（API + Mock 同步）
- 新增: api/material.ts, api/anniversary.ts
- 重写: api/diary.ts, api/ai.ts
- 扩展: api/social.ts, api/user.ts
- 新增 Mock: mock/material.ts, mock/anniversary.ts
- 重写 Mock: mock/diary.ts, mock/ai.ts
- 扩展 Mock: mock/social.ts
- 更新 services/index.ts

## 关键决策
- 确定性 AI 功能（情绪提取、润色、日记生成）→ 直接调 MiniMax API
- 对话 + 推送 → 走 OpenClaw Agent
- 前端保持 USE_MOCK=true 开发模式
- 不删除现有文件，只增和改

## 等待
前后端 Claude Code 完成
