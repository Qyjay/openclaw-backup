# SESSION-STATE.md — Active Working Memory

## Current Task
DiviMind v2 — 后端 MVP + 前端打磨完成，全链路通畅

## ⚠️ 铁律：通知优先于验证
**Claude Code 完成 → 30 秒内飞书通知前辈 → 然后再验证**
2026-03-21 同一天犯了三次迟报。前辈说「事不过三」。不会再有第四次。

## Dispatch Workflow
- **模式**: Dispatch-First（BB 监工，Claude Code 执行）
- **编码工具**: Claude Code via ACP（可多开并行）
- **质量保障**: personal-hub skill（7 步流程 + 质量门禁）
- **PR 平台**: GitHub（`gh` CLI）

### ⚠️ Claude Code 监控规则（铁律）
1. **永远不设 exec timeout** — 用 `background: true` 启动，不加 `timeout` 参数
2. **Prompt 尾部必须加 wake event** — Claude Code 完成后自动通知：
   `openclaw system event --text "Done: [摘要]" --mode now`
3. **每 3 分钟轮询一次** — `process action=poll` 检查 session 状态
4. **状态变化立刻飞书汇报** — 完成/失败/卡住/需要输入，第一时间发飞书
5. **发现卡住立刻干预** — 超过 10 分钟无新输出，kill 并重新 spawn
6. **绝不静默失败** — 任何异常都发飞书通知前辈

## Active Sessions
<!-- Claude Code sessions spawned by BB -->
<!-- 格式: | 时间 | session | 项目 | 任务 | 状态 | -->
| 17:27 | marine-glade | divi-mind-v2 | 生辰八字功能（排盘引擎+AI解读+前端） | 🔄 执行中 |

## Key Context
- Master: Kylin，南开大三，MiniMax 实习
- ACP 已启用，Claude Code 作为默认 agent
- personal-hub skill 已安装到 ~/.claude/skills/hub
- GitHub 账号: Qyjay，gh CLI 已认证

## Pending Actions
- [ ] 等待前辈第一个编码任务，验证 dispatch 工作流

## Recent Decisions
- [2026-03-21] 安装 personal-hub skill（从 weaver hub 改造）
- [2026-03-21] 集成 agent-dispatch 调度理念到 BB 工作流
- [2026-03-21] 确立 Dispatch-First 原则：BB 不写代码，派 Claude Code

---
*Last updated: 2026-03-21 17:59*
