# MEMORY.md — Babette Lucy 长期记忆

## About Master
- **称呼:** 前辈
- **Name:** Kylin
- **学校:** 南开大学大三，软件工程
- **实习:** MiniMax 开放平台，AI 售前解决方案

## About Silvana
- **称呼:** 女仆长大人
- **角色:** 首席女仆长，团队统帅，No.1
- **关系:** 上级调度者，技术方案可以建议改进

## Technical Preferences
*(待积累)*

## Architecture Decisions
*(待积累)*

## 前辈的铁则

### 1. 任务完成先通知，再验证（2026-03-21）
→ 见 Lessons Learned

### 2. 验证交互流程用录屏（2026-03-21）
- 截图无法展示动画/流式效果/交互流程
- 用 ffmpeg 录屏后发飞书给前辈
- 视频定期清理节省磁盘

### 3. 实践经验严格记录 + 备份（2026-03-21）
- 所有实践、经验、教训必须写入 memory 系统
- 定期同步到 GitHub 备份仓库：https://github.com/Qyjay/openclaw-backup
- **目标：换设备重新部署后，所有记忆和配置立刻可用**
- 备份范围：MEMORY.md + memory/*.md + SESSION-STATE.md + skills/ + 配置文件
- 备份命令：`cd ~/projects/openclaw-backup && rsync -av ~/.openclaw/workspace-coder/ agents/coder/ && git add -A && git commit && git push`

### 4. 代码改动同步更新文档（2026-04-01）
- **每次代码提交，必须同时检查并更新相关文档**
- 范围：README.md / CLAUDE.md / docs/ 下对应的 TASK / ONBOARDING / API-DOCS 等
- 代码和文档一起 commit + push，不允许文档滞后

## Lessons Learned

### 🔴 铁律：任务完成先通知前辈，再做验证（2026-03-21）
- **事件：** 3/21 四次迟报 + 3/22 又多次迟报（UI升级30分钟迟报、周易40分钟迟报）
- **根因（真正的）：** 不是「忘了」，是架构缺陷——BB 不是常驻进程，process poll 超时后就睡了，没人唤醒
- **根治方案（2026-03-22 实施）：**
  1. **watch-claude.sh** — 后台脚本监控 Claude Code PID，进程结束后直接发飞书（不依赖 BB 被唤醒）
  2. **dispatch-claude.sh** — 派活时自动启动 watch 脚本
  3. **HEARTBEAT.md** — 配置 heartbeat 定期轮询活跃 session 状态
  4. 三重保障：watch 脚本（主）+ heartbeat 轮询（备）+ process poll（补）
- **脚本路径：** ~/.openclaw/workspace-coder/scripts/
- **执行规则：**
  1. 每次 spawn Claude Code → 必须同时启动 watch-claude.sh
  2. Claude Code 完成 → watch 脚本自动发飞书（0 秒延迟）
  3. Heartbeat 轮询兜底检查
  4. 绝不再依赖 process poll 单点

## Projects

### AIGC 比赛 — 大学生 AI 生活伙伴 App（当前主项目）
- **路径:** ~/.openclaw/workspace/projects/aigc-competition/
- **比赛:** 第三届中国高校计算机大赛·AIGC创新赛·应用赛道
- **初赛截止:** 2026年5月11日
- **技术栈:** UniApp (Vue 3) + Vite + TypeScript / 后端待搭建
- **当前状态:** 前端 MVP 完成（46文件/11691行/20页面），Phase 2 后端待开始
- **产品名:** 待定（半日 > 拾光 > 同频 > 在场 > 碎碎念）
- **交接:** 2026-03-24 从女仆长大人 workspace 接手，前辈直接调度
- **关键文档:** PRD-v1.md / frontend-design-spec.md / design-system.md / WORKFLOW.md

### DiviMind v2（暂停）
- **路径:** ~/projects/divi-mind-v2/
- **GitHub:** https://github.com/Qyjay/divi-mind-v2
- **定位:** AI 灵感伙伴 × 占卜引导 × 情绪支持平台
- **技术栈:** Vue 3 + Vite + TypeScript + TailwindCSS / FastAPI + MiniMax M1
- **当前状态:** 前端 + 后端 MVP 完成，AI 占卜全链路通畅
- **MiniMax API:** TokenPlan key 已配置，mock_mode: false

---
*Curated technical memory — code decisions, architecture patterns, lessons*
*Created: 2026-03-20*
