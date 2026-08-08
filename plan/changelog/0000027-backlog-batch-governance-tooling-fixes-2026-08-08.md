# Changelog — 0000027-backlog-batch-governance-tooling-fixes — 08 Aug 2026

**Feature:** Backlog batch: governance and tooling fixes
**Pipeline run:** P0–P9 complete, no phases skipped
**PR:** pending — `local-git-only` override active; PR title/description output to the human on the loop at P9 for them to raise via `gh pr create` after `git push`

## What Was Built

A batch of 8 confirmed `plan/backlog/` items, picked up at P0 and confirmed as one pipeline run (precedent: `0000025` shipped 7 similarly-scoped items the same way):

1. `emit-phase-start.mjs`/`emit-phase-end.mjs` are now actually wired into `setup.sh`/`setup.ps1`'s hook config (via a new `resolve-phase.mjs` interposer solving the fixed-command/positional-phase-argument problem), alongside `context-pressure.mjs`, plus a positive-presence check that fails loudly on partial wiring.
2. `cline.sh`/`cline.ps1`'s boot-file/skills-dir path collision is fixed — the boot file now lives at `.clinerules/00-planifest-boot.md`, no longer colliding with `.clinerules/skills/`.
3. Dispatched subagents are now explicitly instructed (in `agent-dispatch-standards.md` and all 5 phase skills) to file out-of-scope discoveries directly to `plan/backlog/`, not a host-tool side channel.
4. A deterministic telemetry-compliance backstop closes the remaining gap `0000026` didn't cover: `emit-event-receipt.mjs` writes a receipt on every successful `emit_event` call, and `check-telemetry-receipts.mjs` flags a build-log phase claiming "emitted" with no matching receipt.
5. 7 Deferred Items/Tech Debt rows from 4 pre-`0000025` archived features' `recommendations.md` are backfilled into `plan/backlog/` (entries `0000048`–`0000054`), never modifying the source files.
6. P0 now has an explicit step (Resume Detection 1a) distinguishing a `planifest-framework/` dependency update from an arbitrary code push, gated on human confirmation of both the update and its provenance — documented as this repo's actual Framework Update Policy.
7. An ADR (`ADR-003`) records the "does this skill earn its place" governance test, with `planifest-test-writer`/`implementer`/`refactor`/`verify-by-execution` as worked examples (three retain, one retain-marginal).
8. A minimal default Phase 1 artifact set (execution plan, requirements, scope, risk register, domain glossary) is named, with OpenAPI/Operational Model/SLO Definitions/Cost Model each gated by an explicit trigger condition — `feature-pipeline.md` and `planifest-spec-agent` now agree, and the README states the default artifact count.

Two security findings surfaced and fixed during P5, both with regression tests: a path-traversal risk (CWE-22) in the new `emit-event-receipt.mjs` hook, and a pre-existing shell-interpolation risk in `setup.sh`/`setup.ps1`'s `--backend-url` handling (fixed for all 3 telemetry hook registrations, not just the 2 this feature added, per an explicit human scope-expansion decision at the P5 gate).

## Artifacts Produced

`feature-brief.md`, `design.md`, `discovery.md`, `execution-plan.md`, `scope.md`, `risk-register.md`, `domain-glossary.md`, 8 requirement docs (`requirements/req-001` through `req-008`), 4 ADRs (`adr/ADR-001` through `ADR-004`), `security-report.md`, `recommendations.md`, `build-log.md`. Operational Model, SLO Definitions, and Cost Model were not produced — N/A per `ADR-004`'s own minimal-artifact-set rule (zero deployed runtime footprint), the exact judgment call `req-008` itself formalises.

## Decisions

- **ADR-001:** `check-telemetry-failures.mjs` extended with a sibling `check-telemetry-receipts.mjs` and a new `emit-event-receipt.mjs` receipt hook, closing the emit_event-verification half of backlog `0000044`.
- **ADR-002:** Framework dependency updates get their own P0 step and `standards/framework-update-policy.md`, deliberately not a `planifest-migrator` extension or a new standalone skill.
- **ADR-003:** Skill-scope principle recorded — governance/traceability test, four worked examples, `planifest-refactor` explicitly marginal.
- **ADR-004:** Minimal default Phase 1 artifact set named, with explicit trigger conditions for the rest.

## Skipped Phases

None.
