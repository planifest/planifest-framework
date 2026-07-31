---
title: "Requirement: req-005 - repository self-description CI check"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-005 - repository self-description CI check

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000019-self-description-and-session-hygiene-fixes
**Source:** US-001 (backlog 0000018, external review REQ-004)
**Priority:** must-have

---

## User Story

As a framework maintainer, I want CI to catch future README-vs-repository drift automatically, so that the class of defect req-001 fixes doesn't recur silently.

---

## Functional Requirements
- Add a **new repository-scoped script** (not an extension of `planifest-framework/scripts/consistency-check.mjs` — that script validates `plan/current/` during a feature run with exit-code semantics tied to the design-critic; README-vs-filesystem accuracy is a repository invariant on a different lifecycle, checked on every PR regardless of whether a feature is in flight).
- The script verifies: every path named in the README repository-structure diagram exists, and every folder under `planifest-framework/` has a corresponding row in the framework table.
- Wire it to run on pull request in `.github/workflows/planifest.yml`.
- On failure, the script names the specific divergent path or missing row — not a generic failure message.
- Scope note: since req-001 removes the Count column, this check verifies existence and coverage only — it counts nothing, which is what keeps it stable against future additions.

## Acceptance Criteria
- [ ] New script exists at a repository-scoped path (not inside `consistency-check.mjs`).
- [ ] Verifies every structure-diagram path resolves to something that exists.
- [ ] Verifies every `planifest-framework/` folder has a framework-table row.
- [ ] Runs on pull request.
- [ ] Failure output names the specific divergent path or row.

## Dependencies
- **Depends on req-001 (0000014)** — this check must encode the corrected structure, not the pre-fix one. Implement after req-001 lands.
