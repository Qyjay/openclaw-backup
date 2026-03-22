# Hermes Agent — Key Code Patterns Reference

## 1. Tool Registry Pattern

```python
# tools/registry.py — 核心注册器
class ToolRegistry:
    """Singleton registry that collects tool schemas + handlers from tool files."""

    def register(self, name, toolset, schema, handler, check_fn=None, ...):
        """声明式注册。每个 tool 文件在 import 时调用。"""

    def get_definitions(self, tool_names, quiet=False):
        """只返回 check_fn() 通过的工具 schema。"""

    def dispatch(self, name, args, **kwargs):
        """统一调度。自动桥接 async handler。"""

registry = ToolRegistry()  # 模块级单例
```

**注册方式（每个 tool 文件底部）：**
```python
from tools.registry import registry

registry.register(
    name="web_search",
    toolset="web",
    schema={...},
    handler=web_search_handler,
    check_fn=lambda: bool(os.getenv("BRAVE_API_KEY")),
    emoji="🔍",
)
```

## 2. Memory Store — 冻结快照模式

```python
class MemoryStore:
    def __init__(self, memory_char_limit=2200, user_char_limit=1375):
        self._system_prompt_snapshot = {}  # 冻结在 session 开始
        self.memory_entries = []           # 实时状态

    def load_from_disk(self):
        """加载文件 → 更新 entries + 刷新 snapshot"""

    def format_for_system_prompt(self, target):
        """返回 snapshot（不是实时 entries）"""

    def add(self, target, content):
        """写入 entries + 立即持久化到磁盘"""
        # 但 snapshot 不变 → prefix cache 不失效
```

## 3. Context Compressor — 核心算法

```python
class ContextCompressor:
    def should_compress(self, messages):
        """当前 token 用量 >= threshold_tokens 时返回 True"""

    def compress(self, messages):
        """
        1. _prune_old_tool_results(messages)     # 免费 pre-pass
        2. head = messages[:protect_first_n]      # 保护头部
        3. tail = messages[-tail_budget:]          # 保护尾部 20K tokens
        4. middle = messages[head:tail]            # 待压缩
        5. summary = call_llm(summarize(middle))   # cheap model
        6. return head + [summary_msg] + tail
        """
```

## 4. Background Memory Review

```python
def _spawn_background_review(self, messages_snapshot, review_memory, review_skills):
    """
    后台 thread 中：
    1. 创建一个轻量 AIAgent（quiet_mode=True, max_iterations=8）
    2. 共享 memory_store 引用
    3. 把整个对话历史 + review prompt 传入
    4. 让它自己决定是否保存 memory / 创建 skill
    5. 完成后输出简短摘要："💾 Memory updated · Skill created"
    """
```

## 5. Smart Model Routing

```python
def choose_cheap_model_route(user_message, routing_config):
    """
    简单判断规则：
    - len(text) > 160 chars → 不路由
    - words > 28 → 不路由
    - 包含代码块/URL → 不路由
    - 包含复杂关键词 (debug, implement, refactor...) → 不路由
    - 否则 → 返回 cheap model 配置
    """
```

## 6. Iteration Budget — 共享计数器

```python
class IterationBudget:
    """Thread-safe. Parent creates, all children inherit same instance."""

    def consume(self) -> bool:
        with self._lock:
            if self._used >= self.max_total:
                return False  # 优雅拒绝，不抛异常
            self._used += 1
            return True

    def refund(self):
        """execute_code 等纯计算不消耗预算"""
```

## 7. Orphan Tool Call Repair

```python
@staticmethod
def _sanitize_api_messages(messages):
    """每次 LLM 调用前：
    1. 收集所有 assistant tool_calls 的 ID
    2. 收集所有 tool results 的 ID
    3. 删除没有对应 call 的 result（孤儿 result）
    4. 为没有对应 result 的 call 注入 stub
    """
```

## 8. Prompt Assembly — 分层构建

```python
def _build_system_prompt(self, system_message=None):
    parts = []
    # 1. SOUL.md or DEFAULT_AGENT_IDENTITY
    # 2. Tool-specific guidance (memory, session_search, skills)
    # 3. Honcho cross-session context
    # 4. User/gateway system message
    # 5. Memory snapshot (MEMORY.md + USER.md)
    # 6. Skills index
    # 7. Context files (AGENTS.md, .cursorrules)
    # 8. Timestamp + model info
    # 9. Platform hints
    return "\n\n".join(parts)
```

## 9. Session Search — 语义回忆

```python
# Flow:
# 1. FTS5 全文搜索 SQLite → 匹配消息 + relevance score
# 2. 按 session 分组 → top N sessions
# 3. 加载对话 → 截断到匹配点附近 ~100K chars
# 4. cheap model 生成聚焦摘要
# 5. 返回 per-session summaries + metadata
```

## 10. Safety Patterns

```python
# Memory 注入检测
_MEMORY_THREAT_PATTERNS = [
    (r'ignore\s+(previous|all)\s+instructions', "prompt_injection"),
    (r'you\s+are\s+now\s+', "role_hijack"),
    (r'curl\s+.*\$\{?\w*(KEY|TOKEN|SECRET)', "exfil_curl"),
]

# Context 文件安全扫描
_CONTEXT_THREAT_PATTERNS = [
    (r'system\s+prompt\s+override', "sys_prompt_override"),
    (r'<!--.*(?:ignore|override|secret).*-->', "html_comment_injection"),
]

# 不可见字符检测
_INVISIBLE_CHARS = {'\u200b', '\u200c', '\u200d', '\u2060', '\ufeff'}
```
