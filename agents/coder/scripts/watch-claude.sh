#!/bin/bash
# watch-claude.sh — 监控 Claude Code 进程，完成后立刻发飞书通知
# 用法: watch-claude.sh <PID> <任务描述>
# 例: watch-claude.sh 12345 "DiviMind v2 周易占卜功能"

PID="$1"
TASK="$2"

if [ -z "$PID" ] || [ -z "$TASK" ]; then
    echo "用法: $0 <PID> <任务描述>"
    exit 1
fi

echo "[watch] 开始监控 PID $PID: $TASK"
echo "[watch] $(date '+%Y-%m-%d %H:%M:%S')"

# 等待进程结束
while kill -0 "$PID" 2>/dev/null; do
    sleep 5
done

# 获取退出状态
wait "$PID" 2>/dev/null
EXIT_CODE=$?

TIMESTAMP=$(date '+%H:%M:%S')

if [ $EXIT_CODE -eq 0 ]; then
    STATUS="✅ 完成"
else
    STATUS="❌ 失败 (exit $EXIT_CODE)"
fi

MSG="Claude Code 任务${STATUS}: ${TASK} (${TIMESTAMP})"

echo "[watch] $MSG"

# 方法1: 通过 openclaw system event 通知（唤醒 agent）
openclaw system event --text "$MSG" --mode now 2>/dev/null &

# 方法2: 直接通过 openclaw CLI 发飞书消息（不依赖 agent 被唤醒）
# 这是兜底——即使 agent 没醒，飞书消息也会发出去
openclaw message send --channel feishu --message "$MSG" 2>/dev/null &

echo "[watch] 通知已发送"
