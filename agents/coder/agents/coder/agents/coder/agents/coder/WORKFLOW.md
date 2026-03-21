# 🏭 Silvana 项目开发工作流 — 生产级指南

> Master 说需求 → Silvana 编排一切 → Claude Code 执行 → 代码交付
> 
> **核心 Skill**：PIV + Mini-PIV + PRD + Agentic Coding + Code Review

---

## 📊 决策树：该用哪条流水线？

```
Master 提出需求
    │
    ├── 一句话能说清、改动 < 5 个文件
    │   → 🟢 直接模式：Silvana 自己用 edit/exec 完成
    │
    ├── 单个功能、不需要多阶段
    │   → 🟡 Mini-PIV 模式：对话 → 研究 → 执行 → 验证
    │
    ├── 中型功能、需要 PRD 管理
    │   → 🟠 PIV 模式：PRD → PRP → 多阶段执行 → 验证
    │
    └── 大型项目、前后端分离、多模块并行
        → 🔴 全栈编排模式：PRD → 拆分前后端 → Claude Code ACP 并行 → 集成
```

---

## 🟢 直接模式（< 5 分钟）

**适用**：改个 bug、加个配置、小调整

```
Master: "把登录页的按钮改成蓝色"
Silvana: 直接 read → edit → 完成
```

不需要任何 skill，Silvana 自己搞定。

---

## 🟡 Mini-PIV 模式（15-60 分钟）

**适用**：单个功能、不需要写 PRD

### 流程

```
Step 1: Discovery（Silvana 和 Master 对话）
  ├── 功能做什么？
  ├── 在哪些文件/模块里？
  ├── 用什么技术栈/库？
  ├── "完成"的标准是什么？
  └── 什么不做？

Step 2: Research & PRP（sub-agent）
  ├── 分析现有代码库
  └── 生成 PRP（项目实现计划）

Step 3: Execute（sub-agent 或 Claude Code ACP）
  └── 按 PRP 实现代码

Step 4: Validate（sub-agent）
  ├── PASS → commit
  ├── GAPS_FOUND → 进入 Debug Loop
  └── HUMAN_NEEDED → 问 Master

Step 5: Debug Loop（最多 3 轮）
  └── 修复 → 重新验证

Step 6: Commit
  └── feat(mini): implement {feature-name}
```

### 触发方式

对 Silvana 说：
> "帮我做一个 XXX 功能"（Silvana 自动判断走 Mini-PIV）

或明确指定：
> "/mini-piv user-auth ~/Projects/my-app"

---

## 🟠 PIV 模式（1-4 小时）

**适用**：中型功能、需要分阶段交付

### 流程

```
Step 0: 写 PRD（Silvana 或 PRD skill）
  ├── 拆分 User Stories
  ├── 定义 Acceptance Criteria
  └── 保存到 PROJECT/PRDs/feature-name.md

Step 1-N: 每个 Phase 循环
  ├── 1. 分析代码库 + 生成 PRP
  ├── 2. Executor 实现代码
  ├── 3. Validator 验证
  ├── 4. Debugger 修复（如需要，最多 3 轮）
  └── 5. Commit + 更新 WORKFLOW.md

完成所有 Phase → 交付
```

### PRD 格式（prd.json）

```json
{
  "project": "TaskManager",
  "branchName": "feat/task-manager",
  "description": "任务管理系统",
  "userStories": [
    {
      "id": "US-001",
      "title": "数据库 schema 设计",
      "description": "作为开发者，需要任务表的数据模型",
      "acceptanceCriteria": [
        "创建 tasks 表：id, title, status, priority, created_at",
        "Migration 可成功运行",
        "Typecheck 通过"
      ],
      "priority": 1,
      "passes": false
    },
    {
      "id": "US-002",
      "title": "CRUD API",
      "description": "作为用户，可以增删改查任务",
      "acceptanceCriteria": [
        "GET /api/tasks 返回任务列表",
        "POST /api/tasks 创建任务",
        "PUT /api/tasks/:id 更新任务",
        "DELETE /api/tasks/:id 删除任务",
        "所有接口有输入校验"
      ],
      "priority": 2,
      "passes": false
    }
  ]
}
```

### Story 拆分原则

- ✅ 每个 story 可在一个上下文窗口内完成
- ✅ 顺序：schema → backend logic → API → frontend UI
- ✅ Acceptance criteria 必须可验证（不写"功能正常"）
- ❌ 不写"实现整个后端"这种大故事

### 触发方式

> "/piv ~/Projects/my-app"

或指定 PRD：
> "/piv ~/Projects/my-app/PRDs/task-manager.md"

---

## 🔴 全栈编排模式（半天-数天）

**适用**：大型项目、前后端分离、需要并行开发

### 流程

```
Step 0: Silvana 做需求分析
  ├── 功能拆解
  ├── 技术选型
  ├── 目录结构设计
  └── API 接口契约（CONTRACT.md）

Step 1: 创建项目结构
  ~/Projects/project-name/
  ├── docs/
  │   ├── PRD.md          ← 需求文档
  │   ├── CONTRACT.md     ← API 接口契约
  │   └── TECH-SPEC.md    ← 技术方案
  ├── backend/            ← 后端 workdir（独立 git）
  └── frontend/           ← 前端 workdir（独立 git）

Step 2: 写 PRD + API 契约
  Silvana 生成结构化 PRD（按 prd.json 格式）
  + API 接口契约（前后端共享的 schema 定义）

Step 3: 并行 spawn Claude Code ACP
  ┌─ Claude Code Session A (Backend)
  │   prompt: 技术方案 + API 契约 + 后端 User Stories
  │   workdir: ~/Projects/xxx/backend
  │   约束: agentic-coding PACT 规则
  │
  └─ Claude Code Session B (Frontend)
      prompt: 技术方案 + API 契约 + 前端 User Stories
      workdir: ~/Projects/xxx/frontend
      约束: agentic-coding PACT 规则

Step 4: Silvana 审查
  ├── 用 code-review 7 维度审查清单
  ├── 检查 API 契约一致性
  ├── 检查前后端数据类型匹配
  └── spawn Reviewer sub-agent（如果代码量大）

Step 5: 集成 & 交付
  ├── 联调测试
  ├── 修复集成问题
  └── 向 Master 汇报
```

### Claude Code ACP 调用模板

```
sessions_spawn({
  runtime: "acp",
  agentId: "claude",
  mode: "run",
  cwd: "~/Projects/xxx/backend",
  task: `
你是后端工程师。请严格按照以下规范开发：

## 质量规范（Agentic Coding PACT 协议）
1. 写代码前先锁定 Contract（目标 + 验收标准 + 非目标）
2. PACT 循环：Problem → Acceptance → Change → Trace
3. 保持 diff 最小化，一个目标对应一个变更集
4. Bug 修复必须先证明失败、再证明修复

## 技术方案
[粘贴 TECH-SPEC.md 内容]

## API 契约
[粘贴 CONTRACT.md 内容]

## 任务清单
[粘贴后端 User Stories]

完成后输出：修改了哪些文件、验证结果、已知风险。
  `
})
```

---

## 🛡️ 质量保障层（贯穿所有模式）

### Agentic Coding — PACT 协议

所有编码任务（无论哪个模式）都遵循 PACT 循环：

| 步骤 | 做什么 | 为什么 |
|------|--------|--------|
| **P**roblem | 用一句话重述目标和假设 | 防止做错方向 |
| **A**cceptance | 先定义验收标准再写代码 | 防止无尽迭代 |
| **C**hange | 产出最小有效 diff | 防止过度工程 |
| **T**race | 展示测试证据和残留风险 | 防止虚假成功 |

核心规则：**No contract, no code.**

### Code Review — 7 维度审查

代码完成后，按以下维度逐一检查：

| 维度 | 优先级 | 关注点 |
|------|--------|--------|
| Security | 🔴 Critical | SQL 注入、XSS、CSRF、认证、授权、输入校验 |
| Performance | 🟠 High | N+1 查询、内存泄漏、包体积、缓存策略 |
| Correctness | 🟠 High | 边界值、null 处理、竞态条件、时区 |
| Maintainability | 🟡 Medium | 命名清晰、单一职责、DRY、复杂度 |
| Testing | 🟡 Medium | 覆盖率、边界测试、无 flaky 测试 |
| Accessibility | 🟡 Medium | WCAG、键盘导航 |
| Documentation | 🟢 Low | 注释、API 文档、changelog |

Review 严重度标签：
- `[CRITICAL]` — 安全漏洞/数据丢失 → **阻塞合并**
- `[MAJOR]` — Bug/性能问题 → **阻塞合并**
- `[MINOR]` — 改进建议 → 不阻塞
- `[NIT]` — 风格偏好 → 不阻塞

---

## 📁 项目目录结构标准

### 单体项目
```
~/Projects/project-name/
├── agents/
│   └── prd.json           ← PRD（prd skill 格式）
├── PRDs/
│   └── feature-name.md    ← PRD（PIV 格式）
├── PRPs/
│   ├── templates/
│   │   └── prp_base.md    ← PRP 模板
│   └── planning/
│       └── analysis.md    ← 代码库分析
├── WORKFLOW.md             ← PIV 进度追踪
├── src/
├── tests/
└── ...
```

### 前后端分离项目
```
~/Projects/project-name/
├── docs/
│   ├── PRD.md
│   ├── CONTRACT.md        ← API 接口契约
│   └── TECH-SPEC.md
├── backend/               ← 独立 git repo
│   ├── PRDs/
│   ├── PRPs/
│   └── src/
└── frontend/              ← 独立 git repo
    ├── PRDs/
    ├── PRPs/
    └── src/
```

---

## ⚡ 快速参考

| 场景 | 命令/说法 | 预计时间 |
|------|----------|---------|
| 改个小 bug | "帮我修一下 XXX" | 1-5 min |
| 加个小功能 | "帮我做一个 XXX 功能" → mini-piv | 15-60 min |
| 中型功能开发 | "/piv ~/Projects/app" | 1-4 h |
| 大型项目 | "帮我从零开始做一个 XXX 系统" → 全栈编排 | 半天+ |
| 代码审查 | "帮我 review 一下这个 PR" | 10-30 min |

---

## 🔧 环境配置清单

| 组件 | 状态 | 说明 |
|------|------|------|
| Claude Code CLI | ✅ v2.1.38 | 通过本地代理连接 |
| ACP (acpx) | ✅ 已启用 | `approve-all` 权限模式 |
| Sub-agent 嵌套 | ✅ maxSpawnDepth=2 | 支持编排器模式 |
| Sub-agent 模型 | ✅ Sonnet | 省 token，Opus 只用于 Silvana |
| PIV | ✅ 已安装 | 多阶段开发编排 |
| Mini-PIV | ✅ 已安装 | 轻量功能开发 |
| PRD | ✅ 已安装 | 需求文档管理 |
| Agentic Coding | ✅ 已安装 | PACT 质量协议 |
| Code Review | ✅ 已安装 | 7 维度审查清单 |

---

*Last updated: 2026-03-20*
*Silvana — Master Kylin 的第一从者*
