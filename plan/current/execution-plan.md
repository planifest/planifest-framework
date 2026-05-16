# Execution Plan - 0000011-setup-parity-and-consistency

> Written by the spec-agent. Derived from the confirmed design — not invented. Every requirement is traceable to a user story in `plan/current/design.md`.

**Skill:** [spec-agent](../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000011-setup-parity-and-consistency
**Version:** 0.1.0
**Status:** active

---

## Active Skills

| Skill | Scope | Purpose |
|-------|-------|---------|
| planifest-codegen-agent | plan | Primary implementation skill for all 19 requirements |

---

## Functional Requirements Directory

Functional requirements are split into individual files — one user story per file — at `plan/current/requirements/`.

Each file follows the naming convention `req-{NNN}-{kebab-slug}.md` and the [Requirement Template](../planifest-framework/templates/requirement.template.md).

| File | Requirement |
|------|------------|
| [req-001-include-full-skill-library-ps1.md](requirements/req-001-include-full-skill-library-ps1.md) | `--include-full-skill-library` flag in setup.ps1 |
| [req-002-roo-code-valid-tools.md](requirements/req-002-roo-code-valid-tools.md) | `roo-code` in `$ValidTools` |
| [req-003-skill-sync-dispatch-ps1.md](requirements/req-003-skill-sync-dispatch-ps1.md) | skill-sync dispatch in setup.ps1 |
| [req-004-stale-readme-link.md](requirements/req-004-stale-readme-link.md) | Remove stale link in external-skills/README.md |
| [req-005-test-ps1-include-flag.md](requirements/req-005-test-ps1-include-flag.md) | test_setup.ps1 coverage for `--include-full-skill-library` |
| [req-006-test-rail-tightening-ps1-assertion.md](requirements/req-006-test-rail-tightening-ps1-assertion.md) | grep assertions in test-0000009 for setup.ps1 |
| [req-007-requirement-template-user-stories.md](requirements/req-007-requirement-template-user-stories.md) | Requirement template must include `## User Story` section |
| [req-008-feature-brief-user-story-format.md](requirements/req-008-feature-brief-user-story-format.md) | Feature brief must use "As a / I / so that" format |
| [req-009-non-pipeline-skills-routing.md](requirements/req-009-non-pipeline-skills-routing.md) | Standalone skills routing in orchestrator |
| [req-010-design-template-user-story-body.md](requirements/req-010-design-template-user-story-body.md) | Design template must capture user story text |
| [req-011-validate-agent-ac-coverage.md](requirements/req-011-validate-agent-ac-coverage.md) | Validate-agent must check AC-level coverage |
| [req-012-execution-plan-template-gaps.md](requirements/req-012-execution-plan-template-gaps.md) | Fix stale link and FR section in execution plan template |
| [req-013-docs-living-documentation.md](requirements/req-013-docs-living-documentation.md) | docs/ as living documentation layer |
| [req-014-archive-naming-consistency.md](requirements/req-014-archive-naming-consistency.md) | Standardise to `plan/_archive/` + migration doc |
| [req-015-copilot-hooks-tier1-upgrade.md](requirements/req-015-copilot-hooks-tier1-upgrade.md) | GitHub Copilot hooks (preToolUse + userPromptSubmitted) |
| [req-016-windsurf-expanded-hooks.md](requirements/req-016-windsurf-expanded-hooks.md) | Windsurf Cascade hooks (pre_write_code + pre_user_prompt + pre_mcp_tool_use) |
| [req-017-roo-code-deprecation.md](requirements/req-017-roo-code-deprecation.md) | Roo Code deprecation (shut down 15 May 2026) |
| [req-018-cursor-adapter-envelope-update.md](requirements/req-018-cursor-adapter-envelope-update.md) | Cursor hooks (preToolUse + beforeSubmitPrompt) |
| [req-019-codex-adapter-envelope-update.md](requirements/req-019-codex-adapter-envelope-update.md) | Codex CLI hooks (PreToolUse + UserPromptSubmit) |

---

## Non-Functional Requirements

| ID | Category | Requirement | Target | Measurement |
|----|----------|-------------|--------|-------------|
| NFR-001 | Reliability | All setup scripts must be idempotent | Zero side effects on re-run | Manual re-run produces identical output; `.planifest-manifest` not duplicated |
| NFR-002 | Portability | All hook adapters must degrade gracefully on unsupported platforms | Exit 0 silently when platform is unsupported | Windows path in codex.mjs exits 0; no session block |
| NFR-003 | Safety | Hook adapters must never block a session due to adapter-internal errors | Exit 0 on all unexpected throws | Try/catch wraps all adapter logic; unexpected errors are swallowed |
| NFR-004 | Maintainability | No new external runtime dependencies | Zero new `npm install` or OS package requirements | Hook adapters use only Node.js built-ins; setup scripts use only bash/PowerShell built-ins |
| NFR-005 | Correctness | Hook block responses must use the format each tool documents | Tool accepts the block response; enforcement fires | Verified against official hook API docs for each tool |

---

## API Summary

Not applicable — this feature modifies framework scripts, templates, and hook adapters. No API endpoints are introduced or changed.

---

## Data Model Summary

Not applicable — no database schema. The `.planifest-manifest` file is an existing line-delimited text file; its format is unchanged.

---

## Component Interactions

```
setup.sh / setup.ps1
  └── setup/copilot.sh|ps1   → writes .github/hooks/planifest.json
  └── setup/windsurf.sh|ps1  → writes .windsurf/hooks.json
  └── setup/cursor.sh|ps1    → writes .cursor/hooks.json
  └── setup/codex.sh|ps1     → writes .codex/hooks.json
  └── setup/roo-code.sh|ps1  → prints deprecation warning, exits 0

hooks/adapters/copilot.mjs   ← .github/hooks/planifest.json invokes it
hooks/adapters/windsurf.mjs  ← .windsurf/hooks.json invokes it
hooks/adapters/cursor.mjs    ← .cursor/hooks.json invokes it
hooks/adapters/codex.mjs     ← .codex/hooks.json invokes it

migrations/0003-archive-dirname.md  ← picked up by planifest-migrator on resume
migrations/migrate-archive-dirname.sh|ps1  ← manual alternative
```

---

## Assumptions

| ID | Assumption | Impact if Wrong |
|----|------------|----------------|
| A-001 | `skill-sync.ps1 sync <tool>` interface matches `skill-sync.sh` | REQ-003 dispatch call needs adjustment; low blast radius |
| A-002 | Copilot hooks are available in all Copilot CLI versions in use | Hooks silently not invoked on older versions; enforcement degrades to instructions-only |
| A-003 | Node.js is available in the PATH wherever hook adapters are invoked | Adapter command `node ...` fails silently; tools typically bundle Node |
| A-004 | `.cursor/hooks.json` `version: 1` format is the current stable format | Config rejected by Cursor; setup would need format update |

---

## Open Questions

None — all material gaps were resolved during P0 coaching.

---

*Generated by spec-agent. See [Orchestrator Skill](../planifest-framework/skills/planifest-orchestrator/SKILL.md)*
