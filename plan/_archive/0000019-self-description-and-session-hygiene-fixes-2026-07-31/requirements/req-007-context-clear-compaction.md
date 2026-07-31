---
title: "Requirement: req-007 - orchestrator context clear and compaction"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-007 - orchestrator context clear and compaction

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000019-self-description-and-session-hygiene-fixes
**Source:** US-003 (backlog 0000012)
**Priority:** should-have

---

## User Story

As a human running a long pipeline session, I want context cleared at Phase 0 start and Phase 9 completion, and compacted when it grows wasteful mid-run, so that residual or stale context doesn't degrade agent behaviour.

---

## Functional Requirements
- **Phase 0 context reset:** the orchestrator issues a `/clear` (or tool-equivalent) at the very start of a session entering Phase 0. If the host platform doesn't support programmatic clearing, the orchestrator explicitly flags this to the human to do manually before proceeding.
- **Dynamic context compaction:** the orchestrator monitors for redundant or wasteful context accumulation during a long-running session and prompts for (or performs) compaction when identified. This is advisory/best-effort, not a hard gate — it must not block pipeline progress.
- **P9 completion context clear:** once P9 ship activities finish, the orchestrator issues a `/clear` (or tool-equivalent) so the next session starts cold. Same host-support fallback as Phase 0.
- Document all three trigger points in `.claude/skills/planifest-orchestrator/SKILL.md` at the relevant phase sections (Phase 0 Start Actions, and the P9/Ship section).

## Acceptance Criteria
- [ ] Orchestrator SKILL.md documents a `/clear`-or-flag step at Phase 0 start.
- [ ] Orchestrator SKILL.md documents a `/clear`-or-flag step after P9 completes.
- [ ] Orchestrator SKILL.md documents the dynamic-compaction monitoring behaviour as advisory, non-blocking.
- [ ] Host-unsupported fallback (explicit flag to the human) is documented for both clear points.

## Dependencies
- None.
