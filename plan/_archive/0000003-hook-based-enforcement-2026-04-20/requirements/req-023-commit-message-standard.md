---
title: "Requirement: REQ-023 - Commit message standard"
summary: "A commit message standard document and advisory commit-msg hook. Messages must be concise, scope-focused, and must not attribute authorship to AI tools."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-023 - Commit message standard

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Priority:** must-have

---

## Functional Requirements

- A standards document is created at `planifest-framework/standards/commit-standards.md` defining the commit message format.
- An advisory `commit-msg` hook is added at `planifest-framework/hooks/commit-msg`.
- `setup.sh` wires the `commit-msg` hook alongside `pre-commit` and `pre-push` (already registered via `git config core.hooksPath`).
- `standard-boot.md` gains a one-line reference to commit standards under Operational Directives.

### Commit message rules (normative)

- **Subject line:** imperative mood, present tense, ≤72 characters.
- **Format:** `type(scope): description` where `type` is one of `feat | fix | docs | chore | refactor | test | perf`. Scope is the feature ID or component ID.
- **No AI attribution:** The subject and body MUST NOT contain `Co-Authored-By:`, `co-developed`, `AI-assisted`, tool names (Claude, Copilot, Cursor, etc.), or model names.
- **No affirmatory language:** No "Done!", "Fixed!", "Working now", "Claude helped", or similar confirmation phrasing.
- **No contradictory messaging:** Do not include both a description of change and a reversal of it in the same message.
- **Authorship:** Commits are owned solely by the human practitioner. The commit author field identifies the human, not the tool.

### Hook behaviour

- The `commit-msg` hook is **advisory**: it exits 0 (warning only) on violation. It does not block the commit.
- It prints a clearly formatted warning listing each violated rule.
- This is consistent with the Tier-1 advisory pre-commit pattern (ADR-008).

## Acceptance Criteria

- [ ] `planifest-framework/standards/commit-standards.md` exists and covers all rules above.
- [ ] `planifest-framework/hooks/commit-msg` is executable and installed by `setup.sh`.
- [ ] Hook warns and exits 0 on: AI attribution string, affirmatory phrase, subject line > 72 chars.
- [ ] Hook exits 0 silently on a conforming message.
- [ ] `standard-boot.md` references commit standards.

## Dependencies

- `setup.sh` already uses `git config core.hooksPath planifest-framework/hooks` — no change needed to hook registration mechanism.
