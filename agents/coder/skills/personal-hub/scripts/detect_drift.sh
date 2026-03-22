#!/bin/bash
# detect_drift.sh — 检测服务仓库的 harness 文档与代码的漂移
#
# 用法:
#   bash detect_drift.sh <service-name> <repo-path> [baseline-commit]
#
# 输出: 结构化的漂移报告 (可被 agent 消费)
#
# 如果没有 baseline-commit，自动从 docs/harness-sync-state.yaml 读取基线。
# 退出码: 始终 0（漂移状态通过 stdout 的 drift_found: true/false 输出）
set -euo pipefail

SERVICE_NAME="${1:?Usage: detect_drift.sh <service-name> <repo-path> [baseline-commit]}"
REPO_PATH="${2:?Missing repo path}"
BASELINE="${3:-}"

# ── 验证仓库 ──────────────────────────────────────────────
if [ ! -d "$REPO_PATH" ]; then
    echo "ERROR: repo path does not exist: $REPO_PATH"
    exit 2
fi

cd "$REPO_PATH"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "ERROR: not a git repo: $REPO_PATH"
    exit 2
fi

HEAD_COMMIT=$(git rev-parse HEAD)
HEAD_SHORT=$(git rev-parse --short HEAD)
HEAD_TIME=$(git log -1 --format=%cI HEAD)

DRIFT_FOUND=0

echo "=== DRIFT REPORT ==="
echo "service: $SERVICE_NAME"
echo "repo: $REPO_PATH"
echo "head: $HEAD_COMMIT"
echo "head_short: $HEAD_SHORT"
echo "head_time: $HEAD_TIME"

# 如果没有传 baseline，尝试从仓库的 harness-sync-state.yaml 读取
if [ -z "$BASELINE" ] && [ -f "docs/harness-sync-state.yaml" ]; then
    BASELINE=$(python3 -c "
import yaml
with open('docs/harness-sync-state.yaml') as f:
    print(yaml.safe_load(f).get('last_sync_commit', ''))
" 2>/dev/null || echo "")
fi

if [ -n "$BASELINE" ]; then
    if ! git cat-file -t "$BASELINE" &>/dev/null; then
        echo "baseline: INVALID ($BASELINE not found in repo)"
        echo "mode: full"
        BASELINE=""
    else
        BASELINE_SHORT=$(git rev-parse --short "$BASELINE")
        BASELINE_TIME=$(git log -1 --format=%cI "$BASELINE" 2>/dev/null || echo "unknown")
        COMMIT_COUNT=$(git rev-list --count "$BASELINE".."$HEAD_COMMIT" 2>/dev/null || echo "?")
        echo "baseline: $BASELINE"
        echo "baseline_short: $BASELINE_SHORT"
        echo "baseline_time: $BASELINE_TIME"
        echo "commits_since_baseline: $COMMIT_COUNT"
        echo "mode: incremental"
    fi
else
    echo "baseline: none"
    echo "mode: full"
fi

echo ""
echo "--- CHANGED FILES ---"

if [ -n "$BASELINE" ]; then
    CHANGED_FILES=$(git diff --name-only --diff-filter=ACMRD "$BASELINE".."$HEAD_COMMIT" 2>/dev/null || echo "")
else
    # 全量模式：列出所有被跟踪的文件
    CHANGED_FILES=$(git ls-files)
fi

# 分类变更文件
STRUCTURE_CHANGES=""      # 目录结构变化
BUILD_CHANGES=""          # 构建配置变化
ROUTE_CHANGES=""          # 路由/API 变化
IDL_CHANGES=""            # IDL/proto/OpenAPI 变化
LINTER_CHANGES=""         # linter 配置变化
CI_CHANGES=""             # CI 配置变化
OTHER_CHANGES=""

while IFS= read -r file; do
    [ -z "$file" ] && continue

    case "$file" in
        # 构建配置
        Makefile|pyproject.toml|package.json|build.gradle*|pom.xml|go.mod|Cargo.toml|*.cmake)
            BUILD_CHANGES+="$file"$'\n'
            ;;
        # IDL / API spec
        *.thrift|*.proto|*openapi*.yaml|*openapi*.json|*swagger*.yaml|*swagger*.json)
            IDL_CHANGES+="$file"$'\n'
            ;;
        # Linter 配置
        .golangci*|.eslint*|.ruff*|ruff.toml|mypy.ini|.flake8|.pylintrc|tslint.json|biome.json)
            LINTER_CHANGES+="$file"$'\n'
            ;;
        # CI 配置
        .gitlab-ci.yml|.github/workflows/*|Jenkinsfile)
            CI_CHANGES+="$file"$'\n'
            ;;
        # 路由 / Handler 文件 (启发式)
        *router*|*handler*|*controller*|*route*|*endpoint*|*server*|*main.go|*app.py|*main.py)
            ROUTE_CHANGES+="$file"$'\n'
            ;;
        *)
            OTHER_CHANGES+="$file"$'\n'
            ;;
    esac
done <<< "$CHANGED_FILES"

# 检查是否有新的顶层目录
if [ -n "$BASELINE" ]; then
    NEW_DIRS=$(git diff --diff-filter=A --name-only "$BASELINE".."$HEAD_COMMIT" 2>/dev/null \
        | grep -oE "^[^/]+" | sort -u \
        | while read -r d; do [ -d "$d" ] && echo "$d"; done || true)
    DELETED_DIRS=$(git diff --diff-filter=D --name-only "$BASELINE".."$HEAD_COMMIT" 2>/dev/null \
        | grep -oE "^[^/]+" | sort -u \
        | while read -r d; do [ ! -d "$d" ] && echo "$d"; done || true)
    if [ -n "$NEW_DIRS" ] || [ -n "$DELETED_DIRS" ]; then
        STRUCTURE_CHANGES="new_dirs: $NEW_DIRS"$'\n'"deleted_dirs: $DELETED_DIRS"
    fi
fi

echo "structure_changes: $([ -n "$STRUCTURE_CHANGES" ] && echo "yes" || echo "no")"
echo "build_changes: $([ -n "$BUILD_CHANGES" ] && echo "yes" || echo "no")"
echo "route_changes: $([ -n "$ROUTE_CHANGES" ] && echo "yes" || echo "no")"
echo "idl_changes: $([ -n "$IDL_CHANGES" ] && echo "yes" || echo "no")"
echo "linter_changes: $([ -n "$LINTER_CHANGES" ] && echo "yes" || echo "no")"
echo "ci_changes: $([ -n "$CI_CHANGES" ] && echo "yes" || echo "no")"

if [ -n "$BUILD_CHANGES" ]; then
    echo ""
    echo "build_files:"
    echo "$BUILD_CHANGES" | sed '/^$/d' | sed 's/^/  - /'
fi

if [ -n "$ROUTE_CHANGES" ]; then
    echo ""
    echo "route_files:"
    echo "$ROUTE_CHANGES" | sed '/^$/d' | sed 's/^/  - /'
fi

if [ -n "$IDL_CHANGES" ]; then
    echo ""
    echo "idl_files:"
    echo "$IDL_CHANGES" | sed '/^$/d' | sed 's/^/  - /'
fi

if [ -n "$STRUCTURE_CHANGES" ]; then
    echo ""
    echo "structure_details:"
    echo "$STRUCTURE_CHANGES" | sed 's/^/  /'
fi

# ── 检查各 harness 文件 ──────────────────────────────────
echo ""
echo "--- HARNESS FILES ---"

# CLAUDE.md
echo ""
echo "claude_md:"
if [ -f "CLAUDE.md" ]; then
    echo "  exists: true"

    # 检查 Navigation Map 中的路径是否存在
    NAV_PATHS=$(grep -oE '`[^`]+`' CLAUDE.md | tr -d '`' | grep -E "^[a-zA-Z]" | grep "/" || true)
    BROKEN_PATHS=""
    for p in $NAV_PATHS; do
        if [ ! -e "$p" ] && [ ! -d "$p" ]; then
            BROKEN_PATHS+="$p "
        fi
    done

    if [ -n "$BROKEN_PATHS" ]; then
        echo "  broken_paths: [$BROKEN_PATHS]"
        echo "  drift: true"
        echo "  drift_reason: Navigation Map references non-existent paths"
        DRIFT_FOUND=1
    else
        echo "  broken_paths: []"
    fi

    # 检查 Quick Start 中的 make targets
    MAKE_CMDS=$(grep -oE "make [a-z_-]+" CLAUDE.md || true)
    if [ -n "$MAKE_CMDS" ] && [ -f "Makefile" ]; then
        MISSING_TARGETS=""
        for cmd in $MAKE_CMDS; do
            target=$(echo "$cmd" | sed 's/make //')
            if ! grep -qE "^${target}:" Makefile 2>/dev/null; then
                MISSING_TARGETS+="$target "
            fi
        done
        if [ -n "$MISSING_TARGETS" ]; then
            echo "  missing_make_targets: [$MISSING_TARGETS]"
            echo "  drift: true"
            echo "  drift_reason: Quick Start references non-existent make targets"
            DRIFT_FOUND=1
        fi
    fi

    # 检查是否需要更新（有结构性变化但 CLAUDE.md 没改）
    if [ -n "$STRUCTURE_CHANGES" ] || [ -n "$BUILD_CHANGES" ]; then
        if [ -n "$BASELINE" ]; then
            CLAUDE_CHANGED=$(git diff --name-only "$BASELINE".."$HEAD_COMMIT" -- CLAUDE.md 2>/dev/null || echo "")
            if [ -z "$CLAUDE_CHANGED" ]; then
                echo "  needs_review: true"
                echo "  review_reason: structure/build changes detected but CLAUDE.md not updated"
                DRIFT_FOUND=1
            fi
        fi
    fi

    if [ "$DRIFT_FOUND" -eq 0 ] 2>/dev/null; then
        echo "  drift: false"
    fi
else
    echo "  exists: false"
    echo "  drift: true"
    echo "  drift_reason: CLAUDE.md does not exist"
    DRIFT_FOUND=1
fi

# docs/architecture.md
echo ""
echo "architecture_md:"
if [ -f "docs/architecture.md" ]; then
    echo "  exists: true"

    if [ -n "$STRUCTURE_CHANGES" ] || [ -n "$ROUTE_CHANGES" ]; then
        if [ -n "$BASELINE" ]; then
            ARCH_CHANGED=$(git diff --name-only "$BASELINE".."$HEAD_COMMIT" -- docs/architecture.md 2>/dev/null || echo "")
            if [ -z "$ARCH_CHANGED" ]; then
                echo "  drift: true"
                echo "  drift_reason: structure/route changes detected but architecture.md not updated"
                DRIFT_FOUND=1
            else
                echo "  drift: false"
            fi
        else
            echo "  drift: needs_full_check"
        fi
    else
        echo "  drift: false"
    fi
else
    echo "  exists: false"
    echo "  drift: true"
    echo "  drift_reason: docs/architecture.md does not exist"
    DRIFT_FOUND=1
fi

# docs/golden-rules.md
echo ""
echo "golden_rules_md:"
if [ -f "docs/golden-rules.md" ]; then
    echo "  exists: true"

    if [ -n "$LINTER_CHANGES" ]; then
        if [ -n "$BASELINE" ]; then
            RULES_CHANGED=$(git diff --name-only "$BASELINE".."$HEAD_COMMIT" -- docs/golden-rules.md 2>/dev/null || echo "")
            if [ -z "$RULES_CHANGED" ]; then
                echo "  drift: true"
                echo "  drift_reason: linter config changed but golden-rules.md not updated"
                DRIFT_FOUND=1
            else
                echo "  drift: false"
            fi
        else
            echo "  drift: needs_full_check"
        fi
    else
        echo "  drift: false"
    fi
else
    echo "  exists: false"
    echo "  drift: true"
    echo "  drift_reason: docs/golden-rules.md does not exist"
    DRIFT_FOUND=1
fi

# .claude/skills/
echo ""
echo "skills:"
if [ -d ".claude/skills" ]; then
    echo "  exists: true"
    SKILL_COUNT=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    echo "  count: $SKILL_COUNT"

    # 检查 skill 中引用的命令是否有效
    SKILL_CMDS=$(grep -rhoE "(make [a-z_-]+|npm run [a-z_-]+|go test|go vet|gradle\w*)" .claude/skills/ 2>/dev/null | sort -u || true)
    if [ -n "$BUILD_CHANGES" ] && [ -n "$SKILL_CMDS" ]; then
        echo "  drift: needs_check"
        echo "  drift_reason: build config changed, skill commands may be outdated"
        DRIFT_FOUND=1
    else
        echo "  drift: false"
    fi
else
    echo "  exists: false"
    echo "  drift: true"
    echo "  drift_reason: .claude/skills/ does not exist"
    DRIFT_FOUND=1
fi

# registry 服务文件相关（API 变更检测）
echo ""
echo "registry_service:"
if [ -n "$IDL_CHANGES" ] || [ -n "$ROUTE_CHANGES" ]; then
    echo "  api_drift: true"
    echo "  drift_reason: API-related files changed, registry service file exposes/consumes may need update"
    DRIFT_FOUND=1
else
    echo "  api_drift: false"
fi
if [ -n "$BUILD_CHANGES" ]; then
    echo "  build_drift: true"
    echo "  drift_reason: build config changed, registry service file commands may need update"
    DRIFT_FOUND=1
else
    echo "  build_drift: false"
fi
if [ -n "$CI_CHANGES" ]; then
    echo "  ci_drift: true"
    echo "  drift_reason: CI config changed, registry service file apps may need update"
    DRIFT_FOUND=1
else
    echo "  ci_drift: false"
fi

# ── 总结 ──────────────────────────────────────────────────
echo ""
echo "--- SUMMARY ---"
echo "drift_found: $([ "$DRIFT_FOUND" -eq 1 ] && echo "true" || echo "false")"
echo "=== END REPORT ==="

# ── 写入状态标记 ─────────────────────────────────────────────
STATE_FILE="/tmp/.claude_hub_active"
if [ -f "$STATE_FILE" ]; then
    DRIFT_STATUS=$( [ "$DRIFT_FOUND" -eq 1 ] && echo "drift" || echo "clean" )
    MARKER_KEY="svc_${SERVICE_NAME}_step6"
    if grep -q "^${MARKER_KEY}:" "$STATE_FILE" 2>/dev/null; then
        sed -i.bak "s/^${MARKER_KEY}:.*/${MARKER_KEY}: ${DRIFT_STATUS}/" "$STATE_FILE"
        rm -f "${STATE_FILE}.bak"
    else
        echo "${MARKER_KEY}: ${DRIFT_STATUS}" >> "$STATE_FILE"
    fi
fi

# 始终 exit 0 — 漂移状态通过 drift_found: true/false 输出，不用退出码
# 避免 exit 1 导致 Bash tool 报错或取消并行调用
exit 0
