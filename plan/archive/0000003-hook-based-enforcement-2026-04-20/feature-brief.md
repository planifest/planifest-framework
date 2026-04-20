# Feature Brief - Hook-Based Enforcement: Telemetry & Plan Compliance

**Feature ID:** 0000003-hook-based-enforcement
**Source:** Session discovery — April 2026, while implementing 0000002
**Requested by:** Martin Mayer — April 2026
**Planifest Rating:** 🟡 Defined

> **Scope addition (2026-04-18):** opencode added as a supported tool on this release. Hook support to be researched and wired alongside Track A and Track B where the tool supports it.
>
> **Scope addition (2026-04-18, revised):** research completed across all 8 non-Claude supported tools. Design updated to include multi-tool hook support across three enforcement tiers (native shell hooks, plugin shim, MCP+instructions fallback). See `design.md` → "Track C — Multi-tool hook support".
>
> **Scope addition (2026-04-18, final):** Track D expanded with tool detection mechanism, `.skips` file for mid-run skip tracking, date-stamped archive paths with collision handling, and `planifest-ship-agent` as a distinct new skill for Phase 7. Structured-telemetry-mcp `"ship"` enum addition moved in-scope (coordinated deploy required).

---

## Problem Statement

Two classes of agent behaviour are currently enforced by instruction alone, making them unreliable:

**1. Phase lifecycle telemetry**
`phase_start` and `phase_end` events depend on the LLM following the SKILL.md telemetry section correctly. Agents can skip, forget, or misformat them. There is no deterministic signal that a phase began or ended.

**2. Plan compliance**
Nothing prevents an agent from writing code outside the confirmed design scope, or from implementing features before `plan/current/design.md` exists. This session demonstrated the failure mode: work drifted out of scope and no gate caught it until the human intervened.

Both problems have the same root cause: the enforcement mechanism is the LLM's self-compliance with text instructions. Claude Code hooks provide a way to move enforcement out of the LLM and into the execution environment.

---

## Proposed Solution

### Track A — Phase lifecycle telemetry hooks

Add `PreToolUse` and `Stop` hooks to each of the 7 phase skill SKILL.md frontmatter blocks. These call new Node.js scripts that POST directly to the structured-telemetry MCP backend at `${PLANIFEST_TELEMETRY_URL}/emit`, independent of agent behaviour.

- `PreToolUse` → `emit-phase-start.mjs <phase>` — fires on first tool use within the skill; guarded by a temp flag file to prevent re-emission
- `Stop` → `emit-phase-end.mjs <phase>` — fires when Claude finishes its response turn; reads start timestamp for `duration_ms`

Both scripts follow the `context-pressure.mjs` pattern: fire-and-forget, 3s abort, silent errors, sentinel check.

### Track B — Plan compliance enforcement hooks

Add two hooks to the project settings (`.claude/settings.json`), installed by `setup.sh`/`setup.ps1`:

- **`UserPromptSubmit`** — at the start of every turn, read `plan/current/design.md` and inject its scope section as `additionalContext`. Claude always has confirmed scope visible without searching for it. Prevents "felt like it was in scope" drift.

- **`PreToolUse` on `Write|Edit`** — before any file write, check:
  1. Does `plan/current/design.md` exist? If not → **block** (exit code 2): "No confirmed design at plan/current/design.md. Run Phase 0 first."
  2. Is the file path within the component paths listed in the design? If not → **block**: "This path is not covered by the confirmed design."

---

## Scope

### In scope

**Track A — Telemetry**
- `planifest-framework/hooks/telemetry/emit-phase-start.mjs` (new)
- `planifest-framework/hooks/telemetry/emit-phase-end.mjs` (new)
- `hooks:` frontmatter block on 7 phase skills: spec, adr, codegen, validate, security, docs, ship
- Orchestrator SKILL.md update: note hooks are the primary emission mechanism; instructions are backup

**Track D — Orchestrator UX & Phase 0 health checks**
- Phase 0 opens with structured human briefing (`Px` prefix, phase table, standing invitation to redirect)
- Phase 0 detects active tool via `PLANIFEST_TOOL` env var → directory markers → human prompt fallback
- Phase 0 validates hook installation for the detected tool; inline remediation command shown if missing
- Tier-3 tools (copilot, antigravity, roo-code): human informed that deterministic enforcement is unavailable
- Every pipeline agent response prefixed `Px` (P0–P7); change-agent uses `PC` (Change Pipeline — not a numbered phase)
- Each phase opens with name + one-liner; closes with artefact summary and next phase name
- Escalation messages carry `Px` prefix
- Resume detection: scan `plan/` artefacts on re-entry; open with `Px: Resuming…` not P0 briefing
- Phase skip: `Px: Skipped by human direction` written to `plan/current/.skips` immediately; appended to iteration log and deleted at Ship time
- Ship phase archives `plan/current/` → `plan/archive/{feature-id}-{YYYY-MM-DD}/` with `-{n}` collision suffix
- `getting-started.md` updated with "Understanding phase indicators" section
- `planifest-ship-agent/SKILL.md` (new) — Phase 7 only: raise PR, write changelog, archive plan
- Orchestrator SKILL.md updated with all of the above including Phase 7 Ship section

**Track B — Plan compliance**
- `planifest-framework/hooks/enforcement/check-design.mjs` (new) — UserPromptSubmit hook: reads design.md, injects scope as additionalContext
- `planifest-framework/hooks/enforcement/gate-write.mjs` (new) — PreToolUse Write|Edit hook: checks design.md exists and file is in scope; blocks if not
- `setup.sh` / `setup.ps1`: install both enforcement hooks unconditionally (not gated on MCP flags — enforcement applies to all installs)
- CLAUDE.md update: note hook enforcement is active; manual checks are redundant but left as documentation

**Track C — Multi-tool hook support**
- Tier 1 (native shell hooks, full write interception): cursor, windsurf, cline — per-tool adapter `.mjs` + setup scripts
- Tier 1b (native shell hooks, Bash-only interception): codex-cli — adapter + setup appends `features.codex_hooks = true`; warns Bash-only + Windows unsupported
- Tier 2 (plugin shim): opencode — `@planifest/opencode-hooks` npm plugin; setup registers in `opencode.json`
- Tier 3 (MCP + instructions fallback): copilot, antigravity, roo-code — setup writes instructions only; warns no deterministic enforcement
- `planifest-framework/hooks/adapters/cursor.mjs` (new)
- `planifest-framework/hooks/adapters/codex.mjs` (new)
- `planifest-framework/hooks/adapters/cline.mjs` (new)
- `planifest-framework/hooks/adapters/opencode/` (new npm package)
- Per-tool setup scripts: `setup/{cursor,windsurf,cline,opencode,codex-cli,copilot,antigravity,roo-code}.{sh,ps1}` (new)

**Structured-telemetry-mcp (coordinated)**
- Add `"ship"` to the phase enum; remove or retain `"change"` (change-agent keeps `"change"`; ship-agent uses `"ship"`)
- Deploy MCP server update before ship-agent merge — breaking change if downstream queries filter on phase

### Out of scope
- `mcp_mode` auto-detection in telemetry hooks (hardcode `"none"` for now)
- `phase_end` status inference (always `"pass"` from hooks; orchestrator instructions handle `"fail"` cases)
- LLM-based (prompt hook) scope reasoning — command hooks with path matching are sufficient for v1
- Windows-specific hook command compatibility for Tier 1 adapters (codex-cli Windows limitation documented, not fixed)

### Dependencies
- Feature 0000002 complete ✅
- Claude Code hooks reference reviewed ✅
- `structured-telemetry-mcp` server — Track A (telemetry emission) and coordinated deploy for `"ship"` phase enum addition

---

## Acceptance Criteria

**Track A**
1. `phase_start` event appears in telemetry for each phase without agent instruction compliance
2. `phase_end` event appears with `duration_ms` populated
3. No duplicate `phase_start` per session per phase (flag-file guard)
4. Hook commands exit 0 silently when telemetry is not installed or sentinel absent

**Track B**
5. Starting a new turn with no `plan/current/design.md` present surfaces scope context or blocks Write/Edit
6. Attempting to write a file outside the confirmed design's component paths is blocked with a clear message
7. When `design.md` exists and file is in scope, writes proceed unblocked
8. Enforcement hooks are installed on every `setup.sh`/`setup.ps1` run regardless of MCP flags

**Track C**
9. Tier 1 tools (cursor, windsurf, cline): gate-write and check-design fire via native hooks; blocking works end-to-end
10. Tier 1b (codex-cli): telemetry and context injection work; gate-write degrades gracefully with documented Bash-only limitation
11. Tier 2 (opencode): plugin blocks write when design.md absent; telemetry emits via plugin
12. Tier 3 tools: setup completes without error; human receives clear warning that enforcement is unavailable

**Track D**
13. Every agent response in a pipeline run begins with `Px`
14. Phase 0 opens with the phase table and standing invitation on first invocation; detects tool and verifies hooks
15. On re-entry to an in-progress feature, orchestrator resumes at correct phase without restarting P0
16. Human-directed phase skip is written to `.skips` immediately and survives a context reset
17. Ship archives `plan/current/` to a date-stamped path; no collision on same-day re-run

---

## Open Questions

All open questions resolved in design. See DD-001 through DD-012 in `plan/current/design.md`.
