---
title: "ADR 002: Guardrailed, baseline-gated trim process for skill/instruction content"
summary: "Trimming redundant content from live enforcement instructions is costly to reverse if done wrong and constrains how every future content-reduction pass on this framework proceeds, so the process is: record a regression-pack baseline first, apply trims only behind two independent guardrails, and retry with failure-derived corrections up to 5 times before reverting rather than either force-committing or silently discarding a failed trim."
status: "accepted"
version: "0.1.0"
---
# ADR-002 - Guardrailed, baseline-gated trim process for skill/instruction content

**Skill:** [adr-agent](../../../planifest-framework/skills/planifest-adr-agent/SKILL.md)
**Tool:** Claude Code
**Model:** claude-sonnet-5
**Feature:** 0000021-framework-context-bloat-audit
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-08-01

---

## Context

This feature edits the live instruction content that every future Planifest pipeline run loads and follows — `SKILL.md` files, `standards/`, `templates/`, and `CLAUDE.md`. Getting a trim wrong has two distinct, independently-detectable failure modes (both surfaced during the P0 Scope Lock Challenge): (1) an edit technically removes content a hook or gate depends on only through prose, not code, and (2) an edit removes no enforcement content but leaves the remaining wording ambiguous enough to increase future agent confusion, retries, or escalations — a "doom loop" the framework exists to prevent, not cause. Neither failure mode is acceptable, and the second is easy to miss with a content-loss check alone since nothing is technically "lost." The decision affects every file this feature touches (multiple components' worth of instruction surface within `planifest-framework`) and sets the process precedent for any future context-reduction pass on this framework, making it costly to reverse informally once files are already trimmed under a different process.

## Decision

Adopt a three-part process, sequenced and gated as follows:

1. **Baseline before touching anything.** The regression pack (`tests/regression/`) is populated and run once, before any audit or trim work begins, recording pass/fail and this pipeline run's own self-correction/escalation count. No comparison is possible without a "before" state recorded first.
2. **Two independent guardrails, not one.** Every trimmed file is reviewed by a fresh-context reviewer (distinct dispatch from the editor) checking: (a) zero loss of Hard-Limit/STOP-gate/enforcement-referenced content against the req-002 findings report, and (b) no ambiguity regression likely to increase future agent confusion or doom loops. A content-loss check alone does not catch guardrail (b); both are required independently.
3. **Failure-informed retry, capped, then revert — never force-commit, never silently discard.** If either guardrail fails, the specific failure (which guardrail, what broke) feeds into the next attempt, which retries with a more conservative reduction. Up to 5 attempts per file, matching the existing self-correction cap convention already used elsewhere in the framework (P4 validate-agent). If all 5 fail, the file reverts to its original wording and a report names the file, guardrail, and attempts — the human always sees what happened, nothing is silently abandoned or silently forced through.

This whole run's own remaining P1-P9 phases dogfood the trimmed orchestrator and phase skills in real time (this pipeline literally uses `planifest-orchestrator/SKILL.md` for its own remaining phases after that file is trimmed), providing a live functional check beyond the regression pack alone.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Single guardrail: content-loss check only | Simpler, faster review | Misses the ambiguity/doom-loop failure mode entirely — a file could pass with zero enforcement content lost but still be measurably worse to work with | Rejected during Scope Lock Challenge — the human explicitly raised this as a distinct failure case that "must be avoided too" |
| No baseline; compare trimmed output to human intuition only | No prerequisite work, faster start | No objective "before" state to compare against; the human explicitly required baseline-first sequencing during Scope Lock Challenge | Rejected — human directive, and without it the after-trim comparison in req-004 has nothing to measure against |
| Trim once per file, abandon immediately on any guardrail failure (no retry) | Simplest failure handling | Discards the audit's per-file work on the first setback even when a more conservative reduction would likely succeed; wastes the findings-report investment | Rejected — the human asked for informed retry, not immediate abandonment, matching the existing 5-attempt self-correction convention elsewhere in the framework |
| Unlimited retries until guardrails pass | Maximises chance of eventually finding a safe trim | Risks an unbounded loop burning tokens/time on a file that may simply not be safely trimmable | Rejected — capped at 5 to match existing convention and force escalation to the human rather than looping indefinitely |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | Every `SKILL.md`, `standards/*.md`, `templates/*.md`, and `CLAUDE.md` file this feature trims goes through this process; the process itself (baseline-gate, dual-guardrail, 5-attempt retry-then-revert) becomes the documented precedent for any future content-reduction work on this component |

## Consequences

**Positive:**
- Two independent failure modes are each explicitly checked, not just the more obvious content-loss case
- A documented, capped retry process avoids both premature abandonment and unbounded looping
- The baseline makes "did this help or hurt" an objective, recorded comparison rather than a subjective read of the diff

**Negative:**
- Slower than a single-pass trim-and-commit approach — every file requires at minimum a findings-report entry, a trim, and a second-reviewer check, sometimes multiple retry rounds
- Adds process overhead (regression-pack promotion, baseline recording) as a hard prerequisite before any visible progress on the actual bloat problem

**Risks:**
- A file that genuinely cannot be trimmed safely without restructuring may exhaust all 5 attempts and simply revert, leaving the 20% floor target unmet in aggregate if too many files fall into this category — flagged to the human per design.md assumption A-003, not treated as a silent shortfall

---

## Related ADRs

- ADR-001 - related-to (this process consumes ADR-001's audit findings report as its trim input)

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by adr-agent. Path: `plan/current/adr/ADR-002-guardrailed-baseline-gated-trim-process.md`*
