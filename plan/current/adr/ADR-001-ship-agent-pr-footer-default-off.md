---
title: "ADR 001: Ship-agent PR footer default-off, opt-in via repo instruction"
summary: "The ship-agent's PR description template (both gh pr create and human-push paths) drops the hardcoded AI-attribution footer by default; adopters who want it back add a planifest-overrides/instructions/ file, mirroring the existing local-git-only override pattern."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - Ship-agent PR footer default-off, opt-in via repo instruction

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Component:** planifest-framework
**Date:** 2026-08-03

## Context

`planifest-ship-agent/SKILL.md` P9 Step 10 renders a PR description from a shared template. Both delivery paths use it: Option [1] (`gh pr create --body`, agent pushes) embeds `{PR description — see template below}` directly into the heredoc body; Option [2] (human pushes) prints the same sections as a fenced markdown block for copy-paste. As currently written, the Option [2] block ends with a hardcoded line:

```
🤖 Generated with [Planifest](https://github.com/planifest/framework) + Claude
```

This was flagged live during feature 0000024's P9 ship gate (backlog entry `0000039-suppress-ai-attribution-footer-in-prs`): the human explicitly asked to omit the line before the PR was opened. The backlog entry's own "Suggested Action" section left the fix mechanism as "a design decision for whoever picks this up" — specifically whether removal should be unconditional or gated by a repo-level opt-in — and `req-001-ship-agent-pr-footer.md`'s Dependencies section defers "the exact opt-in override mechanism/keyword" to this ADR.

The repo already has a working precedent for this exact shape of problem: Step 10's own push/PR prompt is itself gated by a `planifest-overrides/instructions/` check — `custom-001-local-git-only.md` is scanned for the strings "local-git-only", "no remote", or "no push" before Step 10 asks whether to push. This is a live, in-skill example of adopter-configurable repo behavior sitting outside the skill file itself, not a hypothetical pattern.

Two options were considered for how attribution restoration should work:

- (a) Hard removal — delete the footer line unconditionally, with no mechanism to bring it back short of editing `planifest-ship-agent/SKILL.md` directly.
- (b) Opt-in override — default to no footer, but let an adopter restore it by dropping a file into `planifest-overrides/instructions/`, checked the same way `local-git-only` is checked.

## Decision

Adopt option (b). Step 10 defaults to no AI-attribution footer in the PR description, on both Option [1] and Option [2] paths, since they share the same template body. Before rendering the PR description (immediately after the existing `local-git-only` check, in the same Step 10 preamble), the ship-agent scans `planifest-overrides/instructions/` for any file whose contents match the keyword `restore-pr-attribution` (case-insensitive substring match, same matching style as the existing local-git-only scan). If a match is found, the footer line `🤖 Generated with [Planifest](https://github.com/planifest/framework) + Claude` is appended as the final line of the PR description in both paths. If no match is found, the footer is omitted entirely and no other template section changes.

An adopter who wants attribution restored creates `planifest-overrides/instructions/custom-{NNN}-restore-pr-attribution.md`, numbered as the next available `custom-NNN` slot, following the same file shape as `custom-001-local-git-only.md` (a short markdown note stating the intent — the exact prose is not load-bearing, only the `restore-pr-attribution` keyword match is). No new config format, flag, or schema is introduced.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| (a) Hard removal, no toggle | Simplest possible change; one line deleted, nothing to check | Forecloses adopters who want attribution without editing framework-owned skill source directly; inconsistent with this repo's own established pattern of adopter-configurable behavior via `planifest-overrides/instructions/` | Removes a real, previously-exercised choice (the human did ask for the footer historically, via `Co-Authored-By` conventions elsewhere in this repo) for no material simplicity gain |
| (b) Opt-in via `planifest-overrides/instructions/` (chosen) | Consistent with existing `local-git-only` gating; zero new mechanism — reuses the same directory, scan style, and file-naming convention already in place; adopters self-serve without touching framework source | One more conditional branch in Step 10; a typo'd or missing keyword silently produces no footer (fails safe, but silently) | None — matches precedent and preserves adopter choice at negligible cost |
| New dedicated config flag (e.g. `product.yml` field) | Structured, discoverable via schema | Introduces a new config surface for a single boolean, when `planifest-overrides/instructions/` already exists for exactly this class of decision | Overkill relative to the existing override pattern; not requested by any requirement |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | `planifest-ship-agent/SKILL.md` Step 10: template default changes to footer-off; preamble gains one additional `planifest-overrides/instructions/` scan alongside the existing `local-git-only` scan. No other component reads or depends on the PR description output. |

## Consequences

**Positive:**
- Every PR raised by the ship-agent (via either delivery path) is footer-free by default, matching the human's explicit preference recorded at 0000024's P9 gate and the spirit of `CLAUDE.md`'s commit-message attribution rule, without per-PR manual editing.
- Adopters who want attribution back get it via a self-service, repo-local file — no framework fork, no skill edit, and no re-litigation of this decision per project.

**Negative:**
- Step 10 now performs two independent `planifest-overrides/instructions/` scans (local-git-only, restore-pr-attribution) instead of one; a future third override in this style will make the preamble progressively less readable unless the pattern is later generalized into a single lookup helper.

**Risks:**
- If an adopter names their override file with the wrong keyword (e.g. "add attribution" instead of "restore-pr-attribution"), the scan silently fails to match and the footer stays off — no error is surfaced. This fails toward the new default (no footer) rather than toward unwanted attribution, which is the safer failure direction, but it may confuse an adopter who expects the footer and doesn't get it.

## Related ADRs

- None — no prior ADR addresses PR description content in this repo.

## Supersedes

- None.

## Superseded By

- None.
