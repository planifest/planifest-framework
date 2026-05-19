# Design - 0000008-context-mode-plugin-routing-rules

## Feature
- Problem: context-mode routing rules were duplicated between a framework-managed template file and the plugin's own system prompt; plugin is now the canonical source
- Adoption mode: standard-iterative
- Feature ID: 0000008-context-mode-plugin-routing-rules

## Product Layer
- User stories confirmed: 3
- Acceptance criteria confirmed: 6
- Constraints: must not touch plan/archive history; must not remove AGENTS.md (used by Codex)
- Integrations: context-mode marketplace plugin (provides routing rules via system prompt)

## Architecture Layer
- Latency target: not applicable
- Availability target: not applicable
- Scalability target: not applicable
- Security: not applicable
- Data privacy: no regulated data
- Observability: not applicable
- Cost boundary: not constrained

## Engineering Layer
- Stack: bash / PowerShell / markdown
- Components: planifest-framework (setup scripts, templates, docs, skill assets)
- Data ownership: not applicable
- Deployment: file changes committed to repo; consumers re-run setup to get updated scripts
- API versioning: not applicable

## Scope
- In: delete 5 context-mode-agents.md files; remove AGENTS.md routing rules copy from setup.sh + setup.ps1; update help text; update docs/context-mode.md; update tool-setup-reference.md; update getting-started.md; update standard-boot.md (5 copies) and CLAUDE.md
- Out: plan/archive history docs; AGENTS.md file itself; enforcement hooks
- Deferred: none

## Assumptions
- context-mode plugin injects routing rules for all tools that support it, not just Claude Code - impact if wrong: other tools (Cursor, Windsurf, etc.) lose routing rules entirely with no fallback
- AGENTS.md in the project root is used exclusively as Codex boot file, not as a routing rules file - impact if wrong: removing the routing rules copy step may silently break Codex setups that relied on it

## Risks
- Other tools (non-Claude Code) relied on the copied AGENTS.md for routing rules and do not support the plugin system — likelihood: low; impact: medium (those tools lose advisory routing)

## Dependencies
- Upstream: context-mode plugin ≥ version that injects system prompt routing rules
- Downstream: none

## Active Skills
None

## Repo Instructions
None

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 08 May 2026
