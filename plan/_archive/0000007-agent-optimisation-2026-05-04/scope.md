---
title: "Scope - 0000007-agent-optimisation"
status: "active"
version: "0.1.0"
---
# Scope — 0000007-agent-optimisation

## In Scope

- New `Build target: local | docker | ci-only` row in `feature-brief.template.md` stack table
- Orchestrator P0 coaching: prompt human to set Build target when compute/IaC implies Docker
- Codegen-agent guidance: when `Build target: docker` — never check host runtimes; scaffold Dockerfile-first; run checks via `docker build`/`docker run`
- Validate-agent guidance: when `Build target: docker` — run CI checks inside container, not against host
- New `planifest-framework/standards/build-target-standards.md`
- New `planifest-framework/skills/planifest-optimise-agent/SKILL.md`
- New `planifest-framework/standards/telemetry-standards.md`
- New `planifest-framework/templates/design.template.md`
- New `planifest-framework/standards/language-quirks-en-gb.md`
- Boilerplate removal from skill files (Hard Limits, footers, Role Boundary) — req-004
- Telemetry extraction from 9 skills — req-005
- Stale reference cleanup across skill files — req-006
- Template extractions and setup manifest — req-007
- Global `artefact` → `artifact` replacement — req-008
- Tests covering all new requirements

## Out of Scope

- Applying confirmed optimisations automatically without human confirmation
- Reviewing `planifest-overrides/capability-skills/` (user-owned)
- Automated removal of content without human confirmation
- Reviewing workflow files (`.claude/commands/`, `.github/copilot-workflows/`)
- Multi-locale support beyond `en-GB` (other locales can add their own `language-quirks-{locale}.md`)
- CI/CD changes for consumer projects

## Deferred

- Optimise-agent reviewing workflow files (can be added in a later change)
- `language-quirks-{locale}.md` files for other locales (structure is ready; content deferred)
- Windsurf native hook wiring (blocked: hooks API not yet stable)
