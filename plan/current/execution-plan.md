# Execution Plan — 0000003-hook-based-enforcement

**Feature:** Hook-Based Enforcement: Telemetry & Plan Compliance
**Phase:** Spec (P1)
**Date:** 2026-04-18

---

## Summary

This feature moves two classes of Planifest enforcement out of LLM instruction compliance and into the execution environment using agent hooks. It also extends hook support to all 9 supported tools, improves orchestrator UX with phase indicators and health checks, and introduces a dedicated Ship agent for Phase 7.

---

## Non-Functional Requirements

| NFR | Target | Source |
|-----|--------|--------|
| Hook script execution time | ≤ 3 seconds (abort on timeout) | DD-001/DD-002 |
| Hook script failure mode | Always exit 0; never block session | NFR |
| External dependencies (Track A/B hooks) | None beyond Node.js built-ins (`fs`, `path`, `os`) | NFR |
| External dependencies (Track C Tier 2) | Bun runtime (bundled with opencode) | NFR |
| Duplicate phase_start emissions | Zero per session per phase | DD-001 |
| Hook config deploy | All setup scripts idempotent | DD-005 |

---

## API / Data Summary

No HTTP API is exposed or consumed by this feature directly. The telemetry hook scripts POST to `${PLANIFEST_TELEMETRY_URL}/emit` (existing structured-telemetry-mcp endpoint). No schema changes to the MCP server schema are made in this feature except adding `"ship"` to the phase enum (coordinated deploy, see risk register).

No component manifest (`src/`) is produced. This feature modifies framework files under `planifest-framework/` rather than user application source. Legitimate absence per spec-agent rules.

---

## Delivery Tracks

| Track | Description | Primary Deliverables |
|-------|-------------|---------------------|
| A | Phase lifecycle telemetry hooks | `emit-phase-start.mjs`, `emit-phase-end.mjs`, hooks frontmatter on 7 SKILL.md files |
| B | Plan compliance enforcement hooks | `gate-write.mjs`, `check-design.mjs`, setup.sh/ps1 updates |
| C | Multi-tool hook support (9 tools, 3 tiers) | Per-tool adapter scripts, per-tool setup scripts, opencode npm plugin |
| D | Orchestrator UX + Phase 7 Ship | `planifest-ship-agent/SKILL.md`, orchestrator SKILL.md updates, getting-started.md, CLAUDE.md |

---

## Functional Requirements Directory

Functional requirements are split into granular files to optimise agent context windows.

See `plan/current/requirements/` for individual feature requirements.
*Each file follows the [Requirement Template](../../planifest-framework/templates/requirement.template.md).*

| File | Track | Summary |
|------|-------|---------|
| req-001-phase-start-deterministic.md | A | phase_start fires via PreToolUse hook, not LLM instruction |
| req-002-phase-end-duration.md | A | phase_end fires via Stop hook with duration_ms |
| req-003-flag-file-guard.md | A | Temp-file sentinel prevents duplicate phase_start per session |
| req-004-silent-failure.md | A | Hook scripts always exit 0, never block session |
| req-005-scope-context-injection.md | B | UserPromptSubmit injects confirmed scope as additionalContext |
| req-006-write-gate.md | B | PreToolUse blocks Write/Edit when design absent or path out of scope |
| req-007-permitted-writes-pass.md | B | In-scope writes always pass through unblocked |
| req-008-enforcement-hooks-installed.md | B | setup.sh/ps1 install enforcement hooks unconditionally |
| req-009-tier1-native-hooks.md | C | Cursor, Windsurf, Cline: native shell hook adapters |
| req-010-tier1b-codex.md | C | Codex CLI: hooks via features.codex_hooks flag, Bash-only |
| req-011-tier2-opencode-plugin.md | C | OpenCode: @planifest/opencode-hooks Bun plugin |
| req-012-tier3-instructions-fallback.md | C | Copilot/Antigravity/Roo Code: instructions-only with warning |
| req-013-per-tool-setup-scripts.md | C | 9 × 2 = 18 idempotent setup scripts |
| req-014-orchestrator-px-prefix.md | D | All agent responses prefixed Px (P0–P7); PC for change-agent |
| req-015-phase0-briefing-tool-detection.md | D | Phase 0 briefing, tool detection, hooks health check |
| req-016-resume-detection.md | D | Artefact scan on re-entry, Px: Resuming… |
| req-017-phase-skip-tracking.md | D | Phase skips written to .skips immediately |
| req-018-getting-started-update.md | D | getting-started.md phase indicators section |
| req-019-ship-agent-skill.md | D | planifest-ship-agent SKILL.md (new Phase 7 skill) |
| req-020-orchestrator-skill-updates.md | D | Orchestrator SKILL.md: Phase 7 routing, Px, resume, telemetry note |
| req-021-mcp-ship-enum.md | coordinated | structured-telemetry-mcp adds "ship" to phase enum |

---

## Dependency Order

1. **Track D first** — no dependencies; orchestrator UX and ship-agent are pure SKILL.md and docs changes
2. **Track A** — requires Node.js script authoring; no dependency on B or C
3. **Track B** — requires Node.js script authoring; no dependency on A or C
4. **Track C Tier 1** — requires Track A/B scripts to exist (adapters wrap them)
5. **Track C Tier 1b** — same as Tier 1
6. **Track C Tier 2** — requires Track A/B scripts to exist; Bun/TS plugin wraps them
7. **Track C Tier 3** — no script dependency; instructions + MCP registration only
8. **MCP server enum update** — must deploy before ship-agent merge (breaking change)
