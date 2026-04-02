# RESTORE.md — OpenClaw 全量恢复指南

> 从 GitHub 备份恢复到全新电脑的完整步骤。
> 预计耗时：15-20 分钟（不含 API key 准备时间）。

---

## 前置条件

- macOS / Linux（Windows 用 WSL）
- Node.js 18+（推荐 v24）
- Python 3.9+
- Git

---

## Step 1：安装 OpenClaw

```bash
npm install -g openclaw
```

验证：
```bash
openclaw --version
# 预期输出类似：OpenClaw 2026.3.28
```

---

## Step 2：克隆备份仓库

```bash
# 克隆到 OpenClaw 默认 workspace 位置
git clone https://github.com/Qyjay/openclaw-backup.git ~/.openclaw/workspace
```

---

## Step 3：恢复 Sub-Agent 工作区

备份中的 `agent-workspaces/` 包含所有 Sub-Agent 的记忆和配置。

```bash
# Coder (Babette Lucy)
mkdir -p ~/.openclaw/workspace-coder/memory
cp -r ~/.openclaw/workspace/agent-workspaces/coder/* ~/.openclaw/workspace-coder/

# Scribe (Muse)
mkdir -p ~/.openclaw/workspace-scribe
cp -r ~/.openclaw/workspace/agent-workspaces/scribe/* ~/.openclaw/workspace-scribe/

# Riji (日迹)
mkdir -p ~/.openclaw/workspace-riji
cp -r ~/.openclaw/workspace/agent-workspaces/riji/* ~/.openclaw/workspace-riji/
```

---

## Step 4：恢复 Agent 配置目录

```bash
# 创建 agent 目录结构
mkdir -p ~/.openclaw/agents/main/agent
mkdir -p ~/.openclaw/agents/coder/agent
mkdir -p ~/.openclaw/agents/scribe/agent
mkdir -p ~/.openclaw/agents/riji/agent
mkdir -p ~/.openclaw/agents/claude
```

---

## Step 5：配置 OpenClaw

### 5a. 创建主配置文件

```bash
cp ~/.openclaw/workspace/config/openclaw.json.template ~/.openclaw/openclaw.json
```

### 5b. 填入 API Keys

编辑 `~/.openclaw/openclaw.json`，替换以下占位符：

| 占位符 | 说明 | 获取方式 |
|--------|------|----------|
| `YOUR_CLAUDE_API_BASE_URL` | Claude API 代理地址 | MiniMax 内部平台 |
| `YOUR_CLAUDE_API_KEY` | Claude API Key | MiniMax 内部平台 |
| `YOUR_X_SUB_MODULE` | Claude 请求头 | MiniMax 内部平台 |
| `YOUR_MINIMAX_PORTAL_API_KEY` | MiniMax 开放平台 Key | api.minimaxi.com |
| `YOUR_MINIMAX_INTERNAL_BASE_URL` | MiniMax 内部 API 地址 | MiniMax 内网 |
| `YOUR_MINIMAX_INTERNAL_API_KEY` | MiniMax 内部 Key | MiniMax 内网 |
| `YOUR_X_BIZ_ID` | MiniMax 业务 ID | MiniMax 内网 |
| `YOUR_MINIMAX_TOKENPLAN_API_KEY` | Token Plan Key | api.minimaxi.com |
| `YOUR_MINIMAX_API_KEY` (MCP) | MiniMax MCP Key | api.minimaxi.com |
| `YOUR_FEISHU_APP_ID` | 飞书 App ID | 飞书开放平台 |
| `YOUR_FEISHU_APP_SECRET` | 飞书 App Secret | 飞书开放平台 |
| `YOUR_GATEWAY_TOKEN` | Gateway 认证 Token | 自定义一个强密码 |

### 5c. 创建 .env 文件

```bash
cp ~/.openclaw/workspace/.env.template ~/.openclaw/workspace/.env
# 编辑 .env 填入 GEMINI_API_KEY 和 MINIMAX_TOKENPLAN_API_KEY
```

---

## Step 6：安装 Skill 依赖

```bash
# colleague-skill Python 依赖
cd ~/.openclaw/workspace/skills/create-colleague
pip3 install -r requirements.txt

# ACP (Claude Code) 依赖 — 如果需要
npm install -g @anthropic-ai/claude-code
```

---

## Step 7：安装 MCP 工具（可选）

```bash
# MiniMax Coding Plan MCP
pip3 install uvx  # 或 pipx
uvx minimax-coding-plan-mcp --help
```

---

## Step 8：启动 OpenClaw

```bash
openclaw gateway start
```

首次启动后打开 Web UI：
```
http://localhost:18789
```

---

## Step 9：验证恢复

在 Web UI 中对话，确认：

- [ ] Silvana 正常响应，记得自己的身份
- [ ] `MEMORY.md` 内容完整
- [ ] 团队花名册 `TEAM.md` 正确
- [ ] Sub-Agent 可以通过 `sessions_spawn` 调用
- [ ] 飞书渠道连接正常（如果配了飞书）
- [ ] AIGC 项目代码在 `projects/aigc-competition/app/`

---

## Step 10：恢复定时任务

备份中的 cron 配置在 `config/cron-jobs.json`，但 cron job 需要重建：

```
告诉 Silvana：
"帮我恢复每晚 23:00 的自动备份 cron job"
```

她会根据 `config/cron-jobs.json` 的配置重建。

---

## 目录结构说明

```
~/.openclaw/
├── openclaw.json              ← 主配置（含 API keys，不入 git）
├── workspace/                 ← 主 workspace（本仓库）
│   ├── SOUL.md               ← Silvana 的灵魂
│   ├── USER.md               ← Master 信息
│   ├── MEMORY.md             ← 长期记忆
│   ├── TEAM.md               ← 团队花名册
│   ├── SESSION-STATE.md      ← 当前任务状态
│   ├── agents/               ← Agent AGENTS.md 备份
│   ├── agent-workspaces/     ← Sub-Agent 工作区备份
│   ├── avatars/              ← 头像
│   ├── config/               ← 配置模板 + cron 备份
│   ├── memory/               ← 日志 + 偏好
│   ├── projects/             ← 项目（AIGC 比赛、雅思等）
│   ├── scripts/              ← 自动化脚本
│   ├── skills/               ← 安装的 Skills
│   └── .env                  ← 环境变量（不入 git）
├── workspace-coder/           ← Babette Lucy 工作区
├── workspace-scribe/          ← Muse 工作区
├── workspace-riji/            ← 日迹工作区
└── agents/                    ← Agent 运行时配置
```

---

## 快速恢复脚本

如果想一键执行 Step 2-4：

```bash
bash ~/.openclaw/workspace/scripts/restore.sh
```

---

## 注意事项

1. **API Keys 不在 git 中** — 必须手动填入 `openclaw.json` 和 `.env`
2. **飞书 App** — 如果换了飞书租户，需要重新创建飞书应用并更新凭证
3. **Session 历史不迁移** — 对话历史存在本地，不备份；但记忆文件（MEMORY.md 等）完整保留
4. **AIGC 项目 node_modules** — 需要重新 `npm install`：
   ```bash
   cd ~/.openclaw/workspace/projects/aigc-competition/app && npm install
   ```
5. **GitHub 仓库是 public** — 绝对不要把 API key 提交进去

---

*Last updated: 2026-04-02*
