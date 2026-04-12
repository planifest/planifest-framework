---
title: "ADR 003: Blocking Strategy — Unconditional (Grep, WebFetch) vs Pattern-Based (Bash)"
summary: "Grep and WebFetch are blocked unconditionally on every invocation. Bash is blocked only when the command matches a set of context-flooding patterns. The asymmetry reflects the tools' usage profiles: Grep and WebFetch have no safe subset in a context-mode environment; Bash is a general-purpose shell that serves many legitimate purposes."
status: "accepted"
version: "0.1.0"
---
# ADR-003 - Blocking Strategy — Unconditional vs Pattern-Based

**Skill:** adr-agent
**Tool:** claude-code
**Model:** claude-sonnet-4-6
**Feature:** 0000001-context-mode-enforcement-hooks
**Component:** context-mode-hooks
**Status:** accepted
**Date:** 2026-04-12

---

## Context

Three Claude Code tools are targeted by the enforcement hooks: `Grep`, `WebFetch`, and `Bash`. The question is whether each tool should be blocked:

- **Unconditionally** — every invocation of the tool is denied, regardless of input
- **Pattern-based** — only invocations whose input matches a blocked pattern are denied; others are allowed

This is not a uniform decision across the three tools. Each tool has a different usage profile:

- **Grep**: exists solely to search file content. In a context-mode environment, `ctx_execute(language:"shell", code:"grep ...")` is the correct replacement. There is no invocation of Grep that is acceptable — even a "quick" grep floods the context window if the file is large.
- **WebFetch**: fetches a URL and returns the full response body into context. In a context-mode environment, `ctx_fetch_and_index` + `ctx_search` is always the replacement. There is no safe subset of WebFetch usage.
- **Bash**: a general-purpose shell. The majority of Bash invocations are legitimate (git operations, file creation, package installation). Only a specific subset — commands that produce large output or make network calls — need redirection. Blocking all Bash would break normal agent operation entirely.

---

## Decision

**Block Grep and WebFetch unconditionally. Block Bash only when the command matches a blocked pattern, subject to the allowlist (see ADR-002).**

This asymmetric strategy reflects the functional reality:
- Grep and WebFetch are context-flooding by definition in every invocation
- Bash has a safe majority (short-output filesystem and process commands) and an unsafe minority (search, fetch, large-output pipelines)

For Bash, pattern matching is applied to `tool_input.command` from the hook stdin JSON. The blocked tokens are: `grep`, `rg`, `curl`, `wget`, `http://`, `https://`.

An optional `if` field in the `settings.json` hook entry for Bash can be used as a coarse pre-filter to avoid spawning the script for clearly safe commands, but the script itself is the authoritative allowlist check.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Block all three tools unconditionally | Simplest implementation — no pattern logic; smallest attack surface | Blocking all Bash makes the agent unable to run git, create files, or install packages — session becomes non-functional | Rejected — Bash is too general-purpose to block entirely |
| Pattern-match all three tools | Uniform approach; could allow "safe" Grep (e.g. `grep -c` for count only) | Grep pattern safety is hard to define — even a count can be large; adds complexity for marginal benefit; WebFetch has no safe subset | Rejected — Grep and WebFetch have no meaningful safe variant; the complexity cost is not justified |
| Block Bash unconditionally, allow Grep with ctx redirect only | Forces all search through ctx_execute | Same problem as blocking all Bash — breaks git and file operations; worse than pattern-based | Rejected |
| Use `if` field in settings.json as the sole filter for Bash (no script) | No script spawn for non-matching commands | `if` field uses glob-style matching, not regex; cannot express the full blocked-pattern set; allowlist logic is not expressible in `if` alone | Rejected as sole mechanism — `if` is used as an optional pre-filter only |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| context-mode-hooks | `block-grep.sh` and `block-webfetch.sh` are unconditional deny scripts (no input parsing required). `block-bash.sh` must parse `tool_input.command` from stdin JSON and apply pattern + allowlist logic. |
| setup-hook-integration | Three separate hook entries in settings.json — one per tool. No impact on the wiring logic itself. |

---

## Consequences

**Positive:**
- Grep and WebFetch scripts are minimal — no input parsing, no branching; extremely fast and easy to test
- Bash script logic is scoped to a well-defined set of patterns; allowlist is explicit and auditable
- Agents can continue all normal Bash operations (git, file ops, installs) without interruption

**Negative:**
- Agents cannot use Grep at all — even single-file, small-output searches must go through `ctx_execute`. This is intentional but may feel restrictive on small codebases.
- Pattern-based Bash blocking can be circumvented by invoking `grep` via an alias or wrapper script not in the blocked-token list. This is an acceptable limitation for v1 — the hooks enforce routing rules for cooperative agents, not adversarial ones.
- `block-bash.sh` is more complex than the other two scripts; it is the highest-maintenance hook.

**Risks:**
- A blocked Bash pattern appears as a substring inside a string argument (e.g. `echo "run grep to find"`) → false positive block. Mitigated by: pattern matching is applied to the leading command structure, not arbitrary substrings. Document this edge case in the script.
- New context-flooding tools emerge (e.g. a future `GlobalSearch` tool) and are not covered by this hook set. Mitigated by: hooks are additive — new hook scripts can be added in a follow-up feature.

---

## Related ADRs

- ADR-001 - related-to (block output format applies to all three scripts)
- ADR-002 - depends-on (Bash pattern blocking requires an allowlist to be useful)

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by adr-agent.*
