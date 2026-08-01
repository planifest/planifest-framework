---
title: "ADR 001: claude-opus-5 model-tier override for the content audit subagent"
summary: "The req-002 audit pass runs on claude-opus-5 instead of the Model Tier Decision Table's default primary tier (Sonnet), because judging what is redundant vs. load-bearing across an entire instruction corpus is exactly the kind of high-stakes, whole-corpus judgement call the table already reserves for the strongest available reasoning tier."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - claude-opus-5 model-tier override for the content audit subagent

**Skill:** [adr-agent](../../../planifest-framework/skills/planifest-adr-agent/SKILL.md)
**Tool:** Claude Code
**Model:** claude-sonnet-5
**Feature:** 0000021-framework-context-bloat-audit
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-08-01

---

## Context

The Model Tier Decision Table in `planifest-orchestrator/SKILL.md` maps "Primary" tier to Sonnet for Claude Code, reserved for tasks needing multi-file reasoning and correctness (code generation, security review, ADR writing). The req-002 audit task — reading every `SKILL.md`, `standards/*.md`, `templates/*.md`, and `CLAUDE.md`, then classifying each section as load-bearing (Hard Limits, STOP gates, enforcement-referenced instructions, non-obvious conventions) versus redundant/model-implicit — is a judgement call across the entire framework's instructional surface at once, with a real cost of getting it wrong in either direction: under-trimming leaves the bloat problem unsolved, over-trimming risks the R-001/R-003 failure modes in the risk register (silent enforcement-content loss, ambiguity-induced doom loops). The human running this pipeline explicitly requested Opus 5 for this specific task when scoping the feature.

## Decision

Dispatch the req-002 audit as a fresh-context subagent on `claude-opus-5`, overriding the Model Tier Decision Table's default primary-tier (Sonnet) mapping for this one requirement only. This is a feature-scoped override, not a change to the table itself — it does not alter the default tier for any other requirement in this feature or any other feature. The override and its rationale are recorded here rather than silently deviating from the table, so future audits of this feature (or future features referencing the table) can see why the deviation happened. If `claude-opus-5` is unavailable at dispatch time (per design.md assumption A-002), degrade to the default primary tier and record a build-log note — do not block the pipeline on model availability.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Use default primary tier (Sonnet) per the standard table | No table deviation, no ADR needed | Weaker judgement on a whole-corpus classification task with asymmetric downside risk (R-001, R-003) | Rejected — the task profile matches exactly what the table reserves the strongest tier for, and the human explicitly requested it |
| Use cheaper tier (Haiku) with a second-pass Sonnet review | Faster, cheaper first pass | Cheaper tier is documented in the table as unsuitable for anything requiring synthesis or judgement; would likely need the same second-guardrail review this feature already has, doubling review cost for a worse first pass | Rejected — no efficiency gain once the mandatory second-reviewer guardrail (req-003) is accounted for |
| Run the audit as this orchestrator's own inline reasoning, no subagent dispatch | Simpler, no dispatch overhead | Not fresh-context — the orchestrator's context is polluted by the full P0 coaching conversation, risking bias toward decisions already discussed rather than an independent read of each file; also not Opus 5, since this session runs on Sonnet | Rejected — fresh-context independence is required by req-002's acceptance criteria |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | The req-002 audit subagent dispatch is scoped to this feature's `plan/current/` work; no change to the framework's own Model Tier Decision Table or its defaults for other features |

## Consequences

**Positive:**
- Highest-capability judgement applied to the highest-risk classification task in the feature (asymmetric downside: silent enforcement-content loss)
- Deviation is documented rather than silent, so it doesn't read as an unexplained inconsistency against the Model Tier Decision Table in a later audit

**Negative:**
- Higher per-call cost than the default primary tier for this one dispatch
- Establishes a precedent that individual features may request tier overrides; if this happens frequently without ADRs, the Model Tier Decision Table's authority erodes

**Risks:**
- If `claude-opus-5` becomes unavailable mid-pipeline (e.g. a later resumed session), the audit must degrade gracefully per assumption A-002 rather than block — implemented as a build-log note, not a hard failure

---

## Related ADRs

- ADR-002 - related-to (the audit's findings report is the direct input to ADR-002's guardrailed trim process)

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by adr-agent. Path: `plan/current/adr/ADR-001-opus5-model-tier-override-for-audit.md`*
