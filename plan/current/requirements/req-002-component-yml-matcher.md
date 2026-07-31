---
title: "Requirement: req-002 - component.yml matcher fix"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-002 - component.yml matcher fix

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000019-self-description-and-session-hygiene-fixes
**Source:** US-002 (backlog 0000015, external review REQ-002)
**Priority:** must-have

---

## User Story

As a repo adopter, I want the shipped `pre-push`/`pre-commit` hooks (and this repo's own CI) to match against `component.yml` — the framework's real manifest filename — so that a change to `src/` which correctly updates its manifest isn't falsely rejected.

---

## Functional Requirements
- Replace every live matcher referencing `component.json` (or the escaped regex `component\.json`) with `component.yml` in: `.github/workflows/planifest.yml` (lines 26, 37), `planifest-framework/hooks/planifest.yml` (lines 26, 37), `planifest-framework/hooks/pre-push` (lines 22, 38), `planifest-framework/hooks/pre-commit` (line 8).
- Replace stale prose mentions in comments and error strings: `pre-push` (lines 20, 25, 34, 37, 45), `pre-commit` (line 11).
- This is a false-rejection bug, not an enforcement hole — the standard matcher `^(plan/|docs/|.*component\.json)` still lets `plan/` and `docs/` changes through; only the `component.json` alternative is wrong. Do not change the overall matcher structure, only the manifest filename it references.
- Verify no remaining occurrence with both a fixed-string search for `component.json` and a regex-aware search for `component\.json` — the workflow/hook files use the escaped form, which a fixed-string search misses, while the plain-text comment mentions are missed by a regex-only search.

## Acceptance Criteria
- [ ] No occurrence of `component.json` or `component\.json` remains outside `plan/_archive/`.
- [ ] A new test asserts that a change touching only `src/` plus a `component.yml` update, with no `plan/` or `docs/` change, **passes** — this is the case currently broken.
- [ ] A new test asserts that a change touching only `src/`, with no manifest, `plan/`, or `docs/` change, **fails**.
- [ ] Both new tests run against the shipped `planifest-framework/hooks/pre-push` and `planifest-framework/hooks/pre-commit` directly, not only against the GitHub Actions workflow.

## Dependencies
- None. Shares file scope with req-003 (0000016) — both edit the same hook/workflow strings; sequence-safe to implement together.
