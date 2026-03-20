#!/bin/bash
# ============================================================
# OpenClaw Restore Script — Seneschal 👑
# 从备份仓库恢复完整 OpenClaw 系统
# ============================================================

set -euo pipefail

BACKUP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPENCLAW_DIR="${OPENCLAW_DIR:-$HOME/.openclaw}"
CLAWHUB_SKILLS_DIR="${CLAWHUB_SKILLS_DIR:-$HOME/clawd/skills}"

echo "🔄 [Seneschal] 开始恢复 OpenClaw 系统"
echo ""

# --- 0. Check prerequisites ---
echo "📋 检查前置条件..."
if ! command -v node &>/dev/null; then
    echo "❌ 需要 Node.js >= 18。请先安装：https://nodejs.org"
    exit 1
fi

if ! command -v openclaw &>/dev/null; then
    echo "⚙️  安装 OpenClaw..."
    npm install -g openclaw
fi

if ! command -v clawhub &>/dev/null; then
    echo "⚙️  安装 ClawHub CLI..."
    npm install -g clawhub
fi

echo "✅ 前置条件满足"
echo ""

# --- 1. Restore workspace ---
echo "📁 恢复 workspace..."
mkdir -p "$OPENCLAW_DIR/workspace/memory"
mkdir -p "$OPENCLAW_DIR/workspace/skills"

# Core files
for f in SOUL.md USER.md IDENTITY.md TEAM.md CHRONICLE.md AGENTS.md TOOLS.md HEARTBEAT.md MEMORY.md BOOTSTRAP.md; do
    [ -f "$BACKUP_DIR/workspace/$f" ] && cp "$BACKUP_DIR/workspace/$f" "$OPENCLAW_DIR/workspace/$f"
done

# Memory
cp -r "$BACKUP_DIR/workspace/memory/"* "$OPENCLAW_DIR/workspace/memory/" 2>/dev/null || true

# Workspace skills
cp -r "$BACKUP_DIR/workspace/skills/"* "$OPENCLAW_DIR/workspace/skills/" 2>/dev/null || true

echo "✅ Workspace 恢复完成"

# --- 2. Restore ClawHub skills ---
echo "🧩 恢复 ClawHub Skills..."
mkdir -p "$CLAWHUB_SKILLS_DIR"
if [ -d "$BACKUP_DIR/skills" ]; then
    cp -r "$BACKUP_DIR/skills/"* "$CLAWHUB_SKILLS_DIR/" 2>/dev/null || true
fi
echo "✅ Skills 恢复完成"

# --- 3. Restore config ---
echo "⚙️  恢复配置..."
if [ -f "$BACKUP_DIR/config/openclaw.json.template" ]; then
    if [ -f "$OPENCLAW_DIR/openclaw.json" ]; then
        echo "  ⚠️  配置文件已存在，备份为 openclaw.json.restore-bak"
        cp "$OPENCLAW_DIR/openclaw.json" "$OPENCLAW_DIR/openclaw.json.restore-bak"
    fi
    cp "$BACKUP_DIR/config/openclaw.json.template" "$OPENCLAW_DIR/openclaw.json"
    echo ""
    echo "  ⚠️  重要：请编辑 ~/.openclaw/openclaw.json 填入你的 API Key："
    echo "     - models.providers.claude-api.apiKey"
    echo "     - models.providers.minimax-internal.apiKey"
    echo "     - gateway.auth.token"
    echo ""
fi

# --- 4. Restore cron jobs ---
echo "⏰ 恢复定时任务..."
mkdir -p "$OPENCLAW_DIR/cron"
[ -f "$BACKUP_DIR/config/cron-jobs.json" ] && cp "$BACKUP_DIR/config/cron-jobs.json" "$OPENCLAW_DIR/cron/jobs.json"
echo "✅ 定时任务恢复完成"

# --- 5. Restore sub-agent workspaces ---
echo "👥 恢复子 Agent..."
if [ -d "$BACKUP_DIR/agents" ]; then
    for agent_dir in "$BACKUP_DIR/agents"/*/; do
        [ -d "$agent_dir" ] || continue
        agent_name=$(basename "$agent_dir")
        target="$OPENCLAW_DIR/workspace-$agent_name"
        mkdir -p "$target"
        cp -r "$agent_dir"* "$target/" 2>/dev/null || true
        echo "  ✓ Agent [$agent_name] 恢复到 $target"
    done
fi

# --- 6. Setup gh CLI ---
echo ""
echo "🐙 GitHub CLI 设置..."
if ! command -v gh &>/dev/null; then
    echo "  ⚠️  gh CLI 未安装。建议安装：brew install gh"
else
    echo "  ✅ gh CLI 已安装"
fi

# --- Done ---
echo ""
echo "============================================"
echo "🎉 [Seneschal] 恢复完成！"
echo "============================================"
echo ""
echo "接下来："
echo "  1. 编辑 ~/.openclaw/openclaw.json 填入 API Key"
echo "  2. 运行 'openclaw gateway start' 启动网关"
echo "  3. 在对话中告诉 Seneschal："
echo '     "我通过备份仓库恢复了你的系统。请检查所有配置。"'
echo ""
