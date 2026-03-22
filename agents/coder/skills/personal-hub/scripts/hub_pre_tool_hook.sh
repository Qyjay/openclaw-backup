#!/bin/bash
# hub_pre_tool_hook.sh — PreToolUse hook，在 hub 流程中阻断危险操作
#
# 作为 Claude Code 的 PreToolUse hook 运行。
# 仅在 hub 流程激活时（/tmp/.claude_hub_active 存在）生效。
#
# 阻断的操作：
#   1. 删除测试文件（rm *_test.go / rm *_test.py 等）
#   2. 直接 git push（必须通过 create_mr.sh）
#
# 输入: JSON on stdin { "tool_name": "Bash", "tool_input": { "command": "..." } }
# 输出: exit 0 放行, exit 2 阻断（stderr 给出原因）
set -uo pipefail

# 读取输入
INPUT=$(cat)

# 只在 hub 流程激活时检查
STATE_FILE="/tmp/.claude_hub_active"
if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

# 只检查 Bash 工具
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name', ''))" 2>/dev/null || echo "")
if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

# 提取命令
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input', {}).get('command', ''))" 2>/dev/null || echo "")
if [ -z "$COMMAND" ]; then
    exit 0
fi

# ── 检查 1: 禁止删除测试文件 ─────────────────────────────────
# 匹配: rm ... *_test.go, rm ... test_*.py, rm ... *.test.ts 等
if echo "$COMMAND" | grep -qE '\brm\b.*(_test\.(go|py|rs|java)|test_[^/]*\.py|\.test\.(ts|js)|\.spec\.(ts|js)|Test\.java)'; then
    echo "Hub 流程禁止删除测试文件。测试是必须的，如果测试因外部依赖失败，请用 mock 隔离依赖后重写测试。" >&2
    exit 2
fi

# ── 检查 2: 禁止直接 git push ────────────────────────────────
# 匹配: git push（不在 create_mr.sh 内调用时）
# create_mr.sh 内部的 git push 不会被拦截，因为它不是 Claude 的直接 tool call
if echo "$COMMAND" | grep -qE '\bgit\s+push\b'; then
    echo "Hub 流程禁止直接 git push。必须通过 create_pr.sh 脚本提交（Step 5）。" >&2
    exit 2
fi

# ── 检查 3: 禁止直接写状态文件的 step 标记 ────────────────────
# step 标记只能由 hub 脚本内部写入，agent 不能直接伪造
if echo "$COMMAND" | grep -qE '(svc_.*_step|step[0-9]+_)' && echo "$COMMAND" | grep -qE 'claude_hub_active'; then
    echo "Hub 流程禁止直接修改状态文件中的 step 标记。标记只能由对应的 hub 脚本（quality_gate.sh / pre_mr_check.sh / create_mr.sh / detect_drift.sh）写入。" >&2
    exit 2
fi

# ── 检查 4: 禁止直接删除状态文件 ──────────────────────────────
# 状态文件只能由 stop hook 在验证全部步骤完成后清除
if echo "$COMMAND" | grep -qE '\brm\b.*claude_hub_active'; then
    echo "Hub 流程禁止直接删除状态文件。状态文件由 Stop hook 在验证全部步骤完成后自动清除。请继续执行缺失的步骤直到 Stop hook 放行。" >&2
    exit 2
fi

# 其他命令放行
exit 0
