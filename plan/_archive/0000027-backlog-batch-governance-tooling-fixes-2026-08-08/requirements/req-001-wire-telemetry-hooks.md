---
title: "Requirement: req-001 - Wire phase_start/phase_end telemetry hooks"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-001 - Wire phase_start/phase_end telemetry hooks

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source:** US-001 (backlog 0000043)
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As the human on the loop, I want phase_start/phase_end telemetry hooks wired into setup.sh/setup.ps1 alongside context-pressure.mjs, so that all hooks gated by the unified telemetry signal are actually registered and no event type silently goes unemitted.

## Grounding (current repo state)

- `planifest-framework/setup.sh`'s `install_telemetry_hooks()` (line ~678) copies every `*.mjs` file under `hooks/telemetry/` — which today is `context-pressure.mjs`, `emit-phase-start.mjs`, and `emit-phase-end.mjs` — to the target project's telemetry hooks directory (e.g. `.claude/hooks/telemetry/`). All three files land on disk.
- Immediately after, `install_telemetry_hooks()` calls `merge_telemetry_hook_settings()`, which registers **only** a `context-pressure.mjs` `PostToolUse` entry in `.claude/settings.json`. `emit-phase-start.mjs` and `emit-phase-end.mjs` are copied but never referenced by any hook entry.
- Confirmed against this repo's own dev install: `.claude/settings.json`'s `PostToolUse` array contains exactly one entry (`context-pressure.mjs`, matcher `.*`, `async: true`, `timeout: 5000`) — no `emit-phase-start.mjs` or `emit-phase-end.mjs` entry exists anywhere in the file, despite `--structured-telemetry-mcp` having been used for this install.
- `emit-phase-start.mjs`'s own header documents it as a "PreToolUse hook" ("Fires on first tool use within a phase") and `emit-phase-end.mjs`'s header documents it as a "Stop hook" ("Fires at the end of each response turn"). Both scripts require a `<phase>` CLI argument (`process.argv[2]`) and no-op silently (exit 0) if it is absent or if `PLANIFEST_TELEMETRY_URL` is unset.
- `planifest-framework/standards/telemetry-standards.md` (Unified Telemetry Signal, ADR-001) states the single `--structured-telemetry-mcp` flag must both write the `.claude/telemetry-enabled` sentinel and "wire the telemetry hooks in `.claude/settings.json`" for `phase_start`/`phase_end`/`context_pressure` posts alike — the current code only does the latter for `context_pressure`.
- **Open mechanism question for P2/P3:** because `emit-phase-start.mjs`/`emit-phase-end.mjs` take a positional `<phase>` argument, a single blanket hook entry (matcher `.*`, one fixed command string) cannot supply the correct phase name the way `context-pressure.mjs`'s phase-agnostic command can. Resolving how the registered command supplies (or the script resolves) the current phase at invocation time is this requirement's specific wiring design choice, to be settled during codegen against the "PreToolUse"/"Stop" hook shapes already documented in the scripts' own headers — not invented fresh here.
- `setup.ps1` mirrors `setup.sh`'s structure (per parity precedent in `test-0000023-req-003-copilot-setup-self-copy.sh`, part (f)-(h)) and has the equivalent gap.

## Functional Requirements
- `setup.sh`'s telemetry hook-config writer (`merge_telemetry_hook_settings()` or a sibling function) registers hook entries for `emit-phase-start.mjs` and `emit-phase-end.mjs` in `.claude/settings.json` when `--structured-telemetry-mcp` is passed, alongside the existing `context-pressure.mjs` registration, using the same idempotent remove-then-re-add merge pattern already used for `context-pressure.mjs`.
- The registered hook type for each script matches what its own header already documents: `emit-phase-start.mjs` registered under `PreToolUse`; `emit-phase-end.mjs` registered under `Stop`. Each embeds `PLANIFEST_TELEMETRY_URL=$backend_url` in the command string the same way `context-pressure.mjs`'s command does.
- `setup.ps1`'s equivalent telemetry-hook-writing function applies the same two additional registrations for parity, following the existing `setup.sh`/`setup.ps1` parity convention (mirrored function names/behavior, verified statically where no PowerShell runtime is available in this environment).
- A positive-presence check confirms all three telemetry hooks (`context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs`) are actually registered as hook entries in the target tool's hook config after setup completes — not merely that `--structured-telemetry-mcp` was passed at install time. This check must fail loudly (non-zero / explicit assertion) if any of the three is missing from the config, so a partial-wiring regression like the current one cannot pass silently again.
- Registration is gated on the same unified telemetry signal (`STRUCTURED_TELEMETRY_MCP=true`) that already gates `context-pressure.mjs` — no new flag introduced.

## Acceptance Criteria
- [ ] A fresh `setup.sh claude-code --structured-telemetry-mcp` run on a disposable workspace registers all 3 telemetry hook entries (`context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs`) in `.claude/settings.json`, verified by parsing the resulting JSON (not just grepping for the flag).
- [ ] The existing telemetry regression test pattern (e.g. `test-0000026-telemetry-failure-hook.sh`'s style of JSON-field assertions) is extended, or a new test is added, to assert presence of all 3 hook entries — re-running it against the current repo's own `.claude/settings.json` before the fix reproduces the gap (only `context-pressure.mjs` present), and passes after the fix.
- [ ] `setup.ps1` is confirmed via static source inspection to declare the equivalent registrations for `emit-phase-start.mjs` and `emit-phase-end.mjs` (parity check, no live PowerShell run required, consistent with how `test-0000023-req-003-copilot-setup-self-copy.sh` parts (f)-(h) verify `setup.ps1` parity today).
- [ ] Re-running `setup.sh claude-code --structured-telemetry-mcp` on an already-configured workspace (idempotency check) does not duplicate hook entries — exactly one entry per script remains after a second run.

## Dependencies
- None (independent of the other 7 items in this batch; suggested-only sequencing note in `feature-brief.md` places this before US-004/0000044, not a hard dependency).

## Input Validation

Not applicable — this requirement modifies setup-script hook registration logic only; it does not introduce a new path that reads untrusted external content into displayed or injected output.
