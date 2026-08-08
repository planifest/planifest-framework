# Changelog — 0000026-context-hook-and-telemetry-backstop-fixes — 03 Aug 2026

**Feature:** Context-mode hook false-positive fix and telemetry-failure-marker backstop hook
**Pipeline run:** Change Pipeline (PC) — two independent bug fixes to existing components, picked up from `plan/backlog/` at P0
**PR:** not yet raised — pending human review

## What Was Built

Two backlog defects, both self-discovered during feature 0000025's own run, picked up together, plus one additional defect found and fixed during this feature's own ship review:

1. **0000042 — context-mode hook false-flags local `http://` args.** `planifest-framework/hooks/context-mode/block-bash.mjs`'s bare `https?://` substring match now exempts arguments whose host — parsed via the platform `URL` constructor, not string matching — is an exact loopback match (`localhost`, `127.0.0.1`, `[::1]`). Closes two spoofing bypass classes identified during scope coaching: subdomain (`http://localhost.evil.com/`) and userinfo (`http://localhost@evil.com/`), both of which contain the literal substring `localhost` immediately after the scheme but resolve to a different host. `curl`/`wget` invocations remain blocked regardless of target — a local fetch can still flood context same as a remote one.
2. **0000044 — orchestrator telemetry-marker/emit_event compliance gap.** New read-only `UserPromptSubmit` hook, `planifest-framework/hooks/enforcement/check-telemetry-failures.mjs`, backstops `0000018-ADR-002`'s phase-start failure-marker check: it scans `plan/.telemetry-failures/` and injects a visible `additionalContext` reminder listing each unacknowledged marker, removing reliance on the orchestrator's own memory to check at every phase boundary. The hook never deletes markers or decides block-or-proceed — that stays the orchestrator's responsibility, unchanged.
3. **product.yml version-tracking drift (found at this feature's own ship review, not a backlog pickup).** `product.yml`'s `components[]` cached each component's version, so context-mode-hooks' 0.2.0 → 0.2.1 bump above (item 1) left `product.yml` stale until manually synced at the next P9 — a defect ADR-002's own alternatives analysis never weighed against. `components[]` entries now hold `{id, path}` pointers to each component's own `component.yml`; `product-version.mjs` reads the live version at derivation time under `versionPolicy: max-component-version`, so there is nothing to keep in sync going forward.

## Artifacts Produced / Modified

`planifest-framework/hooks/context-mode/block-bash.mjs`, `src/context-mode-hooks/tests/test-block-bash.sh` (+9 cases), `src/context-mode-hooks/component.yml` (0.2.0 → 0.2.1), `planifest-framework/hooks/enforcement/check-telemetry-failures.mjs` (new), `planifest-framework/tests/test-0000026-telemetry-failure-hook.sh` (new, 21 cases), `planifest-framework/setup.sh`, `planifest-framework/setup.ps1`, `planifest-framework/skills/planifest-orchestrator/SKILL.md`, `planifest-framework/skills/planifest-ship-agent/SKILL.md`, `planifest-framework/scripts/product-version.mjs`, `planifest-framework/templates/product.template.yml`, `planifest-framework/tests/test-0000016-pipeline-governance.sh` + regression copy, `docs/decisions-index.md`, `product.yml`, `planifest-framework/component.yml` (0.25.0 → 0.26.0), `plan/current/build-log.md`.

## Decisions

- 0000042's fix is a narrow, anchored host-match — not broadened to the `127.0.0.0/8` range or `*.localhost` suffix (human's explicit choice: exact loopback names only).
- 0000044's fix is the hook-based marker check only (human's choice); the phase-gate lint-check alternative was not selected this round and may resurface as a follow-up if the hook alone proves insufficient.
- Routed as Change Pipeline, not Feature Pipeline: all three fixes are to existing components (`context-mode-hooks`, `planifest-framework`), not new user stories.
- Version bumped 0.25.0 → 0.26.0 (minor, human's explicit choice at ship) rather than the patch bump originally planned at PC — the product.yml versioning-mechanism fix (item 3) tipped this past a patch-sized change.

## Backlog Housekeeping

Discarded 8 stale entries at pickup, verified against feature 0000025's archived requirements (titles map 1:1 to already-shipped req-001 through req-007, plus one pre-ADR-003 duplicate): `0000029`, `0000033`, `0000036`, `0000037`, `0000038`, `0000039`, `0000040`, `0000041`. Full verification trail in `plan/current/build-log.md`.

## Skipped Phases

Full P0–P9 Feature Pipeline phases (P1 Spec, P2 ADRs, P4 Validate, P5 Security, P6 Docs as separate gated phases) — Change Pipeline routes directly from scope confirmation to implementation per `workflows/change-pipeline.md`. Validation (bash test suite) ran inline as part of implementation rather than as a separate gated phase.

## Known Pre-Existing, Unrelated Test Failures (not caused by this change)

- `test-0000023-req-003-copilot-setup-self-copy.sh`: 1 failure, explicitly self-flagged in its own output as blocked by the pre-existing `cline.sh` boot-file/skills-dir collision bug (open backlog `0000034`) — confirmed via `git stash` to fail identically before this feature's changes.
- `test-0000024-req-001-declared-product-id.sh`: 42/42 passed; a `Terminated: 15` line after the results is normal mock-server teardown noise, not a test failure.
