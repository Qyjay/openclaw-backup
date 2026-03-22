---
name: hub-init
description: |
  初始化当前项目的 Harness 环境。
  自动检测项目信息，深入阅读源代码生成架构文档。

  触发场景：
  - "初始化 harness"、"hub init"
  - "给这个项目装 harness"
  - "/hub-init"
argument-hint: "[项目名（可选，默认用目录名）]"
---

# Hub Init — 项目 Harness 初始化

在当前项目中生成 Harness 基础设施。一个项目只需跑一次。

## Phase 1: 检测项目信息

```bash
bash ${CLAUDE_SKILL_DIR}/../../scripts/detect_repo.sh $(pwd)
```

解析脚本输出，作为后续步骤的输入。

---

## Phase 2: 深度代码阅读

**核心步骤，不能跳过。** 必须真正阅读源代码来理解架构。

### 2.1 目录结构扫描

使用 Phase 1 输出的 `directory_structure`。

### 2.2 入口文件阅读

使用 Phase 1 输出的 `entry_files` 列表，逐个阅读。追踪：
- 引入了哪些模块/包
- 注册了哪些路由/handler
- 依赖了哪些外部服务

### 2.3 核心模块阅读

对每个核心目录：
1. 读取关键文件（model 定义、service 接口、handler 入口）
2. 理解模块职责
3. 梳理模块间调用关系

### 2.4 配置和依赖

读取配置文件和依赖声明，了解外部依赖。

---

## Phase 3: 向用户确认

展示检测到的信息和架构理解：

```
=== 项目检测结果 ===

项目名:     <name>
路径:       <path>
语言:       <language> (<framework>)

检测到的命令:
  check:    <cmd>
  test:     <cmd>
  format:   <cmd>
  install:  <cmd>

架构理解:
  入口:     <entry point>
  核心模块: <module list>
  分层结构: <e.g. handler → service → dal → model>
  外部依赖: <databases, caches, other services>

请确认以上信息是否正确？
```

---

## Phase 4: 生成 Harness 文件

**已存在的文件不覆盖**。

### 4.1 CLAUDE.md

基于 Phase 2 的代码阅读生成，不留 TODO。包含：
- **Quick Start**：真实可用的命令
- **Navigation Map**：实际存在的核心目录和文件
- **Code Style**：从代码观察到的风格
- **Git Workflow**：主分支名、分支约定

### 4.2 docs/architecture.md

基于代码阅读结果，包含：
- **Overview**：一句话服务描述
- **Module Map**：ASCII 树形图 + 职责
- **Layering Rules**：模块依赖方向
- **Data Flow**：核心请求路径
- **External Dependencies**：外部服务和中间件

### 4.3 docs/golden-rules.md

从代码中观察到的规范和约束。

### 4.4 .claude/skills/

创建 `fix-bug` 和 `new-feature` skill，使用检测到的实际命令。

### 4.5 安装 Hub hooks

```bash
bash ${CLAUDE_SKILL_DIR}/../../scripts/install_hooks.sh ${CLAUDE_SKILL_DIR}/../..
```

---

## Phase 5: 写入同步基线

```bash
bash ${CLAUDE_SKILL_DIR}/../../scripts/update_sync_state.sh $(pwd)
```

---

## Phase 6: 汇总

```
=== Hub Init 完成 ===

生成的文件:
  ✓ CLAUDE.md
  ✓ docs/architecture.md
  ✓ docs/golden-rules.md
  ✓ .claude/skills/fix-bug/SKILL.md
  ✓ .claude/skills/new-feature/SKILL.md
  - 已跳过 (已存在): <list>

同步基线:
  docs/harness-sync-state.yaml → <commit-hash>

现在可以使用 /hub 开发需求了。
```
