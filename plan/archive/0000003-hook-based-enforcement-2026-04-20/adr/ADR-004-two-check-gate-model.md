---
title: "ADR-004: Two-check path gate for write enforcement (existence + prefix matching)"
summary: "gate-write.mjs enforces writes via two checks: design.md existence, then path-prefix membership against the component paths list. LLM-based scope reasoning and exact-match approaches were rejected."
status: "accepted"
version: "0.1.0"
---
# ADR-004 - Two-check path gate for write enforcement

**Skill:** [adr-agent](../../planifest-framework/skills/planifest-adr-agent/SKILL.md)
**Tool:** claude-code
**Model:** claude-sonnet-4-5
**Feature:** 0000003-hook-based-enforcement
**Component:** planifest-framework/hooks/enforcement/gate-write.mjs
**Status:** accepted
**Date:** 2026-04-18

---

## Context

The write gate must answer two questions before allowing a file write to proceed:
1. Has a confirmed design been produced (i.e. is there a `plan/current/design.md`)?
2. Is the target file path within the approved component scope of that design?

Several approaches exist for answering question 2. The choice affects how easy it is to correctly configure scope, how brittle the gate is, and whether the gate can be fooled or bypassed.

The gate runs as a hook script with no LLM access, no network, and no npm dependencies. It must complete in milliseconds.

---

## Decision

**Check 1 — Always-permitted paths:** `plan/`, `docs/`, `CLAUDE.md`, `AGENTS.md` pass immediately. These are planning and documentation artefacts that must never be blocked (otherwise plan-phase work becomes self-blocking).

**Check 2 — Design existence:** If the target is not always-permitted and `plan/current/design.md` does not exist, block with exit code 2.

**Check 3 — Path prefix membership:** If `design.md` exists, extract the component paths list from the design (canonical heading: `## Component Paths` or `## Scope`). The target path must match at least one listed prefix (case-insensitive, normalised separators). If no match, block with exit code 2.

Path matching uses prefix comparison: a listed path of `planifest-framework/hooks/` permits any file under that directory. The target path is resolved to an absolute path and compared against `{cwd}/{listed_prefix}`.

**Failure fallback:** If `design.md` exists but the component paths section cannot be parsed (unrecognised heading format), the gate logs a warning to stderr and passes through (does not block). This prevents misconfigured design files from blocking all writes.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| LLM-based scope reasoning (prompt hook) | Nuanced understanding; handles ambiguous paths | Requires LLM call per write; slow; not deterministic; defeats the purpose of hook-based enforcement | Removes the determinism that makes hooks valuable; too slow |
| Exact file match (each permitted file listed individually) | Maximum precision | Impractical at scale; design.md would list hundreds of files; breaks on file renames | Not maintainable |
| Glob pattern matching | Flexible | Requires a glob library or reimplementation; adds complexity; patterns easy to misconfigure | Prefix matching covers the common case; glob adds dependency and complexity for marginal benefit |
| Existence check only (no path membership) | Simpler implementation | Does not prevent out-of-scope drift once design exists; only catches pre-design writes | Fails AC-6; "design exists" is not sufficient enforcement once the project is in codegen |
| Allowlist file separate from design.md | Decouples enforcement config from design | Additional file to maintain; sync risk between design and allowlist | design.md is the single source of truth; splitting creates divergence |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| `planifest-framework/hooks/enforcement/gate-write.mjs` | Implements the three-check model |
| `plan/current/design.md` | Must use canonical `## Component Paths` heading for gate to parse correctly |
| All per-tool adapter scripts | Must pass `cwd` correctly in common envelope so path resolution is accurate |
| `planifest-framework/skills/planifest-codegen-agent/SKILL.md` | Must produce design.md with the canonical heading format |

---

## Consequences

**Positive:**
- Deterministic, fast, zero LLM dependency — runs in microseconds
- Single source of truth: component paths in design.md drive both documentation and enforcement
- Prefix matching is intuitive: declare `src/payments/` and all files under it are permitted

**Negative:**
- Gate depends on design.md being correctly formatted with the canonical heading. A typo in the heading silently disables path-membership enforcement (falls through to pass-through mode)
- Cannot understand semantic scope — a file path that "should" be out of scope but happens to be under a permitted prefix will pass. E.g. `planifest-framework/hooks/unrelated-experiment.mjs` passes if `planifest-framework/hooks/` is listed
- Always-permitted list (`plan/`, `docs/`) is hardcoded; if the project layout changes, the list must be updated in the script

**Risks:**
- Design.md heading format must be documented and enforced in the codegen-agent SKILL.md. If the format diverges, the gate silently degrades to pass-through mode (R-006 in risk register).

---

## Related ADRs

- ADR-001 - related-to (gate applies to all tiers via shared script)
- ADR-002 - depends-on (cwd from common envelope is required for path resolution)
- ADR-005 - related-to (parse failure falls through to pass-through per exit-0 policy)

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by adr-agent. Path: `plan/current/adr/ADR-004-two-check-gate-model.md`*
