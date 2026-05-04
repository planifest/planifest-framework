---
title: "ADR-001: Three-tier enforcement model for multi-tool hook support"
summary: "Tools are grouped into three tiers based on their hook capabilities. Tier 1 uses native shell hooks, Tier 2 uses a Bun/TS plugin shim, Tier 3 falls back to MCP + instructions. This is the central architectural choice for Track C."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - Three-tier enforcement model for multi-tool hook support

**Skill:** [adr-agent](../../planifest-framework/skills/planifest-adr-agent/SKILL.md)
**Tool:** claude-code
**Model:** claude-sonnet-4-5
**Feature:** 0000003-hook-based-enforcement
**Component:** planifest-framework/hooks/
**Status:** accepted
**Date:** 2026-04-18

---

## Context

Planifest needs deterministic enforcement (write gating, telemetry emission) across 9 supported agentic tools: claude-code, cursor, windsurf, cline, codex-cli, opencode, copilot, antigravity, roo-code. Research (DD-005) showed these tools have fundamentally different hook systems:

- Some expose native shell hooks that can execute arbitrary scripts with exit-code-based blocking
- One (opencode) exposes a JS/TS plugin API running on Bun, with no shell hook system
- Some (copilot, antigravity, roo-code) have no programmable hook system at all at time of writing

A single uniform implementation cannot cover all tools. The architecture must work reliably for tools with hooks while degrading gracefully for those without.

---

## Decision

Group tools into three enforcement tiers based on hook capability, with a shared core of `.mjs` scripts that run regardless of tier:

- **Tier 1 (native shell, full interception):** claude-code, cursor, windsurf, cline — per-tool adapter `.mjs` translates the tool's native hook envelope to the Planifest common envelope, then delegates to shared `gate-write.mjs` and `emit-phase-*.mjs` scripts. Exit code 2 propagates as a block.
- **Tier 1b (native shell, Bash-only):** codex-cli — same pattern as Tier 1 but gating is limited to Bash environments. Activated by `features.codex_hooks = true`.
- **Tier 2 (plugin shim):** opencode — a dedicated `@planifest/opencode-hooks` npm package implements the OpenCode plugin interface and delegates to shared scripts via `Bun.spawnSync`.
- **Tier 3 (instructions fallback):** copilot, antigravity, roo-code — no hook registration. Setup scripts print a warning; enforcement is instruction-based only.

The shared scripts (`gate-write.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs`, `check-design.mjs`) are tool-agnostic. Adapters absorb all tool-specific differences.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Single unified enforcement layer (e.g. MCP server as middleware) | One implementation, no adapter layer | No tool-native blocking; requires MCP to be active; adds latency | Cannot intercept writes deterministically; MCP optional in many setups |
| Per-tool full implementation (no shared core) | Maximum flexibility per tool | 9× maintenance burden; divergence risk; no shared script logic | Unsustainable; shared core is the main correctness guarantee |
| Tier 1 only (skip tools without native hooks) | Simple, uniform | Leaves 4 tools without any enforcement | Unacceptable for a multi-tool framework |
| Single Tier 3 for all non-claude-code tools | Minimal effort | Significant capability regression; Cursor/Windsurf/Cline all have native hooks | Wastes available enforcement capability |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| `planifest-framework/hooks/telemetry/` | Core scripts called by all tiers |
| `planifest-framework/hooks/enforcement/` | Core scripts called by all tiers |
| `planifest-framework/hooks/adapters/` | New adapter scripts per Tier 1/1b tool |
| `planifest-framework/hooks/adapters/opencode/` | New Tier 2 npm package |
| `planifest-framework/setup/` | Per-tool setup scripts registering appropriate tier |
| `planifest-framework/skills/planifest-orchestrator/SKILL.md` | Phase 0 must detect tool tier and warn for Tier 3 |

---

## Consequences

**Positive:**
- Deterministic enforcement available for 6 of 9 tools (Tier 1 + 1b + 2)
- Shared core scripts means enforcement logic is written and tested once
- Adapters are thin; bugs in enforcement logic require only core script changes
- Tier 3 tools are supported with a clear, documented limitation rather than silently broken

**Negative:**
- Adapter layer adds indirection; debugging a hook firing requires tracing through adapter → shared script
- Tier 1b (codex-cli) has a platform limitation (no Windows write gate) that cannot be resolved without upstream changes
- Tier 3 tools receive materially weaker enforcement — humans working with copilot/antigravity/roo-code have a lower confidence level

**Risks:**
- OpenCode plugin API (Tier 2) is in active development; breaking changes could silently disable Tier 2 enforcement (R-004 in risk register)
- Tier detection in Phase 0 must stay in sync with this tier assignment; if a tool moves tiers, the orchestrator SKILL.md and setup scripts both need updating

---

## Related ADRs

- ADR-002 - depends-on (common envelope is required for the adapter pattern to work)
- ADR-005 - related-to (exit-0 failure mode applies to all tiers)

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by adr-agent. Path: `plan/current/adr/ADR-001-three-tier-enforcement-model.md`*
