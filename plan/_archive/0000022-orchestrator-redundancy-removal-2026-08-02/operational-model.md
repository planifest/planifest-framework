# Operational Model - orchestrator-redundancy-removal

**Skill:** [spec-agent](../skills/spec-agent-SKILL.md)
**Feature:** 0000022-orchestrator-redundancy-removal
**Version:** 0.22.0

Not applicable. This feature edits static Markdown skill/standards content within the `planifest-framework` component; it has no runtime service, no deployment, no on-call rotation, and no data store to back up. `planifest-framework`'s existing operational posture (installed via `setup.sh`/`setup.ps1` into consumer repos, no hosted service) is unchanged by this feature.

## Component Ownership

| Component | Owner (team/role) | On-call Rotation | Escalation Path |
|-----------|------------------|-----------------|-----------------|
| planifest-framework | Martin Mayer (human on the loop) | none - not a runtime service | n/a |

## Runbook Triggers

None. No automated triggers apply to a documentation/skill-content trim.

## Alerting Thresholds

None.

## Deployment Model

| Component | Strategy | Rollback Plan | Health Check |
|-----------|----------|--------------|-------------|
| planifest-framework | Consumer repos re-run `setup.sh`/`setup.ps1` to pick up the updated skill content | `git revert` the merged PR; consumer repos re-run setup against the prior commit | Regression pack (`tests/regression/`) is the health check for this component |

## Backup and Recovery

Not applicable - no data store.
