# Recommendations — 0000009-framework-rail-tightening

**Date:** 12 May 2026
**Author:** planifest-docs-agent (P6)

---

## R-001 — Update `src/setup-hook-integration` docs for new hooks

**Priority:** Low  
**File:** `src/setup-hook-integration/docs/purpose.md`, `interface-contract.md`, `component.yml`

This feature added `auto-trigger-orchestrator.mjs`, `check-orchestrator-presence.mjs`, and the `--strict-orchestrator` flag to the setup scripts. These are not reflected in the `setup-hook-integration` component docs because `src/` is outside this feature's declared component scope (feature 0000003 owns that component). A follow-on Change Pipeline run against 0000003 should update:

- `purpose.md` — add the three new enforcement hooks and `--strict-orchestrator`
- `interface-contract.md` — add `--strict-orchestrator` flag as input; add `plan/.orchestrator-strict` and `plan/.orchestrator-ack` to outputs
- `component.yml` — version bump to 0.4.0, update `metadata.updatedAt`

## R-002 — Add `--strict-orchestrator` to domain glossary

**Priority:** Low  
**File:** `plan/current/domain-glossary.md`

The terms `plan/.orchestrator-strict` and `plan/.orchestrator-ack` were introduced in REQ-008 but are not yet in the domain glossary. Add them when the glossary is next updated.

## R-003 — Consider a session_id sanitisation step in strict mode

**Priority:** Low  
**File:** `planifest-framework/hooks/enforcement/check-orchestrator-presence.mjs`

The `session_id` from hook stdin is echoed into the strict-mode banner without sanitisation (S-002, accepted in P5). Since Claude Code controls this value it is low risk, but a `.replace(/[^a-zA-Z0-9\-_.]/g, "")` guard (matching the `featureId` treatment) would make the two inputs consistently sanitised.

## R-004 — Extend test coverage to setup.ps1 strict-orchestrator path

**Priority:** Low  
**File:** `planifest-framework/tests/test_setup.ps1`

The `--strict-orchestrator` flag is tested structurally in the bash test suite (test-0000009). A PowerShell unit test verifying that `Invoke-PlanifestSetup` with `$StrictOrchestrator = $true` creates `plan/.orchestrator-strict` would close the PS1 test gap.
