---
title: "ADR 001: Restore continuous_run exception for P1-P3 gates"
summary: "The Phase Invocation Table's P1/P2/P3 STOP rules hardcoded 'No exception', silently overriding the human's continuous_run choice at P0. Restores the exception these three phases had before a word-count trim pass (commit 42ae808, feature 0000021) dropped it, and records the corrected root-cause attribution."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - Restore continuous_run exception for P1-P3 gates

**Skill:** [adr-agent](../../../planifest-framework/skills/planifest-adr-agent/SKILL.md)
**Feature:** 0000023-framework-pipeline-fixes
**Component:** planifest-framework
**Date:** 2026-08-02

## Context

`planifest-orchestrator/SKILL.md`'s Phase Conventions state the general rule: phases P1-P6 stop for human confirmation "unless `continuous_run: true` was set at P0, or the phase states its own exception below." The Phase Invocation Table's P1, P2, and P3 rows currently state their own exception as the literal text "No exception" — which, read against the general rule, cancels the `continuous_run` allowance for those three phases specifically. P4, P5, and P6 instead state an additive clean-result exception ("proceed without confirmation if all checks passed first-attempt with zero self-corrections", etc.) that does not cancel the general rule, so `continuous_run` continues to apply there via the general rule undisturbed.

Net effect as filed in backlog 0000031: a human who explicitly selects continuous run at P0 is still interrupted three times (after P1, P2, P3) before Codegen output is even validated.

Backlog 0000031's own text characterized this as "a pre-existing behaviour, not introduced by feature 0000022," reasoning that 0000022 "consolidated the old per-phase P1-P6 sections into the current Phase Invocation Table but explicitly preserved existing gate semantics." That reasoning traced the wording back exactly one commit (to feature 0000021's output) and stopped there without checking whether 0000021 itself had introduced the wording or merely carried it forward too.

This session investigated further, at the human's explicit request, using `git show {commit}:planifest-framework/skills/planifest-orchestrator/SKILL.md` across the relevant history:

- **Commit `1eec013`** (feature 0000018) — the version in effect through features 0000019 and 0000020's actual pipeline runs — has each of P1 through P6 individually listing `continuous_run: true` was set at P0` as one of two OR-conditions to skip the stop. No "No exception" wording exists anywhere in this version.
- This is independently confirmed by the actual build logs of those two runs: `plan/_archive/0000019-*/build-log.md` states verbatim *"continuous_run: true — proceeding to P2 without a stop-and-confirm gate"* and *"Gate note: continuous_run active, P1→P2 proceeded without stopping per orchestrator exception rule."* `plan/_archive/0000020-*/build-log.md` records the same run-mode behavior across all of P1-P6.
- **Commit `42ae808`** (feature 0000021-framework-context-bloat-audit) is where the wording changed. That feature's stated purpose was reducing word count. As part of that trim, all six phases' STOP lines were reworded; P1, P2, and P3's multi-line "Wait for confirmation... Exceptions — proceed without confirmation if either: `continuous_run: true` was set at P0 / {phase-specific note}" collapsed to a single terse line ending in "No exception" — which silently deleted the `continuous_run` condition rather than just shortening its phrasing. P4, P5, and P6 survived the same trim pass with their exception intact, because their exception clause happened to be additive to the general rule rather than dependent on being explicitly restated per-phase.
- **Commit `fa7f751`** (feature 0000022) then consolidated the six already-reworded sections into the current single Phase Invocation Table, carrying the already-broken P1-P3 wording forward verbatim, consistent with that feature's own explicitly stated "zero behavioural change" mandate — it was not the origin, and had no reason to catch a defect it did not introduce.

There is no ADR, scope item, or build-log note in feature 0000021 announcing an intentional gating-behavior change. The evidence (working behavior in two shipped features immediately prior, no decision record, a stated goal of trimming words rather than changing behavior) supports this being an unintended side effect of that trim, not a deliberate design choice that was later just poorly explained.

## Decision

Restore the `continuous_run` exception to the P1, P2, and P3 rows of the Phase Invocation Table, matching the mechanism P4-P6 already use successfully — an explicit per-row exception clause naming `continuous_run: true` was set at P0`, rather than relying on the general rule alone (since relying on the general rule alone is exactly what silently broke here once a phase-specific "No exception" override was introduced by a later edit).

New STOP-rule wording for the three affected rows:

- P1 Requirements: `STOP, present requirement count/scope decisions/deferred items. Exception: continuous_run: true was set at P0.`
- P2 Architecture Decisions: `STOP, present ADR list with one-line summaries. Exception: continuous_run: true was set at P0.`
- P3 Code Generation: `STOP, present components built/tests produced/deviations. Exception: continuous_run: true was set at P0.`

P4, P5, P6, and P9 rows are unchanged.

Backlog 0000031's "pre-existing, not introduced by feature 0000022" claim is corrected by this ADR: the regression's actual origin is commit `42ae808` (feature 0000021), not a long-standing quirk, and not feature 0000022.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Keep P1-P3 as permanent always-stop gates, formalize via this ADR as a deliberate higher-stakes-gate policy | Requirements/ADRs/Codegen are arguably harder to unwind than validation/docs, so an argument for always-stopping exists in principle | No such policy was ever actually decided or requested; it would be inventing a new restriction under the guise of "recording" one, contradicting two features' worth of verified working behavior and the human's explicit intent for this very run | Not what actually happened; would be presenting an invented policy as a restored one |
| Fix only P1 and P2, leave P3 (Codegen) as an always-stop gate since code changes are higher-risk | Extra caution before code generation | Contradicts the verified pre-0000021 behavior (P3 was included in the working exception through 0000019/0000020); no incident or rationale motivates singling out P3 | Same rejection basis — this would be a new restriction, not a restoration |
| Leave the general Phase Conventions rule as the sole mechanism (remove per-row "No exception" text entirely rather than adding an explicit exception clause) | Slightly less repetitive text | This is exactly the failure mode observed: a bare general rule with no per-row restatement is one edit away from being silently overridden again, as 0000021 demonstrated | Explicit per-row restatement is the safer, already-proven pattern (it's how P4-P6 avoided the same fate) |

## Affected Components

| Component | Impact |
|-----------|--------|
| `planifest-framework` | `planifest-orchestrator/SKILL.md`'s Phase Invocation Table gains 3 corrected STOP-rule cells; no other file changes as a result of this decision |

## Consequences

**Positive:**
- `continuous_run: true` behaves consistently across all of P1-P6 again, matching verified historical behavior and the human's expectation.
- The root-cause record in this ADR gives a future contributor doing another word-count trim pass a concrete example of how an edit can silently delete a behavioral condition while looking like a pure rewording — a specific, citable precedent rather than a generic warning.

**Negative:**
- None identified — this restores previously-working, previously-relied-upon behavior; it does not introduce new behavior beyond what shipped correctly through 0000019 and 0000020.

**Risks:**
- A future prose-trimming pass over `planifest-orchestrator/SKILL.md` could reintroduce this same class of regression if it treats the per-row exception clauses as redundant boilerplate to shorten, since the general rule alone has now been shown not to be a reliable backstop against a badly-worded per-row override. No automated guard exists against this; it remains a documentation-only safeguard.

## Related ADRs

- None — no prior ADR in this repo's history addressed `continuous_run` gate semantics directly; ADR-003 (referenced elsewhere in the orchestrator skill) covers the Scope Lock suggested-answer protocol, an unrelated decision.

## Supersedes

- None.

## Superseded By

- None.
