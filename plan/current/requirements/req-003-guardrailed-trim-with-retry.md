---
title: "Requirement: req-003 - Framework Context Bloat Audit"
summary: "Per-file trim with dual-guardrail review and a 5-attempt failure-informed retry before reverting."
status: "active"
version: "0.1.0"
---
# Requirement: req-003 - Framework Context Bloat Audit

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000021-framework-context-bloat-audit
**Source:** US-002
**Priority:** must-have

---

## User Story

As the human running Planifest pipelines, I want redundant/implicit content trimmed from skills, templates, standards, and CLAUDE.md while every enforcement-relevant instruction survives, so that agents spend less context on boilerplate.

---

## Functional Requirements
- For each file listed in the req-002 findings report, apply the recommended trim: remove the flagged redundant/restated/implicit content, preserve everything else verbatim in meaning.
- A second fresh-context reviewer (distinct dispatch from the file's editor, per the maker-checker pattern) diffs the before/after content against the findings report and checks two guardrails:
  1. No Hard Limit, STOP gate, or enforcement-referenced instruction was lost or had its meaning changed.
  2. The remaining wording is not ambiguous in a way likely to increase agent confusion, retries, or escalations versus the original (a "doom loop" risk).
- If either guardrail fails, the specific failure (which guardrail, what broke) is fed into a new trim attempt for that file, using a more conservative reduction informed by the failure. Repeat up to 5 attempts.
- If all 5 attempts fail either guardrail, abandon the trim for that file — it reverts to its original wording — and record a report entry naming the file, the guardrail that failed, and what each attempt tried.
- A file's trim is only committed once it clears both guardrails (or is confirmed reverted after 5 failed attempts). No file is ever left in a partially-trimmed state.
- Never edit any file under `.claude/`. Never restructure the orchestrator into a router + `references/` pattern. Never author a new skill-scope ADR as part of this requirement.

## Acceptance Criteria
- [ ] Every file trimmed per the findings report has a corresponding second-reviewer guardrail check recorded before commit
- [ ] Total line count across `planifest-framework/skills/*/SKILL.md` drops by at least 20% from the 3,959-line baseline, floor only, no fixed ceiling
- [ ] Any file that failed a guardrail shows a retry history (up to 5 attempts) with failure details feeding each subsequent attempt
- [ ] Any file that failed all 5 attempts is confirmed reverted to original wording, with a human-facing report entry
- [ ] `.claude/` has zero changes across every commit in this requirement's work
- [ ] No commit in this requirement's work restructures the orchestrator into a router/`references/` pattern or adds a skill-scope ADR

## Dependencies
- Depends on req-002 (findings report must exist first)
