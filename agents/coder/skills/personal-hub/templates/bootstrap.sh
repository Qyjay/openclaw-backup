#!/bin/bash
# bootstrap.sh — 给新的服务仓库安装 Harness 基础设施
#
# 用法:
#   bash bootstrap.sh --name <service-name> --language <python|nodejs|java|go>
#
# 效果:
#   1. 创建 CLAUDE.md（目录式导航）
#   2. 创建 docs/architecture.md, docs/golden-rules.md
#   3. 创建 .claude/skills/ 基础 skill 集
#   4. 创建 Makefile targets（如果是 Python）
#   5. 输出需要手动补充的内容
#
set -euo pipefail

# ── 参数解析 ────────────────────────────────────────────────
SERVICE_NAME=""
LANGUAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --name) SERVICE_NAME="$2"; shift 2 ;;
        --language) LANGUAGE="$2"; shift 2 ;;
        --help|-h)
            echo "用法: bash bootstrap.sh --name <service-name> --language <python|nodejs|java|go>"
            exit 0 ;;
        *) echo "未知参数: $1"; exit 1 ;;
    esac
done

if [ -z "$SERVICE_NAME" ] || [ -z "$LANGUAGE" ]; then
    echo "Error: --name 和 --language 参数必填"
    echo "用法: bash bootstrap.sh --name <service-name> --language <python|nodejs|java|go>"
    exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
echo "=== Harness Bootstrap ==="
echo "服务: ${SERVICE_NAME}"
echo "语言: ${LANGUAGE}"
echo "仓库: ${REPO_ROOT}"
echo ""

# ── 语言相关配置 ────────────────────────────────────────────
case $LANGUAGE in
    python)
        CHECK_CMD="make check-diff"
        TEST_CMD="make test"
        FORMAT_CMD="uv run ruff format ."
        INSTALL_CMD="uv sync"
        ;;
    nodejs)
        CHECK_CMD="npm run lint"
        TEST_CMD="npm test"
        FORMAT_CMD="npm run format"
        INSTALL_CMD="npm install"
        ;;
    java)
        CHECK_CMD="./gradlew check"
        TEST_CMD="./gradlew test"
        FORMAT_CMD="./gradlew spotlessApply"
        INSTALL_CMD="./gradlew build -x test"
        ;;
    go)
        CHECK_CMD="go vet ./..."
        TEST_CMD="go test ./..."
        FORMAT_CMD="gofmt -w ."
        INSTALL_CMD="go mod download"
        ;;
    *)
        echo "Error: 不支持的语言 ${LANGUAGE}，支持: python, nodejs, java, go"
        exit 1
        ;;
esac

# ── 创建 CLAUDE.md ──────────────────────────────────────────
if [ ! -f "${REPO_ROOT}/CLAUDE.md" ]; then
    cat > "${REPO_ROOT}/CLAUDE.md" << CLAUDEMD
# ${SERVICE_NAME}

## Quick Start

\`\`\`bash
${INSTALL_CMD}    # 安装依赖
${TEST_CMD}       # 运行测试
${CHECK_CMD}      # 代码检查
\`\`\`

## Navigation Map

| What | Where |
|------|-------|
| Architecture | \`docs/architecture.md\` |
| Code rules | \`docs/golden-rules.md\` |
| Core modules | TODO: 填入核心模块路径 |
| Tests | \`tests/\` |
| Config | TODO: 填入配置文件路径 |

## Code Style

- TODO: 补充本仓库的代码规范

## Git Workflow

- Main branch: \`main\`
- Pre-commit: \`${CHECK_CMD}\`
CLAUDEMD
    echo "Created: CLAUDE.md"
else
    echo "Skipped: CLAUDE.md (already exists)"
fi

# ── 创建 docs/ ──────────────────────────────────────────────
mkdir -p "${REPO_ROOT}/docs"

if [ ! -f "${REPO_ROOT}/docs/architecture.md" ]; then
    cat > "${REPO_ROOT}/docs/architecture.md" << 'ARCH'
# Architecture

TODO: 描述本服务的模块结构和依赖关系。

## Module Map

```
src/
├── TODO
```

## Layering Rules

TODO: 描述模块间的依赖方向约束。
ARCH
    echo "Created: docs/architecture.md"
fi

if [ ! -f "${REPO_ROOT}/docs/golden-rules.md" ]; then
    cat > "${REPO_ROOT}/docs/golden-rules.md" << 'RULES'
# Golden Rules

本仓库的代码不变式。违反这些规则的代码不应通过 review。

## 1. TODO

描述第一条规则。

## Escalation Protocol

以下情况必须交给人类处理：
- 涉及安全相关代码
- 架构变更
- 大规模删除或重构
- 需求不明确
RULES
    echo "Created: docs/golden-rules.md"
fi

# ── 创建 .claude/skills/ ────────────────────────────────────
mkdir -p "${REPO_ROOT}/.claude/skills/fix-bug"
mkdir -p "${REPO_ROOT}/.claude/skills/new-feature"

if [ ! -f "${REPO_ROOT}/.claude/skills/fix-bug/SKILL.md" ]; then
    cat > "${REPO_ROOT}/.claude/skills/fix-bug/SKILL.md" << FIXBUG
---
name: fix-bug
description: "Bug 修复工作流。当用户描述 bug、error、crash、500 或要求修复时触发。"
---

# Bug Fix Workflow

1. **理解问题**：读相关代码和日志，定位根因
2. **写失败测试**：先写一个能重现 bug 的测试
3. **修复**：最小化修改，只改必要的代码
4. **验证**：运行 \`${CHECK_CMD}\` 确保通过
5. **提交**：commit message 说清楚修了什么和为什么
FIXBUG
    echo "Created: .claude/skills/fix-bug/SKILL.md"
fi

if [ ! -f "${REPO_ROOT}/.claude/skills/new-feature/SKILL.md" ]; then
    cat > "${REPO_ROOT}/.claude/skills/new-feature/SKILL.md" << FEATURE
---
name: new-feature
description: "新功能开发工作流。当用户要求添加、实现、构建新功能时触发。"
---

# New Feature Workflow

1. **理解需求**：确认要做什么，边界在哪
2. **设计**：确定改动范围，参考 docs/architecture.md
3. **实现**：遵循仓库代码规范
4. **测试**：写单元测试覆盖核心逻辑
5. **验证**：运行 \`${CHECK_CMD}\` 确保通过
6. **提交**：commit message 说清楚加了什么功能
FEATURE
    echo "Created: .claude/skills/new-feature/SKILL.md"
fi

# ── 创建 .gitlab-ci.yml 泳道部署 snippet ────────────────────
echo ""
echo "=== Bootstrap 完成 ==="
echo ""
echo "已创建的文件:"
echo "  - CLAUDE.md"
echo "  - docs/architecture.md"
echo "  - docs/golden-rules.md"
echo "  - .claude/skills/fix-bug/SKILL.md"
echo "  - .claude/skills/new-feature/SKILL.md"
echo ""
echo "=== 需要手动完成 ==="
echo ""
echo "1. 编辑 CLAUDE.md — 补充 Navigation Map 和 Code Style"
echo "2. 编辑 docs/architecture.md — 描述模块结构"
echo "3. 编辑 docs/golden-rules.md — 添加代码规则"
echo "4. 确认 .gitlab-ci.yml 中有 test/lane/* 泳道部署规则"
echo "5. 运行 /hub-init 注册本服务到 harness-hub-registry"
echo ""
