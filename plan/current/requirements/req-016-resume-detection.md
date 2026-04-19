---
title: "Requirement: REQ-016 - Resume detection on orchestrator re-entry"
summary: "When plan/current/ artefacts exist, the orchestrator resumes at the correct phase rather than restarting P0."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-016 - Resume detection on re-entry

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-15; DD-009
**Priority:** must-have

---

## Functional Requirements

- On orchestrator invocation, before presenting the P0 briefing, scan `plan/current/` for existing artefacts.
- If `plan/current/feature-brief.md` exists, an in-progress feature is detected.
- The orchestrator determines the furthest completed phase by checking for artefact presence in order: design.md → execution-plan.md + requirements/ → ADRs → src/ implementation → validate results → security review → docs → ship.
- The orchestrator opens with: `Px: Resuming {feature-id} — {phase-name} in progress. {brief status summary}.`
- The P0 briefing (phase table, tool detection, hooks check) is NOT repeated on resume — it was already completed.
- If `plan/current/.skips` exists, the orchestrator reads and acknowledges the skipped phases.
- If `plan/current/.feature-id` exists and its contents differ from the feature currently being started, the orchestrator warns: `"P0: ⚠ plan/current/ contains artefacts for feature {X}. Archive manually or load that feature."` It does not auto-proceed.

## Acceptance Criteria

- [ ] Re-entering the orchestrator with `plan/current/feature-brief.md` present does not trigger the P0 briefing.
- [ ] The resume message includes the feature ID and current phase name.
- [ ] Skipped phases from `.skips` are acknowledged in the resume message.
- [ ] Resuming at P3 (codegen in progress) correctly identifies and loads the right phase state.
- [ ] `.feature-id` present with a different feature ID triggers a stale-artefacts warning and halts auto-resume.

## Dependencies

- REQ-017 (phase skip tracking — `.skips` file must exist for resume to read it).
- DD-009 (artefact detection order is specified there).
