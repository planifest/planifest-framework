# Operational Model - Pipeline Gate and Config Fixes and Ship-Agent Fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Version:** 0.25.0

> This feature has no runtime service, on-call rotation, or deployment topology — `planifest-framework` is installed tooling (prose skills, setup scripts, hook scripts) consumed by AI coding agents, not a hosted service. Sections below are marked not applicable rather than fabricated.

## Component Ownership

| Component | Owner (team/role) | On-call Rotation | Escalation Path |
|-----------|------------------|-----------------|-----------------|
| `planifest-framework` | Human on the loop (sole maintainer, this repo) | Not applicable — no runtime service | Not applicable |

## Runbook Triggers

Not applicable — no runtime service to run a runbook against. One operational concern (US-004): if a consuming project has both an old `.planifest-setup-flags` marker file and the new `planifest-overrides/setup-config/` file present during `setup.sh`, the script reads the new file; if they disagree, the human should manually resolve which backend-url is canonical and delete the stale marker. This is a one-time migration edge case, not an ongoing runbook.

## Alerting Thresholds

Not applicable — no metrics pipeline for this tooling. Hook or test failures in consuming projects (detected during `setup.sh` regression tests) indicate that the feature's fixes have introduced an incompatibility; the fix is rolled back via `git revert`.

## Deployment Model

| Component | Strategy | Rollback Plan | Health Check |
|-----------|----------|--------------|-------------|
| `planifest-framework` | Installed via `setup.sh`/`setup.ps1` into consuming project workspaces; this repo's own copy is source | `git revert` the merge commit; consuming projects re-run `setup.sh` to pick up a prior tagged version | Regression tests across all seven stories (US-001 through US-007) act as the health check for this feature's fixes |

## Backup and Recovery

Not applicable — no data store beyond `planifest-overrides/setup-config/` (a small human-authored file already covered by normal git history) and `plan/backlog/` (routed from recommendations.md, also under git).
