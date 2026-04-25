---
id: ADR-008
title: Blocking commit-msg hook (exit 1 on violation)
status: superseded
date: 2026-04-20
amended: 2026-04-25
deciders: [human-on-the-loop]
---
# ADR-008 — Blocking commit-msg hook

## Context

REQ-023 requires a commit message standard enforced via a `commit-msg` Git hook. The original decision (2026-04-20) made the hook advisory (exit 0). This was amended after AI agents were observed appending `Co-Authored-By` attribution lines that violate the standard — advisory warnings were insufficient to change agent behavior.

## Decision

The `commit-msg` hook is **blocking**: it exits 1 on any violation, preventing the commit from proceeding. `git commit --no-verify` remains available as a deliberate human bypass.

## Rationale

1. **Advisory hooks don't change agent behavior.** AI agents follow system-level instructions to append attribution; a warning printed after the fact is invisible to that decision path. Only a hard block at commit time is effective.
2. **`--no-verify` is a deliberate opt-out.** A human who needs to bypass for an emergency can do so explicitly. The original "bypass parity" argument conflated ease of bypass with reason to not enforce.
3. **CLAUDE.md reinforces the rule.** The blocking hook is a second layer — `CLAUDE.md` states the rule, the hook enforces it mechanically.
4. **Consistent with gate-write philosophy.** Planifest already uses blocking hooks for write enforcement; commit message enforcement should follow the same model.

## Alternatives considered

- **Advisory hook (exit 0):** Original decision. Insufficient — AI agents ignore warnings appended post-commit.
- **No hook, documentation only:** Rejected. No feedback loop at commit time.

## Consequences

- Commits with AI attribution, affirmatory language, or >72-char subjects will fail until the message is corrected.
- `git commit --no-verify` bypasses the hook — this is intentional for human emergencies.
- The `CLAUDE.md` rule is the primary agent-facing enforcement; this hook is the mechanical backstop.
