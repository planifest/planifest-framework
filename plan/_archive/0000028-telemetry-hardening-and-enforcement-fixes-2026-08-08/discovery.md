---
title: "Discovery - 0000028-telemetry-hardening-and-enforcement-fixes"
summary: "Raw P0 discovery-pass findings, recorded before coaching began."
---
# Discovery - 0000028-telemetry-hardening-and-enforcement-fixes

> Created at the start of P0, before the first coaching question, in every adoption mode.
> Raw findings only. Decisions belong in `design.md`, the Q&A audit trail in `build-log.md`.

## Header (all modes)

| Field | Value |
|-------|-------|
| Adoption mode detected | `standard-iterative` |
| Detection signal | `plan/_archive/` holds 28 completed features, and `docs/about.md` exists. Priority-2 signal. No `planifest-overrides/instructions/external-versioning.md`, so External Anchor does not apply. |
| Git pre-flight | Started on `main`. `git fetch origin` succeeded; `git rev-list --left-right --count origin/main...main` returned `0	0`, so local `main` was identical to `origin/main` at `abe130f` (PR #54). No divergence, no local-only commits, no pull required. Working branch `feat/0000028-telemetry-hardening-and-enforcement-fixes` created from that point. Carried-over working-tree state at branch creation: modified `.gitignore` (adds the `*.local-only.*` rule) and four untracked backlog entries (`0000060`, `0000061`, `0000062`, `0000063`). |
| Skills inbox | empty (`planifest-framework/skills-inbox/` holds only `.gitkeep`) |

## Mode Findings

### Standard Iterative

- Current version (`docs/about.md`): `0.27.0`, matching `product.yml` (`id: planifest-framework`,
  `versionPolicy: max-component-version`, feature `0000027-backlog-batch-governance-tooling-fixes`).
  Declared product id present and non-empty, so the ADR-002 hard stop does not apply.

- Prior features (`plan/_archive/`, most recent six of 28):

  | Feature | Date | One-liner |
  |---------|------|-----------|
  | `0000022-orchestrator-redundancy-removal` | 2026-08-02 | De-duplication pass over the orchestrator skill |
  | `0000023-framework-pipeline-fixes` | 2026-08-02 | Assorted pipeline corrections |
  | `0000024-declared-product-id-for-telemetry` | 2026-08-03 | Declared `product_id` and telemetry envelope fix |
  | `0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes` | 2026-08-03 | Pipeline gate and config fixes, ship-agent fixes |
  | `0000026-context-hook-and-telemetry-backstop-fixes` | 2026-08-08 | Hook fixes, telemetry backstop, live product.yml versioning |
  | `0000027-backlog-batch-governance-tooling-fixes` | 2026-08-08 | Telemetry hook wiring, cline.sh fix, backlog governance |

- Constraining ADRs (unless superseded):
  - `0000016 ADR-002` product.yml with versionPolicy, amended by `0000026 ADR-001` so `components[]` holds
    `{id, path}` pointers read live by `product-version.mjs` rather than cached versions.
  - `0000025 ADR-003` supersedes `0000016 ADR-003`: the Scope Lock Challenge defaults to parallel drafting
    and batch presentation, with per-item explicit accept, edit, or reject retained.
  - `0000027 ADR-001` telemetry `emit_event` receipt backstop, introducing `emit-event-receipt.mjs` and
    `check-telemetry-receipts.mjs`.
  - `0000018 ADR-001` unified telemetry signal, gated on `--structured-telemetry-mcp` at setup.
  - `0000018 ADR-002` durable failure markers with interactive block-or-proceed recovery.

- Component and data-ownership map (`product.yml`, `docs/component-registry.md`):

  | Component | Manifest | Owns |
  |-----------|----------|------|
  | `planifest-framework` | `planifest-framework/component.yml` | Skills, templates, standards, hooks, migrations, tests |
  | `setup-hook-integration` | `src/setup-hook-integration/component.yml` | `setup.sh` / `setup.ps1` and per-tool hook registration |
  | `context-mode-hooks` | `src/context-mode-hooks/component.yml` | `block-bash.mjs`, `block-grep.mjs`, `block-webfetch.mjs` |

- Stack markers: no `package.json` anywhere in the repo. Hooks and scripts are dependency-free Node ESM
  (`.mjs`) run directly by the host tool. Tests are shell and `.mjs` scripts under
  `planifest-framework/tests/`, driven by `run-tests.sh`. Setup is `setup.sh` (bash) and `setup.ps1` (pwsh).

## Signals Read That Bear On This Feature

Recorded here as raw findings. The scope decisions they informed live in `design.md`.

**Installed hook inventory (`.claude/settings.json`), complete:**

| Event | Matcher | Command |
|-------|---------|---------|
| PreToolUse | `Grep` | `.claude/hooks/context-mode/block-grep.mjs` |
| PreToolUse | `Bash` | `.claude/hooks/context-mode/block-bash.mjs` |
| PreToolUse | `WebFetch` | `.claude/hooks/context-mode/block-webfetch.mjs` |
| PreToolUse | `Write`, `Edit` | `.claude/hooks/enforcement/gate-write.mjs` |
| PreToolUse | `Write`, `Edit` | `.claude/hooks/enforcement/ratchet-check.mjs` |
| UserPromptSubmit | `.*` | `auto-trigger-orchestrator.mjs`, `check-orchestrator-presence.mjs`, `check-design.mjs`, `check-telemetry-failures.mjs` |
| PostToolUse | `.*` | `PLANIFEST_TELEMETRY_URL=http://localhost:3741 node .claude/hooks/telemetry/context-pressure.mjs` |

`context-pressure.mjs` is the only telemetry hook registered. There is no `PreToolUse(Skill)` matcher and no
`Stop` hook, so `resolve-phase.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs`, `emit-event-receipt.mjs`
and `check-telemetry-receipts.mjs` are present on disk but never fire. `phase_start` and `phase_end` are
therefore not emitted in this repo. Whether this is a deliberate consequence of the
`--structured-telemetry-mcp` gate or an oversight could not be determined from the repo alone; the backend
URL is hard-coded into the one wired hook, which points towards the flag having been passed.

**Retry state of every telemetry hook** (`grep RETRY_DELAYS_MS`):

| Hook | Retry present |
|------|---------------|
| `context-pressure.mjs` | no, single unretried `fetch` |
| `emit-phase-start.mjs` | no |
| `emit-phase-end.mjs` | no |
| `emit-event-receipt.mjs` | no |
| `resolve-phase.mjs` | no |

Backlog `0000063` states three affected hooks. Five carry the defect.

**Telemetry backend health at P0:** listener confirmed on `127.0.0.1:3741` (node, PID 10565). `POST /emit`
with a deliberately malformed body returned HTTP 400, so a listener is answering and validating. The failure
marker present at P0 start was a false positive from the daemon-restart window documented in `0000063`.

**Backlog state:** 21 open entries at P0 start, four of them untracked at branch creation. `0000029` and
`0000030`, referenced by `0000052`, are absent from `plan/backlog/` and appear in the changelogs for
`0000022` and `0000026`, indicating they were actioned.
