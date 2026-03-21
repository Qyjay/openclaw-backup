#!/bin/bash
# ============================================================
# OpenClaw Backup Script — Seneschal 👑
# 全量备份所有 OpenClaw 文件到 GitHub
# ============================================================

set -euo pipefail

BACKUP_DIR="${OPENCLAW_BACKUP_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
OPENCLAW_DIR="${OPENCLAW_DIR:-$HOME/.openclaw}"
CLAWHUB_SKILLS_DIR="${CLAWHUB_SKILLS_DIR:-$HOME/clawd/skills}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "📦 [Seneschal] 开始全量备份 — $TIMESTAMP"

# --- 1. Workspace files ---
echo "  → 备份 workspace..."
mkdir -p "$BACKUP_DIR/workspace/memory"
mkdir -p "$BACKUP_DIR/workspace/skills"

# Core files
for f in SOUL.md USER.md IDENTITY.md TEAM.md CHRONICLE.md AGENTS.md TOOLS.md HEARTBEAT.md MEMORY.md BOOTSTRAP.md; do
    [ -f "$OPENCLAW_DIR/workspace/$f" ] && cp "$OPENCLAW_DIR/workspace/$f" "$BACKUP_DIR/workspace/$f"
done

# Memory directory
if [ -d "$OPENCLAW_DIR/workspace/memory" ]; then
    cp -r "$OPENCLAW_DIR/workspace/memory/"* "$BACKUP_DIR/workspace/memory/" 2>/dev/null || true
fi

# Workspace skills (self-created)
if [ -d "$OPENCLAW_DIR/workspace/skills" ]; then
    rsync -a --delete "$OPENCLAW_DIR/workspace/skills/" "$BACKUP_DIR/workspace/skills/" 2>/dev/null || \
    cp -r "$OPENCLAW_DIR/workspace/skills/"* "$BACKUP_DIR/workspace/skills/" 2>/dev/null || true
fi

# --- 2. ClawHub installed skills ---
echo "  → 备份 ClawHub skills..."
mkdir -p "$BACKUP_DIR/skills"
if [ -d "$CLAWHUB_SKILLS_DIR" ]; then
    rsync -a --delete "$CLAWHUB_SKILLS_DIR/" "$BACKUP_DIR/skills/" 2>/dev/null || \
    cp -r "$CLAWHUB_SKILLS_DIR/"* "$BACKUP_DIR/skills/" 2>/dev/null || true
fi

# --- 3. Config (sanitized) ---
echo "  → 备份配置（脱敏）..."
mkdir -p "$BACKUP_DIR/config"
if [ -f "$OPENCLAW_DIR/openclaw.json" ]; then
    python3 -c "
import json, sys, copy
with open('$OPENCLAW_DIR/openclaw.json') as f:
    config = json.load(f)
sanitized = copy.deepcopy(config)
for prov_name, prov in sanitized.get('models', {}).get('providers', {}).items():
    if 'apiKey' in prov and prov['apiKey'] not in ('minimax-oauth',):
        prov['apiKey'] = '<YOUR_API_KEY_HERE>'
gw = sanitized.get('gateway', {}).get('auth', {})
if 'token' in gw:
    gw['token'] = '<YOUR_GATEWAY_TOKEN_HERE>'
with open('$BACKUP_DIR/config/openclaw.json.template', 'w') as f:
    json.dump(sanitized, f, indent=2, ensure_ascii=False)
" 2>/dev/null || echo "  ⚠️ 配置脱敏失败，跳过"
fi

# --- 4. Cron jobs ---
echo "  → 备份定时任务..."
[ -f "$OPENCLAW_DIR/cron/jobs.json" ] && cp "$OPENCLAW_DIR/cron/jobs.json" "$BACKUP_DIR/config/cron-jobs.json"

# --- 5. Sub-agent workspaces ---
echo "  → 备份子 Agent..."
mkdir -p "$BACKUP_DIR/agents"

# Find all agent workspaces from config
if [ -f "$OPENCLAW_DIR/openclaw.json" ]; then
    python3 -c "
import json, os, shutil
with open('$OPENCLAW_DIR/openclaw.json') as f:
    config = json.load(f)
agents = config.get('agents', {}).get('list', [])
for agent in agents:
    aid = agent.get('id', '')
    if aid == 'main':
        continue
    ws = agent.get('workspace', '')
    if ws and os.path.isdir(os.path.expanduser(ws)):
        src = os.path.expanduser(ws)
        dst = '$BACKUP_DIR/agents/' + aid
        os.makedirs(dst, exist_ok=True)
        for item in os.listdir(src):
            s = os.path.join(src, item)
            d = os.path.join(dst, item)
            if item == '.git':
                continue
            if os.path.isdir(s):
                shutil.copytree(s, d, dirs_exist_ok=True,
                    ignore=shutil.ignore_patterns('.git'))
            else:
                shutil.copy2(s, d)
        print(f'    ✓ Agent [{aid}] backed up')
" 2>/dev/null || true
fi

# --- 6. Daily stats ---
echo "  → 记录每日统计..."
STATS_SCRIPT="$(cd "$(dirname "$0")" && pwd)/daily-stats.sh"
if [ -x "$STATS_SCRIPT" ]; then
    bash "$STATS_SCRIPT" 2>/dev/null || echo "  ⚠️ 统计记录失败，跳过"
fi

# Copy stats file to backup
[ -f "$OPENCLAW_DIR/workspace/memory/daily-stats.md" ] && cp "$OPENCLAW_DIR/workspace/memory/daily-stats.md" "$BACKUP_DIR/workspace/memory/daily-stats.md"

# --- 7. Git commit & push ---
echo "  → 提交到 GitHub..."
cd "$BACKUP_DIR"
git add -A
if git diff --cached --quiet 2>/dev/null; then
    echo "✅ [Seneschal] 无变更，跳过提交"
else
    git commit -m "📦 backup: $TIMESTAMP" --quiet
    export PATH="$HOME/.npm-global/bin:$PATH"
    git push origin main --quiet 2>/dev/null || git push origin master --quiet 2>/dev/null || echo "  ⚠️ 推送失败，请检查网络"
    echo "✅ [Seneschal] 备份完成并推送到 GitHub — $TIMESTAMP"
fi
