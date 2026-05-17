# Changelog — 0000011-setup-parity-and-consistency — 17 May 2026

**Feature:** Setup parity and consistency — setup.ps1 gaps, hook adapter fixes, template alignment, archive rename
**Pipeline run:** P0 (Assess), P1 (Spec), P2 (ADRs), P3 (Codegen), P4 (Validate), P5 (Security), P6 (Docs), P7 (Ship), P8 (Build Assessment — pending)
**PR:** pending — updated after PR is raised in Step 9

## What Was Built

- `setup.ps1` parity with `setup.sh`: `--include-full-skill-library` flag, `roo-code` in ValidTools, skill-sync dispatch
- External skills README stale link removed
- PowerShell test coverage for `--include-full-skill-library`
- Rail-tightening test assertion for setup.ps1
- Requirement template: user story section added
- Feature brief template: "As a / I / so that" format
- Non-pipeline skill routing documented in orchestrator
- Design template: captures full user story text
- Validate-agent: AC-level coverage check (not just req-ID)
- Execution plan template: stale link fix + FR directory section
- Docs-agent: living documentation mandate (architecture-overview, decisions-index)
- Three new templates: architecture-overview, api-index, decisions-index
- Archive directory standardised to `plan/_archive/` across all skills, templates, migration scripts
- Migration 0003 (`plan/archive/` → `plan/_archive/`) applied
- GitHub Copilot hook adapter: `pre_tool_use`/`prompt_submit` event name variants
- Windsurf adapter: envelope fix + expanded Cascade event routing
- Roo Code: deprecated — warning + exit 0, no installation
- Cursor adapter: `conversation_id`/`workspace_roots` envelope + `beforeSubmitPrompt` routing
- Codex adapter: `hook_event_name` dispatch + UserPromptSubmit routing + JSON deny format
- All 8 skill SKILL.md files: emission gate text added to Telemetry sections
- Ship-agent: PR raised after P8 (not before archive) per REQ-020
- Living docs: architecture-overview.md and decisions-index.md created for first time

## Artifacts Produced

- `plan/current/design.md`
- `plan/current/execution-plan.md`
- `plan/current/scope.md`
- `plan/current/risk-register.md`
- `plan/current/domain-glossary.md`
- `plan/current/requirements/` — 20 requirement files (REQ-001 through REQ-020)
- `plan/current/adr/ADR-001-hook-deny-response-format.md`
- `plan/current/adr/ADR-002-workspace-hook-config-write-strategy.md`
- `plan/current/adr/ADR-003-hook-adapter-architecture.md`
- `plan/current/build-log.md`
- `plan/current/security-report.md`
- `plan/current/recommendations.md`
- `plan/changelog/0000011-setup-parity-and-consistency-2026-05-17.md` (iteration log)
- `plan/changelog/0000011-setup-parity-and-consistency-test-report-2026-05-17.md` (test report — see Step T)
- `docs/architecture-overview.md` (new)
- `docs/decisions-index.md` (new)

## Decisions

- **ADR-001:** Adapters translate exit-2 signals to tool-specific JSON deny shapes; enforcement scripts stay tool-agnostic
- **ADR-002:** Planifest owns the workspace-level hook config file entirely; custom hooks belong in user-level config
- **ADR-003:** All adapters use the delegating pattern — translate envelope, call shared enforcement script via spawnSync

## Skipped Phases

None
