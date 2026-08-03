# SLO Definitions - Pipeline Gate and Config Fixes and Ship Agent Fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Version:** 0.25.0

> No hosted service, no request volume, no uptime target — this feature is a batch of tooling fixes to skills, standards, setup scripts, and hooks. The design's NFRs are the closest analogue to SLOs and are restated below rather than fabricating a service-style SLO table.

## Service Level Objectives

Not applicable in the traditional sense. The functional equivalent, drawn directly from the design's architecture layer:

| Equivalent-of-SLO | Target | Source |
|---|---|---|
| Phase parallelism coverage (US-003) | 100% of phase batches with 2+ independent, non-cross-referencing writes dispatch in parallel subagents, not sequentially | Design Architecture Layer, Pipeline efficiency target |

## SLI Definitions

Not applicable — no continuous measurement pipeline. The target above is verified at feature-ship time via the `Parallel task batches` field in `build-log.md` for each phase touched by this feature's codegen pass — a one-time snapshot, not a monitored production metric.

## Error Budget Policy

Not applicable — no error budget tracking exists for this tooling.

## Burn Rate Alerts

Not applicable.
