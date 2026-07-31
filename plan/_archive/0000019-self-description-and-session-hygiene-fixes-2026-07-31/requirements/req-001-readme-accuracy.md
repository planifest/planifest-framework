---
title: "Requirement: req-001 - README accuracy"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-001 - README accuracy

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000019-self-description-and-session-hygiene-fixes
**Source:** US-001 (backlog 0000014, external review REQ-001)
**Priority:** must-have

---

## User Story

As a framework maintainer, I want the README's counts, paths, and structural claims to match the actual repository, so that a new reader's first check doesn't fail and undermine trust.

---

## Functional Requirements
- Remove the Count column from the framework table in `README.md` entirely (do not correct the figures — they are a drift-generating construct verified wrong on five of seven rows: skills 8 vs 20, templates 24 vs 42, standards 10 vs 16, setup 14 vs 18, hooks 3 vs 8).
- Rewrite each table row to describe its folder by category rather than by enumerating members.
- Fix `README.md:46`, which points to `planifest-framework/feature-structure.md` (does not exist) — correct to `plan/feature-structure.md`.
- Fix `README.md:55`, which shows a `planifest-docs/` directory in the repository-structure diagram where the repo actually has `docs/` — the framework's own CI and hooks encode `docs/` as canonical. The Documentation section's separate, correct reference to the external `planifest-docs` repository (`README.md:144`) is unaffected.
- Align `README.md:42` ("orchestrator + 7 phase skills") and the `setup/` row (enumerates 7 tools; 9 adapters ship, `opencode` and `roo-code` undocumented) so neither carries a member list that will drift again.

## Acceptance Criteria
- [ ] Framework table has no Count column.
- [ ] Every table row describes its folder by category, not by enumerating members.
- [ ] Every path named in the repository-structure diagram resolves to something that exists in the repo.
- [ ] The diagram's documentation entry names `docs/`; the external `planifest-docs` reference in the Documentation section is preserved as-is.
- [ ] `README.md:42` and the `setup/` row no longer enumerate a member list that can drift.

## Dependencies
- None. req-005 (0000018, self-description CI check) depends on this landing first.
