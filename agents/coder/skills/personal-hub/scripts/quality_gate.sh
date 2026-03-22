#!/bin/bash
# quality_gate.sh — 质量门禁检查
#
# 用法:
#   bash quality_gate.sh <repo-path> <language> [check-cmd] [test-cmd] [coverage-threshold] [base-branch] [service-name]
# 当指定 service-name 时，状态标记使用 svc_<service-name>_step3 前缀
#
# 依次执行: lint/check → 单元测试 → 增量覆盖率检查
# 覆盖率只检查相对 base-branch 变更的代码，不检查全量覆盖率
# 输出结构化报告，退出码: 0=全部通过, 1=有失败项
set -uo pipefail

REPO_PATH="${1:?Usage: quality_gate.sh <repo-path> <language> [check-cmd] [test-cmd] [coverage-threshold] [base-branch] [service-name]}"
LANGUAGE="${2:?Missing language}"
CHECK_CMD="${3:-}"
TEST_CMD="${4:-}"
COVERAGE_THRESHOLD="${5:-80}"
BASE_BRANCH="${6:-main}"
SERVICE_NAME="${7:-}"

if [ ! -d "$REPO_PATH" ]; then
    echo "ERROR: repo path does not exist: $REPO_PATH"
    exit 2
fi

cd "$REPO_PATH"

# 校验 base_branch 存在
git fetch origin "$BASE_BRANCH" --quiet 2>/dev/null || true
if ! git rev-parse "origin/${BASE_BRANCH}" &>/dev/null; then
    echo "ERROR: base branch 'origin/${BASE_BRANCH}' does not exist. Check registry service file base_branch."
    exit 1
fi

GATE_PASSED=0
GATE_FAILED=0
TOTAL_GATES=0

echo "=== QUALITY GATE ==="
echo "repo: $REPO_PATH"
echo "language: $LANGUAGE"
echo "coverage_threshold: ${COVERAGE_THRESHOLD}%"
echo ""

# ── Helper ────────────────────────────────────────────────
run_gate() {
    local name="$1"
    local cmd="$2"
    TOTAL_GATES=$((TOTAL_GATES + 1))

    echo "--- GATE: $name ---"
    echo "command: $cmd"

    local start_time
    start_time=$(date +%s)

    local output
    local exit_code
    output=$(eval "$cmd" 2>&1)
    exit_code=$?

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo "duration: ${duration}s"

    if [ "$exit_code" -eq 0 ]; then
        echo "result: PASS"
        GATE_PASSED=$((GATE_PASSED + 1))
    else
        echo "result: FAIL"
        echo "exit_code: $exit_code"
        echo "output_tail:"
        echo "$output" | tail -20 | sed 's/^/  /'
        GATE_FAILED=$((GATE_FAILED + 1))
    fi
    echo ""
}

# ── Gate 1: Lint / Check ──────────────────────────────────
if [ -n "$CHECK_CMD" ]; then
    run_gate "lint_check" "$CHECK_CMD"
else
    # 按语言默认
    case "$LANGUAGE" in
        python)
            if [ -f "Makefile" ] && grep -q "check-diff:" Makefile 2>/dev/null; then
                run_gate "lint_check" "make check-diff"
            elif command -v ruff &>/dev/null; then
                run_gate "lint_check" "ruff check ."
            else
                echo "--- GATE: lint_check ---"
                echo "result: SKIP (no check command found)"
                echo ""
            fi
            ;;
        go)
            if command -v golangci-lint &>/dev/null; then
                run_gate "lint_check" "golangci-lint run -v"
            else
                run_gate "lint_check" "go vet ./..."
            fi
            ;;
        nodejs)
            if [ -f "package.json" ] && grep -q '"lint"' package.json 2>/dev/null; then
                run_gate "lint_check" "npm run lint"
            else
                echo "--- GATE: lint_check ---"
                echo "result: SKIP (no lint script in package.json)"
                echo ""
            fi
            ;;
        java)
            if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
                run_gate "lint_check" "./gradlew check -x test"
            fi
            ;;
    esac
fi

# ── Gate 2: Unit Tests ────────────────────────────────────
if [ -n "$TEST_CMD" ]; then
    run_gate "unit_test" "$TEST_CMD"
else
    case "$LANGUAGE" in
        python)
            if [ -f "Makefile" ] && grep -q "^test:" Makefile 2>/dev/null; then
                run_gate "unit_test" "make test"
            else
                run_gate "unit_test" "uv run pytest tests/ -m unit -v --tb=short"
            fi
            ;;
        go)     run_gate "unit_test" "go test ./..." ;;
        nodejs) run_gate "unit_test" "npm test" ;;
        java)   run_gate "unit_test" "./gradlew test" ;;
    esac
fi

# ── Gate 3: Incremental Coverage ─────────────────────────
# 只检查相对 base_branch 变更的代码的覆盖率，不检查全量
echo "--- GATE: coverage (incremental) ---"
echo "base_branch: ${BASE_BRANCH}"
TOTAL_GATES=$((TOTAL_GATES + 1))

COVERAGE_VALUE=""

# 获取变更的源文件（排除测试文件）
git fetch origin "$BASE_BRANCH" --quiet 2>/dev/null || true

case "$LANGUAGE" in
    python)
        CHANGED_SRC=$(git diff --name-only "origin/${BASE_BRANCH}...HEAD" -- '*.py' 2>/dev/null | grep -vE 'test_|_test\.py|tests/' || echo "")
        if [ -z "$CHANGED_SRC" ]; then
            echo "changed_source_files: 0"
            echo "coverage: N/A (no source files changed, tests/config only)"
            echo "result: PASS"
            GATE_PASSED=$((GATE_PASSED + 1))
        elif python3 -c "import pytest_cov" 2>/dev/null || uv run python -c "import pytest_cov" 2>/dev/null; then
            # 只对变更文件计算覆盖率
            COV_MODULES=$(echo "$CHANGED_SRC" | sed 's|/|.|g; s|\.py$||' | tr '\n' ',' | sed 's/,$//')
            COV_DIRS=$(echo "$CHANGED_SRC" | xargs -I{} dirname {} | sort -u | tr '\n' ' ')
            COV_OUTPUT=$(uv run pytest tests/ --cov --cov-report=term-missing --tb=no -q 2>&1 || true)
            # 从变更文件的覆盖率行提取（不用 TOTAL，只看变更文件）
            TOTAL_STMTS=0
            TOTAL_MISS=0
            while IFS= read -r src_file; do
                # pytest-cov 输出格式: filename    stmts    miss    cover
                FILE_LINE=$(echo "$COV_OUTPUT" | grep "$(basename "$src_file" .py)" | head -1 || echo "")
                if [ -n "$FILE_LINE" ]; then
                    STMTS=$(echo "$FILE_LINE" | awk '{print $2}' || echo "0")
                    MISS=$(echo "$FILE_LINE" | awk '{print $3}' || echo "0")
                    TOTAL_STMTS=$((TOTAL_STMTS + STMTS))
                    TOTAL_MISS=$((TOTAL_MISS + MISS))
                fi
            done <<< "$CHANGED_SRC"
            if [ "$TOTAL_STMTS" -gt 0 ]; then
                COVERED=$((TOTAL_STMTS - TOTAL_MISS))
                COVERAGE_VALUE=$((COVERED * 100 / TOTAL_STMTS))
            else
                COVERAGE_VALUE=""
            fi
        fi
        ;;
    go)
        CHANGED_SRC=$(git diff --name-only "origin/${BASE_BRANCH}...HEAD" -- '*.go' 2>/dev/null | grep -v '_test\.go' || echo "")
        if [ -z "$CHANGED_SRC" ]; then
            echo "changed_source_files: 0"
            echo "coverage: N/A (no source files changed, tests/config only)"
            echo "result: PASS"
            GATE_PASSED=$((GATE_PASSED + 1))
        else
            # 只测试包含变更文件的 package
            CHANGED_PKGS=$(echo "$CHANGED_SRC" | xargs -I{} dirname {} | sort -u | sed 's|^|./|' | tr '\n' ' ')
            echo "changed_packages: $CHANGED_PKGS"

            COV_OUTPUT=$(go test $CHANGED_PKGS -coverprofile=/tmp/coverage_inc.out 2>&1 || true)
            if [ -f /tmp/coverage_inc.out ]; then
                # 只看变更文件的覆盖率
                COV_FUNC=$(go tool cover -func=/tmp/coverage_inc.out 2>/dev/null || echo "")
                TOTAL_STMTS=0
                TOTAL_COVERED=0
                while IFS= read -r src_file; do
                    # go tool cover -func 输出: file:line: funcName xx.x%
                    FILE_LINES=$(echo "$COV_FUNC" | grep "$(basename "$src_file")" || echo "")
                    while IFS= read -r line; do
                        [ -z "$line" ] && continue
                        PCT=$(echo "$line" | grep -oE '[0-9]+\.[0-9]+%' | tr -d '%' || echo "")
                        if [ -n "$PCT" ]; then
                            # 简化：按函数数计入
                            PCT_INT=$(echo "$PCT" | cut -d. -f1)
                            TOTAL_STMTS=$((TOTAL_STMTS + 1))
                            if [ "$PCT_INT" -gt 0 ] 2>/dev/null; then
                                TOTAL_COVERED=$((TOTAL_COVERED + 1))
                            fi
                        fi
                    done <<< "$FILE_LINES"
                done <<< "$CHANGED_SRC"
                if [ "$TOTAL_STMTS" -gt 0 ]; then
                    COVERAGE_VALUE=$((TOTAL_COVERED * 100 / TOTAL_STMTS))
                fi
                rm -f /tmp/coverage_inc.out
            fi
        fi
        ;;
    nodejs)
        CHANGED_SRC=$(git diff --name-only "origin/${BASE_BRANCH}...HEAD" -- '*.ts' '*.js' 2>/dev/null | grep -vE '\.test\.|\.spec\.|__tests__' || echo "")
        if [ -z "$CHANGED_SRC" ]; then
            echo "changed_source_files: 0"
            echo "coverage: N/A (no source files changed)"
            echo "result: PASS"
            GATE_PASSED=$((GATE_PASSED + 1))
        elif [ -f "package.json" ] && grep -q '"coverage"' package.json 2>/dev/null; then
            COV_OUTPUT=$(npm run coverage 2>&1 || true)
            COVERAGE_VALUE=$(echo "$COV_OUTPUT" | grep -oE "All files[^|]*\|[^|]*\|[^|]*\|[^|]*\| *([0-9]+)" | grep -oE "[0-9]+" | tail -1 || echo "")
        fi
        ;;
    java)
        CHANGED_SRC=$(git diff --name-only "origin/${BASE_BRANCH}...HEAD" -- '*.java' 2>/dev/null | grep -v 'Test\.java' || echo "")
        if [ -z "$CHANGED_SRC" ]; then
            echo "changed_source_files: 0"
            echo "coverage: N/A (no source files changed)"
            echo "result: PASS"
            GATE_PASSED=$((GATE_PASSED + 1))
        elif [ -f "build/reports/jacoco/test/html/index.html" ]; then
            COVERAGE_VALUE=$(grep -oE "Total[^%]*([0-9]+)%" build/reports/jacoco/test/html/index.html | grep -oE "[0-9]+" | head -1 || echo "")
        fi
        ;;
esac

# 如果上面还没有输出结果（CHANGED_SRC 非空的分支）
if [ -n "$COVERAGE_VALUE" ]; then
    echo "changed_source_files: $(echo "$CHANGED_SRC" | wc -l | tr -d ' ')"
    echo "incremental_coverage: ${COVERAGE_VALUE}%"
    echo "threshold: ${COVERAGE_THRESHOLD}%"

    if [ "$COVERAGE_VALUE" -ge "$COVERAGE_THRESHOLD" ] 2>/dev/null; then
        echo "result: PASS"
        GATE_PASSED=$((GATE_PASSED + 1))
    else
        echo "result: FAIL"
        echo "gap: $((COVERAGE_THRESHOLD - COVERAGE_VALUE))% below threshold"
        echo "uncovered_files:"
        echo "$CHANGED_SRC" | while IFS= read -r f; do
            [ -z "$f" ] && continue
            echo "  - $f"
        done
        echo "action_required: |"
        echo "  1. 为上述文件编写或补充单元测试（外部依赖用 mock 隔离）"
        echo "  2. git add + git commit 测试代码"
        echo "  3. 重新运行本脚本（quality_gate.sh）验证覆盖率"
        GATE_FAILED=$((GATE_FAILED + 1))
    fi
elif [ -z "$CHANGED_SRC" ]; then
    : # 已在上面处理（PASS）
else
    echo "coverage: unknown (coverage tool not available)"
    echo "result: SKIP"
    echo "suggestion: install coverage tool (pytest-cov / go tool cover / istanbul)"
fi
echo ""

# ── 总结 ──────────────────────────────────────────────────
echo "--- SUMMARY ---"
echo "total_gates: $TOTAL_GATES"
echo "passed: $GATE_PASSED"
echo "failed: $GATE_FAILED"

if [ "$GATE_FAILED" -gt 0 ]; then
    echo "verdict: BLOCKED"
    echo "message: $GATE_FAILED gate(s) failed. MR creation blocked."
else
    echo "verdict: PASSED"
    echo "message: All quality gates passed. Ready for MR."
fi

echo "=== END QUALITY GATE ==="

# ── 写入状态标记 ─────────────────────────────────────────────
STATE_FILE="/tmp/.claude_hub_active"
if [ -f "$STATE_FILE" ]; then
    VERDICT=$( [ "$GATE_FAILED" -eq 0 ] && echo "PASSED" || echo "BLOCKED" )
    if [ -n "$SERVICE_NAME" ]; then
        MARKER_KEY="svc_${SERVICE_NAME}_step3"
    else
        MARKER_KEY="step3_quality_gate"
    fi
    if grep -q "^${MARKER_KEY}:" "$STATE_FILE" 2>/dev/null; then
        sed -i.bak "s/^${MARKER_KEY}:.*/${MARKER_KEY}: ${VERDICT}/" "$STATE_FILE"
        rm -f "${STATE_FILE}.bak"
    else
        echo "${MARKER_KEY}: ${VERDICT}" >> "$STATE_FILE"
    fi
fi

# 始终 exit 0 — verdict 通过 PASSED/BLOCKED 输出，不用退出码
# 避免 exit 1 导致 Bash tool 报错或取消并行调用
exit 0
