# Lessons & Mistakes

## 2026-03-19
- API Key 类型搞混：MiniMax JWT Token ≠ Google Gemini API Key，要注意区分代理节点和原生 API
- nano-banana API 端点：MiniMax 代理路径是 `api.minimax.io/v1/gemini`，不是 `api.minimaxi.com/google`
- 需要 `X-Biz-Id: op` header + Bearer token 认证
