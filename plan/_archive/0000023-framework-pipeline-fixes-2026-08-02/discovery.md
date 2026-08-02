---
title: "Discovery - 0000023-framework-pipeline-fixes"
summary: "Raw P0 discovery-pass findings — what the orchestrator knew before coaching began."
---
# Discovery - 0000023-framework-pipeline-fixes

> Created at the start of P0, before the first coaching question.
> Raw findings only — decisions belong in `design.md`, the Q&A audit trail in `build-log.md`.

## Header

| Field | Value |
|-------|-------|
| Adoption mode detected | `standard-iterative` |
| Detection signal | `plan/_archive/` contains 22 prior feature dirs; `docs/about.md` exists (version `0.22.0`) |
| Git pre-flight | branch `main` at session start, confirmed by human as merged/up to date; created `feat/0000023-framework-pipeline-fixes` off `main` |
| Skills inbox | empty (`planifest-framework/skills-inbox/` has no SKILL.md files) |

## Mode Findings — Standard Iterative

- Current version (`docs/about.md`): `0.22.0`, last feature `0000022-orchestrator-redundancy-removal`
- No `product.yml` at project root — version derived from `docs/about.md` only
- Prior features (`plan/_archive/`, 22 total, most recent five): `0000018-telemetry-emission-consistency` (2026-07-31), `0000019-self-description-and-session-hygiene-fixes` (2026-07-31), `0000020-setup-refresh-skill` (2026-08-01), `0000021-framework-context-bloat-audit` (2026-08-01), `0000022-orchestrator-redundancy-removal` (2026-08-02) — full list runs back to `0000001-context-mode-enforcement-hooks` (2026-04-12)
- Constraining ADRs: ADR-005 (fail-open on unexpected hook errors, exit 0), ADR-003 (Scope Lock suggested-answer offered-not-drafted, being tested by 0000029 but not superseded yet), ADR-017 (structured-telemetry-mcp: no backfill of historical telemetry rows)
- Component / data-ownership map (`docs/component-registry.md`):
  - `planifest-framework` (component-pack, top-level, not under `src/`) — core standards, skills, hooks, setup scripts. Owns `planifest-framework/skills/`, `planifest-framework/hooks/`, `planifest-framework/setup/`, `planifest-framework/standards/`.
  - `setup-hook-integration` (`src/setup-hook-integration/`) — narrower slice: only Claude-Code-specific `--context-mode-mcp` flag wiring in `setup.sh`/`setup.ps1`. Its own manifest explicitly excludes "hook wiring for Cursor, Windsurf, Cline, Antigravity" and "general setup.sh/setup.ps1 parity fixes unrelated to the flags-used marker" from scope.
  - `context-mode-hooks` (`src/context-mode-hooks/`) — Grep/Bash/WebFetch enforcement hook scripts, unrelated to this batch.
  - **Finding relevant to 0000027:** the copilot.sh self-copy bug lives in `planifest-framework/setup/copilot.sh`, which is generic Tier-1 adapter wiring, not the Claude-Code-only flag logic `setup-hook-integration` claims. This batch treats it as owned by the top-level `planifest-framework` component-pack, consistent with every other tool adapter script (`cursor.sh`, `windsurf.sh`, etc.) living in the same `planifest-framework/setup/` directory outside `setup-hook-integration`'s declared scope.

## Pre-research already done (informs P1, not part of the standard discovery pass)

- `install_tier1_hooks()` (`planifest-framework/setup.sh:403`) copies `TOOL_HOOK_ADAPTER_SRC` → `TOOL_HOOK_ADAPTER_DEST` via `cp`. Every other Tier-1 tool (e.g. `cursor.sh`) sets `TOOL_HOOK_ADAPTER_DEST` to a project-local path under the tool's own directory (`.cursor/hooks/adapters/cursor.mjs`). `copilot.sh` alone sets `TOOL_HOOK_ADAPTER_DEST="planifest-framework/hooks/adapters/copilot.mjs"` — identical to `TOOL_HOOK_ADAPTER_SRC` once resolved, causing the self-copy `cp` failure under `set -euo pipefail`. `copilot.sh`'s own `.github/hooks/planifest.json` heredoc also currently references `node planifest-framework/hooks/adapters/copilot.mjs` directly, so both the dest path and the hook registration command need to move to `.github/hooks/adapters/copilot.mjs` together.
- Backlog `0000032`'s handoff-report.md gives exact line numbers for the three telemetry hook scripts and the canonical envelope template — treated as pre-verified P1 input.
