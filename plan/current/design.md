# Confirmed Design — 0000003 Hook-Based Enforcement: Telemetry & Plan Compliance

**Status:** Design confirmed
**Feature ID:** 0000003-hook-based-enforcement
**Date:** 2026-04-18

---

## Design Decisions

### DD-001 — PreToolUse fires on every tool call; flag-file guard is required

`PreToolUse` fires on every tool call inside the agentic loop. The `emit-phase-start.mjs` script must guard against re-emission using a temp flag file keyed by `session_id + phase`. Without the guard, `phase_start` would emit once per tool call for the duration of the phase.

**Resolution:** Flag file at `{tmpdir}/planifest-telemetry/phase-start-{session_id}-{phase}`. On first invocation: write file + emit. On subsequent invocations: detect file exists + exit 0 silently.

**Session ID fallback (R-005 mitigation):** Not all tools provide `PLANIFEST_SESSION_ID`. If the env var is absent, `emit-phase-start.mjs` reads (or creates) a project-scoped session file at `{cwd}/.claude/.planifest-session`. On first creation, the file contains a generated UUID. Subsequent hook invocations in the same project read this file as the session ID — consistent across process restarts. The ship-agent deletes `.planifest-session` alongside `.skips` during Phase 7 archiving.

---

### DD-002 — Stop fires per turn; multiple emissions per phase are expected

`Stop` fires at the end of every response turn. A multi-turn phase (e.g. validate retrying 5 times) produces multiple `phase_end` emissions. This is acceptable: the backend receives several and the last one is the true completion signal. No deduplication is needed in the hook script.

**Resolution:** `emit-phase-end.mjs` always emits on `Stop`. Duration is calculated from the flag file timestamp written by `emit-phase-start.mjs`. If the flag file is absent (phase_start hook never fired), duration is omitted.

---

### DD-003 — Scope enforcement uses two-tier path classification (Option C)

Checking whether a specific file path matches the design's component scope requires machine-readable structure in design.md that does not exist yet. For v1, the gate uses a simpler two-tier model:

- **Always permitted:** `plan/`, `docs/`, `CLAUDE.md`, `AGENTS.md` — planning and documentation files are never blocked
- **Requires design.md:** everything else (src/, planifest-framework/, hooks/, any .mjs/.sh/.md outside plan/ and docs/) — blocked if `plan/current/design.md` does not exist

**Resolution:** `gate-write.mjs` classifies the target path. Permitted paths proceed. Everything else checks for design.md existence and blocks if absent.

---

### DD-007 — Phase 0 opens with a structured human briefing and hooks health check

Phase 0 (Assess & Coach) currently jumps straight into asking the human about their feature. Two gaps:
1. First-time users don't know what they've signed up for — phases, what each produces, how to exit
2. Nothing confirms hooks are wired before implementation begins — a failed hook setup only surfaces later when enforcement silently doesn't fire

**Resolution:** Orchestrator SKILL.md Phase 0 section gains two mandatory opening steps:

**Step 1 — Process briefing** (always, at Phase 0 start):
Open with exactly this shape — `Px` prefix, the phase name, the opening question, then the phase table:

```
P0: Starting the "Assess & Coach" phase. What do you want to develop?

Subsequently, we'll go through the following phases until we complete the feature.

| Phase | Name     |
|-------|----------|
| 1     | Spec     |
| 2     | ADR      |
| 3     | Codegen  |
| 4     | Validate |
| 5     | Security |
| 6     | Docs     |
| 7     | Ship     |

You can ask questions, redirect, or pause at any point.
```

Each subsequent phase opening follows the same pattern — `Px` prefix, phase name, one-sentence description of what happens in this phase:

```
P6: Starting the "Documentation" phase. Here we will produce per-component docs,
the system-wide registry, dependency graph, and the iteration log audit trail.
```

**Step 2 — Hooks health check** (at Phase 0, after briefing):
Detect which tool is running using this priority order:
1. Check `PLANIFEST_TOOL` env var (set by setup scripts) — most reliable
2. Check for tool-specific marker directories/files: `.claude/` → claude-code; `.cursor/` → cursor; `.windsurf/` → windsurf; `.clinerules/` → cline; `.codex/` → codex-cli; `.opencode/` or `opencode.json` → opencode; `.github/copilot-instructions.md` → copilot; `AGENTS.md` + none of the above → antigravity or roo-code (distinguish by asking)
3. If undetectable → ask the human: "Which AI coding tool are you using?" with a numbered list

Verify that Planifest hooks are installed for the detected tool:
- For Claude Code: check `.claude/settings.json` contains the enforcement hooks
- For Cursor: check `.cursor/hooks.json` exists and contains Planifest entries
- For Codex CLI: check `~/.codex/config.toml` has `features.codex_hooks = true` and `.codex/hooks.json` exists
- For tools without hooks (Tier 3): inform the human that deterministic enforcement is unavailable for their tool and explain what that means
- If hooks missing for a hook-capable tool: surface a clear warning with remediation step (`run setup.sh --tool <name>`) before proceeding

---

### DD-008 — Orchestrator periodically reminds the human of the current phase

In multi-phase runs the human can lose track of where they are, especially after validation retries or long codegen. The orchestrator should surface the current phase at natural boundaries.

**Resolution:** Orchestrator SKILL.md gains a periodic reminder rule:
- Every agent response begins with **`Px`** where `x` is the current phase number (e.g. `P0`, `P3`). This applies to the orchestrator and all sub-skill agents it invokes.
- At the **start of each phase**: announce phase name, number, and one-liner ("▶ P3 — Codegen: writing implementation files")
- After a **phase completes**: confirm completion and state what phase comes next ("✅ P3 — Codegen complete. Moving to P4 — Validate.")
- After **5 or more tool calls within a phase**: re-surface the `Px` prefix with a brief status line to maintain orientation
- Standing reminder in each phase section: "The human may redirect, pause, or ask questions at any point — acknowledge and adapt"

The `Px` prefix is a **hard convention** — not optional prose. Every response from every Planifest agent starts with it. The prefix goes before any other content on the first line. This includes escalation messages: `Px: Escalating — could not resolve [action] after 5 attempts. [description]. Please advise.`

**Phase exit summary** — each phase close mirrors the open:
```
P3 ✅ Codegen complete. Produced: src/auth/, component.yml, 12 test files.
Moving to P4 — Validate.
```

**Phase skip** — if the human directs a phase to be skipped, the orchestrator responds:
```
P5: Skipped by human direction. Reason: [human's stated reason]. Recorded in iteration log.
```
The skip is written immediately to `plan/current/.skips` (one line per skip: `{YYYY-MM-DD} P{x} {phase-name}: {reason}`). This file is readable by resume detection (DD-009) so a resumed session knows what was skipped. At Ship time the ship-agent appends the skips to the iteration log under `## Skipped Phases` and deletes `.skips` before archiving.

---

### DD-012 — Ship phase archives `plan/current/` on completion

After a successful Ship (PR raised, changelog written, docs complete), `plan/current/` must be archived so the workspace is clean for the next feature. Leaving artefacts in `plan/current/` after shipping causes resume-detection (DD-009) to misread the state as an in-progress feature.

**Resolution:** The final step of the ship-agent is:
1. Determine the feature ID from `plan/current/feature-brief.md` frontmatter
2. Write `plan/current/.feature-id` with the feature ID (allows resume detection to identify stale artefacts from a failed ship attempt)
3. **Copy** `plan/current/` → `plan/archive/{feature-id}-{YYYY-MM-DD}/` (today's date) — copy first, delete after
4. If the target archive path already exists, append `-{n}` (e.g. `-2`) to avoid collision
5. Delete `plan/current/` contents (`.skips`, `.planifest-session`, all artefacts) after successful copy
6. Confirm `plan/current/` is empty (or does not exist) before declaring Ship complete
7. Emit a `phase_end` telemetry event with `status: "pass"`

**Two-phase archive rationale (R-007 mitigation):** Copy-then-delete means a failure mid-archive leaves artefacts in both locations. This is safe and idempotent — a re-run finds the archive path, adds `-{n}`, and proceeds. A move (rename) that fails mid-way can leave `plan/current/` partially deleted, which is harder to recover from.

**`.feature-id` marker (R-007 mitigation):** Resume detection (DD-009) reads `plan/current/.feature-id` to identify which feature the artefacts belong to. If the marker is absent or contains a different feature ID than the session's active feature, the orchestrator warns the human before proceeding.

This mirrors the manual archive step the orchestrator performed when transitioning from feature 0000002 → 0000003, but makes it deterministic and automated.

---

### DD-009 — Resume detection on re-entry

When the orchestrator is invoked without a fresh feature request (e.g. after a context reset or new session on an in-progress feature), it must detect the current phase from existing `plan/` artefacts rather than restarting from P0.

**Resolution:** Orchestrator Phase 0 opens with a check:
1. Does `plan/current/design.md` exist? If yes → feature is in progress
2. Scan `plan/current/` for presence of phase artefacts (spec, ADRs, security report, etc.) to determine the furthest completed phase
3. Open with: `Px: Resuming [phase name]. [Brief summary of what exists.] Shall we continue?`
4. If no `design.md` → treat as new feature, open with P0 briefing as normal

---

### DD-010 — Hooks health check shows inline remediation command

The P0 hooks health check (DD-007 Step 2) must not just warn — it must give the human a copy-pasteable fix.

**Resolution:** If hooks are missing or misconfigured for the detected tool, the check outputs:
```
P0 ⚠ Hooks not detected for [tool]. Enforcement and telemetry will not fire.
To install: run ./planifest-framework/setup.sh --tool [tool]
            (Windows: .\planifest-framework\setup.ps1 -Tool [tool])
Continuing without hooks — you can run setup at any time.
```
If hooks are confirmed present: `P0 ✅ Hooks verified for [tool].` — one line, no noise.

---

### DD-011 — `getting-started.md` documents the `Px` convention

New users encounter `P0:` on their first interaction and need to know what it means.

**Resolution:** Add a short section to `getting-started.md` — "Understanding phase indicators" — explaining:
- Every Planifest agent response opens with `Px` where `x` is the current phase number
- P0 is Assess & Coach; P1–P7 are the implementation phases
- The prefix is there so you always know where you are without asking

---

### DD-005 — Multi-tool hook support via three enforcement tiers

Research across the 8 non-Claude supported tools (cursor, codex-cli, antigravity, copilot, windsurf, cline, roo-code, opencode) shows fragmented hook capabilities. A single implementation does not fit all. The design adopts three tiers keyed on the tool's native capability:

- **Tier 1 — Native shell hooks, full write interception** (claude-code, cursor, windsurf, cline): tools ship shell-command lifecycle hooks with stdin JSON and blocking semantics. `PreToolUse` intercepts Write/Edit calls directly. Planifest's `.mjs` scripts run directly; per-tool adapters translate native input/output formats to the common envelope.
- **Tier 1b — Native shell hooks, Bash-only interception** (codex-cli): full lifecycle hooks (`SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`) with exit-code-2 + JSON blocking. However `PreToolUse` only intercepts `Bash` today — not `Write`/`Edit`/`MCP`. Track B `gate-write` degrades: can block bash-based writes but cannot intercept direct Write tool calls. Track A telemetry and Track B `check-design` context injection work fully. Requires `features.codex_hooks = true` in `~/.codex/config.toml`; Windows support temporarily disabled.
- **Tier 2 — Plugin shim** (opencode): tool uses a JS/TS plugin system rather than shell hooks. Planifest ships `@planifest/opencode-hooks` npm plugin that wraps the same `.mjs` scripts via `Bun.spawn`, emitting Claude-Code-shape stdin JSON so hook bodies stay tool-agnostic.
- **Tier 3 — MCP + instructions fallback** (copilot, antigravity, roo-code): tool has no lifecycle hooks. Enforcement degrades to MCP tool gating, `AGENTS.md`/`copilot-instructions.md` advisory rules, and CI/branch-protection guards. Telemetry emission relies on agent compliance (as today).

**Resolution:** Per-tool adapter directory layout `planifest-framework/hooks/adapters/{tool}/`, with `setup/{tool}.sh` emitting native config. Tier-3 tools receive instructions + MCP registration only; users are warned at setup time that deterministic enforcement is unavailable for those tools.

---

### DD-006 — Common envelope across tiers

All `.mjs` hook scripts (Track A `emit-phase-*`, Track B `check-design`, `gate-write`) read a normalised stdin JSON envelope with `{session_id, cwd, tool_input, event}` regardless of the originating tool. Per-tool adapter scripts translate native formats (Cursor JSON, Windsurf JSON, Cline JSON, OpenCode plugin object) into this shape and translate decision output back (exit 2 for Windsurf/Claude; `{"permission":"deny"}` for Cursor; `{"cancel":true}` for Cline; `throw` for OpenCode).

**Resolution:** Hook script bodies remain unchanged across tools. Adapter layer isolates per-tool differences.

---

### DD-004 — Write gate blocks (exit code 2), not warns

Warn-only is equivalent to the current state: another instruction the LLM can ignore. The gate must be a hard block. Exit code 2 surfaces the message to Claude as feedback, which it can act on (create a design first).

**Resolution:** `gate-write.mjs` exits with code 2 and a clear message: `"No confirmed design found at plan/current/design.md. Complete Phase 0 and confirm the design before writing implementation files."`

---

## Architecture

### Track A — Phase lifecycle telemetry

```
Skill frontmatter (e.g. planifest-spec-agent/SKILL.md)
  └── hooks:
        PreToolUse → emit-phase-start.mjs spec
        Stop       → emit-phase-end.mjs spec

emit-phase-start.mjs <phase>
  1. Read stdin JSON → extract session_id, cwd
  2. Check .claude/telemetry-enabled sentinel → exit 0 if absent
  3. Check flag file → exit 0 if already emitted this session
  4. Write flag file with start timestamp (epoch ms)
  5. POST phase_start event to ${PLANIFEST_TELEMETRY_URL}/emit
  6. Fire-and-forget, 3s abort, silent errors

emit-phase-end.mjs <phase>
  1. Read stdin JSON → extract session_id, cwd
  2. Check .claude/telemetry-enabled sentinel → exit 0 if absent
  3. Read flag file → compute duration_ms if present
  4. POST phase_end event to ${PLANIFEST_TELEMETRY_URL}/emit
  5. Fire-and-forget, 3s abort, silent errors
```

**Affected skills:** spec, adr, codegen, validate, security, docs, ship (7 files)

**Not affected:** orchestrator — it emits phase_start/phase_end via instructions as a complementary signal. Hooks are the primary mechanism; instructions are backup.

---

### Track B — Plan compliance enforcement

```
.claude/settings.json (installed by setup.sh / setup.ps1)
  └── hooks:
        UserPromptSubmit → check-design.mjs (inject scope context)
        PreToolUse Write|Edit → gate-write.mjs (block if no design)

check-design.mjs
  1. Read stdin JSON → extract cwd
  2. Read plan/current/design.md → extract ## Scope section
  3. Return additionalContext with scope summary
  4. Exit 0 if design.md absent (no context to inject)

gate-write.mjs
  1. Read stdin JSON → extract tool_input.file_path (or path), cwd
  2. Classify path:
     - Starts with plan/, docs/, or is CLAUDE.md/AGENTS.md → exit 0 (permitted)
     - Anything else → check for plan/current/design.md
  3. If design.md exists → exit 0 (permitted)
  4. If design.md absent → exit 2 with blocking message
```

**Installation:** Both hooks installed unconditionally by `setup.sh`/`setup.ps1` (not gated on MCP flags). Enforcement applies to all Planifest installs.

---

### Track C — Multi-tool hook support

Per-tool capability summary and mapping:

| Tool | Tier | PreToolUse | Stop/End | UserPromptSubmit | Block Signal | Config Surface |
|------|------|-----------|----------|------------------|--------------|----------------|
| claude-code | 1 | ✅ | `Stop` | ✅ | exit 2 / JSON | `.claude/settings.json` |
| cursor | 1 | `beforeMCPExecution`, `beforeShellExecution` | `stop` | `beforeSubmitPrompt` | JSON `permission`/`continue` | `.cursor/hooks.json` — no enable flag; auto-activates on file presence (stable, Cursor 1.7+) |
| windsurf | 1 | `pre_mcp_tool_use`, `pre_write_code`, `pre_run_command` | `post_cascade_response` | `pre_user_prompt` | exit 2 | `hooks.json` (workspace) |
| cline | 1 | `PreToolUse` | `TaskComplete` | `UserPromptSubmit` | JSON `{"cancel":true}` | `.clinerules/hooks/` |
| opencode | 2 | `tool.execute.before` | `event` (filter `session.idle`) | `chat.message` | `throw` / mutate output | `@planifest/opencode-hooks` plugin |
| codex-cli | 1b | `PreToolUse` (Bash only) | `Stop` | `UserPromptSubmit` | exit 2 / `{"decision":"block"}` | `.codex/hooks.json` — **requires** `features.codex_hooks = true` in `~/.codex/config.toml`; Windows unsupported |
| copilot | 3 | — | — | — | — | `.github/copilot-instructions.md`, MCP |
| antigravity | 3 | — | — | — | — | `AGENTS.md`, MCP, Agent Permissions |
| roo-code | 3 | — | — | — | — | `.roo/rules/`, MCP, custom Modes |

**Architecture:**

```
planifest-framework/hooks/
  ├── telemetry/
  │   ├── emit-phase-start.mjs      # Shared — reads common envelope
  │   ├── emit-phase-end.mjs        # Shared
  │   └── context-pressure.mjs      # Existing
  ├── enforcement/
  │   ├── check-design.mjs          # Shared
  │   └── gate-write.mjs            # Shared
  └── adapters/
      ├── cursor.mjs                # ~20 lines: translate Cursor JSON → common envelope; exit-2 → {"permission":"deny"}
      ├── codex.mjs                 # ~25 lines: translate Codex hookSpecificOutput shape; exit-2 + {"decision":"block"} both supported
      ├── cline.mjs                 # ~20 lines: translate Cline JSON → common envelope; exit-2 → {"cancel":true,"errorMessage":"..."}
      └── opencode/                 # npm package only — needs package.json + TS source
          ├── package.json          # name: @planifest/opencode-hooks
          └── src/
              ├── index.ts          # Plugin entrypoint; registers all hook events
              └── adapter.ts        # Shells out to .mjs scripts via Bun.spawn; maps throw/output mutation back
```

Notes:
- **windsurf**: no adapter needed — uses exit-2 identical to Claude Code; hook scripts run directly
- **claude-code**: no adapter — native envelope
- **Tier-3 tools** (copilot, antigravity, roo-code): no hook scripts; setup writes instruction files only

**Tier 1b (codex-cli):** setup writes `.codex/hooks.json` and enables `features.codex_hooks = true`. Telemetry (Track A) and context injection (Track B `check-design`) work fully. `gate-write` degrades — only bash-based writes are interceptable; direct Write/Edit tool calls are not blocked. Setup warns the user of this limitation and that Windows is unsupported.

**Tier 3 tools (copilot, antigravity, roo-code):** setup writes instructions-only integration (`AGENTS.md` fragment + MCP server registration) and emits a warning explaining that deterministic enforcement is unavailable. Telemetry relies on agent compliance with SKILL.md instructions (current state).

---

## File Inventory

| File | Status | Notes |
|------|--------|-------|
| `planifest-framework/hooks/telemetry/emit-phase-start.mjs` | New | Track A |
| `planifest-framework/hooks/telemetry/emit-phase-end.mjs` | New | Track A |
| `planifest-framework/hooks/enforcement/check-design.mjs` | New | Track B |
| `planifest-framework/hooks/enforcement/gate-write.mjs` | New | Track B |
| `planifest-framework/skills/planifest-spec-agent/SKILL.md` | Modify | Add hooks frontmatter; add `P1` response prefix rule |
| `planifest-framework/skills/planifest-adr-agent/SKILL.md` | Modify | Add hooks frontmatter; add `P2` response prefix rule |
| `planifest-framework/skills/planifest-codegen-agent/SKILL.md` | Modify | Add hooks frontmatter; add `P3` response prefix rule |
| `planifest-framework/skills/planifest-validate-agent/SKILL.md` | Modify | Add hooks frontmatter; add `P4` response prefix rule |
| `planifest-framework/skills/planifest-security-agent/SKILL.md` | Modify | Add hooks frontmatter; add `P5` response prefix rule |
| `planifest-framework/skills/planifest-docs-agent/SKILL.md` | Modify | Add hooks frontmatter; add `P6` response prefix rule |
| `planifest-framework/skills/planifest-change-agent/SKILL.md` | Modify | Add hooks frontmatter; `PC` response prefix rule (Change Pipeline — not a numbered phase); rename internal section labels Phase 1–5 → Step 1–5 (avoid clash with pipeline P1–P7); telemetry phase value remains `"change"` |
| `planifest-framework/skills/planifest-ship-agent/SKILL.md` | New | Phase 7 only — raise PR, write changelog, archive `plan/current/`; telemetry `"phase": "ship"` |
| `planifest-framework/skills/planifest-orchestrator/SKILL.md` | Modify | Note hooks as primary mechanism; add Phase 0 briefing script; add hooks health check (tool detection + verification + inline remediation); add periodic phase reminder + phase exit summary; add resume detection; add phase skip handling + `.skips` file; `Px` prefix on all responses; escalation messages carry `Px`; add Phase 7 Ship section; update `phase_start` enum to include `"ship"` |
| `planifest-framework/getting-started.md` | Modify | Add "Understanding phase indicators" section explaining `Px` convention |
| `CLAUDE.md` | Modify | Note hook enforcement is active; manual gate checks are redundant but retained as documentation |
| `planifest-framework/setup.sh` | Modify | Install enforcement hooks; copy new telemetry scripts |
| `planifest-framework/setup.ps1` | Modify | Same |
| `planifest-framework/setup/claude-code.sh` | Modify | Add enforcement hook config vars |
| `planifest-framework/setup/claude-code.ps1` | Modify | Same |
| `planifest-framework/hooks/adapters/cursor.mjs` | New | Track C — translate Cursor JSON in/out |
| `planifest-framework/hooks/adapters/codex.mjs` | New | Track C (Tier 1b) — translate Codex `hookSpecificOutput` shape; note Bash-only PreToolUse limitation |
| `planifest-framework/hooks/adapters/cline.mjs` | New | Track C — wrap JSON cancel output |
| `planifest-framework/hooks/adapters/opencode/package.json` | New | Track C — `@planifest/opencode-hooks` npm package |
| `planifest-framework/hooks/adapters/opencode/src/index.ts` | New | Track C — plugin entrypoint |
| `planifest-framework/hooks/adapters/opencode/src/adapter.ts` | New | Track C — Bun.spawn shim to .mjs scripts |
| `planifest-framework/setup/cursor.sh` / `.ps1` | New | Track C — write `.cursor/hooks.json`; no enable flag needed, hooks auto-activate |
| `planifest-framework/setup/windsurf.sh` / `.ps1` | New | Track C — write workspace `hooks.json` |
| `planifest-framework/setup/cline.sh` / `.ps1` | New | Track C — write `.clinerules/hooks/` scripts |
| `planifest-framework/setup/opencode.sh` / `.ps1` | New | Track C — register plugin in `opencode.json` |
| `planifest-framework/setup/codex-cli.sh` / `.ps1` | New | Track C (Tier 1b) — write `.codex/hooks.json`; append `features.codex_hooks = true` to `~/.codex/config.toml`; warn Bash-only interception + Windows unsupported |
| `planifest-framework/setup/copilot.sh` / `.ps1` | New | Track C (Tier 3) — write copilot-instructions.md + MCP; warn no hooks |
| `planifest-framework/setup/antigravity.sh` / `.ps1` | New | Track C (Tier 3) — write AGENTS.md + MCP; warn no hooks |
| `planifest-framework/setup/roo-code.sh` / `.ps1` | New | Track C (Tier 3) — write `.roo/rules/` + MCP; warn no hooks |

---

## Build Plan

**Track D — Orchestrator UX (do first — no dependencies)**
1. Write `planifest-ship-agent/SKILL.md` (new): Phase 7 only — raise PR, write changelog, archive plan/current/
2. Update orchestrator SKILL.md: Phase 0 briefing script (phase list, process overview, standing invitation)
3. Update orchestrator SKILL.md: Phase 0 hooks health check (tool detection via env/markers/ask; verification; Tier-3 warning; inline remediation)
4. Update orchestrator SKILL.md: Phase 7 Ship section (load planifest-ship-agent; gate check; update phase_start enum to include "ship")
5. Update orchestrator SKILL.md: periodic phase reminder rules (`Px` prefix on every response; announce at start/end; re-surface after 5+ tool calls)
6. Update orchestrator SKILL.md: phase exit summary format
7. Update orchestrator SKILL.md: resume detection logic (scan plan/ artefacts; open with `Px: Resuming…`)
8. Update orchestrator SKILL.md: phase skip handling (`Px: Skipped`; write to `.skips` immediately)
9. Update orchestrator SKILL.md: escalation messages carry `Px` prefix
10. Update all 7 pipeline sub-skill SKILL.md files: add `Px` response prefix (P1–P6 + P7 for ship-agent)
11. Update change-agent SKILL.md: add `PC` response prefix; rename internal Phase 1–5 → Step 1–5
12. Update `getting-started.md`: "Understanding phase indicators" section (DD-011)
13. Update `CLAUDE.md`: note hook enforcement active

**Track A — Telemetry scripts**
1. Write `emit-phase-start.mjs`
2. Write `emit-phase-end.mjs`
3. Add `hooks:` frontmatter to all 7 phase skill SKILL.md files
4. Update orchestrator SKILL.md note
5. Run setup to deploy; smoke test with a real emit

**Track B — Enforcement scripts**
6. Write `gate-write.mjs`
7. Write `check-design.mjs`
8. Update `setup/claude-code.sh` and `setup/claude-code.ps1` with enforcement hook config vars
9. Update `setup.sh` and `setup.ps1` to install enforcement hooks unconditionally
10. Run setup; verify gate blocks a write with no design.md; verify it passes with one present

**Track C (Tier 1) — Adapters: cursor, windsurf, cline**
11. Write `adapters/cursor/adapter.mjs` + `setup/cursor.{sh,ps1}`
12. Write `adapters/windsurf/adapter.mjs` + `setup/windsurf.{sh,ps1}`
13. Write `adapters/cline/adapter.mjs` + `setup/cline.{sh,ps1}`
14. Verify Track A (telemetry) and Track B (enforcement) fire through each adapter with a smoke test

**Track C (Tier 2) — opencode plugin**
15. Write `adapters/opencode/` npm plugin source (TS)
16. Write `setup/opencode.{sh,ps1}` that adds plugin to `opencode.json`
17. Smoke test plugin blocks write when `design.md` absent

**Track C (Tier 3) — Instructions fallback: codex-cli, copilot, antigravity, roo-code**
18. Write `setup/{tool}.{sh,ps1}` for each tier-3 tool: emit AGENTS.md/instructions fragment + MCP registration + user warning explaining no deterministic enforcement
19. Ensure telemetry instructions in SKILL.md remain the fallback path for tier-3 tools

**Track C (Tier 1b) — codex-cli setup**
20. Write `setup/codex-cli.{sh,ps1}`: write `.codex/hooks.json`, append `features.codex_hooks = true` to `~/.codex/config.toml`, warn Bash-only + Windows unsupported

**Validate & ship**
21. Run test suite (`test-setup-telemetry.sh`, `test-skill-telemetry.sh`)
22. Update `test-setup-telemetry.sh` to cover enforcement hook installation across all 9 tools
23. Add per-tool smoke tests under `tests/adapters/{tool}/`
24. **Coordinate structured-telemetry-mcp deploy:** add `"ship"` to the phase enum on the MCP server before committing ship-agent. Deploy order: MCP server update first, then ship-agent merge. **Functional impact is telemetry gap only** — ship-agent hook scripts exit 0 on schema rejection and never block execution. Add a CI check to the ship-agent PR that POSTs a test event with `"phase": "ship"` to the MCP endpoint and fails the build if the schema rejects it, enforcing the deploy order automatically (R-001 mitigation).
25. Commit, update changelog, update `getting-started.md` with per-tool hook support matrix

---

## NFRs

- All hook scripts must exit 0 on any unexpected error (never block the session due to script failure)
- Hook scripts must complete within 3 seconds (telemetry: abort fetch; enforcement: fast path check only)
- Track A + B hook scripts: no external dependencies beyond Node.js built-ins (`fs`, `path`, `os`)
- Track C Tier 1 adapters: no external dependencies beyond Node.js built-ins
- Track C Tier 2 (opencode plugin): TypeScript + Bun runtime — external dependency is acceptable as opencode ships Bun; no additional npm installs required beyond `@planifest/opencode-hooks` itself
