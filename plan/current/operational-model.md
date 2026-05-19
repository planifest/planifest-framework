---
title: "Operational Model - 0000015-pipeline-session-cleanup"
---
# Operational Model - 0000015-pipeline-session-cleanup

## Runbook Triggers

| Trigger | Action |
|---------|--------|
| Stale `plan/.run-mode` detected at P0 | Orchestrator warns and clears automatically — no human action required |
| Interrupted P9 detected on resume | Orchestrator completes cleanup and stops — human starts new session |

## On-Call Expectations

Not applicable — framework skill changes only.

## Alerting Thresholds

Not applicable — no runtime component.
