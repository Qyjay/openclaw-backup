---
name: hub-sync
description: |
  检查并同步各服务仓库的 harness 文件与代码的一致性。
  用脚本做机械化漂移检测，agent 只负责阅读代码和修复文档。

  触发场景：
  - "hub sync"、"同步 harness"、"检查文档"
  - "docs 是不是过时了"、"更新文档"、"harness 巡检"
argument-hint: "[服务名（可选，不填则扫描所有服务）]"
---

# Hub Sync — Harness 文档同步

## Hub 根目录

!`cd -P "${CLAUDE_SKILL_DIR}/../.." && echo "HUB_ROOT=$(pwd)" && echo "scripts: $(pwd)/scripts/"`

!`bash "$(cd -P "${CLAUDE_SKILL_DIR}/../.." && pwd)/scripts/hub_config.sh" env 2>/dev/null || echo "ERROR: hub_config.sh 执行失败"`

## 服务注册表

!`bash "$(cd -P "${CLAUDE_SKILL_DIR}/../.." && pwd)/scripts/hub_config.sh" pull >/dev/null 2>&1; bash "$(cd -P "${CLAUDE_SKILL_DIR}/../.." && pwd)/scripts/hub_config.sh" services 2>/dev/null || echo "(未找到)"`

---

## 执行流程

### Step 1: 对每个服务运行漂移检测脚本

从 registry 的 services 目录读取服务列表（如果用户指定了服务名，只处理该服务）。
用 `hub_config.sh local_path <service-name>` 获取服务的本地路径。

对每个服务执行（脚本自动从仓库的 `docs/harness-sync-state.yaml` 读取基线）：

```bash
bash <detect_drift.sh路径> <service-name> <local_path>
```

脚本会输出结构化的漂移报告，包含：
- 哪些类型的文件变更了（structure/build/route/idl/linter/ci）
- 每个 harness 文件（CLAUDE.md, architecture.md 等）是否漂移
- 漂移原因

**如果脚本退出码为 0（无漂移），跳过该服务。**

### Step 2: 分析漂移报告

阅读脚本输出的报告，对标记为 `drift: true` 的文件：

1. **了解变更内容**：根据报告中的 `build_files` / `route_files` / `idl_files`，阅读这些变更文件的当前内容
2. **阅读当前 harness 文件**：读取需要修复的文档的当前内容
3. **判断具体要改什么**：对比代码现状和文档描述，定位差异

### Step 3: 修复漂移

只修改脚本标记为漂移的文件，对每个漂移文件：

- **CLAUDE.md**：更新 Navigation Map 中不存在的路径、更新 Quick Start 中过时的命令
- **docs/architecture.md**：阅读新增的模块代码，补充到 Module Map 和 Layering Rules
- **docs/golden-rules.md**：对比新的 linter 配置，更新规则描述
- **.claude/skills/**：更新 skill 中过时的命令引用
- **registry 服务文件**：更新 exposes / consumes / commands（编辑 registry 仓库中对应的服务 YAML 文件）

**原则**：
- 增量修补，不要重写整个文件
- 保留用户手动添加的内容
- 需要阅读代码才能写好的部分（如新模块的职责描述），要先读代码再写

每个服务的修复放在一个 commit 里。

### Step 4: 更新基线

每个服务修复完成后，更新基线（写入仓库的 `docs/harness-sync-state.yaml`）：

```bash
bash <update_sync_state.sh路径> <local_path>
```

### Step 5: 汇总

```
=== Hub Sync 完成 ===

扫描服务: N
  service-a: 47 commits since baseline → 2 漂移 → 已修复
  service-b: 无漂移 → 跳过
  service-c: 首次 sync → 3 漂移 → 已修复

基线已更新。

下一步:
  - review 各仓库改动
  - git push 提交
```
