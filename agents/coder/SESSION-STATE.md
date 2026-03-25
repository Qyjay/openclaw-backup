# SESSION-STATE.md — Active Working Memory

## Current Task
**AIGC 比赛 — 日迹 App**（全面接手，前辈直接调度）

## 比赛信息
- 比赛：第三届中国高校计算机大赛·AIGC创新赛（应用赛道）
- 初赛截止：2026年5月11日（还剩约 6.5 周）
- 技术栈：UniApp (Vue 3) + Vite + TypeScript / FastAPI + SQLite（后端规划）
- **产品名：日迹** ✅

## Current Status
- **Phase 1 前端 MVP** ✅（2026-03-23）
- **UI Doodle 重构** ✅（2026-03-24，24文件，40+图标）
- **rpx 单位统一** ✅（2026-03-24）
- **APK 打包** 🔄 进行中（HBuilderX 云打包，Mock 数据版）
- **Phase 2 后端搭建** ⬜ 下一步

## 迭代路线
路线 B → 先打磨前端+APK → 再搭后端
后端由 BB 负责，部署先用 Mac + 内网穿透

## Key Paths
- 项目根目录：`~/.openclaw/workspace/projects/aigc-competition/`
- 前端代码：`projects/aigc-competition/app/`
- PRD：`projects/aigc-competition/PRD-v1.md`
- 设计规范：`projects/aigc-competition/design/frontend-design-spec.md`
- UI 重构规范：`projects/aigc-competition/UI-REFACTOR-SPEC.md`

## ⚠️ 铁律：通知优先于验证
**Claude Code 完成 → 30 秒内通知前辈 → 然后再验证**

## Dispatch Workflow
- **模式**: Dispatch-First（BB 监工，Claude Code 执行）
- **编码工具**: Claude Code via exec background

## Active Sessions
<!-- 格式: | 时间 | session | 任务 | 状态 | -->
| 11:33 | calm-ember | UI Doodle Round 1 | ✅ |
| 12:02 | plaid-slug | UI Doodle Round 2 | ✅ |
| 13:10 | amber-crustacean | px→rpx 统一 | ✅ |
| 17:03 | tender-prairie | 全页面布局统一 | ✅ |

## Key Context
- Master: Kylin，南开大三，MiniMax 实习
- 5人团队，队友分工待定
- SVG 图标是 Claude Code 手写 path，非 NanoBanana
- SVG width/height 不支持 rpx，用 100% + 外层 view rpx 控制

---
*Last updated: 2026-03-24 14:55*
