---
title: "Requirement: req-006 - em dash write-time guard and cleanup"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-006 - em dash write-time guard and cleanup

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source:** US-006
**Priority:** should-have

## User Story

As a human on the loop, I want a deterministic check that rejects em dashes in Planifest artifacts at write time, plus a one-off cleanup of existing live artifacts, so that the rule is enforced instead of re-explained every session.

## Functional Requirements

Covers backlog 0000026, deliberately scoped hard by the human on the loop at P0. Only the em dash character (U+2014) is in scope. The broader AI writing-tells list from 0000026's own suggested action (hedging, "it's not just X, it's Y" constructions, filler section headers) is explicitly deferred; nothing in this requirement is blocked by that deferral.

### The guard

- **Attachment point:** a `PreToolUse` hook on `Write` and `Edit`, following the `gate-write.mjs` precedent (`planifest-framework/hooks/enforcement/gate-write.mjs`), not the `commit-msg` git-hook precedent. A git hook only inspects the commit message, not artifact content, and would let an em dash land in the file itself before any check ran. `gate-write.mjs` already reads `tool_input.path`/`tool_input.file_path` from the same JSON envelope this check needs, and already exits 2 to block — the new check is a sibling hook in `planifest-framework/hooks/enforcement/`, not a modification of `gate-write.mjs` itself, so a defect in one never disables the other.
- The check reads the content being written (`tool_input.content` for `Write`, `tool_input.new_string` for `Edit`) and scans for U+2014. It never retroactively scans the existing file or the repo; matching the `commit-msg` precedent of inspecting only what is being committed right now.
- Scope of enforcement: `plan/current/`, `docs/`, and `planifest-framework/skills/`, `planifest-framework/templates/`, `planifest-framework/standards/`. This mirrors the cleanup scope below. Paths outside this set (source code, `plan/_archive/`, `plan/changelog/`, this repo's own test fixtures) are not gated, since the rule is about Planifest prose artifacts, not code or historical record.
- On a match: exit 2, print the offending line number and a short message naming the character and the bypass path (below). Fail open on any unexpected error reading or parsing stdin, consistent with every other enforcement hook in this repo (ADR-005) — a bug in this check must never block an unrelated write.

### Bypass mechanism (open question closed here)

`commit-msg`'s bypass is `git commit --no-verify`, a flag Git itself provides. A `PreToolUse` hook has no equivalent built-in escape hatch — Claude Code does not offer a per-call "skip this hook" flag. This requirement specifies the bypass explicitly rather than assuming one exists:

- A single-line sentinel comment, `<!-- planifest-em-dash-allow -->`, present anywhere in the content being written, allows that write through regardless of em dash matches. This follows the existing single-use human-marker precedent in this repo (`plan/current/.ratchet-approve`, used by `ratchet-check.mjs`) but is reusable rather than single-use, since a legitimate em dash (a literal quotation containing one, for example) is not a one-off event the way a ratchet weakening is.
- The sentinel is a deliberate, visible marker a human or agent must type into the artifact itself, not a hook config flag or environment variable, so the bypass is auditable in the artifact's own diff rather than invisible in tool configuration.
- This differs from `commit-msg`'s bypass in kind (an in-content marker instead of a CLI flag) because the attachment point differs in kind (a content-inspecting hook instead of a message-inspecting git hook). The requirement records this as a deliberate deviation from the git-hook precedent, not an oversight.

### The cleanup

Bounded to live artifacts only, matching the scope list above. `plan/_archive/` and `plan/changelog/` are explicitly excluded: they are historical record, and rewriting shipped artifacts to satisfy a rule introduced after they shipped would falsify the audit trail.

Scoped grep run against this repo at spec time, counting the live-artifact subset (`plan/current/`, `docs/`, `planifest-framework/skills/`, `planifest-framework/templates/`, `planifest-framework/standards/`):

- **99 files** contain at least one U+2014 em dash across that scope.
- **772 total occurrences** of U+2014 across those 99 files.
- Breakdown by directory: `plan/current/` 1 file (`build-log.md`), `docs/` 7 files, `planifest-framework/skills/` 20 files, `planifest-framework/templates/` 20 files, `planifest-framework/standards/` 51 files.
- For contrast, the same character across the whole repository (excluding `.git/`) totals 1,010 files; the live-artifact scope above is the subset this requirement's cleanup actually touches.

The cleanup is not a mechanical find-and-replace. An em dash's correct replacement depends on the sentence it sits in: it usually becomes a comma, a colon, or a full sentence break, and no single substitution is correct across all 772 occurrences.

## Acceptance Criteria

- [ ] A `PreToolUse(Write, Edit)` hook exists in `planifest-framework/hooks/enforcement/` that blocks (exit 2) a write containing U+2014 within the scoped paths, and passes (exit 0) outside those paths or when the sentinel bypass is present.
- [ ] The bypass mechanism (`<!-- planifest-em-dash-allow -->`) is documented in the hook's own header comment and in `planifest-framework/standards/` alongside the other enforcement hooks.
- [ ] The hook fails open (exit 0) on any stdin parse error or unexpected exception, consistent with every other hook in `planifest-framework/hooks/enforcement/`.
- [ ] `setup.sh`/`setup.ps1` wiring for the new hook is added following the existing `gate-write.mjs` registration pattern, so a fresh install picks it up.
- [ ] All 99 identified live-artifact files are reviewed; each em dash is either replaced with a context-appropriate comma, colon, or sentence break, or left in place behind the sentinel bypass with a stated reason.
- [ ] `plan/_archive/` and `plan/changelog/` are confirmed untouched by the cleanup (zero diff against those paths).
- [ ] The full cleanup diff is presented for human-on-the-loop review at P4, itemised by file, before being considered complete — not auto-applied and merged without that review, given the risk that a mechanical pass gets some instances contextually wrong.
- [ ] A re-run of the same scoped grep after cleanup returns zero matches across the five scoped paths, or an explicit list of intentionally-retained em dashes behind the sentinel bypass.

## Dependencies

- `gate-write.mjs` (`planifest-framework/hooks/enforcement/gate-write.mjs`) as the structural precedent for hook shape, stdin envelope, and exit-code convention.
- `ratchet-check.mjs` and its `.ratchet-approve` marker as the precedent for an in-repo human-authored bypass marker.
- `setup.sh` / `setup.ps1` hook registration, for wiring the new hook into a fresh install.
- P4 validate-agent, for the human-reviewable diff review gate on the cleanup.
