---
title: "ADR-001: Build log as a plain Markdown working file"
status: "accepted"
date: "03 May 2026"
---
# ADR-001: Build log as a plain Markdown working file

## Context

The pipeline needs a persistent record of build telemetry (models, agents, MCP calls, parallelism) that survives session changes. Options considered:
1. Plain Markdown file in `plan/current/`
2. Structured JSON/YAML file
3. Telemetry events emitted to the structured-telemetry-mcp backend

## Decision

Use a plain Markdown file at `plan/current/build-log.md`, created from a template at P0 and appended by the orchestrator at each phase boundary.

## Consequences

- **Consistent with existing artefacts**: all `plan/current/` files are Markdown; no new format to learn
- **Survives session changes**: committed to the repo alongside other plan artefacts
- **Human-readable**: developers can inspect mid-run without tooling
- **Committed with the archive**: filed alongside the build report in `plan/archive/`
- **No structured-telemetry-mcp dependency**: works with or without the MCP server running
- **Trade-off**: manual append by orchestrator means entries can be missed if the orchestrator skips the update instruction; mitigated by placing the instruction prominently per phase
