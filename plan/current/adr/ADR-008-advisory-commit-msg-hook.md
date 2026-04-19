---
id: ADR-008
title: Advisory commit-msg hook (exit 0, warn only)
status: accepted
date: 2026-04-20
deciders: [human-on-the-loop]
---
# ADR-008 — Advisory commit-msg hook

## Context

REQ-023 requires a commit message standard enforced via a `commit-msg` Git hook. The question is whether the hook should be blocking (exit 1 — prevents the commit) or advisory (exit 0 — warns but allows the commit).

## Decision

The `commit-msg` hook is **advisory**: it exits 0 on any violation, printing a human-readable warning, and never prevents the commit from proceeding.

## Rationale

1. **Consistency with existing hook philosophy.** The `pre-commit` hook (Tier 1 guardrail) is also advisory. Commit-msg follows the same pattern.
2. **Bypass parity.** A blocking hook can always be bypassed with `git commit --no-verify`. An advisory hook achieves the same outcome without creating a false sense of enforcement.
3. **Human autonomy.** The Human on the Loop is the author of record. Blocking their commit over message style is paternalistic. The standard is guidance; the hook is a reminder.
4. **Emergency path.** In a time-pressured situation (hotfix, incident), a blocked commit creates friction with no safety benefit.

## Alternatives considered

- **Blocking hook (exit 1):** Rejected. False enforcement — `--no-verify` trivially bypasses it. Creates friction with no meaningful safety gain.
- **No hook, documentation only:** Rejected. No feedback loop at commit time. The standard becomes invisible.

## Consequences

- Commit messages that violate the standard will succeed with a visible warning in the terminal.
- CI has no commit-message gate — this is intentional (CI validates code/doc parity, not message style).
- The advisory model means enforcement is cultural, not mechanical.
