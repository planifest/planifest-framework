# Operational Model - Framework Pipeline Fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000023-framework-pipeline-fixes
**Version:** 0.23.0

> This feature has no runtime service, on-call rotation, or deployment topology — `planifest-framework` is installed tooling (prose skills, setup scripts, hook scripts) consumed by AI coding agents, not a hosted service. Sections below are marked not applicable rather than fabricated.

## Component Ownership

| Component | Owner (team/role) | On-call Rotation | Escalation Path |
|-----------|------------------|-----------------|-----------------|
| `planifest-framework` | Human on the loop (sole maintainer, this repo) | Not applicable — no runtime service | Not applicable |

## Runbook Triggers

Not applicable — no runtime service to run a runbook against. The closest analogue: if `setup.sh copilot` still fails after this fix ships, the new regression test (req-003) catches it in CI before a human discovers it live.

## Alerting Thresholds

Not applicable — no metrics pipeline for this tooling. Telemetry emission failures are already handled by the existing `plan/.telemetry-failures/` marker + interactive-recovery mechanism (0000018, ADR-002), unchanged by this feature.

## Deployment Model

| Component | Strategy | Rollback Plan | Health Check |
|-----------|----------|--------------|-------------|
| `planifest-framework` | Installed via `setup.sh`/`setup.ps1` into consuming project workspaces; this repo's own copy is source | `git revert` the merge commit; consuming projects re-run `setup.sh` to pick up a prior tagged version | New regression tests (req-003, req-004) act as the health check for this feature's specific fixes |

## Backup and Recovery

Not applicable — no data store. Session markers' own recovery story is the subject of this feature (req-002).
