# Design - 0000009-framework-rail-tightening

## Feature
- Problem: Orchestrator spec/implementation drift, bash/PS1 setup parity gaps, incomplete platform coverage (Windows Tier 1 tools), gate-write Windows path bug blocking P7 archive writes
- Adoption mode: retrofit
- Feature ID: 0000009-framework-rail-tightening

## Product Layer
- User stories confirmed: 13
- Acceptance criteria confirmed: 12
- Constraints: planifest-overrides/ never written or deleted by setup; commit-standards.md enforced; TypeScript adapter uses Bun built-ins only; local git only
- Integrations: Cursor, Windsurf, Cline, roo-code hook configs; opencode/KiloCode TypeScript plugin API; context-mode plugin (routing rules, not enforcement)

## Architecture Layer
- Latency target: not applicable
- Availability target: not applicable
- Scalability target: not applicable
- Security: no new auth surface; gate-write enforcement extended to additional tools
- Data privacy: no regulated data
- Observability: existing telemetry standards apply; build log produced per pipeline run
- Cost boundary: not constrained

## Engineering Layer
- Stack: Markdown / Bash / PowerShell / TypeScript / Bun — local build target; existing test suite
- Components: planifest-framework (existing component-pack) — skills, setup scripts, hooks, templates, standards, open-source skill library
- Data ownership: plan/current/ owned by planifest-framework; planifest-overrides/ owned by project (read-only to framework)
- Deployment: file changes committed to local feat/ branch; human pushes and raises PR
- API versioning: not applicable

## Component Paths
- planifest-framework/
- .claude/

## Scope
- In:
  - REQ-1: fix bare `.skips` refs in orchestrator SKILL.md → `plan/current/.skips`
  - REQ-2: auto-trigger orchestrator via UserPromptSubmit hook + CLAUDE.md fallback
  - REQ-3a: orchestrator instructs phase agents to decompose into subagents with skill-library lookup and model-tier selection
  - REQ-3b: skill-to-requirement mapping from P0; re-evaluated at each gate; human confirms
  - REQ-4: curated open-source skill library in `planifest-framework/external-skills/`; `--include-full-skill-library` flag; permissive-license only; each skill directory contains `attribution.txt` with license type, copyright holder, source URL, required attribution text, and full license text appended at the bottom; library populated during this pipeline run via web search
  - REQ-5: pause.md written on command; resume detection restores from exact pause point
  - REQ-6: setup.ps1 and setup.sh inject planifest-overrides/instructions/ into orchestrator SKILL.md and copied workflow files; sentinel-marker idempotency
  - REQ-7: setup.sh Append-OverrideInstructions parity with PS1
  - REQ-8: setup.sh Copy-CapabilitySkills parity with PS1
  - REQ-9: setup.ps1 Tier 1 adapter support — Cursor, Windsurf (conditional), Cline, roo-code
  - REQ-10: setup.ps1 opencode support — $ValidTools entry + setup/opencode.ps1
  - REQ-11: TypeScript adapter for OpenCode/KiloCode — tool.execute.before/after, gate-write + check-design enforcement, Bun runtime
  - REQ-12: fix gate-write.mjs Windows path bug in planifest-framework/hooks/enforcement/gate-write.mjs; regression test added
- Out:
  - Changes to phase agent skills beyond orchestrator wiring
  - New MCP plugins or server-side infrastructure
  - Gemini CLI, VS Code Copilot, JetBrains Copilot enforcement
  - Windsurf hook registration if Windsurf has no configurable settings file (documented as conditional)
- Deferred:
  - OpenCode/KiloCode full session continuity — context-mode handles this
  - Per-tool routing rules fallback (0000008 ADR-002)

## Assumptions
- Windsurf exposes a configurable hook settings file — impact if wrong: REQ-9 covers Cursor, Cline, roo-code only; documented in scope
- opencode and KiloCode plugin APIs stable at current versions — impact if wrong: TypeScript adapter may need revision against updated API
- Existing bash Tier 1 adapter scripts (cursor.mjs, windsurf.mjs, cline.mjs) reusable as-is for PS1 wiring — impact if wrong: adapters need Windows-specific variants

## Risks
- Open-source skill licenses may be ambiguous or mixed — likelihood: medium; impact: low (non-permissive skills simply excluded; library ships smaller)
- Windsurf hook config format undocumented — likelihood: medium; impact: low (conditional scope; document gap and ship without Windsurf if unresolvable)
- opencode/KiloCode plugin API changes between discovery and implementation — likelihood: low; impact: medium (adapter needs rework)

## Dependencies
- Upstream: context-mode plugin (routing, not enforcement — no direct code dependency)
- Downstream: none

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| REQ-001 - skips-path-fix | planifest-codegen-agent | Text substitution in Markdown SKILL.md |
| REQ-002 - auto-trigger-orchestrator | planifest-codegen-agent | New JS hook file + settings.json + CLAUDE.md |
| REQ-003a - subagent-decomposition | planifest-codegen-agent | Orchestrator SKILL.md prose update |
| REQ-003b - skill-requirement-mapping | planifest-codegen-agent | Orchestrator SKILL.md + design.template.md update |
| REQ-004 - open-source-skill-library | planifest-codegen-agent | Web search + external-skills/ dir + setup script flag |
| REQ-005 - attribution-validation | planifest-codegen-agent | Bash test script for attribution.txt completeness |
| REQ-006 - pause-resume | planifest-codegen-agent | pause.template.md + orchestrator SKILL.md updates |
| REQ-007 - gate-write-windows-fix | planifest-codegen-agent | JS path normalisation fix + bash regression test |

## Active Skills
None

## Repo Instructions
Don't fetch, pull, push or otherwise attempt to use remote git commands. You don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 09 May 2026
