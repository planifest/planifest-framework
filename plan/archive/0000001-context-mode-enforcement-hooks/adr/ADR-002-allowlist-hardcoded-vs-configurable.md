---
title: "ADR 002: Bash Allowlist — Hardcoded vs Per-Project Configurable"
summary: "The Bash hook allowlist (git, mkdir, rm, mv, cd, ls, npm install, pip install) is hardcoded in the hook script for v1. Per-project configuration is deferred. This constrains customisation but eliminates config schema complexity and keeps hooks stateless."
status: "accepted"
version: "0.1.0"
---
# ADR-002 - Bash Allowlist — Hardcoded vs Per-Project Configurable

**Skill:** adr-agent
**Tool:** claude-code
**Model:** claude-sonnet-4-6
**Feature:** 0000001-context-mode-enforcement-hooks
**Component:** context-mode-hooks
**Status:** accepted
**Date:** 2026-04-12

---

## Context

The `block-bash.sh` hook intercepts Bash tool calls and blocks those matching context-flooding patterns (`grep`, `rg`, `curl`, `wget`, inline HTTP). However, not all commands should be blocked — common low-output operations like `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, and package installs are safe and necessary for normal agent operation.

The question is whether this allowlist should be:
- **Hardcoded** in the script (same for all projects using planifest-framework)
- **Configurable per-project** via a config file read at hook execution time

This decision directly constrains how projects with non-standard toolchains (e.g. `pnpm`, `cargo`, `make`) can customise the hook's behaviour without modifying the framework source.

---

## Decision

**Hardcode the allowlist in `block-bash.sh` for v1.** The allowlist covers universally safe, low-output commands: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`.

Per-project configuration is deferred. The allowlist is clearly commented in the script and extending it requires only editing that file — a low-friction override for projects that need it.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Hardcoded allowlist (chosen) | Stateless hook — no disk reads, no config schema; simple to reason about; meets NFR-001 < 50ms easily | Cannot adapt to per-project toolchains without editing framework source; `pnpm`, `cargo`, `make`, `dotnet` not covered | Accepted — low-friction to extend; universal commands cover the common case |
| Config file at `.claude/context-mode.json` read on each hook invocation | Per-project customisation without modifying framework | Disk I/O on every tool call (latency risk vs NFR-001); config schema to design, validate, and document; config file must be created at setup time | Rejected — adds I/O latency, schema complexity, and a new file to manage |
| Environment variable allowlist | No disk I/O; per-project without editing source | Env vars set in settings.json are session-scoped, not hook-scoped in Claude Code; hard to document and discover | Rejected — env var propagation to hook processes is not confirmed for all Claude Code versions |
| `if` field in settings.json hook config | Pre-filtering at config level, no script spawn for allowed commands | `if` field pattern language is limited (glob-style, not regex); full allowlist logic would require a complex multi-entry hook config; fragile to maintain | Rejected — the `if` field is better used as a coarse pre-filter (see ADR-003), not as the allowlist mechanism |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| context-mode-hooks | Allowlist is compiled into `block-bash.sh`; extending it requires editing the script or reinstalling via setup |
| setup-hook-integration | No direct impact — setup copies the script as-is; allowlist is not parameterised at install time |

---

## Consequences

**Positive:**
- Hook remains fully stateless — no disk reads, no config parsing; NFR-001 latency budget is easily met
- Simple to audit: the complete set of allowed commands is visible in one place in the script
- No new config file or schema to maintain in v1

**Negative:**
- Projects using `pnpm`, `yarn`, `cargo`, `make`, `dotnet`, `go`, or other build tools will have those commands blocked if they appear as the leading token — users must edit `block-bash.sh` to extend the allowlist
- The allowlist is shared across all projects using the same installed hook script; per-project differentiation requires maintaining separate copies

**Risks:**
- Allowlist too narrow → legitimate build commands blocked → agent stalls (R-001 in risk register). Mitigated by: conservative default list covering universal commands; allowlist is a one-line edit to extend; flagged in validate phase.
- Allowlist too broad → an allowlisted prefix is used to smuggle a blocked command (e.g. `git log | grep secret`) → hook passes when it should deny. Mitigated by: the allowlist checks the *leading command token* only, not the full pipeline; `git log | grep` is allowed by design (git output piped to grep is bounded and intentional).

---

## Related ADRs

- ADR-001 - related-to (allowlist determines when the deny output fires)
- ADR-003 - depends-on (blocking strategy determines the need for an allowlist)

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by adr-agent.*
