# Purpose — context-mode-hooks

**Component:** context-mode-hooks
**Feature:** 0000001-context-mode-enforcement-hooks
**Version:** 0.1.0

---

## What This Component Does

`context-mode-hooks` provides three Claude Code `PreToolUse` hook scripts that intercept tool calls at the point of invocation and redirect agents away from direct tool use toward the context-mode MCP sandbox equivalents.

The hooks enforce the **context-mode routing rule**: agents must not use `Grep`, `WebFetch`, or (for blocked patterns) `Bash` to interact with the codebase or external URLs. Instead they must use `ctx_execute`, `ctx_fetch_and_index`, and `ctx_search` — tools that route large outputs into a sandboxed knowledge base rather than flooding the context window.

---

## Why It Exists

Without enforcement, an agent operating in context-mode can comply conceptually with the routing rules but still accidentally (or habitually) invoke the native tools — especially when following learned patterns from training data. The hooks close this gap by making the routing rules **machine-enforceable**: the native tools literally cannot be called without a block decision being returned.

The component exists at the boundary between Claude Code's tool invocation layer and the context-mode MCP server. It does not replace the MCP server — it enforces the precondition for using it.

---

## Position in the System

```
User prompt
    │
    ▼
Claude Code agent (plans tool call)
    │
    ▼
PreToolUse hook (this component)
    │
    ├─ allow → tool executes normally
    │
    └─ deny  → agent receives redirect message
                 → agent uses ctx_* MCP tool instead
                 → output goes into context-mode sandbox
```

---

## Scripts

| Script | Tool Intercepted | Strategy |
|--------|-----------------|----------|
| `block-grep.sh` | `Grep` | Unconditional block; redirect to `ctx_execute(language:"shell", code:"grep ...")` |
| `block-bash.sh` | `Bash` | Pattern-matched block; redirect to `ctx_execute` or `ctx_fetch_and_index`; allowlist permits safe low-output commands |
| `block-webfetch.sh` | `WebFetch` | Unconditional block; redirect to `ctx_fetch_and_index` + `ctx_search` |

---

## Installation

Scripts are installed into `.claude/hooks/context-mode/` in the target project by running:

```bash
./planifest-framework/setup.sh claude-code --context-mode-mcp
```

The setup script also writes the three `PreToolUse` entries to `.claude/settings.json`.
