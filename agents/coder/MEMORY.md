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
