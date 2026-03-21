#!/bin/bash
# pre_mr_check.sh — MR 提交前的就绪检查
#
# 用法:
#   bash pre_mr_check.sh <repo-path> <branch> <language> [format-cmd] [base-branch] [service-name]
#
# 检查项:
#   1. 分支存在且是当前分支
#   2. 工作区干净（无未提交变更）
#   3. 分支有 commit（相对于 origin/<base-branch>）
#   4. 代码已格式化（format 后无 diff）
#   5. 改动中包含测试文件
#   6. commit message 格式正确
#
# 输出结构化报告，退出码: 0=就绪, 1=未就绪
set -uo pipefail

REPO_PATH="${1:?Usage: pre_mr_check.sh <repo-path> <branch> <language> [format-cmd] [base-branch] [service-name]}"
BRANCH="${2:?Missing branch name}"
LANGUAGE="${3:?Missing language}"
FORMAT_CMD="${4:-}"
BASE_BRANCH="${5:-main}"
SERVICE_NAME="${6:-}"

if [ ! -d "$REPO_PATH" ]; then
    echo "ERROR: repo path does not exist: $REPO_PATH"
    exit 2
fi

cd "$REPO_PATH"

# ── 前置条件：质量门禁必须已通过 ────────────────────────────────
STATE_FILE_CHECK="/tmp/.claude_hub_active"
if [ -f "$STATE_FILE_CHECK" ]; then
    if [ -n "$SERVICE_NAME" ]; then
        STEP3_KEY="svc_${SERVICE_NAME}_step3"
    else
        STEP3_KEY="step3_quality_gate"
    fi
    STEP3_VAL=$(grep "^${STEP3_KEY}:" "$STATE_FILE_CHECK" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
    if [ "$STEP3_VAL" = "BLOCKED" ]; then
        echo "ERROR: 质量门禁未通过（${STEP3_KEY}: BLOCKED），禁止进行 MR 就绪检查。"
        echo ""
        echo "你必须先回去修复问题："
        echo "  1. 阅读上次 quality_gate.sh 的输出，找到 FAIL 的门禁"
        echo "  2. 覆盖率不足 → 为 uncovered_files 编写单元测试（mock 隔离外部依赖）"
        echo "  3. lint/test 失败 → 修复代码错误"
        echo "  4. git add + git commit"
        echo "  5. 重跑 quality_gate.sh 直到 verdict: PASSED"
        exit 1
    elif [ -z "$STEP3_VAL" ]; then
        echo "ERROR: 质量门禁尚未运行（${STEP3_KEY} 不存在）。必须先运行 quality_gate.sh（Step 3）。"
        exit 1
    fi
fi

# 校验 base_branch 存在
git fetch origin "$BASE_BRANCH" --quiet 2>/dev/null || true
if ! git rev-parse "origin/${BASE_BRANCH}" &>/dev/null; then
    echo "ERROR: base branch 'origin/${BASE_BRANCH}' does not exist. Check registry service file base_branch."
    exit 1
fi

CHECK_PASSED=0
CHECK_FAILED=0
CHECK_WARNED=0
TOTAL_CHECKS=0
ISSUES=""

echo "=== PRE-MR CHECK ==="
echo "repo: $REPO_PATH"
echo "branch: $BRANCH"
echo ""

# ── Helper ────────────────────────────────────────────────
pass_check() {
    local name="$1"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    CHECK_PASSED=$((CHECK_PASSED + 1))
    echo "  [PASS] $name"
}

fail_check() {
    local name="$1"
    local detail="$2"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    CHECK_FAILED=$((CHECK_FAILED + 1))
    echo "  [FAIL] $name"
    [ -n "$detail" ] && echo "         $detail"
    ISSUES="${ISSUES}\n- ${name}: ${detail}"
}

warn_check() {
    local name="$1"
    local detail="$2"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    CHECK_WARNED=$((CHECK_WARNED + 1))
    echo "  [WARN] $name"
    [ -n "$detail" ] && echo "         $detail"
}

# ── 主分支（由参数指定，默认 main）────────────────────────────
MAIN_BRANCH="$BASE_BRANCH"

# ── Check 1: 分支状态 ───────────────────────────────────────
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [ "$CURRENT_BRANCH" = "$BRANCH" ]; then
    pass_check "branch_current: on ${BRANCH}"
else
    fail_check "branch_current" "expected '${BRANCH}', on '${CURRENT_BRANCH}'"
fi

# ── Check 2: 工作区干净 ─────────────────────────────────────
DIRTY_FILES=$(git status --porcelain 2>/dev/null | head -10)
if [ -z "$DIRTY_FILES" ]; then
    pass_check "working_tree_clean"
else
    DIRTY_COUNT=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    fail_check "working_tree_clean" "${DIRTY_COUNT} uncommitted file(s)"
fi

# ── Check 3: 有 commit ──────────────────────────────────────
git fetch origin "$MAIN_BRANCH" --quiet 2>/dev/null || true
COMMIT_COUNT=$(git rev-list --count "origin/${MAIN_BRANCH}..HEAD" 2>/dev/null || echo "0")
if [ "$COMMIT_COUNT" -gt 0 ]; then
    pass_check "has_commits: ${COMMIT_COUNT} commit(s) ahead of origin/${MAIN_BRANCH}"
else
    fail_check "has_commits" "no commits ahead of origin/${MAIN_BRANCH}"
fi

# ── Check 4: 代码已格式化 ───────────────────────────────────
if [ -n "$FORMAT_CMD" ]; then
    # 保存当前状态，运行 format，检查有无 diff，然后恢复
    STASH_NEEDED="false"
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        # 有未提交变更，跳过格式化检查（已经在 Check 2 失败了）
        warn_check "format_check" "skipped (working tree not clean)"
    else
        # 运行格式化
        eval "$FORMAT_CMD" >/dev/null 2>&1 || true
        FORMAT_DIFF=$(git diff --name-only 2>/dev/null)
        if [ -z "$FORMAT_DIFF" ]; then
            pass_check "format_check: code is formatted"
        else
            FORMAT_DIFF_COUNT=$(echo "$FORMAT_DIFF" | wc -l | tr -d ' ')
            fail_check "format_check" "${FORMAT_DIFF_COUNT} file(s) need formatting"
            # 恢复格式化前的状态
            git checkout -- . 2>/dev/null || true
        fi
    fi
else
    warn_check "format_check" "no format command configured"
fi

# ── Check 5: 改动包含测试文件 ───────────────────────────────
CHANGED_FILES=$(git diff --name-only "origin/${MAIN_BRANCH}...HEAD" 2>/dev/null || echo "")

HAS_CODE_CHANGES="false"
HAS_TEST_FILES="false"

if [ -n "$CHANGED_FILES" ]; then
    case "$LANGUAGE" in
        python)
            if echo "$CHANGED_FILES" | grep -E '\.py$' | grep -qvE 'test_|_test\.py|tests/'; then
                HAS_CODE_CHANGES="true"
            fi
            if echo "$CHANGED_FILES" | grep -qE 'test_.*\.py$|_test\.py$|tests/.*\.py$'; then
                HAS_TEST_FILES="true"
            fi
            ;;
        go)
            if echo "$CHANGED_FILES" | grep -E '\.go$' | grep -qv '_test\.go'; then
                HAS_CODE_CHANGES="true"
            fi
            if echo "$CHANGED_FILES" | grep -qE '_test\.go$'; then
                HAS_TEST_FILES="true"
            fi
            ;;
        nodejs)
            if echo "$CHANGED_FILES" | grep -E '\.(ts|js)$' | grep -qvE '\.test\.|\.spec\.|__tests__'; then
                HAS_CODE_CHANGES="true"
            fi
            if echo "$CHANGED_FILES" | grep -qE '\.test\.(ts|js)$|\.spec\.(ts|js)$|__tests__/'; then
                HAS_TEST_FILES="true"
            fi
            ;;
        java)
            if echo "$CHANGED_FILES" | grep -E '\.java$' | grep -qv 'Test\.java'; then
                HAS_CODE_CHANGES="true"
            fi
            if echo "$CHANGED_FILES" | grep -qE 'Test\.java$|Tests\.java$|src/test/'; then
                HAS_TEST_FILES="true"
            fi
            ;;
    esac

    # 简化判断：只要有对应语言的源文件变更
    CODE_FILE_COUNT=$(echo "$CHANGED_FILES" | grep -cE '\.(py|go|ts|js|java|rs)$' 2>/dev/null || echo "0")
    TEST_FILE_COUNT=0

    case "$LANGUAGE" in
        python) TEST_FILE_COUNT=$(echo "$CHANGED_FILES" | grep -cE 'test_.*\.py$|_test\.py$|tests/.*\.py$' 2>/dev/null || echo "0") ;;
        go)     TEST_FILE_COUNT=$(echo "$CHANGED_FILES" | grep -cE '_test\.go$' 2>/dev/null || echo "0") ;;
        nodejs) TEST_FILE_COUNT=$(echo "$CHANGED_FILES" | grep -cE '\.test\.(ts|js)$|\.spec\.(ts|js)$|__tests__/' 2>/dev/null || echo "0") ;;
        java)   TEST_FILE_COUNT=$(echo "$CHANGED_FILES" | grep -cE 'Test\.java$|src/test/' 2>/dev/null || echo "0") ;;
    esac

    if [ "$TEST_FILE_COUNT" -gt 0 ]; then
        pass_check "test_files_included: ${TEST_FILE_COUNT} test file(s) in changeset"
    elif [ "$CODE_FILE_COUNT" -gt 0 ]; then
        warn_check "test_files_included" "code changed but no test files in changeset"
    else
        pass_check "test_files_included: no code files changed (config/docs only)"
    fi
else
    warn_check "test_files_included" "no changed files detected"
fi

# ── Check 6: commit message 格式 ────────────────────────────
if [ "$COMMIT_COUNT" -gt 0 ]; then
    # 检查最近的 commit message
    LAST_MSG=$(git log -1 --pretty=%B 2>/dev/null || echo "")

    # 检查是否有 Co-Authored-By
    if echo "$LAST_MSG" | grep -q "Co-Authored-By:"; then
        pass_check "commit_message: has Co-Authored-By"
    else
        warn_check "commit_message" "missing Co-Authored-By trailer"
    fi

    # 检查 message 不为空且有意义
    FIRST_LINE=$(echo "$LAST_MSG" | head -1)
    if [ ${#FIRST_LINE} -lt 5 ]; then
        warn_check "commit_message_quality" "commit message too short: '${FIRST_LINE}'"
    else
        pass_check "commit_message_quality: '${FIRST_LINE}'"
    fi
fi

# ── Check 7: 无冲突标记 ─────────────────────────────────────
CONFLICT_FILES=$(git diff --name-only "origin/${MAIN_BRANCH}...HEAD" 2>/dev/null | xargs grep -l "^<<<<<<< " 2>/dev/null || echo "")
if [ -z "$CONFLICT_FILES" ]; then
    pass_check "no_conflict_markers"
else
    fail_check "no_conflict_markers" "conflict markers found in: $(echo "$CONFLICT_FILES" | tr '\n' ' ')"
fi

# ── Check 8: 无敏感文件 ─────────────────────────────────────
SENSITIVE_FILES=$(echo "$CHANGED_FILES" | grep -iE '\.env$|\.env\.|credentials|secret|\.pem$|\.key$|password' 2>/dev/null || echo "")
if [ -z "$SENSITIVE_FILES" ]; then
    pass_check "no_sensitive_files"
else
    fail_check "no_sensitive_files" "potentially sensitive files: $(echo "$SENSITIVE_FILES" | tr '\n' ' ')"
fi

# ── 总结 ─────────────────────────────────────────────────────
echo ""
echo "--- SUMMARY ---"
echo "total_checks: $TOTAL_CHECKS"
echo "passed: $CHECK_PASSED"
echo "failed: $CHECK_FAILED"
echo "warned: $CHECK_WARNED"

echo ""
echo "changed_files:"
if [ -n "$CHANGED_FILES" ]; then
    echo "$CHANGED_FILES" | while read -r f; do
        echo "  - $f"
    done
else
    echo "  (none)"
fi

echo ""
if [ "$CHECK_FAILED" -gt 0 ]; then
    echo "verdict: NOT_READY"
    echo "message: ${CHECK_FAILED} check(s) failed. Fix issues before creating MR."
    echo -e "issues:${ISSUES}"
else
    echo "verdict: READY"
    if [ "$CHECK_WARNED" -gt 0 ]; then
        echo "message: All checks passed (${CHECK_WARNED} warning(s)). Ready for MR."
    else
        echo "message: All checks passed. Ready for MR."
    fi
fi

echo ""
echo "=== END PRE-MR CHECK ==="

# ── 写入状态标记 ─────────────────────────────────────────────
STATE_FILE="/tmp/.claude_hub_active"
if [ -f "$STATE_FILE" ]; then
    VERDICT=$( [ "$CHECK_FAILED" -eq 0 ] && echo "READY" || echo "NOT_READY" )
    if [ -n "$SERVICE_NAME" ]; then
        MARKER_KEY="svc_${SERVICE_NAME}_step4"
    else
        MARKER_KEY="step4_pre_mr"
    fi
    if grep -q "^${MARKER_KEY}:" "$STATE_FILE" 2>/dev/null; then
        sed -i.bak "s/^${MARKER_KEY}:.*/${MARKER_KEY}: ${VERDICT}/" "$STATE_FILE"
        rm -f "${STATE_FILE}.bak"
    else
        echo "${MARKER_KEY}: ${VERDICT}" >> "$STATE_FILE"
    fi
fi

# 始终 exit 0 — verdict 通过 READY/NOT_READY 输出，不用退出码
# 避免 exit 1 导致 Bash tool 报错或取消并行调用
exit 0
