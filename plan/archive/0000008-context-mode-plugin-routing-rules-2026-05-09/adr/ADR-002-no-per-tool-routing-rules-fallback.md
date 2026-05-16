---
title: "ADR-002: No per-tool routing rules fallback for non-plugin tools"
summary: "When removing the framework-managed routing rules file, Planifest does not introduce a per-tool fallback mechanism for tools that cannot receive the plugin's system prompt. This gap is explicitly deferred, not silently accepted."
status: "accepted"
version: "0.1.0"
---
# ADR-002 - No per-tool routing rules fallback for non-plugin tools

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000008-context-mode-plugin-routing-rules
**Component:** planifest-framework
**Status:** accepted
**Date:** 08 May 2026

---

## Context

ADR-001 delegates routing rules to the context-mode plugin's system prompt. This works cleanly for Claude Code, which supports the plugin system. However, Planifest also supports Cursor, Windsurf, GitHub Copilot, Cline, and Codex — tools for which plugin system-prompt injection is unconfirmed or unsupported.

Previously, all tools received routing rules via the `AGENTS.md` file copied by setup. Removing this step means non-Claude Code tools receive no routing rules from any source. Their agents will use native tools (Grep, Bash, WebFetch) by default, potentially flooding their context windows.

Three options exist: build per-tool fallback routing rules files, maintain a single shared routing rules file for non-plugin tools, or defer the problem and document it explicitly.

---

## Decision

No per-tool routing rules fallback is introduced in this change. The gap is explicitly deferred and tracked in:
- `plan/current/scope.md` under Deferred
- `plan/current/risk-register.md` as R-001 (Cursor/Windsurf/Copilot/Cline) and R-002 (Codex)
- `docs/context-mode.md` Supported Tools table, which now distinguishes "plugin" as the routing rules source

A future change will address per-tool routing rules if and when plugin compatibility is confirmed or ruled out for each tool.

**Rationale:**
- Building per-tool fallback files now would require confirming which tools receive plugin system prompts — information not currently available. Building against an unknown creates the same drift problem ADR-001 resolves.
- The previous routing rules were advisory only. Enforcement hooks (Claude Code only) remain the hard guarantee. Non-Claude Code tools never had enforcement hooks; they also never had hard context-window protection. The change in their routing rules status is a reduction in advisory guidance, not a reduction in hard safety.
- Deferring with explicit documentation is better than silently accepting the gap or building a solution against unconfirmed assumptions.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Build per-tool routing rules files (one per non-plugin tool) | No tool left without routing guidance | Requires knowing each tool's boot file format and plugin compatibility; significant maintenance; immediately creates drift risk again | Reintroduces the problem ADR-001 solves; deferred until tool compatibility is known |
| Maintain a single shared routing rules file for all non-Claude Code tools | Simpler than per-tool files; one place to update | Still requires knowing which tools need it; cannot be the plugin source for Claude Code; partial split contradicts the clean separation | Partial solution; does not resolve the underlying confirmation gap |
| Reinstate AGENTS.md write for Codex only | Preserves routing rules for one specific tool | Creates an inconsistency: Claude Code uses plugin, Codex uses file; Codex routing rules would still drift from plugin | Inconsistency harder to maintain long-term than a clean deferred gap |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework/setup.sh | No new fallback logic added; routing rules step removed without replacement |
| planifest-framework/setup.ps1 | Same |
| docs/context-mode.md | Supported Tools table updated to reflect plugin as source; column header clarified |
| plan/current/scope.md | Deferred item explicitly recorded |
| plan/current/risk-register.md | R-001 and R-002 explicitly tracked |

---

## Consequences

**Positive:**
- No new maintenance burden introduced
- Clean separation: plugin owns routing rules for tools that support it; the gap for other tools is documented and trackable
- Future change can address per-tool fallback with full information about plugin compatibility

**Negative:**
- Cursor, Windsurf, GitHub Copilot, Cline, and Codex users who relied on advisory routing rules via `AGENTS.md` no longer receive them after re-running setup
- Non-Claude Code tools are silently degraded in context-window management until the deferred item is resolved

**Risks:**
- The deferred item may never be prioritised, leaving non-Claude Code tool users permanently without routing rules guidance
- Context window flooding on non-Claude Code tools may go unnoticed without enforcement hooks or routing rules — harder to detect than an explicit failure

---

## Related ADRs

- ADR-001 - depends-on (this decision follows directly from delegating routing rules to the plugin)

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by adr-agent.*
