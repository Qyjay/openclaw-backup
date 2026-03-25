# SESSION-STATE.md — Hot RAM

## Current Project
**AIGC 比赛 — 大学生 AI 生活伙伴 App**
- 比赛：第三届中国高校计算机大赛·AIGC创新赛（应用赛道）
- 初赛截止：2026年5月11日
- 技术栈：UniApp (Vue 3) + TypeScript

## Current Status
**前端 MVP 已完成** ✅（2026-03-23 晚）
- 5 Sprint 全部完成，46 个源文件，11,691 行代码
- 20 个完整页面 + 多个复用组件
- 全部 Mock 数据驱动，`USE_MOCK = true` 一键切换
- Dev server: `http://localhost:5177/`

**后端 v2 改造完成** ✅（2026-03-25 15:15）
- 模型扩展 + 素材/日记/纪念日/衍生/社交/对话模块全部实现
- 测试通过

## Open TODOs
- [ ] 产品名称最终确定（候选：半日 > 拾光 > 同频 > 在场 > 碎碎念）
- [ ] Logo 方案选择（4选1：A日记本/B小太阳/C气泡笔/D小狐狸，推荐D）
- [ ] 后端搭建（Phase 2）
- [ ] 前后端联调（Phase 3）
- [ ] 真机测试 APK 打包（Phase 4）
- [ ] 竞品分析（PRD 待补充）
- [ ] 队友分工规划
- [ ] 泄露的 API key 需轮换
- [ ] UI 细节打磨（中间写按钮图标、页面过渡动画等）

## Key Paths
- 项目目录：`projects/aigc-competition/app/`
- PRD：`projects/aigc-competition/PRD-v1.md`
- 设计规范：`projects/aigc-competition/design/frontend-design-spec.md`
- 设计系统：`projects/aigc-competition/design/design-system.md`
- 服务层：`src/services/config.ts`（USE_MOCK 开关）

## Last Session
- 2026-03-23 22:37：Master 说晚安，明天继续
