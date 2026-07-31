---
title: "Requirement: REQ-006 - Setup failure handling"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-006 - Setup failure handling

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000020-setup-refresh-skill
**Source:** US-002
**Priority:** must-have

---

## User Story

As a human on the loop, if the re-invoked setup script fails partway through, I want to know exactly what happened and how to retry, rather than being left guessing whether the refresh half-succeeded.

---

## Functional Requirements
- If the re-invoked `setup.sh`/`setup.ps1` exits non-zero or otherwise fails partway through, the skill stops immediately — it does not retry automatically
- The skill investigates the likely cause available to it (e.g. checks whether the target path reported in the failure is locked, permission-denied, or held by another process) and includes that in its report
- The skill reports: what the setup script's own output said, which step it reached, and that `CLAUDE.md`/`AGENTS.md` may now be missing pending a successful rerun
- The skill prints the exact command it attempted as a copyable code block
- The skill confirms `settings.local.json` and other user-owned files were never touched (they were never part of the deletion allowlist regardless of this failure)
- The reconstructed flags and attempted command remain cached in `.claude/.planifest-setup-flags` (written before deletion, per REQ-004/REQ-009) so a retry does not need to repeat detection

## Acceptance Criteria
- [ ] A non-zero exit or partial failure from the re-invoked setup script halts the skill with no automatic retry
- [ ] The failure report includes: setup's own reported output, the step reached, an investigated likely cause (lock/permission/held-by-process, where determinable), and the exact attempted command as a code block
- [ ] The report explicitly states user-owned files were not touched
- [ ] The cached marker file (REQ-009) still contains the attempted flags/command after a failure, ready for a retry to read

## Dependencies
- REQ-005 (this is the failure branch of that step)
- REQ-009 (relies on the marker-file cache written before deletion)
