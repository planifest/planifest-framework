# Quirks — context-mode-hooks

**Feature:** 0000001-context-mode-enforcement-hooks
**Component:** context-mode-hooks

---

## Q-001: Allowlist applies to leading token only — `ls | grep` is permitted

**File:** `block-bash.sh`

The allowlist check in `block-bash.sh` examines only the leading command token (first word before any space, pipe, or semicolon). If the leading token is in the allowlist, the entire command is permitted regardless of what follows — including pipes to `grep`.

**Example:** `ls | grep .env` is permitted because `ls` is the leading token and is allowlisted. This is consistent with the ADR-002 decision and the explicit acceptance criterion `git log --oneline | grep feat → allow`.

**Consequence:** A command that pipes an allowlisted command into `grep` will not be blocked, even though the `grep` output will enter the context window.

**Why accepted:** The allowlist was designed for short-output operations. `ls` output is bounded; `ls | grep` is a common and legitimate pattern. The risk of flooding the context window via an allowlisted pipe is considered low.

**Future:** Configurable allowlist (deferred in scope) would allow per-project tuning of this behaviour.

---

## Q-002: NFR-001 latency target not met on Windows when using node fallback

**Observed:** Hook execution takes 250–310ms on Windows (Git Bash) when `node` is used as the JSON tool (no `jq` in PATH). NFR-001 target is < 50ms.

**Root cause:** Node.js cold-start overhead on Windows is ~200-300ms per invocation. The NFR was set assuming `jq` would be available (~5-10ms startup).

**On macOS / Linux with `jq` installed:** NFR-001 is expected to be met — `jq` startup is fast and the hook scripts complete well under 50ms.

**Mitigation options:**
1. Install `jq` on Windows (via scoop: `scoop install jq` or choco: `choco install jq`) — restores the fast path
2. Increase NFR target for Windows to < 500ms — proportionate to node startup overhead
3. Future: vendor a minimal JSON tool in the framework to remove the external dependency

**Current status:** Tests WARN (not FAIL) on latency. The hook still functions correctly — it blocks and redirects — just with higher overhead.

---

## Q-002b: `jq` is a recommended dependency, not strictly required

**Files:** `block-grep.sh`, `block-bash.sh`, `block-webfetch.sh`

All three hook scripts require `jq` for:
1. Parsing `tool_input` fields from the stdin JSON payload
2. Constructing the `hookSpecificOutput` JSON response with proper escaping

`jq` is available by default on macOS and most Linux distributions. On Windows, it must be installed separately (or available via WSL / Git Bash).

**Mitigation:** If `jq` is absent, the script will fail with a command-not-found error, which causes a non-zero exit. Claude Code treats this as a hook error (not a block decision) — the tool call may proceed. See R-003 in the risk register.

**Future:** A fallback path using pure-bash JSON construction could be added, but adds significant complexity and is not justified for v1.

---

## Q-003: Bash pattern matching uses `grep -w` (whole-word) — edge cases exist

**File:** `block-bash.sh`

Blocked patterns (`grep`, `rg`, `curl`, `wget`) are matched using `grep -wE`. This uses word-boundary matching: the token must be surrounded by non-word characters. This avoids false positives like:
- `cargo` matching `rg` (it doesn't — `rg` is not a whole word in `cargo`)
- `--arg` matching `rg` (it doesn't)

Known edge case: a shell variable name like `$RG_PATH` would contain `RG` (uppercase). Because matching is case-sensitive, `rg` would not match `RG_PATH`. Commands using `rg` via a variable (e.g. `$RG pattern`) would not be blocked. This is acceptable for v1 — cooperative agents use the tool name directly.

---

## Q-004: Scripts will be contributed to upstream `mksglu/context-mode`

The hook scripts were authored in `planifest-framework/hooks/context-mode/` for this pipeline run. After completion, they will be contributed to `https://github.com/mksglu/context-mode` as a PR. Until the contribution is accepted, planifest-framework is the source of truth. See ADR-004.

---

## Q-005: Windows — scripts require bash-compatible environment

The hook scripts use `#!/usr/bin/env bash` and require a POSIX shell. On Windows, this means Git Bash, WSL, or another bash environment must be in PATH when Claude Code invokes the hooks. The setup scripts (`.ps1`) copy the `.sh` files verbatim — no PowerShell equivalents are provided in v1.

This is an accepted limitation for v1, tracked in the risk register as R-004.
