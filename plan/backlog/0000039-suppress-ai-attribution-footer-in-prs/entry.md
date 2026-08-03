---
title: "Backlog Entry: 0000039 - Suppress AI-attribution footer in ship-agent PR output"
summary: "planifest-ship-agent's P9 Step 10 PR description template hardcodes a '🤖 Generated with [Planifest](...) + Claude' footer line; the human asked for it removed when shipping 0000024's PR, suggesting it should be dropped from the template by default rather than edited out per-PR."
status: "open"
---
# Backlog Entry: 0000039 - Suppress AI-attribution footer in ship-agent PR output

**Source feature:** 0000024-declared-product-id-for-telemetry
**Source phase:** P9 (Ship), at the final gate after the human reviewed the generated PR description
**Date filed:** 2026-08-03

---

## Problem

`planifest-framework/skills/planifest-ship-agent/SKILL.md`'s P9 Step 10 ("Option [2] — Human pushes") PR description template ends with a hardcoded line:

```
🤖 Generated with [Planifest](https://github.com/planifest/framework) + Claude
```

This also appears to be the pattern Option [1] (`gh pr create` invoked directly by the agent) would produce, since both paths share the same body template. When shipping feature 0000024, the human explicitly asked to omit this line before the PR was opened ("push and open the PR (without this text)"). This is worth noting against the project's own general instruction (`CLAUDE.md`, "Commit messages: Never add `Co-Authored-By` or any AI attribution... commit-msg hook is blocking") — that rule is scoped to commit messages specifically and enforced by a git hook, but the same underlying preference (no AI-attribution text in artifacts humans will read/publish) plausibly extends to PR descriptions too, which currently has no equivalent enforcement.

## Suggested Action

Remove the hardcoded attribution footer from `planifest-ship-agent/SKILL.md`'s PR description template (both the Option [2] output block and wherever Option [1]'s `gh pr create --body` construction shares the same template). Consider whether this should be a hard removal or a toggle (e.g. respecting a `planifest-overrides/instructions/` file the same way `local-git-only` already gates push behaviour), in case some adopters want attribution and others don't — that's a design decision for whoever picks this up, not decided here.

## Why Deferred

Discovered live at a single PR's ship gate, not part of 0000024's own requirements (which were about telemetry `product_id` and `emit_event`, unrelated to PR formatting). The immediate instance was handled inline (PR #50 opened without the footer); the underlying template default is a separate, small fix warranting its own pickup rather than a rushed in-flight skill edit during an active P9.
