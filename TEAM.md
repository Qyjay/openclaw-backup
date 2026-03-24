# TEAM.md - Agent 团队花名册

> Leader: **Silvana（希尔）** 👑 (main agent)
> Master: **Kylin**

---

## 当前团队

| Agent ID | 名称 | 职责 | 模型 | 状态 |
|----------|------|------|------|------|
| `main` | **Silvana（希尔）** 👑 | Leader / 统筹调度 / 首席女仆长 | Claude Opus 4 | ✅ 在线 |
| `coder` | **Babette Lucy（BB/露西）** 🔮 | Moon Netrunner / 首席编码者 | Claude Opus 4 | ✅ 在线 |
| `designer` | **Iris（艾莉丝）** 🎨 | Visual Director / 视觉总监 | Claude Sonnet | ✅ 就绪 |
| `scribe` | **Muse（缪丝）** ✍️ | Content Strategist / 内容策略师 | Claude Sonnet | ✅ 就绪 |

## 待创建

*(等待 Master 指示)*

---

## 团队架构设计（建议）

根据 Master 当前需求，建议组建以下 Servant：

### 核心编队

| 建议 ID | 代号 | 职责 | 推荐模型 |
|---------|------|------|----------|
| `coder` | 🔧 Artificer | 编程、代码审查、项目开发 | sonnet |
| `scholar` | 📚 Scholar | 雅思备考、留学申请、文书撰写 | sonnet |
| `strategist` | 🎯 Strategist | 求职策略、简历优化、面试准备 | sonnet |
| `researcher` | 🔍 Researcher | 信息搜集、技术调研、市场分析 | sonnet |

### 可选扩展

| 建议 ID | 代号 | 职责 | 推荐模型 |
|---------|------|------|----------|
| `scribe` | ✍️ Scribe | 文档写作、翻译、内容创作 | sonnet |
| `sentinel` | 🛡 Sentinel | 系统运维、安全监控、定时任务 | haiku |

---

## 通信协议

- Master → Seneschal: 直接对话
- Seneschal → Servant: `sessions_spawn` / `sessions_send`
- Servant → Seneschal: 任务完成后自动汇报
- Servant ↔ Servant: 通过 Seneschal 中转（保持秩序）

## 更新日志

- 2026-03-19: 团队创立，Seneschal 就任 Leader
- 2026-03-23: Iris（艾莉丝）🎨 加入，担任视觉总监（AIGC 比赛设计支持）
- 2026-03-24: Muse（缪丝）✍️ 加入，担任内容策略师（MiniMax 小红书/公众号内容创作）
