# Lessons & Mistakes

## 2026-03-22
- **Servant 交付未验收：** BB 开发 DiviMind v2 后端，代码写了但 pip 依赖未安装到系统环境，我没有检查就视为完成。**规则：任何 Servant 交付的项目，必须执行全栈冒烟测试（前端渲染 + 后端 health check + 核心 API 调用）**
- **项目启动只做一半：** Master 要求打开塔罗项目，我只启动了前端 Vite dev server，忘了检查后端。**规则：Web 全栈项目，前后端必须同时拉起并确认连通**
- **环境假设：** 假设 BB 已经搭好环境（pip install），没有验证。**规则：不要假设环境就绪，永远先验证**

## 2026-03-19
- API Key 类型搞混：MiniMax JWT Token ≠ Google Gemini API Key，要注意区分代理节点和原生 API
- nano-banana API 端点：MiniMax 代理路径是 `api.minimax.io/v1/gemini`，不是 `api.minimaxi.com/google`
- 需要 `X-Biz-Id: op` header + Bearer token 认证
