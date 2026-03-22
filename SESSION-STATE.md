# SESSION-STATE.md — Active Working Memory

## Current Task
DiviMind v2 塔罗占卜平台 — 开发迭代中

## Key Context
- Master: Kylin，南开大三，MiniMax 实习
- 飞书渠道已连接
- ACP 模式已启用，Claude Code 作为默认 agent

## DiviMind v2 Status
- **后端** `~/projects/divi-mind-v2/backend/`：运行正常，MiniMax-M1 模型
  - 知识库已迁移，R.I.T.E. 解读法已整合
  - SSE 流式加了错误处理和重试
  - 启动命令：`cd backend && python3 main.py`
- **前端** `~/projects/divi-mind-v2/frontend/`：Vite dev server
  - Claude Code 已修复流式体验（未 commit）
  - 启动命令：`cd frontend && npm run dev`
- **已知问题**：Master 反馈浏览器仍有 CORS/SSE 报错，需进一步排查

## Pending Actions
- [ ] 确认前端修复效果（Master 刷新页面测试）
- [ ] 泄露的 API key 需要轮换
- [ ] BB 的 Hermes 架构学习笔记待检查

## Recent Decisions
- [2026-03-22] Hermes Agent 架构 10 个核心模式融合到 skill + AGENTS.md
- [2026-03-22] DiviMind 塔罗解读升级：R.I.T.E. 框架 + 知识库注入
- [2026-03-22] 后端 SSE 加重试机制（2 次）和异常兜底

---
*Last updated: 2026-03-22 17:42*
