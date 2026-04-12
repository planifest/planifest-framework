# Security Report - 0000001-context-mode-enforcement-hooks

**Skill:** security-agent
**Feature:** 0000001-context-mode-enforcement-hooks
**Date:** 2026-04-12
**Reviewer:** planifest-security-agent
**Overall Risk Rating:** Low

---

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|--------|----------|----------|------------|
| Attacker with shell access crafts stdin to manipulate deny message | Tampering | Low | Hook output goes only to Claude Code (local, same user). Shell access already implies full compromise — no additional leverage gained. Not mitigated, not necessary. |
| Very large stdin payload causes memory exhaustion in `input=$(cat)` | DoS | Low | Claude Code tool inputs are bounded in practice. No `ulimit` applied. Mitigated by deployment context (local dev tool, same-user invocation). |
| Claude Code changes `hookSpecificOutput` schema silently; hooks exit 0 with unrecognised JSON → tool calls pass through | DoS / bypass | Low | Documented in pipeline-run.md. Mitigated by: add smoke test to validate deny is surfaced (open item). |
| `merge_hook_settings` (setup.sh) has no file locking; concurrent setup runs could corrupt `.claude/settings.json` | Tampering | Low | Concurrent execution of setup is not a normal operation. Practical risk is negligible. |
| Bash `$pattern` / `$path` / `$url` / `$command` substituted into double-quoted string before passing to `jq --arg` — subcommand injection via `$(...)` in values | Elevation | None | **Not a vulnerability.** Bash does not re-evaluate command substitution within the expanded value of a variable in a double-quoted string. `$(evil)` in `$pattern` expands to the literal string `$(evil)` — not executed. `jq --arg reason "$reason"` then JSON-encodes it correctly. |
| `CMD="$command"` env var passed to `node -e` — code injection via node eval | Elevation | None | **Not a vulnerability.** `CMD` is read in node as `process.env.CMD` — a plain string, not executed. JSON.stringify ensures it is encoded correctly in the output. |

---

## Dependency Audit

| Dependency | Version | Risk | Notes |
|------------|---------|------|-------|
| `jq` | system | None | Only used for JSON parsing and output construction. No network calls. Standard tool with no known injection paths for this usage pattern. |
| `node` / Node.js | system (v24.13.0 on this machine) | None | Used as jq fallback. Reads stdin, writes stdout. No require() / import of untrusted modules. Inline `-e` script is hardcoded in the bash source — not user-supplied. |
| `bash` | system | None | `#!/usr/bin/env bash` — standard shell. `set -euo pipefail` is applied. |
| `awk` | system | None | Used only for leading-token extraction in `block-bash.sh` via pipe. Reads from controlled stdin. |

No abandoned packages, no version pinning required (all system tools).

---

## Secrets Management

**No secrets present.** The hook scripts are read-only stdin processors. They contain:
- No API keys, tokens, or credentials
- No hardcoded passwords or sensitive values
- No calls to external services

`setup.sh` / `setup.ps1` write only to `.claude/settings.json` — file paths only, no credentials.

No secrets management gaps found.

---

## Authentication & Authorisation Review

Not applicable. This feature produces no HTTP API. Hooks are local scripts invoked by Claude Code as the same OS user. No authentication layer is required or appropriate.

---

## Input Validation Review

### `block-grep.sh`
- `tool_input.pattern`: extracted by jq/node as a string. Used in the `reason` message only — not executed as a command.
- `tool_input.path`: same handling.
- If `tool_input` is absent or malformed JSON, the jq/node extraction defaults to `"PATTERN"` / `"PATH"` — no crash.
- **Finding:** None.

### `block-bash.sh`
- `tool_input.command`: extracted by jq/node as a string. Used in three ways:
  1. Piped to `grep -qwE 'grep|rg'` — grep treats `$command` as input TEXT, not a regex. No injection.
  2. Piped to `awk '{print $1}'` — awk treats `$command` as input data. No code execution.
  3. Passed as `CMD` env var to node — node reads as a plain string. No execution.
- **Finding:** None.
- **Finding (Low):** No maximum input length enforced on `command=$(cat)`. A command string exceeding available memory would cause the script to hang or crash. In the intended deployment context (Claude Code tool calls), inputs are short. No fix required for v1; note for upstream contribution.

### `block-webfetch.sh`
- `tool_input.url`: extracted by jq/node as a string. Included verbatim in the deny message.
- **Finding (Info):** The URL is echoed back in the `permissionDecisionReason`. This is intentional — the agent needs the URL to reconstruct the `ctx_fetch_and_index` call. The output goes to Claude Code only, not an external system. No disclosure risk.

---

## Network Policy

Zero network surface. All three hook scripts are entirely offline:
- No `curl`, `wget`, or HTTP calls
- No DNS lookups
- No outbound connections of any kind

`setup.sh` / `setup.ps1` perform only filesystem operations.

---

## Infrastructure as Code Review

No IaC files. This feature is local developer tooling — no cloud resources, no containers, no infrastructure declarations.

---

## Risk Register Cross-Reference

| Register Risk | Implementation Status |
|---------------|----------------------|
| R-001: Allowlist too narrow | Open — expected; conservative v1 list. Not a security issue. |
| R-002: settings.json schema assumption | Open — verified against Claude Code docs (Q-001 resolved). Low risk. |
| R-003: Hook stdin payload scope | Resolved — confirmed full `tool_input` on stdin. |
| R-004: Windows bash shebang | Open — accepted. Quirk Q-005 documented. Not a security issue. |
| R-005: settings.json merge overwrites existing hooks | Mitigated — additive merge implemented in `merge_hook_settings`. |
| R-006: Agent ignores block message | Open — quality concern, not security. |
| R-007: Upstream script divergence | Open — roadmap item. Not a security issue. |
| A-001: PreToolUse hook output schema | Resolved — `hookSpecificOutput` format confirmed. |

---

## Summary

**Overall risk rating: Low**

No critical or high findings. The hook scripts have a minimal security surface:
- Read-only stdin processors
- No network, no file writes, no credentials, no privilege escalation
- Input values are handled as data (not executed)
- JSON encoding is delegated to `jq --arg` or `node JSON.stringify` — both handle escaping correctly

**Top actions before production:**

1. **(Low)** Add input size guard to `install_context_mode_hooks` in setup.sh — validate that hook scripts exist and are non-empty before copying, to prevent accidental installation of empty files.
2. **(Low)** Add a smoke test to the REQ-004 manual checklist: verify Claude Code actually surfaces the deny reason to the agent (not just that the JSON is written), to detect silent schema changes in `hookSpecificOutput`.
3. **(Info)** Consider adding `jq` installation guidance to `getting-started.md` — not for security, but to ensure NFR-001 (< 50ms latency) is met on Windows (see quirks Q-002).

No findings require code changes before shipping.

---

*Generated by planifest-security-agent.*
