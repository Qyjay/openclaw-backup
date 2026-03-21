#!/bin/bash
# hub_stop_hook.sh — Stop hook，检查 hub 流程是否完成
#
# 个人版：无 registry 依赖，从状态文件直接读取服务信息。
set -uo pipefail

INPUT=$(cat)

STATE_FILE="/tmp/.claude_hub_active"
if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

REQ_ID=$(grep "^req_id:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2-)
BRANCH=$(grep "^branch:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2-)

if [ -z "$BRANCH" ]; then
    exit 0
fi

# ── 重试计数器（防死循环） ───────────────────────────────────
MAX_RETRIES=20
RETRY_COUNT=$(grep "^retry_count:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- || echo "0")
RETRY_COUNT=$(echo "$RETRY_COUNT" | tr -d '[:space:]')
RETRY_COUNT=${RETRY_COUNT:-0}

if [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; then
    echo "Hub Stop hook: 已阻断 ${RETRY_COUNT} 次，强制放行。" >&2
    rm -f "$STATE_FILE"
    exit 0
fi

LAST_MSG=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('last_assistant_message', ''))" 2>/dev/null || echo "")

HAS_REPORT="false"
if echo "$LAST_MSG" | grep -q "Hub 执行报告"; then
    HAS_REPORT="true"
fi

# ── 读取服务列表 ──────────────────────────────────────────────
SERVICES=$(grep "^services:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")

# ── 完成条件检查 ──────────────────────────────────────────────
MISSING=""

check_service() {
    local svc="$1"
    local prefix="svc_${svc}"

    local svc_repo svc_base
    svc_repo=$(grep "^${prefix}_repo:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
    svc_base=$(grep "^${prefix}_base:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "main")
    svc_base=${svc_base:-main}

    if [ -n "$svc_repo" ] && [ -d "$svc_repo" ]; then
        (
            cd "$svc_repo"
            COMMIT_COUNT=$(git rev-list --count "origin/${svc_base}..HEAD" 2>/dev/null || echo 0)
            COMMIT_COUNT=$(echo "$COMMIT_COUNT" | tr -d '[:space:]')
            DIRTY=$(git status --porcelain 2>/dev/null | head -1)
            if [ -n "$DIRTY" ]; then
                echo "- [${svc}] 工作区有未提交的变更（Step 2 要求 commit）"
            fi
            if [ "${COMMIT_COUNT:-0}" -eq 0 ]; then
                echo "- [${svc}] 分支上没有 commit（Step 2 要求 commit 代码和测试）"
            fi
        )
    fi

    local step3 step4 step5 step6
    step3=$(grep "^${prefix}_step3:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
    step4=$(grep "^${prefix}_step4:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
    step5=$(grep "^${prefix}_step5:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
    step6=$(grep "^${prefix}_step6:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")

    if [ "$step3" = "BLOCKED" ]; then
        echo "- [${svc}] 质量门禁未通过（verdict: BLOCKED）（Step 3）"
    elif [ "$step3" != "PASSED" ]; then
        echo "- [${svc}] 未运行质量门禁脚本 quality_gate.sh（Step 3）"
    fi
    if [ "$step4" = "NOT_READY" ]; then
        echo "- [${svc}] PR 就绪检查未通过（Step 4）"
    elif [ "$step4" != "READY" ]; then
        echo "- [${svc}] 未运行 pre_pr_check.sh（Step 4）"
    fi
    if [ -z "$step5" ]; then
        echo "- [${svc}] 未运行 create_pr.sh（Step 5）"
    fi
    if [ -z "$step6" ]; then
        echo "- [${svc}] 未运行 detect_drift.sh（Step 6）"
    fi
}

if [ -n "$SERVICES" ]; then
    IFS=',' read -ra SVC_ARRAY <<< "$SERVICES"
    for svc in "${SVC_ARRAY[@]}"; do
        svc=$(echo "$svc" | tr -d '[:space:]')
        [ -z "$svc" ] && continue
        SVC_MISSING=$(check_service "$svc")
        if [ -n "$SVC_MISSING" ]; then
            MISSING="${MISSING}\n${SVC_MISSING}"
        fi
    done
else
    # 单服务兼容模式
    REPO_PATH=$(grep "^repo:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2-)
    BASE_BRANCH=$(grep "^base_branch:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- || echo "main")
    BASE_BRANCH=$(echo "$BASE_BRANCH" | tr -d '[:space:]')
    BASE_BRANCH=${BASE_BRANCH:-main}

    if [ -n "$REPO_PATH" ] && [ -d "$REPO_PATH" ]; then
        cd "$REPO_PATH"
        COMMIT_COUNT=$(git rev-list --count "origin/${BASE_BRANCH}..HEAD" 2>/dev/null || echo 0)
        DIRTY=$(git status --porcelain 2>/dev/null | head -1)
        [ -n "$DIRTY" ] && MISSING="${MISSING}\n- 工作区有未提交变更"
        [ "${COMMIT_COUNT:-0}" -eq 0 ] && MISSING="${MISSING}\n- 无 commit"
    fi

    STEP3=$(grep "^step3_quality_gate:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
    [ "$STEP3" = "BLOCKED" ] && MISSING="${MISSING}\n- 质量门禁 BLOCKED（Step 3）"
    [ "$STEP3" != "PASSED" ] && [ "$STEP3" != "BLOCKED" ] && MISSING="${MISSING}\n- 未运行 quality_gate.sh（Step 3）"

    STEP4=$(grep "^step4_pre_pr:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
    [ "$STEP4" = "NOT_READY" ] && MISSING="${MISSING}\n- PR 就绪检查 NOT_READY（Step 4）"
    [ "$STEP4" != "READY" ] && [ "$STEP4" != "NOT_READY" ] && MISSING="${MISSING}\n- 未运行 pre_pr_check.sh（Step 4）"

    STEP5=$(grep "^step5_pr_created:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
    [ -z "$STEP5" ] && MISSING="${MISSING}\n- 未运行 create_pr.sh（Step 5）"

    STEP6=$(grep "^step6_drift_checked:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
    [ -z "$STEP6" ] && MISSING="${MISSING}\n- 未运行 detect_drift.sh（Step 6）"
fi

# ── 判定 ─────────────────────────────────────────────────────
increment_retry() {
    NEW_COUNT=$((RETRY_COUNT + 1))
    if grep -q "^retry_count:" "$STATE_FILE" 2>/dev/null; then
        sed -i.bak "s/^retry_count:.*/retry_count: ${NEW_COUNT}/" "$STATE_FILE"
        rm -f "${STATE_FILE}.bak"
    else
        echo "retry_count: ${NEW_COUNT}" >> "$STATE_FILE"
    fi
    echo "$NEW_COUNT"
}

if [ -n "$MISSING" ]; then
    NEW_COUNT=$(increment_retry)

    HOOK_DIR="$(cd -P "$(dirname "$0")" 2>/dev/null && pwd)"
    HUB_ROOT="$(dirname "$HOOK_DIR")"
    SCRIPTS_DIR="${HUB_ROOT}/scripts"

    # 生成下一步命令提示
    NEXT_CMD=""
    if [ -n "$SERVICES" ]; then
        IFS=',' read -ra SVC_ARRAY2 <<< "$SERVICES"
        for svc in "${SVC_ARRAY2[@]}"; do
            svc=$(echo "$svc" | tr -d '[:space:]')
            [ -z "$svc" ] && continue
            [ -n "$NEXT_CMD" ] && break

            s3=$(grep "^svc_${svc}_step3:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
            s4=$(grep "^svc_${svc}_step4:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
            s5=$(grep "^svc_${svc}_step5:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
            s6=$(grep "^svc_${svc}_step6:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
            svc_repo=$(grep "^svc_${svc}_repo:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "")
            svc_base=$(grep "^svc_${svc}_base:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- | tr -d '[:space:]' || echo "main")

            if [ "$s3" = "BLOCKED" ]; then
                NEXT_CMD="质量门禁 BLOCKED。修复问题后重跑：bash ${SCRIPTS_DIR}/quality_gate.sh ${svc_repo} <lang> <check> <test> 80 ${svc_base} ${svc}"
            elif [ "$s3" != "PASSED" ]; then
                NEXT_CMD="bash ${SCRIPTS_DIR}/quality_gate.sh ${svc_repo} <lang> <check> <test> 80 ${svc_base} ${svc}"
            elif [ "$s4" != "READY" ]; then
                NEXT_CMD="bash ${SCRIPTS_DIR}/pre_pr_check.sh ${svc_repo} ${BRANCH} <lang> <format> ${svc_base} ${svc}"
            elif [ -z "$s5" ]; then
                NEXT_CMD="bash ${SCRIPTS_DIR}/create_pr.sh ${svc_repo} ${BRANCH} ${REQ_ID} <title> <desc> '' ${svc_base} ${svc}"
            elif [ -z "$s6" ]; then
                NEXT_CMD="bash ${SCRIPTS_DIR}/detect_drift.sh ${svc} ${svc_repo}"
            fi
        done
    fi

    if [ -n "$NEXT_CMD" ]; then
        echo -e "STOP BLOCKED（${NEW_COUNT}/${MAX_RETRIES}）。缺失：${MISSING}\n\n下一步：\n${NEXT_CMD}" >&2
    else
        echo -e "STOP BLOCKED（${NEW_COUNT}/${MAX_RETRIES}）。缺失：${MISSING}\n\n读 SKILL.md Step 3-6 执行缺失脚本。" >&2
    fi
    exit 2
fi

if [ "$HAS_REPORT" = "true" ]; then
    rm -f "$STATE_FILE"
    exit 0
fi

NEW_COUNT=$(increment_retry)
echo "所有检查已通过，但没有输出「=== Hub 执行报告 ===」。请输出 Step 7 汇总报告。" >&2
exit 2
