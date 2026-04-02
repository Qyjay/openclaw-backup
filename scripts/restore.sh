#!/bin/bash
# restore.sh — 从 GitHub 备份恢复 OpenClaw 环境
# 用法：克隆仓库到 ~/.openclaw/workspace 后执行本脚本

set -e

WORKSPACE="$HOME/.openclaw/workspace"
OPENCLAW_DIR="$HOME/.openclaw"

echo "🔧 [Restore] 开始恢复 OpenClaw 环境..."

# Step 1: 检查 workspace
if [ ! -d "$WORKSPACE" ]; then
    echo "❌ 未找到 $WORKSPACE"
    echo "   请先执行: git clone https://github.com/Qyjay/openclaw-backup.git ~/.openclaw/workspace"
    exit 1
fi

# Step 2: 恢复 Sub-Agent 工作区
echo "📂 恢复 Sub-Agent 工作区..."

if [ -d "$WORKSPACE/agent-workspaces/coder" ]; then
    mkdir -p "$OPENCLAW_DIR/workspace-coder/memory"
    cp -r "$WORKSPACE/agent-workspaces/coder/"* "$OPENCLAW_DIR/workspace-coder/" 2>/dev/null || true
    echo "  ✅ Coder (Babette Lucy)"
fi

if [ -d "$WORKSPACE/agent-workspaces/scribe" ]; then
    mkdir -p "$OPENCLAW_DIR/workspace-scribe"
    cp -r "$WORKSPACE/agent-workspaces/scribe/"* "$OPENCLAW_DIR/workspace-scribe/" 2>/dev/null || true
    echo "  ✅ Scribe (Muse)"
fi

if [ -d "$WORKSPACE/agent-workspaces/riji" ]; then
    mkdir -p "$OPENCLAW_DIR/workspace-riji"
    cp -r "$WORKSPACE/agent-workspaces/riji/"* "$OPENCLAW_DIR/workspace-riji/" 2>/dev/null || true
    echo "  ✅ Riji (日迹)"
fi

# Step 3: 创建 Agent 配置目录
echo "📂 创建 Agent 配置目录..."
mkdir -p "$OPENCLAW_DIR/agents/main/agent"
mkdir -p "$OPENCLAW_DIR/agents/coder/agent"
mkdir -p "$OPENCLAW_DIR/agents/scribe/agent"
mkdir -p "$OPENCLAW_DIR/agents/riji/agent"
mkdir -p "$OPENCLAW_DIR/agents/claude"
echo "  ✅ Agent 目录已创建"

# Step 4: 配置文件
if [ ! -f "$OPENCLAW_DIR/openclaw.json" ]; then
    if [ -f "$WORKSPACE/config/openclaw.json.template" ]; then
        cp "$WORKSPACE/config/openclaw.json.template" "$OPENCLAW_DIR/openclaw.json"
        echo "📝 已复制配置模板到 ~/.openclaw/openclaw.json"
        echo "   ⚠️  请编辑此文件，填入你的 API Keys！"
    fi
else
    echo "⏭️  配置文件已存在，跳过"
fi

# Step 5: .env 文件
if [ ! -f "$WORKSPACE/.env" ]; then
    if [ -f "$WORKSPACE/.env.template" ]; then
        cp "$WORKSPACE/.env.template" "$WORKSPACE/.env"
        echo "📝 已复制 .env 模板"
        echo "   ⚠️  请编辑 ~/.openclaw/workspace/.env，填入 API Keys！"
    fi
else
    echo "⏭️  .env 已存在，跳过"
fi

# Step 6: Skill 依赖
if [ -f "$WORKSPACE/skills/create-colleague/requirements.txt" ]; then
    echo "📦 安装 colleague-skill 依赖..."
    pip3 install -r "$WORKSPACE/skills/create-colleague/requirements.txt" -q 2>/dev/null && echo "  ✅ 依赖已安装" || echo "  ⚠️  依赖安装失败，请手动执行"
fi

echo ""
echo "✅ [Restore] 恢复完成！"
echo ""
echo "下一步："
echo "  1. 编辑 ~/.openclaw/openclaw.json — 填入 API Keys"
echo "  2. 编辑 ~/.openclaw/workspace/.env — 填入环境变量"
echo "  3. 执行 openclaw gateway start — 启动 OpenClaw"
echo ""
echo "详细说明请参考 RESTORE.md"
