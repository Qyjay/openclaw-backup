# SESSION-STATE.md — BB 热内存

## 当前任务
日迹 App 后端重写 — 52 接口全量实现

## Active Sessions
- **后端重写** — Claude Code session `rapid-harbor` PID 84189（进行中）
  - 项目路径: ~/projects/riji-backend/
  - 规范文档: BACKEND-REWRITE-SPEC.md + API-SPEC.md
  - 执行计划: Group 0→7 串行，预估 3 小时
  - 启动时间: 2026-03-25 21:16

## 已完成
- 前端代码推送到 GitHub: https://github.com/Qyjay/riji-frontend (public)
- API-SPEC.md 生成（52 接口完整规范）
- BACKEND-REWRITE-SPEC.md 生成（开发路径规范）
- 旧后端分析报告（6 大类问题定位）

## 关键决策
- 全局 camelCase: CamelModel 基类 + alias_generator=to_camel
- 列表格式逐接口核对前端泛型参数
- POST /chat 返回纯文本不是 SSE
- 可复用: config/database/dependencies/response/auth-service/minimax-client/models
- 重写: 所有 router.py + schemas.py + service.py

## 等待
Claude Code 完成后端重写（自动 system event 通知）
