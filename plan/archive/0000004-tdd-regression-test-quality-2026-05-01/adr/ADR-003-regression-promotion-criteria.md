---
title: "ADR 003: Regression promotion — agent-tag plus human-confirm"
summary: "Tests are promoted to the regression pack via a two-step process: the codegen-agent tags candidates during P3, and the human confirms (or rejects) each candidate at P7 Step R. The ship-agent invokes promote-to-regression.sh for confirmed promotions. This balances automation with human curation."
status: "accepted"
version: "0.1.0"
---
# ADR-003 - Regression promotion — agent-tag plus human-confirm

**Feature:** 0000004-tdd-regression-test-quality
**Status:** accepted
**Date:** 2026-04-26

---

## Context

The regression pack (`planifest-framework/tests/regression/`) is a long-term, curated set of tests that outlive their originating feature archive. A key design question is: who decides which tests belong in the regression pack, and when?

There are several concerns to balance:
- **Quality over quantity:** The regression pack should contain tests for core framework behaviours likely to break under change — not every test from every feature.
- **Human accountability:** Promotions are permanent (tests survive archive). A human should be in the loop.
- **Automation efficiency:** Requiring a human to identify every candidate from scratch is slow. The agent sees the tests it wrote and has context about their significance.
- **Timing:** Promotion should happen before archiving so the promoted tests are in the pack before the plan is closed.

---

## Decision

Regression promotion uses a **two-step agent-tag + human-confirm** model:

1. **Agent tags** (P3): During codegen, the `planifest-test-writer` (or codegen-agent) marks tests it considers regression candidates. Tagging is advisory — it signals significance without committing to promotion.

2. **Human confirms** (P7 Step R): The ship-agent presents tagged candidates to the human before archiving. The human explicitly confirms or rejects each one. Confirmed candidates are promoted via `promote-to-regression.sh` with `promotedBy: "human"`.

3. **Auto-promotion** is not used for the initial release of this feature. All promotions require human confirmation. Future features may introduce auto-promotion for specific, well-defined criteria.

This was chosen because:
- The agent has context about which tests cover core vs. incidental behaviour — tagging uses that context.
- Human confirmation prevents the regression pack growing unboundedly with low-value tests.
- The timing (P7 before archive) ensures promoted tests are available immediately for subsequent feature P4 runs.
- `promotedBy` field in the manifest records accountability: every promoted test traces to either an agent recommendation + human approval, or a future explicit auto-promotion rule.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| **Human-only (no agent tagging)** | Full human control; no false positives | Human must review all tests without agent guidance; slow; requires deep context the human may not have at P7 | Agent context at P3 is more accurate for identifying regression significance than human review at P7 without that context |
| **Agent-only auto-promotion (no human confirm)** | Fully automated; no P7 interruption | Regression pack may grow with low-value tests; no human accountability; hard to trust without established criteria | Regression pack quality degrades over time; human-in-the-loop is important for a curated, long-term suite |
| **Both agent-auto and human-tagged, separate tracks** | Maximum flexibility | Two promotion paths increase manifest complexity; unclear which track a test came from | Unnecessary complexity for initial implementation; deferred to future feature if demand exists |
| **Promotion at P3 time (not P7)** | Earlier promotion; tests available sooner | P3 tests may be revised by P4/P5/P6 before ship; promoting a test that later changes creates stale regression entries | Promoting before ship risks stale tests; P7 is the correct moment when tests are stable |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-codegen-agent | Agents tag regression candidates during P3; tagging mechanism documented in SKILL.md |
| planifest-test-writer | May tag tests it writes as regression candidates |
| planifest-ship-agent | Step R: presents candidates, records decisions, invokes promote-to-regression.sh |
| regression-pack (promote-to-regression.sh) | Invoked per confirmed promotion; records `promotedBy` in manifest |
| regression-manifest.json | Stores `promotedBy: "human"` or `"agent"` per entry |

---

## Consequences

**Positive:**
- Regression pack grows with human-curated, high-value tests — quality over quantity.
- Agent tagging reduces cognitive load at P7: human reviews a short candidate list, not all tests.
- Manifest records full provenance: which feature, when promoted, by whom.
- Additive: nothing in the existing pipeline is removed; promotion is a new optional step.

**Negative:**
- P7 ship step is slightly longer: human must review and confirm candidates.
- If the agent tags poorly (too many or too few candidates), the human bears the full review burden.

**Risks:**
- Regression pack starts empty for the first P7 run of this feature — there are no tagged candidates until P3 produces them. Not a problem: the empty case is handled gracefully.
- Agent tagging criteria are not formally specified in this ADR — they are left to the codegen-agent's judgment based on SKILL.md guidance. A future ADR may formalise scoring criteria if the quality of tagging is insufficient.

---

## Related ADRs

- ADR-001 — related-to (TDD loop produces the tests that may become regression candidates)
- ADR-002 — related-to (sub-agents that write tests may also tag them)
