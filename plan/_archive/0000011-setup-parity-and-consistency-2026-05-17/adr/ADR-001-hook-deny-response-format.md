---
title: "ADR-001: Hook deny response format — translation in the adapter layer"
summary: "Each agentic tool requires a different JSON shape to deny a hook-intercepted tool call. Adapters translate the internal exit-code-2 signal from shared enforcement scripts into the tool's required format, so enforcement scripts remain tool-agnostic."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - Hook deny response format — translation in the adapter layer

**Skill:** adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000011-setup-parity-and-consistency
**Status:** accepted
**Date:** 2026-05-16

---

## Context

Planifest's hook enforcement is split into two layers:

1. **Shared enforcement scripts** (`gate-write.mjs`, `check-design.mjs`) — implement the enforcement logic (check design.md, check sentinel, check path scope) and signal their decision via exit code: `0` = allow, `2` = block.
2. **Adapters** (`copilot.mjs`, `cursor.mjs`, `windsurf.mjs`, `codex.mjs`) — translate the tool's native hook envelope to the common format, invoke the enforcement script, and return a result to the tool.

The problem: each tool requires a different response shape when blocking a `PreToolUse`-equivalent event:

| Tool | Block mechanism |
|------|----------------|
| Claude Code | Exit code 2 |
| Cursor | Exit code 2 (or JSON `{ "permission": "deny", "user_message": "..." }`) |
| Windsurf | Exit code 2 |
| Codex CLI | JSON to stdout: `{ "hookSpecificOutput": { "hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "..." } }` — exit code alone is insufficient |
| GitHub Copilot | JSON to stdout: `{ "permissionDecision": "deny", "permissionDecisionReason": "..." }` — exit code 2 is warning-only for preToolUse |

Shared enforcement scripts cannot emit tool-specific output because they have no knowledge of which tool invoked them.

---

## Decision

**Shared enforcement scripts communicate via exit code only.** They exit 2 to signal a block and write a human-readable reason to stdout. They never emit tool-specific JSON.

**Adapters are responsible for translating exit code 2 into the tool's required block format.** After invoking the enforcement script via `spawnSync`, the adapter:
- For tools where exit code 2 suffices (Cursor, Windsurf, Claude Code): passes through the exit code directly.
- For tools requiring JSON output (Codex, Copilot): captures stdout from the enforcement script (the human-readable reason), constructs the tool-specific JSON, writes it to the adapter's stdout, and exits 0.

This preserves the enforcement scripts as tool-agnostic contracts while keeping format concerns in the adapter.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| Enforcement scripts emit JSON configured by env var | Enforcement scripts remain the single source of truth | Adds coupling between enforcement scripts and all tool formats; scripts must know about all tools | Enforcement scripts should be tool-agnostic — adding tool awareness reverses the abstraction |
| Each adapter contains its own enforcement logic (self-contained) | No inter-script dependency; each adapter is fully standalone | Enforcement logic duplicated across all adapters; a bug fix requires updating every adapter | Maintainability cost is too high; a single change to gate-write logic requires N adapter edits |
| Adapters emit exit code 2 for all tools and rely on tools accepting it | Simplest possible adapter | Codex and Copilot documentation explicitly state exit code 2 does not block preToolUse; enforcement would silently not fire | Contradicts official API documentation for two of the four tools |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| `hooks/adapters/codex.mjs` | Must capture enforcement script stdout and construct `hookSpecificOutput` JSON when exit 2 is received |
| `hooks/adapters/copilot.mjs` | Must construct `{ "permissionDecision": "deny", "permissionDecisionReason": "..." }` JSON when exit 2 is received |
| `hooks/adapters/cursor.mjs` | Passes exit code through; no JSON construction needed |
| `hooks/adapters/windsurf.mjs` | Passes exit code through; no JSON construction needed |
| `hooks/enforcement/gate-write.mjs` | No change — exits 2 with reason on stdout; this is already correct |
| `hooks/enforcement/check-design.mjs` | No change — exits 0; writes context to stdout |

---

## Consequences

**Positive:**
- Enforcement scripts remain tool-agnostic and have a single implementation; bug fixes propagate to all tools automatically.
- Adding support for a new tool only requires writing a new adapter — enforcement scripts are untouched.
- The exit-code-2 contract between enforcement scripts and adapters is simple and testable.

**Negative:**
- Adapters for Codex and Copilot are more complex than adapters for exit-code-2 tools; they must understand the enforcement script's stdout format to extract the reason string.
- If an enforcement script changes its stdout format (e.g. adds JSON wrapping), Codex and Copilot adapters must be updated.

**Risks:**
- Future tools may require yet another deny format; each new format adds adapter complexity without changing enforcement scripts.
- The enforcement script stdout format is an implicit contract. If it changes silently, Codex and Copilot adapters will construct deny responses with garbled reason strings.

---

## Related ADRs

- ADR-003 — depends-on (this decision assumes the delegating adapter architecture from ADR-003)

---

## Supersedes

- None

## Superseded By

- None
