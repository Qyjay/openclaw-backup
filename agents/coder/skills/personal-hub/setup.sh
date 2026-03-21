#!/bin/bash
# setup.sh — 安装 Personal Harness Hub 到 Claude Code
set -euo pipefail

HUB_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

echo "=== Personal Harness Hub Setup ==="
echo "Hub 目录: $HUB_DIR"
echo ""

# ── 1. 创建 skills 软链接 ────────────────────────────────────
mkdir -p "$SKILLS_DIR"

create_link() {
    local name="$1"
    local target="$2"

    if [ -L "$SKILLS_DIR/$name" ]; then
        local current_target
        current_target=$(readlink "$SKILLS_DIR/$name")
        if [ "$current_target" = "$target" ]; then
            echo "  [OK] $name → $target (已存在)"
            return
        else
            echo "  [UPDATE] $name: $current_target → $target"
            rm "$SKILLS_DIR/$name"
        fi
    elif [ -e "$SKILLS_DIR/$name" ]; then
        echo "  [SKIP] $name: 已存在且不是软链接"
        return
    fi

    ln -s "$target" "$SKILLS_DIR/$name"
    echo "  [CREATED] $name → $target"
}

echo "Skills 软链接:"
create_link "hub" "$HUB_DIR"
create_link "hub-init" "$HUB_DIR/skills/init"
create_link "hub-sync" "$HUB_DIR/skills/sync"
echo ""

# ── 2. 安装 hooks ────────────────────────────────────────────
echo "Hooks:"
bash "$HUB_DIR/scripts/install_hooks.sh" "$HUB_DIR"
echo ""

echo "=== Setup 完成 ==="
echo ""
echo "已安装:"
echo "  /hub       — 需求开发全流程"
echo "  /hub-init  — 项目 Harness 初始化"
echo "  /hub-sync  — Harness 文档同步"
echo "  hooks      — PreToolUse + Stop 防护"
echo ""
echo "使用方式:"
echo "  1. 在项目目录打开 Claude Code"
echo "  2. 描述需求或输入 /hub <需求>"
echo "  3. 新项目先 /hub-init"
