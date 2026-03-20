---
name: backup-manager
description: "OpenClaw 系统备份管理。在以下情况触发：(1) 手动备份（'备份'、'backup'、'同步到GitHub'），(2) 重大变更后自动备份（Agent 创建/删除、Skill 安装/卸载、配置变更），(3) 查看备份状态，(4) 从备份恢复。自动脱敏 API Key 和 Token。"
---

# Backup Manager — 备份管理

管理 OpenClaw 系统到 GitHub 仓库 `Qyjay/openclaw-backup` 的全量备份。

## 备份仓库

- **GitHub**: `https://github.com/Qyjay/openclaw-backup`
- **本地克隆**: `/tmp/openclaw-backup`（运行时）

## 触发条件

### 自动触发（重大变更后立即备份）
- Agent 创建或删除
- Skill 安装、卸载或更新
- 配置文件变更（模型、渠道、路由）
- 团队架构变更

### 手动触发
- Master 说 "备份" / "backup" / "同步到GitHub"
- Master 说 "查看备份状态"

### 定时触发
- 每晚 23:00 CST 自动全量备份（cron job）

## 备份流程

1. 确保本地克隆存在（`/tmp/openclaw-backup`），不存在则克隆
2. 运行备份脚本：`bash /tmp/openclaw-backup/scripts/backup.sh`
3. 脚本自动：复制所有文件 → 脱敏配置 → git commit → git push
4. 更新 CHRONICLE.md 记录备份事件

## 快速备份命令

```bash
# 确保仓库存在
cd /tmp && [ -d openclaw-backup ] || git clone https://github.com/Qyjay/openclaw-backup.git
# 运行备份
bash /tmp/openclaw-backup/scripts/backup.sh
```

## 备份内容

| 目录 | 内容 | 说明 |
|------|------|------|
| `workspace/` | SOUL.md, USER.md, IDENTITY.md, TEAM.md 等 | Main Agent 工作空间 |
| `workspace/memory/` | 每日记忆文件 | 日志 |
| `workspace/skills/` | 自建 Skill | chronicle 等 |
| `skills/` | ClawHub 安装的 Skill | 第三方 Skill |
| `config/` | openclaw.json.template, cron-jobs.json | 脱敏配置 |
| `agents/` | 子 Agent 工作空间 | 所有 Servant |

## 安全规则

- **绝不**将明文 API Key 或 Token 推送到 GitHub
- 配置文件自动脱敏：`apiKey` → `<YOUR_API_KEY_HERE>`
- Gateway token 自动脱敏：`token` → `<YOUR_GATEWAY_TOKEN_HERE>`
- `minimax-oauth` 保留（非敏感）
