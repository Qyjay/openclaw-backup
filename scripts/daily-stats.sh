#!/bin/bash
# ============================================================
# OpenClaw Daily Stats — Silvana 👑
# 记录每日对话轮数、token 用量、磁盘占用
# ============================================================

set -euo pipefail

OPENCLAW_DIR="${OPENCLAW_DIR:-$HOME/.openclaw}"
WORKSPACE_DIR="$OPENCLAW_DIR/workspace"
STATS_FILE="$WORKSPACE_DIR/memory/daily-stats.md"
TODAY=$(date '+%Y-%m-%d')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 如果文件不存在，创建表头
if [ ! -f "$STATS_FILE" ]; then
    cat > "$STATS_FILE" << 'EOF'
# Daily Stats — Silvana 👑

每日自动记录对话量、token 用量、磁盘占用。

EOF
fi

# 检查今天是否已记录
if grep -q "^## $TODAY" "$STATS_FILE" 2>/dev/null; then
    echo "📊 今日已记录，跳过"
    exit 0
fi

# --- 1. 对话轮数统计 ---
# 统计今天活跃的 session 文件中的 user 消息数
TOTAL_ROUNDS=0
SESSIONS_ACTIVE=0

for agent_dir in "$OPENCLAW_DIR/agents"/*/sessions; do
    [ -d "$agent_dir" ] || continue
    for session_file in "$agent_dir"/*.jsonl; do
        [ -f "$session_file" ] || continue
        # 检查文件今天是否被修改过
        FILE_DATE=$(date -r "$session_file" '+%Y-%m-%d' 2>/dev/null || stat -c '%y' "$session_file" 2>/dev/null | cut -d' ' -f1)
        if [ "$FILE_DATE" = "$TODAY" ]; then
            # 计算 user role 消息数作为对话轮数
            ROUNDS=$(grep -c '"role":"user"' "$session_file" 2>/dev/null || echo 0)
            TOTAL_ROUNDS=$((TOTAL_ROUNDS + ROUNDS))
            SESSIONS_ACTIVE=$((SESSIONS_ACTIVE + 1))
        fi
    done
done

# --- 2. Token 用量统计 ---
# 从 session 元数据或日志中提取
TOKEN_LINES=""
if command -v python3 &>/dev/null; then
    TOKEN_LINES=$(python3 << 'PYEOF'
import json, os, glob

openclaw_dir = os.path.expanduser("~/.openclaw")
results = []

for agent_dir in glob.glob(os.path.join(openclaw_dir, "agents", "*", "sessions")):
    agent_name = agent_dir.split("/agents/")[1].split("/sessions")[0]
    sessions_file = os.path.join(agent_dir, "sessions.json")
    if not os.path.exists(sessions_file):
        continue
    try:
        with open(sessions_file) as f:
            sessions = json.load(f)
        for sid, sdata in sessions.items():
            if not isinstance(sdata, dict):
                continue
            model = sdata.get("model", "unknown")
            provider = sdata.get("modelProvider", "")
            input_t = sdata.get("inputTokens", 0)
            output_t = sdata.get("outputTokens", 0)
            cache_read = sdata.get("cacheRead", 0)
            cache_write = sdata.get("cacheWrite", 0)
            total_t = sdata.get("totalTokens", 0)
            compactions = sdata.get("compactionCount", 0)
            
            if total_t > 0:
                full_model = f"{provider}/{model}" if provider else model
                results.append({
                    "agent": agent_name,
                    "model": full_model,
                    "input": input_t,
                    "output": output_t,
                    "cache_read": cache_read,
                    "cache_write": cache_write,
                    "total": total_t,
                    "compactions": compactions
                })
    except:
        pass

for r in results:
    print(f"| 模型 | {r['model']} |")
    print(f"| Token (输入/输出) | {r['input']:,} / {r['output']:,} |")
    print(f"| Cache (读/写) | {r['cache_read']:,} / {r['cache_write']:,} |")
    print(f"| Token 总计 | {r['total']:,} |")
    print(f"| 压缩次数 | {r['compactions']} |")
PYEOF
    )
fi

# --- 3. 磁盘占用统计 ---
WORKSPACE_SIZE=$(du -sh "$WORKSPACE_DIR" 2>/dev/null | cut -f1)
OPENCLAW_TOTAL=$(du -sh "$OPENCLAW_DIR" 2>/dev/null | cut -f1)
SESSIONS_SIZE=$(du -sh "$OPENCLAW_DIR/agents" 2>/dev/null | cut -f1)
SKILLS_SIZE=$(du -sh "$HOME/clawd/skills" 2>/dev/null | cut -f1 || echo "0B")

# --- 4. 写入统计 ---
cat >> "$STATS_FILE" << EOF

## $TODAY

| 项目 | 数值 |
|------|------|
| 记录时间 | $TIMESTAMP |
| 活跃会话数 | $SESSIONS_ACTIVE |
| 对话轮数 (user messages) | $TOTAL_ROUNDS |
$TOKEN_LINES
| Workspace 大小 | $WORKSPACE_SIZE |
| Sessions 大小 | $SESSIONS_SIZE |
| ClawHub Skills 大小 | $SKILLS_SIZE |
| OpenClaw 总占用 | $OPENCLAW_TOTAL |

EOF

echo "📊 [Silvana] 每日统计已记录 — $TIMESTAMP"
