# Cost Model - Pipeline Gate and Config Fixes and Ship Agent Fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Version:** 0.25.0

> No compute, storage, network, or third-party service cost — this feature edits prose skills and shell/Node.js scripts already installed as local tooling in `planifest-framework`. All changes are to source files in a git repository; no deployed infrastructure or metered services are touched.

## Summary

| Category | Estimated Monthly Cost | Notes |
|----------|----------------------|-------|
| Compute | $0 | No deployed services; changes are to framework source files only |
| Storage | $0 | No new data stores; changes to configuration files already committed as source |
| Network / Egress | $0 | No new network paths; no change to what agents transmit |
| Third-party Services | $0 | No new third-party dependencies |
| **Total** | **$0** | |

## Compute Costs

Not applicable. All changes are to skills and setup scripts in the framework source tree, executed locally on the human's machine as part of the planning pipeline. No serverless functions, containers, or cloud VMs are deployed.

## Storage Costs

Not applicable. Configuration files (`planifest-overrides/setup-config/`) and backlog entries are stored in the same git repository already versioned and committed, with no cost surface.

## Network / Egress Costs

Not applicable. No new network requests are introduced. Existing telemetry events (structured-telemetry-mcp) carry the same payload structure; the orchestrator's enhanced parallelism (US-003) affects how many agent calls run in parallel, not what data is transmitted.

## Third-party Services

Not applicable. All changes are internal to the `planifest-framework` component.

## Token Cost Trade-off: US-003 Subagent Parallelism

**Cost dimension:** US-003 (subagent parallelism expansion) increases the number of parallel agent/subagent dispatches per pipeline run beyond Phase 1 and Phase 3. More concurrent agents = more total tokens consumed in exchange for lower wall-clock time.

- **Impact direction:** Per-run token cost increases; pipeline latency decreases.
- **Example:** Dispatching 5 independent phase-skill writes in parallel consumes ~5× the tokens of running them sequentially, but completes in ~1/5 the wall-clock time.
- **Measurement:** Tracked per phase in `plan/current/build-log.md` under `Parallel task batches` and `Parallel dispatch time` fields.
- **Assumption:** The human's token budget and the value of faster pipeline feedback justify the tradeoff; no explicit cap is modeled here.

## Assumptions

1. This feature ships no new infrastructure, so ongoing cloud operating cost remains zero.
2. The one-time engineering cost (this pipeline run) is not modeled here — the cost model tracks recurring operational cost, not development effort.
3. Token budget for parallel agent dispatch is managed at the Planifest operator level (human decision); this feature documents the tradeoff but does not impose hard limits.
