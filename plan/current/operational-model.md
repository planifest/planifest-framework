# Operational Model - Declared Product ID and Telemetry Envelope Fix

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000024-declared-product-id-for-telemetry
**Version:** 0.24.0

> This feature has no runtime service, on-call rotation, or deployment topology — `planifest-framework` is installed tooling (prose skills, setup scripts, hook scripts) consumed by AI coding agents, not a hosted service. Sections below are marked not applicable rather than fabricated.

## Component Ownership

| Component | Owner (team/role) | On-call Rotation | Escalation Path |
|-----------|------------------|-----------------|-----------------|
| `planifest-framework` | Human on the loop (sole maintainer, this repo) | Not applicable — no runtime service | Not applicable |

## Runbook Triggers

Not applicable — no runtime service to run a runbook against. The closest analogue: a `plan/.telemetry-failures/` marker appearing for `product_id_undeclared` (or similar root cause) after this feature ships is the operational signal that a project's `product.yml` needs an `id` — the marker mechanism is the runbook trigger.

## Alerting Thresholds

Not applicable — no metrics pipeline for this tooling. Telemetry emission failures are already handled by the existing `plan/.telemetry-failures/` marker + interactive-recovery mechanism (0000018, ADR-002), reused unchanged by this feature.

## Deployment Model

| Component | Strategy | Rollback Plan | Health Check |
|-----------|----------|--------------|-------------|
| `planifest-framework` | Installed via `setup.sh`/`setup.ps1` into consuming project workspaces; this repo's own copy is source | `git revert` the merge commit; consuming projects re-run `setup.sh` to pick up a prior tagged version | New regression tests (req-001, req-002) act as the health check for this feature's specific fixes |

## Backup and Recovery

Not applicable — no data store beyond `product.yml`, a small human-authored file already covered by normal git history.
