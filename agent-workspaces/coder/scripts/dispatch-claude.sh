#!/bin/bash
# dispatch-claude.sh — 派 Claude Code + 自动启动监控
# BB 的调度脚本：启动 Claude Code 后台任务，同时启动 watch 脚本监控完成
# 用法: dispatch-claude.sh <项目目录> <任务描述> <prompt>

PROJECT_DIR="$1"
TASK_DESC="$2"
PROMPT="$3"
SCRIPT_DIR="$(dirname "$0")"

if [ -z "$PROJECT_DIR" ] || [ -z "$TASK_DESC" ] || [ -z "$PROMPT" ]; then
    echo "用法: $0 <项目目录> <任务描述> <prompt>"
    exit 1
fi

echo "[dispatch] 启动 Claude Code: $TASK_DESC"
echo "[dispatch] 项目: $PROJECT_DIR"
echo "[dispatch] $(date '+%Y-%m-%d %H:%M:%S')"

# 启动 Claude Code 后台运行
cd "$PROJECT_DIR" && claude --permission-mode bypassPermissions --print "$PROMPT" &
CLAUDE_PID=$!

echo "[dispatch] Claude Code PID: $CLAUDE_PID"

# 启动监控脚本（后台）
"$SCRIPT_DIR/watch-claude.sh" "$CLAUDE_PID" "$TASK_DESC" &
WATCH_PID=$!

echo "[dispatch] Watch PID: $WATCH_PID"
echo "[dispatch] 任务已派出，完成后会自动飞书通知"

# 输出信息供 BB 记录
echo "CLAUDE_PID=$CLAUDE_PID"
echo "WATCH_PID=$WATCH_PID"
