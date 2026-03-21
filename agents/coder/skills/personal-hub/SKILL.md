---
name: hub
description: |
  开发需求的统一入口。当用户描述任何开发任务时使用此 skill。
  包括但不限于：新功能开发、bug 修复、重构、添加逻辑、修改接口等。

  触发关键词（任意匹配即触发）：
  - 功能描述："加上XX逻辑"、"实现XX功能"、"添加XX"、"支持XX"
  - Bug 修复："修复"、"fix"、"bug"、"报错"、"异常"
  - 重构："重构"、"拆分"、"优化"、"迁移"
  - 直接触发："/hub"、"hub"

  不触发的场景：
  - 纯粹的代码阅读/理解
  - 文档查询
  - review
argument-hint: "[需求描述]"
---

# Personal Harness Hub

你是 Harness Hub 编排器（个人版）。开发者给你一个需求描述，你负责**从头到尾完成以下所有步骤**。

**⚠️ 强制要求：你必须按顺序执行全部 7 个 Step，直到输出 Step 7 的汇总报告才算完成。写完代码不是完成，只有输出最终报告才是完成。**

**⚠️ 禁止绕过脚本。** 脚本失败时，你必须修复问题并重跑，或标记 FAILED 跳到 Step 7 报告。

**⚠️ 机械化约束（PreToolUse hook 强制执行）：**
- **禁止删除测试文件**
- **禁止手动 git push**，必须通过 create_pr.sh
- 这些不是建议而是硬约束，命令会直接报错

**⚠️ 如果你收到 Stop hook 反馈（「Hub 流程未完成」）：**
- 反馈消息中包含具体的命令，直接执行
- 不要再输出报告，不要解释，直接执行

## 完成清单

```
[ ] Step 1: 需求分析 — 检测项目、生成任务描述
[ ] Step 2: 执行开发 — 创建分支、编写代码、编写单测、lint、测试、格式化、commit
[ ] Step 3: 质量门禁 — 运行 quality_gate.sh，全部 PASSED
[ ] Step 4: PR 就绪检查 — 运行 pre_pr_check.sh，verdict: READY
[ ] Step 5: 提交 PR — 运行 create_pr.sh，获得 PR URL
[ ] Step 6: 同步文档 — 运行 detect_drift.sh，修复漂移
[ ] Step 7: 汇总报告 — 输出最终报告（这是终点）
```

---

## 工作流程

### Step 1: 需求分析

1. **检测当前项目**：运行检测脚本了解项目信息

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/detect_repo.sh $(pwd)
```

2. **读取 CLAUDE.md**：如果项目有 CLAUDE.md，读它了解项目结构和规范
3. **理解需求**：分析用户的需求描述，生成代码级别的任务描述
4. **生成需求 ID**：格式 `req-<6位随机字符>`
5. **安装 hooks**（首次自动安装，后续幂等）：

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/install_hooks.sh ${CLAUDE_SKILL_DIR}
```

6. **获取项目信息**（从 detect_repo.sh 输出中提取）：
   - `language`、`build_system`、`framework`
   - `commands.check`、`commands.test`、`commands.format`
   - `default_branch`（作为 base_branch）
   - `service_name`（仓库目录名）

7. **激活流程追踪**：

```bash
SERVICE_NAME=<从 detect_repo 获取>
REPO_PATH=$(pwd)
BASE_BRANCH=<从 detect_repo 获取的 default_branch>

cat > /tmp/.claude_hub_active << EOF
req_id: <req-id>
branch: feat/<req-id>
started: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
services: ${SERVICE_NAME}
svc_${SERVICE_NAME}_repo: ${REPO_PATH}
svc_${SERVICE_NAME}_base: ${BASE_BRANCH}
EOF
```

输出格式（向用户确认）：

```
需求分析结果：
- 需求 ID: req-xxxxxx
- 项目: <service_name> (<language> / <framework>)
- 分支: feat/req-xxxxxx
- 任务: <具体代码级任务描述>
```

**→ 确认后立即执行 Step 2，不要停。**

### Step 2: 执行开发

1. **创建工作分支**：`git checkout -b feat/<req-id> origin/<base_branch>`
2. **读 CLAUDE.md**（如果存在）：了解仓库结构、代码规范、测试约定
3. **编写代码**：实现需求功能
4. **编写单测**（不可跳过）：
   - 查找仓库中已有测试文件，模仿风格
   - 新功能：覆盖核心逻辑和边界条件
   - Bug 修复：先写重现 bug 的失败测试，再修复
   - **必须用 mock 隔离外部依赖**
5. **运行 lint**：执行 `<commands.check>`
6. **运行单测**：执行 `<commands.test>`
7. **失败则修复**：最多 20 轮
8. **格式化**：执行 `<commands.format>`
9. **commit**：`git add <files> && git commit`，代码和测试同一个 commit

**⚠️ Step 2 必须包含「编写单测」和「commit」。只写代码不算完成。**

**→ commit 完成后立即执行 Step 3，不要停。**

### Step 3: 质量门禁

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/quality_gate.sh \
  <repo-path> \
  <language> \
  "<commands.check>" \
  "<commands.test>" \
  <coverage_threshold> \
  <base_branch> \
  <service_name>
```

- `coverage_threshold` 默认 80
- 三道门禁：lint + 单测 + 增量覆盖率
- `verdict: BLOCKED` → 修复后重跑，最多 20 轮
- `verdict: PASSED` → 继续 Step 4

**→ PASSED 后立即执行 Step 4，不要停。**

### Step 4: PR 就绪检查

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/pre_pr_check.sh \
  <repo-path> \
  <branch> \
  <language> \
  "<commands.format>" \
  <base_branch> \
  <service_name>
```

- `verdict: NOT_READY` → 修复后重新检查
- `verdict: READY` → 继续 Step 5

**→ READY 后立即执行 Step 5，不要停。**

### Step 5: 提交 PR

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/create_pr.sh \
  <repo-path> \
  <branch> \
  <req-id> \
  "<任务简述>" \
  "<改动摘要>" \
  "" \
  <base_branch> \
  <service_name>
```

脚本自动：push 分支 → `gh` 可用时创建 GitHub PR → 否则输出链接。
**禁止手动 git push**（PreToolUse hook 物理阻断），必须通过此脚本。

**→ PR 创建成功后立即执行 Step 6，不要停。**

### Step 6: 同步 Harness 文档

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/detect_drift.sh <service-name> <repo-path>
```

- `drift_found: false` → 无漂移，跳过
- `drift_found: true` → 根据报告增量修复文档

修复后更新基线：

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/update_sync_state.sh <repo-path>
```

**→ 立即执行 Step 7 输出最终报告。**

### Step 7: 汇总报告（终点）

```
=== Hub 执行报告 ===
需求 ID: req-xxxxxx
需求描述: <原始需求>
状态: COMPLETED / PARTIAL / FAILED

项目: <service_name>
分支: feat/req-xxxxxx
PR: <url>

质量门禁: PASSED
  - lint: ✓
  - test: ✓
  - coverage: XX%

改动文件:
  - <file list>

下一步:
- [ ] Review PR
- [ ] 合并
```

**状态定义：**
- **COMPLETED**：全部 7 个 Step 通过，PR 已创建
- **PARTIAL**：代码已完成但某些门禁失败，需人工介入
- **FAILED**：关键步骤失败

---

## 特殊场景

### 新项目（无 git 历史）

如果当前目录不是 git 仓库：
1. `git init`
2. 创建初始 commit
3. 正常走流程（base_branch 用 `main`）
4. Step 5 时如果没有 remote，提示用户先创建 GitHub repo 并 `git remote add origin`

### 需求不明确

向用户提问，不要猜测。

---

## 迭代指南

| 问题 | 改什么 |
|------|--------|
| Agent 在某个仓库写代码质量差 | 改该仓库的 `CLAUDE.md` |
| 编排流程有问题 | 改本文件 `SKILL.md` |
| 质量门禁太松/太严 | 改 `quality_gate.sh` 或 coverage_threshold |
