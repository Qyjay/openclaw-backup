#!/bin/bash
# install_hooks.sh — 一键安装 Hub 的 PreToolUse + Stop hook
#
# 用法:
#   bash install_hooks.sh [hub-root]
#
# 如果不传 hub-root，自动从脚本自身位置推断。
# 只需执行一次，会写入 ~/.claude/settings.json。
# 重复执行安全（幂等），会更新已有配置。
set -euo pipefail

# ── 定位 hub 根目录 ──────────────────────────────────────────
SCRIPT_DIR="$(cd -P "$(dirname "$0")" && pwd)"
HUB_ROOT="${1:-$(dirname "$SCRIPT_DIR")}"

if [ ! -f "${HUB_ROOT}/scripts/hub_pre_tool_hook.sh" ] || [ ! -f "${HUB_ROOT}/scripts/hub_stop_hook.sh" ]; then
    echo "ERROR: 找不到 hook 脚本，请确认 hub 根目录: ${HUB_ROOT}"
    exit 1
fi

PRE_HOOK="${HUB_ROOT}/scripts/hub_pre_tool_hook.sh"
STOP_HOOK="${HUB_ROOT}/scripts/hub_stop_hook.sh"

echo "Hub root: ${HUB_ROOT}"
echo "PreToolUse hook: ${PRE_HOOK}"
echo "Stop hook: ${STOP_HOOK}"

# ── 确保 ~/.claude 目录存在 ───────────────────────────────────
SETTINGS_FILE="${HOME}/.claude/settings.json"
mkdir -p "$(dirname "$SETTINGS_FILE")"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# ── 用 python3 安全合并 JSON ─────────────────────────────────
python3 << PYEOF
import json, sys, os

settings_file = os.path.expanduser("${SETTINGS_FILE}")
pre_hook_path = "${PRE_HOOK}"
stop_hook_path = "${STOP_HOOK}"

with open(settings_file, "r") as f:
    try:
        settings = json.load(f)
    except json.JSONDecodeError:
        settings = {}

hooks = settings.setdefault("hooks", {})

# ── PreToolUse hook ──
pre_tool_hooks = hooks.get("PreToolUse", [])
hub_pre_cmd = f"bash {pre_hook_path}"

# 查找已有的 hub hook 并更新/添加
found_pre = False
for entry in pre_tool_hooks:
    if entry.get("matcher") == "Bash":
        for h in entry.get("hooks", []):
            if "hub_pre_tool_hook" in h.get("command", ""):
                h["command"] = hub_pre_cmd
                h["timeout"] = 5
                found_pre = True
                break
        if not found_pre:
            # Bash matcher 存在但没有 hub hook，添加
            entry.setdefault("hooks", []).append({
                "type": "command",
                "command": hub_pre_cmd,
                "timeout": 5
            })
            found_pre = True
        break

if not found_pre:
    pre_tool_hooks.append({
        "matcher": "Bash",
        "hooks": [{
            "type": "command",
            "command": hub_pre_cmd,
            "timeout": 5
        }]
    })

hooks["PreToolUse"] = pre_tool_hooks

# ── Stop hook ──
stop_hooks = hooks.get("Stop", [])
hub_stop_cmd = f"bash {stop_hook_path}"

found_stop = False
for entry in stop_hooks:
    for h in entry.get("hooks", []):
        if "hub_stop_hook" in h.get("command", ""):
            h["command"] = hub_stop_cmd
            h["timeout"] = 15
            found_stop = True
            break
    if found_stop:
        break

if not found_stop:
    stop_hooks.append({
        "hooks": [{
            "type": "command",
            "command": hub_stop_cmd,
            "timeout": 15
        }]
    })

hooks["Stop"] = stop_hooks

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)

print(f"\n✓ hooks 已写入 {settings_file}")
PYEOF

echo ""
echo "验证配置："
python3 -c "
import json
with open('${SETTINGS_FILE}') as f:
    h = json.load(f).get('hooks', {})
pre = [e for e in h.get('PreToolUse', []) if e.get('matcher') == 'Bash']
stop = h.get('Stop', [])
print(f'  PreToolUse (Bash): {len(pre)} 条规则')
print(f'  Stop: {len(stop)} 条规则')
for e in pre:
    for hook in e.get('hooks', []):
        if 'hub' in hook.get('command', ''):
            print(f'    ✓ {hook[\"command\"][:80]}')
for e in stop:
    for hook in e.get('hooks', []):
        if 'hub' in hook.get('command', ''):
            print(f'    ✓ {hook[\"command\"][:80]}')
"
echo ""
echo "安装完成。hook 在 hub 流程未激活时（/tmp/.claude_hub_active 不存在）不会影响任何操作。"
