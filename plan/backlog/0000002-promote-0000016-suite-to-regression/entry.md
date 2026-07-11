---
title: "Backlog Entry: 0000002 - Promote 0000016 governance tests to regression pack"
summary: "The ratchet/product-version/consistency-check tests were not tagged REGRESSION-CANDIDATE during P3; consider promotion at the next opportunity."
status: "open"
---
# Backlog Entry: 0000002 - Promote 0000016 governance tests to regression pack

**Source feature:** 0000016-pipeline-governance-and-loop-engineering
**Source phase:** P7
**Date filed:** 2026-07-11

---

## Problem

`planifest-framework/tests/test-0000016-pipeline-governance.sh` (97 assertions covering the ratchet hook's block/pass/marker semantics, product-version.mjs policy derivation, and consistency-check.mjs defect classes) was written during P3 without `# REGRESSION-CANDIDATE:` tags, so P7's regression-confirmation step found no candidates to offer the human. These deterministic-enforcement tests are exactly the class the regression pack exists for — the ratchet and budget guarantees (NFR-001) should not be re-verifiable only while the feature suite happens to run.

## Suggested Action

Present the executable-artifact sections of the 0000016 suite (ratchet, product-version, consistency-check) for human-confirmed promotion via `scripts/promote-to-regression.sh`, either standalone or at the next feature's P7.

## Why Deferred

P7 promotion requires per-candidate human confirmation against tagged tests; retro-tagging and promoting mid-close-out would widen the ship step. Non-blocking: the suite still runs in the standard harness.
