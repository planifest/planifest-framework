# Changelog — 0000005-framework-governance — 02 May 2026

**Feature:** Framework Governance — seven governance gaps closed
**Pipeline run:** P0 Assess → P1 Spec → P2 ADRs → P3 Codegen → P4 Validate → P5 Security → P6 Docs → P7 Ship
**PR:** (pending)

## What Was Built

- **Library standards**: directory tree under `standards/library-standards/` with prefer/avoid docs and version policy for TypeScript, Python, Go, Java, and databases; test-frameworks docs for TypeScript, Python, and Go
- **Formatting standards**: `standards/formatting-standards.md` declaring DD MMM YYYY date format, British English locale, and verbosity standard; propagated to all agent SKILL.md files via `bundle_standards`
- **Migration infrastructure**: `migrations/` directory with `0001-date-format.md`, `0002-british-english.md`, `_done/` archive; `planifest-migrator` skill
- **Orchestrator sentinel enforcement**: `gate-write.mjs` blocks `plan/current/**` writes unless `plan/.orchestrator-active` exists; `check-design.mjs` injects STOP when neither feature-brief nor sentinel is present
- **GitHub Copilot adapter**: `hooks/adapters/copilot.mjs` wiring gate-write and check-design logic into the Copilot `agent_hooks` API
- **Capability skill intake**: `skills-inbox/`, `external-skills.json`, `Sync-OverrideSkills` in `setup.ps1`
- **planifest-overrides support**: `planifest-overrides/library-standards/` scaffolded; `setup.ps1` reads overrides; `setup.sh` does not write to it
- **British English rewrite**: `testing-standards.md`, `planifest-change-agent/SKILL.md` corrected to British English
- **Security fix (P5)**: path prefix bypass in `gate-write.mjs` and `copilot.mjs` — `startsWith(cwd)` replaced with `startsWith(cwd + "/")` to prevent sibling-directory path truncation

## Artefacts Produced

**plan/current/**
- `feature-brief.md`, `design.md`, `execution-plan.md`, `scope.md`, `risk-register.md`, `domain-glossary.md`
- `requirements/req-001` through `req-016`
- `adr/ADR-001` through `ADR-006`
- `iteration-log.md`

**planifest-framework/**
- `standards/library-standards/_version-policy.md`
- `standards/library-standards/typescript/prefer-avoid.md`, `test-frameworks.md`
- `standards/library-standards/python/prefer-avoid.md`, `test-frameworks.md`
- `standards/library-standards/go/prefer-avoid.md`, `test-frameworks.md`
- `standards/library-standards/java/prefer-avoid.md`
- `standards/library-standards/databases/prefer-avoid.md`
- `standards/formatting-standards.md`
- `migrations/0001-date-format.md`, `migrations/0002-british-english.md`, `migrations/_done/.gitkeep`
- `hooks/enforcement/gate-write.mjs` (updated)
- `hooks/enforcement/check-design.mjs` (updated)
- `hooks/adapters/copilot.mjs` (new)
- `external-skills.json`
- `skills-inbox/.gitkeep`
- `component.yml`
- Updated SKILL.md files: codegen, validate, orchestrator, spec, adr, docs, security, ship, change, migrator

**tests/**
- `test-0000005-framework-governance.sh` (54 assertions, req-001–016)
- `test-context-pressure.sh` (updated — MSYS cygpath fixes)
- `run-tests.sh` (updated — added governance suite)

## Decisions

- **ADR-001**: Library standards as flat Markdown files under `standards/library-standards/` — human-readable, diffable, no tooling dependency
- **ADR-002**: `planifest-overrides/` as sibling directory to `planifest-framework/` — user-owned, never overwritten by setup scripts
- **ADR-003**: Sentinel file (`plan/.orchestrator-active`) for orchestrator enforcement — avoids env var fragility
- **ADR-004**: Scope injection via `design.md` `## Component Paths` section — single source of truth already present
- **ADR-005**: Markdown migration files — auditable, no runtime migration runner needed for standards docs
- **ADR-006**: Two-registry capability skills (`skills-inbox/` ephemeral, `planifest-overrides/capability-skills/` permanent)

## Skipped Phases

None
