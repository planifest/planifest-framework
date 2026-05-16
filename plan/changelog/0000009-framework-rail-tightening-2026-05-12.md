# Changelog — 0000009-framework-rail-tightening — 12 May 2026

**Feature:** framework-rail-tightening
**Pipeline run:** P0–P6 complete (P7 Ship pending)
**PR:** (pending)

---

## What Was Built

- **REQ-001** — Fixed bare `.skips` references in orchestrator SKILL.md to canonical `plan/current/.skips`
- **REQ-002** — `auto-trigger-orchestrator.mjs` UserPromptSubmit hook: auto-loads orchestrator at session start when `plan/.orchestrator-active` is absent; CLAUDE.md fallback instruction added
- **REQ-003a** — Orchestrator Subagent Decomposition Directive: phase agents instructed to decompose complex tasks into subagents with skill-library lookup and model-tier selection
- **REQ-003b** — Skill Map in `design.md`: orchestrator produces `## Skill Map` at P0, re-evaluated at each phase gate
- **REQ-004/005** — External-skills library: 192 curated open-source skills from 20 upstream repos (MIT/Apache 2.0), 8 original skills; all with `attribution.txt`; `--include-full-skill-library` setup flag; `external-skills/README.md` index
- **REQ-006** — Pause/resume: `pause.md` written on command; resume detection extended; `gate-write.mjs` always-permits `pause.md`
- **REQ-007** — `setup.sh` `append_override_instructions` parity with `setup.ps1`
- **REQ-008** (feature numbering) — `setup.sh` `copy_capability_skills` parity with `setup.ps1`
- **REQ-009** — `setup.ps1` Tier 1 adapter support: Cursor, Windsurf, Cline, roo-code
- **REQ-010** — `setup.ps1 opencode` support
- **REQ-011** — TypeScript adapter for OpenCode/KiloCode (`hooks/adapters/opencode/index.ts`)
- **REQ-012** — `gate-write.mjs` Windows path normalisation fix: `norm()` helper, `cwdPrefix` comparison; regression test
- **REQ-008 (mid-pipeline)** — `check-orchestrator-presence.mjs` UserPromptSubmit hook: advisory banner on every prompt when pipeline active; `--strict-orchestrator` flag enables session_id-based ack enforcement; `plan/.orchestrator-ack` written by orchestrator at P0 start, deleted at P7; `getting-started.md` updated

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature brief | `plan/current/feature-brief.md` |
| Execution plan | `plan/current/execution-plan.md` |
| Design | `plan/current/design.md` |
| Requirements (8 files) | `plan/current/requirements/` |
| ADRs (6 files) | `plan/current/adr/` |
| Scope | `plan/current/scope.md` |
| Risk register | `plan/current/risk-register.md` |
| Domain glossary | `plan/current/domain-glossary.md` |
| Security report | `plan/current/security-report.md` |
| Build log | `plan/current/build-log.md` |
| Recommendations | `plan/current/recommendations.md` |
| External-skills README | `planifest-framework/external-skills/README.md` |

## Decisions

| ADR | Decision |
|-----|----------|
| ADR-001 | External skills opt-in via `--include-full-skill-library` flag |
| ADR-002 | Per-skill `attribution.txt` format for licence compliance |
| ADR-003 | Auto-trigger via UserPromptSubmit hook + CLAUDE.md fallback |
| ADR-004 | Skill Map in `design.md` (not a separate file) |
| ADR-005 | `norm()`-based path normalisation in gate-write for Windows fix |
| ADR-006 | Pause/resume via `plan/current/pause.md` file |

## Security

- S-001 (Medium, fixed): `featureId` in presence-check banner sanitised to `[a-zA-Z0-9\-_.]`, max 80 chars
- S-002 (Low, accepted): `session_id` echoed into strict-mode banner — Claude Code runtime-controlled
- S-003 (Low, accepted): `cwd` from hook stdin not validated against host value

## Skipped Phases

None.
