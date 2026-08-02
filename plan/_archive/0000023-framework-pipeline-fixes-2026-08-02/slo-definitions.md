# SLO Definitions - Framework Pipeline Fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000023-framework-pipeline-fixes
**Version:** 0.23.0

> No hosted service, no request volume, no uptime target — this feature is a batch of tooling fixes to prose skills, a setup script, and telemetry hook scripts. The design's NFRs (execution-plan.md) are the closest analogue to SLOs here and are restated below rather than fabricating a service-style SLO table.

## Service Level Objectives

Not applicable in the traditional sense. The functional equivalents, drawn directly from the design's NFRs:

| Equivalent-of-SLO | Target | Source |
|---|---|---|
| `setup.sh copilot` / `setup.sh all` exit code | 0 on a fresh workspace, every invocation | NFR-001 |
| `product_id` derivation latency | No added latency beyond the existing ~3s telemetry fetch-abort budget | NFR-002 |
| Telemetry emission fault tolerance | Never blocks on a `product_id` derivation failure | NFR-003 |

## SLI Definitions

Not applicable — no continuous measurement pipeline. Each target above is verified once, by a regression test, at CI time — not monitored in production.

## Error Budget Policy

Not applicable — no error budget tracking exists for this tooling.

## Burn Rate Alerts

Not applicable.
