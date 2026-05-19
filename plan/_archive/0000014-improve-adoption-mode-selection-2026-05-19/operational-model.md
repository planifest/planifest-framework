---
title: "Operational Model - 0000014-improve-adoption-mode-selection"
---
# Operational Model - 0000014-improve-adoption-mode-selection

## Runtime Characteristics

No runtime component. All changes are to skill files and templates executed within an AI agent session. There is no deployed service, no on-call rotation, and no alerting threshold applicable.

## Runbook Triggers

| Trigger | Action |
|---------|--------|
| `docs/about.md` missing after a pipeline completes | Run the migration (REQ-008) to initialise it |
| Adoption mode incorrectly recorded in a design.md | Run the migration (REQ-008) to correct archived files |
| Migration fails mid-run | Resume from progress file in `planifest-framework/migrations/_progress/` |
| Version regression blocked unexpectedly | Verify `docs/about.md` and archive history; re-version archives if a reset is intended |

## On-Call Expectations

None — no production service.

## Alerting

None — no runtime.
