---
title: "Requirement: req-007 - discovery-md-hard-limit"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-007 - discovery-md-hard-limit

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000018-telemetry-emission-consistency
**Source:** US-003
**Priority:** must-have

---

## User Story

As a human running P0 in any adoption mode, I can trust that discovery.md was actually created and populated before coaching began, because a missing or incomplete one is a pipeline error the orchestrator stops on — not a silently-skipped step I have to notice myself.

---

## Functional Requirements
- Add a new Hard Limit to `planifest-orchestrator/SKILL.md`'s Hard Limits list: `discovery.md` must exist and be populated for the confirmed adoption mode before the first coaching question is asked, in every adoption mode; a missing or incomplete one before coaching begins is a pipeline error — stop and write it before proceeding. Phrasing matches the existing build-log.md Hard Limit 8 pattern.
- Update Phase 0 Start Actions step 3d's text to explicitly cross-reference this new Hard Limit, mirroring how step 2 (build-log creation) already cross-references Hard Limit 8
- Add "discovery.md exists and is complete for the confirmed adoption mode" as a new item in the Phase 0 → Phase 1 Gate Checklist, as a redundant catch independent of the Hard Limit itself

## Acceptance Criteria
- [ ] A new Hard Limit entry exists in `planifest-orchestrator/SKILL.md`, phrased consistently with Hard Limit 8's "stop and write it before proceeding" pattern
- [ ] Phase 0 Start Actions step 3d references the new Hard Limit by number, matching step 2's existing cross-reference to Hard Limit 8
- [ ] The Phase 0 → Phase 1 Gate Checklist includes a discovery.md completeness item

## Dependencies
- None — self-contained skill-file change, independent of req-001 through req-006 (which are all telemetry-specific; this is the self-audit finding folded in mid-P0)

## Source

Self-identified during this feature's own P0: `discovery.md` (0000017 req-006) was silently skipped for this pipeline run because it was a numbered sub-step with no enforcement teeth — the same failure class this feature exists to fix for telemetry emission. Folded in by explicit human confirmation.
