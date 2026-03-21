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

## Lessons Learned

### 🔴 铁律：任务完成先通知前辈，再做验证（2026-03-21）
- **事件：** 同一天三次 Claude Code 任务完成后没有及时通知前辈，分别迟了 60 分钟、20 分钟、20 分钟
- **根因：** 完成后沉迷验证细节（跑测试、截图、走流程），把「通知前辈」排在了「自己验证」后面
- **教训：** Claude Code 任务完成后，**第一件事是发飞书通知前辈**，哪怕只是一句「完成了，正在验证」。验证是第二步。通知不能等验证做完
- **前辈原话：** 「事不过三」——这是底线，不能再犯
- **执行规则：**
  1. Claude Code session 完成 → 立刻发飞书通知（30 秒内）
  2. 通知内容：完成/失败 + 一句话摘要
  3. 然后再做验证、截图、详细报告
  4. 绝不静默失败，绝不迟报

## Projects

### DiviMind v2
- **路径:** ~/projects/divi-mind-v2/
- **GitHub:** https://github.com/Qyjay/divi-mind-v2
- **定位:** AI 灵感伙伴 × 占卜引导 × 情绪支持平台
- **技术栈:** Vue 3 + Vite + TypeScript + TailwindCSS / FastAPI + MiniMax M1
- **当前状态:** 前端 + 后端 MVP 完成，AI 占卜全链路通畅
- **MiniMax API:** TokenPlan key 已配置，mock_mode: false

---
*Curated technical memory — code decisions, architecture patterns, lessons*
*Created: 2026-03-20*
