---
title: "Requirement: req-002 - build-target-agent-guidance"
status: "active"
version: "0.1.0"
---
# Requirement: req-002 — Build target agent guidance

**Feature:** 0000007-agent-optimisation
**Source:** User story — "As an agent, I read `Build target` from the design and adjust my environment assumptions accordingly"
**Priority:** must-have

---

## Functional Requirements

- `planifest-framework/standards/build-target-standards.md` MUST exist defining all three tiers and per-tier agent behaviour:
  - `local` — agent may check host-installed runtimes and tools; standard behaviour
  - `docker` — agent MUST NOT check host runtimes; scaffold Dockerfile-first; run all checks via `docker build` / `docker run`; never run `node`, `dotnet`, `python`, `go`, or equivalent CLI commands directly against the host
  - `ci-only` — agent runs checks only via CI pipeline commands; no local execution assumed

- `planifest-orchestrator/SKILL.md` P0 coaching MUST include: when the stack declaration contains `compute: docker` or `iac: dockerfile`, coach the human to set `Build target: docker`

- `planifest-codegen-agent/SKILL.md` MUST include an explicit `Build target: docker` behaviour section stating: never check host runtimes; scaffold Dockerfile-first; all validation runs via `docker build`/`docker run`

- `planifest-validate-agent/SKILL.md` MUST include an explicit `Build target: docker` behaviour section stating: run CI checks inside container, not against host; no direct lint/typecheck/test invocations against host toolchain

## Acceptance Criteria

- [ ] `build-target-standards.md` exists with all three tier definitions and per-tier agent behaviour
- [ ] Orchestrator P0 coaching section references Build target and coaches when Docker is implied by the stack
- [ ] Codegen-agent has a `Build target: docker` behaviour section
- [ ] Validate-agent has a `Build target: docker` behaviour section
- [ ] No acceptance criterion requires checking host-installed tools when `Build target: docker` is declared

## Dependencies

- req-001 (build target field must exist in template before agents can reference it)
