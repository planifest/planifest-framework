# Feature Brief - Hook-Based Enforcement: Telemetry & Plan Compliance

**Feature ID:** 0000003-hook-based-enforcement
**Source:** Session discovery — April 2026, while implementing 0000002
**Requested by:** Martin Mayer — April 2026
**Planifest Rating:** 🟡 Defined

> **Scope addition (2026-04-18):** opencode added as a supported tool on this release. Hook support to be researched and wired alongside Track A and Track B where the tool supports it.
>
> **Scope addition (2026-04-18, revised):** research completed across all 8 non-Claude supported tools. Design updated to include multi-tool hook support across three enforcement tiers (native shell hooks, plugin shim, MCP+instructions fallback). See `design.md` → "Track C — Multi-tool hook support".

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
- Phase 0 opens with a structured human briefing: list all phases, explain process start→end, invite questions
- Phase 0 validates hook installation for the detected tool (or warns if hooks cannot be verified); remediation command shown inline
- Orchestrator periodically reminds the human of the current phase during multi-phase runs; every agent response prefixed `Px`
- Each phase closes with a summary of artefacts produced and the name of the next phase
- Resume detection: orchestrator detects current phase from `plan/` artefacts on re-entry and opens with `Px: Resuming…` instead of restarting from P0
- Explicit phase skip: human-directed skips are acknowledged, logged in the iteration log, and prefixed `Px: Skipped by human direction`
- Escalation messages carry `Px` prefix so the human knows which phase is blocked
- `getting-started.md` updated with a section explaining the `Px` convention
- Ship phase final step: archive `plan/current/` → `plan/archive/{feature-id}/` automatically on completion
- Orchestrator SKILL.md updated with all of the above

**Track B — Plan compliance**
- `planifest-framework/hooks/enforcement/check-design.mjs` (new) — UserPromptSubmit hook: reads design.md, injects scope as additionalContext
- `planifest-framework/hooks/enforcement/gate-write.mjs` (new) — PreToolUse Write|Edit hook: checks design.md exists and file is in scope; blocks if not
- `setup.sh` / `setup.ps1`: install both enforcement hooks unconditionally (not gated on MCP flags — enforcement applies to all installs)
- CLAUDE.md update: note hook enforcement is active; manual checks are redundant but left as documentation

### Out of scope
- Changes to the structured-telemetry MCP server
- `mcp_mode` auto-detection in telemetry hooks (hardcode `"none"` for now)
- `phase_end` status inference (always `"pass"` from hooks; orchestrator instructions handle `"fail"` cases)
- LLM-based (prompt hook) scope reasoning — command hooks with path matching are sufficient for v1
- Windows-specific hook command compatibility

### Dependencies
- Feature 0000002 complete ✅
- Claude Code hooks reference reviewed ✅
- `structured-telemetry-mcp` server for Track A

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

---

## Open Questions

1. Does `PreToolUse` in a skill's frontmatter fire on every tool use or only the first? (Flag-file guard handles either case but affects implementation complexity.)
2. When multiple phases run in one session, does each skill's `Stop` hook fire per-phase or once at session end?
3. For Track B `gate-write.mjs`: how should "file path within design scope" be determined? Options: (a) explicit component path list in design.md frontmatter, (b) presence of `src/<component-id>/` pattern matching against design.md component IDs, (c) allowlist of always-permitted paths (plan/, docs/, CLAUDE.md).
4. Should `gate-write.mjs` block or warn-only for the first iteration? Blocking is safer but may be disruptive until the hook is well-tuned.
