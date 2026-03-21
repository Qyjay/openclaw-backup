# Personal Harness Hub

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that turns AI into a disciplined developer — not just a code generator.

Adapted from MiniMax's internal Weaver Harness Hub, stripped down for solo developers who want structured, quality-enforced AI coding without the enterprise overhead.

## What It Does

You describe what you want. The skill forces Claude Code through a **7-step pipeline** that mirrors how a real developer works:

```
Detect Project → Write Code + Tests → Quality Gate → PR Check → GitHub PR → Doc Sync → Report
```

No shortcuts. No "I'll skip tests since it's simple." The hooks physically block it.

## Why Not Just Use Claude Code Directly?

| Claude Code alone | With this skill |
|---|---|
| Agent decides when it's "done" | 7-step pipeline with exit gates |
| May skip tests | PreToolUse hook **blocks** test deletion |
| May `git push` broken code | Hook **blocks** manual push; must pass quality gate first |
| No coverage enforcement | Incremental coverage ≥ 80% on changed files |
| Forgets to lint | Script runs lint automatically |
| "Trust me it works" | lint ✓ test ✓ coverage ✓ — prove it |

## The Pipeline

| Step | What Happens | Enforced By |
|------|-------------|-------------|
| **1. Detect** | Auto-detect language, framework, commands | `detect_repo.sh` |
| **2. Develop** | Branch → code → tests → lint → commit | SKILL.md instructions |
| **3. Quality Gate** | lint + unit test + incremental coverage ≥ 80% | `quality_gate.sh` |
| **4. PR Check** | 8-point readiness check | `pre_pr_check.sh` |
| **5. Submit PR** | Push + create GitHub PR via `gh` | `create_pr.sh` |
| **6. Doc Sync** | Detect harness doc drift, fix if needed | `detect_drift.sh` |
| **7. Report** | Structured summary | Stop hook verifies completion |

## Safety Hooks

Two Claude Code hooks prevent the agent from cutting corners:

**PreToolUse Hook** — fires before every Bash command:
- ❌ `rm *_test.go` → blocked
- ❌ `git push` → blocked (must use `create_pr.sh`)
- ❌ Writing fake state markers → blocked

**Stop Hook** — fires when agent tries to stop:
- Checks all 7 steps completed
- Missing steps? Agent gets sent back with specific commands to run
- Max 20 retries before force-release (no infinite loops)

Both hooks are **no-ops** outside hub workflows (`/tmp/.claude_hub_active` must exist).

## Supported Languages

Auto-detection via `detect_repo.sh`:

| Language | Lint | Test | Format |
|----------|------|------|--------|
| Go | golangci-lint / go vet | go test | goimports / gofmt |
| Python | ruff / make check | pytest / make test | ruff format |
| Node.js | npm run lint | npm test | npm run format |
| Java | gradle check / mvn verify | gradle test / mvn test | spotless |
| Rust | cargo clippy | cargo test | cargo fmt |

## Install

```bash
git clone https://github.com/Qyjay/personal-harness-hub.git
cd personal-harness-hub
bash setup.sh
```

This creates three symlinks in `~/.claude/skills/` and registers the hooks in `~/.claude/settings.json`.

**Prerequisites:**
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- [GitHub CLI](https://cli.github.com/) (`gh`) authenticated — for PR creation
- Git configured

## Usage

### Initialize a new project

Open Claude Code in your project directory:

```
/hub-init
```

Agent reads your code, generates `CLAUDE.md` + architecture docs + golden rules.

### Develop a feature

```
/hub Add dark mode toggle with system preference detection
```

Or just describe what you want — the skill auto-triggers on development keywords.

### Sync docs after manual changes

```
/hub-sync
```

## File Structure

```
.
├── SKILL.md                    # Main 7-step workflow
├── setup.sh                    # One-command installer
├── agents/
│   └── service-worker.md       # Sub-agent template
├── scripts/
│   ├── detect_repo.sh          # Language/framework auto-detection
│   ├── quality_gate.sh         # lint + test + incremental coverage
│   ├── pre_pr_check.sh         # 8-point PR readiness check
│   ├── create_pr.sh            # GitHub PR via `gh` CLI
│   ├── detect_drift.sh         # Harness doc drift detection
│   ├── update_sync_state.sh    # Sync baseline update
│   ├── hub_pre_tool_hook.sh    # PreToolUse safety hook
│   ├── hub_stop_hook.sh        # Stop completion hook
│   ├── install_hooks.sh        # Hook installer (idempotent)
│   └── hub_config.sh           # Config helper
├── skills/
│   ├── init/SKILL.md           # /hub-init workflow
│   └── sync/SKILL.md           # /hub-sync workflow
└── docs/
    └── harness-hub-guide.md    # Full design doc
```

## Integration with OpenClaw

This skill works standalone in Claude Code, but it's designed to be orchestrated by [OpenClaw](https://github.com/openclaw/openclaw) agents:

```
You → OpenClaw Agent → spawns Claude Code via ACP → skill runs the pipeline → report back
```

You talk to the agent. The agent handles everything else.

## Adapting

| Problem | Fix |
|---------|-----|
| Agent writes bad code in a repo | Improve that repo's `CLAUDE.md` |
| Pipeline steps wrong | Edit `SKILL.md` |
| Coverage threshold too high/low | Change value in `quality_gate.sh` call |
| Need new workflow | Add skill in `skills/` |

## Origin

Adapted from MiniMax's internal **Weaver Harness Hub** — an enterprise-grade Claude Code plugin for cross-service development orchestration. This personal version removes:

- GitLab / `glab` → GitHub / `gh`
- Cross-service registry → single-project focus
- Lane deployment → removed
- Service registration → removed

Core quality enforcement and safety hooks preserved.

## License

MIT
