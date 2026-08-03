---
title: "Risk Register - pipeline-gate-and-config-fixes-and-ship-agent-fixes"
summary: "Technical, operational, and security risks with their mitigations."
status: "draft"
version: "0.1.0"
---
# Risk Register - pipeline-gate-and-config-fixes-and-ship-agent-fixes

**Skill:** [spec-agent](../skills/spec-agent-SKILL.md) (updated by any agent that identifies a new risk)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Version:** 0.25.0
**Overall Risk Level:** medium

> Every entry must be specific to this feature. Do not produce generic risks.

## Risks

| ID | Category | Description | Likelihood | Impact | Mitigation | Status |
|----|----------|------------|------------|--------|-----------|--------|
| R-001 | operational | Bundling all 7 stories into one pipeline run exceeds the framework's own "≤3 stories" decomposition rule of thumb, increasing coordination/context risk across P1–P9 for this single run. | low | low | Human explicitly confirmed proceeding as one run at P0; all stories are small, same-component (`planifest-framework`), low-risk fixes; each story is committed granularly per repo instruction and validated together at P4. | accepted |
| R-002 | operational | US-007 reverses `0000017-ADR-003`'s default (opt-in draft-and-batch becomes always-on) and sits adjacent to `0000014-ADR-008`'s one-question-at-a-time convention boundary; the new P2 ADR risks reading as reversing that convention framework-wide instead of narrowly for the Scope Lock Challenge. | medium | low | P2 ADR must explicitly scope the supersession to the Scope Lock Challenge only, per discovery.md's constraining-ADR note; all other one-question-at-a-time gates elsewhere in the framework are left untouched. | open |
| R-003 | technical | US-004 (setup config relocation): if setup is interrupted after writing the new `planifest-overrides/setup-config/{tool}.md` but before the existing gitignored `.planifest-setup-flags` marker, the two sources of truth can silently duplicate or conflict on the next refresh/setup run. | medium | medium | Per feature-brief's cross-session-continuity note, the next refresh/setup run must treat `planifest-overrides/setup-config/` as authoritative and reconcile rather than silently duplicate or conflict. | open |
| R-004 | security | US-004 moves the active backend-url (and other setup flags) from the gitignored `.planifest-setup-flags` marker into a versioned, tracked file (`planifest-overrides/setup-config/{tool}.md`); if a backend-url or flag value ever embeds an internal-only endpoint or credential-like token, it becomes committed to git history where it previously was not. | low | medium | Setup scripts write only flag names and backend-url, never secrets, consistent with Hard Limit 6 ("No credentials in context"); the P5 security-agent review covers the setup-script change as part of this story. | open |
| R-005 | technical | US-003 extends "MUST parallelise independent writes" beyond P1/P3 into phases like P4 (test files) and P6 (living-doc edits); a phase skill could misclassify two writes as non-cross-referencing when they actually share state, causing the same silent-correctness risk this feature exists to close — now introduced by its own fix. | medium | medium | Parallelism guidance is restricted to writes each phase skill's own dispatch checklist explicitly confirms are independent/non-cross-referencing; P4 validate-agent and P8 build-assessment-agent are positioned to catch downstream inconsistency if it slips through. | open |
| R-006 | technical | US-006's audit of all `.claude/skills/planifest-*` phase skills for the same skill-internal-gate-ignoring-`continuous_run` pattern may miss an instance, leaving at least one skill-internal gate that still interrupts a continuous-run session after this feature ships. | medium | low | req-006 AC4 requires audit findings to be explicitly recorded, so any gap is visible and independently fixable via a future Fast Path rather than silently missed. | open |
| R-007 | technical | US-007's parallel dispatch of the four Scope Lock scenario-path draft subagents (via `planifest-scope-lock-agent`) can partially fail for one question; if the per-item fallback isn't implemented correctly, the whole batch could block P0 entirely instead of degrading gracefully for just the failed item. | medium | medium | Per feature-brief's error/sad path, a failed dispatch must present the three successful drafts plus a clear failure marker and fall back to the original blank-question flow for that one item only. | open |
| R-008 | operational | US-005's backlog unification is explicitly forward-only (out of scope: retroactively rewriting already-archived `recommendations.md` files), so already-archived features' deferred items stay scattered in old `recommendations.md` tables while new ones land in `plan/backlog/`, creating an inconsistent discoverability view during the transition. | high | low | Explicitly accepted in scope boundaries — old items remain independently findable in their archived location; a future backlog item could migrate historical entries if friction is confirmed. | accepted |
| R-009 | technical | req-002's fix depends on P7 Step 6 (copy-then-delete of `plan/current/`) already having emptied `plan/current/` before Step 7's `git add` runs; if a future edit to Step 6 changes that ordering or mechanic without accounting for this dependency, the explicit `git add plan/current/` could stage stale or unintended content. | low | low | req-002's acceptance criteria explicitly scope the fix to Step 7 only and leave Step 6 unchanged; the dependency is documented in the requirement doc itself so future edits are on notice. | mitigated |

## Assumptions Logged as Risks

Documented assumptions from the specification are logged here with likelihood: medium.

| ID | Assumption | Impact if Wrong | Status |
|----|-----------|----------------|--------|
| A-001 | The two downstream-filed backlog entries (0000040, 0000041) informing US-006 and US-007 reflect real friction in a genuine Planifest deployment, not a formatting artifact. | US-006 and US-007 would be solving a non-problem, but this is independently corroborated by this repo's own history (0000029 was filed by feature 0000016 in this same repo) and by the human's direct confirmation at P0 — impact assessed as low even if the downstream framing is imperfect. | open |
