#!/bin/bash
# update_sync_state.sh — 更新仓库的 harness 同步基线
#
# 用法:
#   bash update_sync_state.sh <repo-path> [commit-hash]
#
# 在 <repo-path>/docs/harness-sync-state.yaml 写入当前同步基线。
# 如果不指定 commit-hash，默认使用 HEAD。
set -euo pipefail

REPO_PATH="${1:?Usage: update_sync_state.sh <repo-path> [commit-hash]}"

if [ ! -d "$REPO_PATH" ]; then
    echo "ERROR: repo path does not exist: $REPO_PATH"
    exit 2
fi

cd "$REPO_PATH"

COMMIT_HASH="${2:-$(git rev-parse HEAD)}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_SHORT=$(git rev-parse --short "$COMMIT_HASH" 2>/dev/null || echo "${COMMIT_HASH:0:8}")

# 确保 docs 目录存在
mkdir -p docs

STATE_FILE="docs/harness-sync-state.yaml"

cat > "$STATE_FILE" << EOF
# Harness Sync State
#
# 记录 harness 文档上次同步到的 commit。
# detect_drift.sh 用这个基线做增量漂移检测。
# 每次 /hub 开发完成或 /hub-sync 后自动更新。
#
# 不要手动编辑此文件。

last_sync_commit: ${COMMIT_HASH}
last_sync_time: ${TIMESTAMP}
synced_files:
  - CLAUDE.md
  - docs/architecture.md
  - docs/golden-rules.md
  - .claude/skills/
EOF

echo "Updated harness sync baseline: ${COMMIT_SHORT} @ ${TIMESTAMP}"
echo "  file: ${REPO_PATH}/${STATE_FILE}"
