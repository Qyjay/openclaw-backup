# SESSION-STATE.md — BB 热内存

## 当前任务
日迹 App 后端重写 — 已完成（2026-03-25 夜）

## 已完成
- 前端代码推送到 GitHub: https://github.com/Qyjay/riji-frontend (public)
- API-SPEC.md 生成（52 接口完整规范）
- BACKEND-REWRITE-SPEC.md 生成（开发路径规范）
- 旧后端分析报告（6 大类问题定位）
- 后端重写 Group 0→7 全量完成

## 关键决策
- 全局 camelCase: CamelModel 基类 + alias_generator=to_camel
- 列表格式逐接口核对前端泛型参数
- POST /chat 返回纯文本不是 SSE
- 可复用: config/database/dependencies/response/auth-service/minimax-client/models
- 重写: 所有 router.py + schemas.py + service.py

## 待处理
- 日迹 App 后端部署验证（未开始）
- AIGC 比赛后端（未开始）

## Active Sessions
无活跃 session。

