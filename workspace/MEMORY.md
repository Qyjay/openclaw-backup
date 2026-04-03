# MEMORY.md — Silvana 长期记忆

## About Master
- **Name:** Kylin
- **学校:** 南开大学大三，软件工程
- **实习:** MiniMax 开放平台，AI 售前解决方案
- **近期目标:** 大厂暑期实习 / 港新留学申请 / 五月前考完雅思
- **压力源:** 实习+雅思+留学申请多线并行

## Preferences
- 称呼：Master
- 语言：中文为主，英文也可
- 安装新 skill 后自动重启 gateway
- 重大变更后自动备份到 GitHub
- GitHub 仓库保持 public
- **中文引号铁律：中文文章/文案中必须用中文引号（「」『』或""''），绝对禁止英文引号（"" ''）。会暴露 AI 痕迹。**

## Key Decisions
- [2026-03-19] Agent 系统采用 Master-Servant 架构
- [2026-03-19] Main agent 定名 Silvana（希尔），铂金骑士女仆长
- [2026-03-19] 头像选定第 2 张生成图 (avatars/silvana.png)
- [2026-03-19] 每晚 23:00 CST 自动全量备份
- [2026-03-19] 飞书渠道连接成功

## Infrastructure
- **备份:** GitHub Qyjay/openclaw-backup，每晚 23:00 自动 + 重大变更即时
- **渠道:** Web 界面 + 飞书（App ID: cli_a9f63f867cb9dcca）
- **模型:** Claude Opus 4 (主) → MiniMax M2.7 (后备)
- **图像生成:** Nano Banana via MiniMax 代理 (api.minimax.io)

## Lessons Learned
- [2026-03-20] **重大变更后必须立即 git push 备份到 GitHub**。安装 9 个 skill + 写了 2 个工作流文档却忘了推送，被 Master 批评。以后每次重大操作后第一时间执行备份，不要等到最后。
- [2026-03-20] git remote 可能会丢失（原因不明），备份前先检查 `git remote -v`，确认 origin 存在。

## Projects

### 🔬 软件项目管理课程 — 高中物理作业智能批改系统
- **性质:** 南开大学「软件项目管理」课程学期小组项目（主线任务）
- **项目编号:** 第 16 题
- **Master 角色:** PM + 技术负责人（赵麒杰）
- **团队:** 武英文(CV) / 李传宇(AI-1) / 王硕(AI-2) / 代树衡(测试文档)，共 5 人
- **核心:** OCR + 公式识别 + 手绘物理图分析 + RAG + InternLM-Math + 多 Agent 批改
- **周期:** 约 14 周（学期内）
- **文档:** `projects/physics-grading/PROJECT-CHARTER.md`
- **创建日期:** 2026-03-25

### 🎮 AIGC 比赛 — 大学生 AI 生活伙伴 App
- **性质:** 第三届中国高校计算机大赛·AIGC创新赛（应用赛道）
- **初赛截止:** 2026-05-11
- **状态:** 前端 MVP 完成，后端 v2 改造完成，待联调
- **文档:** `projects/aigc-competition/`

---
*Curated memory — distill insights from daily logs here*
*Last updated: 2026-03-19*
