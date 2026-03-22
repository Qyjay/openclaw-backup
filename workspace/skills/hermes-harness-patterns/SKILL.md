# SKILL.md — Hermes Harness Architecture Patterns

---
name: hermes-harness-patterns
description: Agent harness architecture patterns derived from Nous Research's Hermes Agent. Covers tool registry, memory systems, context compression, skill lifecycle, smart routing, and session management for building robust AI agent systems.
version: 1.0.0
---

# Hermes Agent Harness Architecture — Reference Patterns

> 源自 [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) 的架构分析。
> 本文档提炼了 Hermes 的核心设计模式，供 Silvana 团队在构建 Agent 系统时参考和融合。

---

## 1. Tool Registry — 集中式工具注册

**模式：** 单例 `ToolRegistry` 管理所有工具的 schema、handler、toolset 归属和可用性检查。

```
tools/registry.py (无外部依赖)
      ↑
tools/*.py (模块加载时注册)
      ↑
model_tools.py (查询 registry 获取工具定义)
      ↑
run_agent.py (运行时使用)
```

### 关键设计：
- **声明式注册**：每个 tool 文件在 import 时调用 `registry.register(name, toolset, schema, handler, check_fn)`
- **可用性检查**：`check_fn` 在运行时动态判断工具是否可用（如某 API key 是否存在）
- **Toolset 分组**：工具按 toolset 分组，支持批量启用/禁用
- **Tool 名修复**：用 difflib fuzzy matching 修复 LLM 输出的错误工具名
- **并行安全分类**：
  - `_PARALLEL_SAFE_TOOLS`：只读工具，可安全并行
  - `_NEVER_PARALLEL_TOOLS`：交互式工具，必须串行
  - `_PATH_SCOPED_TOOLS`：按文件路径隔离的并行

### 应用场景：
当管理多个 Servant 的工具集时，用 registry 模式统一注册和调度，避免每个 Servant 各自维护工具列表。

---

## 2. Memory 三层架构

**模式：** 冻结快照 + 实时写入 + 跨会话建模

### 层级：

| 层 | 文件/系统 | 作用 | 刷新时机 |
|---|---|---|---|
| L1 系统提示词快照 | MEMORY.md / USER.md 注入 system prompt | 每轮对话的稳定上下文 | 仅在 session 开始或 context 压缩后重建 |
| L2 实时写入 | `memory` tool → 立即写磁盘 | 持久化新信息 | 每次 tool 调用 |
| L3 跨会话建模 | Honcho 集成 | 用户画像 + 对话延续性 | 异步后台同步 |

### 关键设计：
- **冻结快照模式**：system prompt 中的 memory 在 session 内不变，保证 prefix cache 命中率
- **`§` 分隔符**：条目用 section sign 分隔，支持多行内容
- **子串匹配替换**：replace/remove 用短唯一子串定位，不需要完整文本或 ID
- **安全扫描**：memory 写入前检查 prompt injection 模式（`ignore previous instructions` 等）
- **字符限制**（非 token）：memory 2200 chars, user 1375 chars — 模型无关
- **背景审查**：每隔 N 轮，后台 spawn 一个轻量 agent 审查对话，自动保存值得记住的信息

### 已融合到 Silvana 的实践：
- `MEMORY.md`：长期记忆（精炼洞察）
- `memory/YYYY-MM-DD.md`：每日原始日志
- `memory/lessons/mistakes.md`：错误教训
- `memory/preferences.md`：偏好设置
- `SESSION-STATE.md`：WAL 模式热状态

---

## 3. Context Compression — 自动上下文压缩

**模式：** 阈值触发 → 工具输出修剪 → 头尾保护 → LLM 结构化摘要

### 算法流程：
1. **监控**：每次 API 响应后更新 token 用量
2. **触发**：达到 context length 的 50%（可配置）
3. **修剪**：先清理旧 tool 输出（零成本 pre-pass）
4. **保护**：头部 3 条消息 + 尾部 20K tokens 不动
5. **摘要**：中间部分用 cheap model 生成结构化摘要
6. **迭代**：后续压缩基于上次摘要增量更新，不重新生成

### 结构化摘要模板：
```
- Goal: 用户的目标
- Progress: 已完成的工作
- Decisions: 关键决策
- Files: 涉及的文件
- Next Steps: 接下来要做什么
```

### 关键设计：
- **摘要前缀**：`[CONTEXT COMPACTION]` 标记，告诉模型这是已完成的工作
- **预算压力通知**：
  - 70% iteration budget → 温柔提醒收尾
  - 90% → 紧急要求立即响应
- **Context 50%/70% 用户警告**：通知用户上下文快满了（不注入 prompt）

---

## 4. Skill System — 自我进化的技能库

**模式：** 渐进式披露 + 条件激活 + 使用中自修复

### 三层披露：
1. **Tier 1 - 索引**：system prompt 中的 skill 列表（名称 + 简短描述）
2. **Tier 2 - 加载**：`skill_view(name)` 加载完整 SKILL.md 指令
3. **Tier 3 - 引用**：按需加载 references/、templates/ 子目录文件

### 条件激活：
```yaml
metadata:
  hermes:
    fallback_for_toolsets: [browser]  # 当 browser 工具可用时隐藏此 skill
    requires_toolsets: [terminal]      # 当 terminal 不可用时隐藏
    fallback_for_tools: [web_search]
    requires_tools: [read_file]
```

### 自修复循环：
1. Agent 完成复杂任务（5+ tool calls）
2. 后台审查：这个方法值得保存为 skill 吗？
3. 如果已有 skill 但过时/错误 → 用 `skill_manage(action='patch')` 立即修复
4. 每 N 次迭代提醒 agent 考虑创建/更新 skill

### 平台兼容性：
```yaml
platforms: [macos, linux]  # 仅在这些平台显示
```

---

## 5. Smart Model Routing — 智能模型路由

**模式：** 简单消息用便宜模型，复杂任务用强模型

### 分类启发式：
- **简单**：≤160 字符、≤28 词、无多行、无代码块、无 URL
- **复杂**：包含 debug/implement/refactor/analyze/architecture 等关键词

### Provider Fallback：
- 主模型 rate limit / 超载 → 自动切换到 fallback model
- 支持运行时刷新凭证（Codex、Anthropic OAuth）

### 应用到 Silvana 团队：
- 日常问答 → MiniMax M2.7（快速便宜）
- 复杂分析/编码 → Claude Opus 4（强推理）
- 模型选择可以是 skill 级别的配置

---

## 6. Iteration Budget — 共享迭代预算

**模式：** 父子 Agent 共享一个线程安全的迭代计数器

```python
class IterationBudget:
    def __init__(self, max_total: int):
        self.max_total = max_total
        self._used = 0
        self._lock = threading.Lock()

    def consume(self) -> bool:
        """尝试消费一次迭代。超出预算返回 False。"""

    def refund(self) -> None:
        """退还一次迭代（如 execute_code 不算入预算）。"""
```

### 关键设计：
- 父 Agent 创建 budget，所有子 Agent 继承同一个实例
- `consume()` 返回 bool 而非抛异常 — 优雅降级
- `refund()` 用于不消耗推理的工具调用（如纯代码执行）
- 70% / 90% 阈值注入压力提示到最近的 tool result 中

---

## 7. Session Management — 会话管理

### 多层持久化：
- **JSON Session Log**：完整原始记录，每轮覆写
- **SQLite Session DB**：增量追加，支持 FTS5 全文搜索
- **Trajectory JSONL**：训练数据格式导出

### Session Search（跨会话回忆）：
1. FTS5 全文搜索匹配消息
2. 按 session 分组，取 top N
3. 截断到匹配点附近 ~100K chars
4. 用 cheap model 生成聚焦摘要
5. 返回 per-session 摘要 + 元数据

### 应用价值：
- "我们上次讨论的那个方案" → 搜索历史 session → 返回相关摘要
- 不是简单的关键词匹配，而是 LLM 加持的语义回忆

---

## 8. Prompt Assembly — 分层系统提示词

### 组装顺序（从高到低优先级）：
1. **Identity** → SOUL.md（首选）或内置 DEFAULT_AGENT_IDENTITY
2. **User/Gateway prompt** → 外部传入的额外指令
3. **Memory** → MEMORY.md + USER.md 冻结快照
4. **Honcho context** → 跨会话用户建模（如启用）
5. **Skills index** → 可用技能列表
6. **Context files** → AGENTS.md / .cursorrules / .hermes.md
7. **Timestamp** → 当前日期时间 + 模型信息
8. **Platform hints** → 平台特定格式提示（WhatsApp 不用 markdown 等）

### 关键设计：
- **安全扫描**：所有 context 文件加载前检查 prompt injection
- **截断策略**：超过 20K chars 用 70% head + 20% tail + 中间标记
- **YAML frontmatter 剥离**：.hermes.md 的 YAML 头被移除（给结构化配置用）
- **缓存**：system prompt 每 session 只构建一次，压缩后重建

---

## 9. Interrupt & Safety — 中断与安全

### 中断传播：
```
User sends new message
  → parent.interrupt(message)
    → _set_interrupt(True)  # 全局信号
    → child1.interrupt(message)  # 递归传播到所有子 Agent
    → child2.interrupt(message)
```

### 破坏性命令检测：
```python
_DESTRUCTIVE_PATTERNS = re.compile(
    r'rm\s|rmdir\s|mv\s|sed\s+-i|truncate\s|dd\s|shred\s|git\s+(?:reset|clean|checkout)\s'
)
```

### Tool 调用去重：
同一轮中相同 (tool_name, arguments) 的重复调用被自动去除。

### 孤儿 tool_call 修复：
每次 LLM 调用前自动修复：
- 有 tool result 但没有对应的 assistant tool_call → 删除 result
- 有 tool_call 但没有对应的 tool result → 注入 stub result

---

## 10. 对 Silvana 团队的启示

### 已有且可强化的：
- ✅ Memory 多层架构（已有 MEMORY.md / daily / lessons）
- ✅ Skill 系统（已有 available_skills）
- ✅ Servant 分工（类似 subagent delegation）
- ✅ 安全扫描（需要加强 context 文件注入检测）

### 可引入的新模式：
- 🔄 **背景审查线程**：完成复杂任务后自动 spawn 轻量 agent 审查是否有值得保存的 memory/skill
- 📊 **Iteration Budget**：给子 Agent 设定共享的迭代预算上限，防止失控
- 🗜️ **Context Compression**：长对话自动压缩中间部分，保护头尾
- 🔍 **Session Search**：基于历史对话的语义回忆
- 🧹 **Tool Call 修复**：自动去重 + 孤儿修复 + 名称模糊匹配
- 🎯 **Smart Routing**：简单问题自动降级到便宜模型
- 🛡️ **Memory 安全扫描**：写入 memory 前检查 injection 模式
- 📈 **Insights Engine**：跨 session 的使用统计（token、成本、工具使用频率）

---

*Last updated: 2026-03-22*
*Source: github.com/NousResearch/hermes-agent (MIT License)*
