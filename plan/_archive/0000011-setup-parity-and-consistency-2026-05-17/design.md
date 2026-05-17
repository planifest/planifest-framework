# Design - 0000011-setup-parity-and-consistency

## Feature
- Problem: setup.ps1 has multiple parity gaps vs setup.sh, and broader framework inconsistencies exist in tests and docs
- Adoption mode: retrofit
- Feature ID: 0000011-setup-parity-and-consistency

## Product Layer

### User Stories
- US-001: As a Windows user running setup.ps1 with `--include-full-skill-library`, external skills are copied to my tool's skill directory with the same behaviour as setup.sh
- US-002: As a Windows user running `setup.ps1 roo-code`, setup succeeds (not "Unknown tool")
- US-003: As a framework maintainer, I can trust that setup.ps1 and setup.sh produce equivalent results for all shared flags and behaviours
- US-004: As a framework contributor, tests catch regressions in setup.ps1 parity
- US-005: As a spec-agent producing requirements, I want a clear template that includes user story text and acceptance criteria so that each requirement doc is self-contained and testable
- US-006: As a spec-agent, I want the feature brief to use "As a / I / so that" format consistently so stories are captured correctly from the start
- US-007: As a framework user, I want non-pipeline skills (implementer, optimise, refactor, test-writer) to be clearly documented in the orchestrator so I know when to invoke them outside the full pipeline
- US-008: As a framework agent in P3 or later, I want the confirmed design to contain the full user story text so I can implement against stories without reloading the feature brief into context
- US-009: As a framework maintainer, I want the validate-agent to confirm all acceptance criteria in each requirement doc are exercised by tests so that a passing test suite is meaningful evidence of completeness
- US-010: As a spec-agent producing an execution plan, I want the template to have accurate references and clear structure guidance so the artifact I produce is correct without guessing or investigating broken links
- US-011: As a developer onboarding to a Planifest repo, I want to read docs/ and understand the current state of the system without having to read plan archives or source code
- US-012: As a framework user, I want the archive directory consistently named plan/_archive/ across all skills, templates, and scripts so it sorts to the top of directory listings and the indexing ignore rule matches the real directory
- US-013: As a developer using GitHub Copilot in a Planifest repo, I want gate-write and check-design enforcement hooks to run natively through Copilot's hook system so that scope enforcement is automatic
- US-014: As a developer using Windsurf Cascade in a Planifest repo, I want Planifest hooks to fire on all relevant Cascade events so that enforcement runs at the correct moments across the full hook suite
- US-015: As a developer who previously used Roo Code in a Planifest repo, I want setup to inform me that Roo Code is discontinued and recommend a migration path so I am not left with broken or unenforced hooks

### Acceptance Criteria

**REQ-001 — `--include-full-skill-library` flag in setup.ps1**
- AC-001a: `$IncludeFullSkillLibrary = $false` initialised in the variable block alongside `$ContextModeMcp`, `$StructuredTelemetryMcp`, `$StrictOrchestrator`
- AC-001b: `'--include-full-skill-library' { $IncludeFullSkillLibrary = $true; $i++ }` present in the `while`/`switch` arg parser
- AC-001c: `Copy-ExternalSkills` function implemented: iterates `planifest-framework/external-skills/*/`, skips any dir missing `SKILL.md` or `attribution.txt` (with per-skip warning), copies both files to `$TargetDir/$skillName/`, prints total count at end
- AC-001d: `Copy-ExternalSkills -TargetDir $skillsDir` called in `Invoke-PlanifestSetup` immediately after `Copy-PlanifestSkills`, gated on `$IncludeFullSkillLibrary -eq $true`
- AC-001e: External skill dirs installed by `Copy-ExternalSkills` are included in `.planifest-manifest` tracking (re-run cleanup must remove them)
- AC-001f: Help text block includes `--include-full-skill-library` with description matching setup.sh wording

**REQ-002 — `roo-code` in setup.ps1 `$ValidTools`**
- AC-002a: `'roo-code'` present in `$ValidTools` array
- AC-002b: `setup.ps1 roo-code` executes without "Unknown tool" error (setup/roo-code.ps1 already exists)

**REQ-003 — skill-sync re-run in setup.ps1 main dispatch**
- AC-003a: After `Invoke-PlanifestSetup` completes for each tool, setup.ps1 calls `skill-sync.ps1 sync $t` (via `& $syncScript sync $toolName`)
- AC-003b: The call is guarded: skips silently if `planifest-framework/scripts/skill-sync.ps1` does not exist (mirrors setup.sh's `[ -f "$sync_script" ]` guard)
- AC-003c: Applies to both single-tool and `all` dispatch paths

**REQ-004 — Fix stale link in `external-skills/README.md`**
- AC-004a: Line 25 reference to `plan/current/requirements/req-005-open-source-skill-library.md` is removed; the paragraph either references the archive path or drops the link entirely

**REQ-005 — `test_setup.ps1` coverage for `--include-full-skill-library`**
- AC-005a: `test_setup.ps1` includes a test block that runs `setup.ps1 claude-code --include-full-skill-library` in the temp workspace
- AC-005b: Test asserts at least one external skill dir exists under `.claude/skills/` (e.g. checks that a known external skill SKILL.md is present)
- AC-005c: Test asserts `.planifest-manifest` includes at least one external skill path

**REQ-006 — `test-0000009-rail-tightening.sh` assertion for setup.ps1**
- AC-006a: A new assertion checks that `setup.ps1` contains `include-full-skill-library` (mirrors existing lines 90–91 which check setup.sh)
- AC-006b: A new assertion checks that `setup.ps1` contains `Copy-ExternalSkills` function name

**REQ-007 — Requirement template must include user story section**
- AC-007a: `requirement.template.md` contains a `## User Story` section before `## Functional Requirements`
- AC-007b: The `## User Story` section contains an "As a / I / so that" placeholder
- AC-007c: `planifest-spec-agent/SKILL.md` instructs the agent to populate `## User Story` before writing functional requirements
- AC-007d: The spec-agent skill instructs the agent to flag any requirement without a user story as incomplete (not silently skip)
- AC-007e: The spec-agent skill states that acceptance criteria must be traceable to the user story in the same doc

**REQ-008 — Feature brief template must use "As a / I / so that" user story format**
- AC-008a: `feature-brief.template.md` Features table replaces generic `{{story-N}}` placeholders with "As a / I / so that" example rows
- AC-008b: A note is added to the Features section: one user story = one requirement doc
- AC-008c: No other sections of `feature-brief.template.md` are modified

**REQ-009 — Non-pipeline skills must be documented in orchestrator routing**
- AC-009a: `planifest-orchestrator/SKILL.md` contains a Standalone Skills section listing: planifest-implementer, planifest-optimise-agent, planifest-refactor, planifest-test-writer
- AC-009b: Each skill entry includes: name, one-line purpose, and when to invoke (outside the pipeline)
- AC-009c: The routing decision tree does not route standalone skill requests through the Feature or Change pipeline
- AC-009d: Each listed skill's `description` frontmatter field accurately reflects its standalone vs pipeline role

**REQ-010 — Design template must capture user story text, not just count**
- AC-010a: `design.template.md` Product Layer contains a `- User stories:` list field with "As a / I / so that" placeholder rows (not just a count)
- AC-010b: `planifest-orchestrator/SKILL.md` Phase 0 gate checklist requires full story text in the design, not just a count
- AC-010c: `design.md` for feature 0000011 contains the full user story list (this file demonstrates the new template)
- AC-010d: `Acceptance criteria confirmed: {count}` summary field may remain; it is not removed

**REQ-011 — Validate-agent must check acceptance criteria coverage, not just req-ID mapping**
- AC-011a: `planifest-validate-agent/SKILL.md` Step 1 explicitly requires AC-level coverage check, not just req-ID presence
- AC-011b: The skill instructs the agent to produce a coverage table per-requirement: `REQ-ID | AC | Covered by test | Pass/Fail`
- AC-011c: Missing AC coverage = semantic validation failure (not a warning)
- AC-011d: Malformed requirement doc (no `## Acceptance Criteria` section) = doc gap flag, not a halt
- AC-011e: The skill does not require 1:1 test-per-AC; one test may cover multiple ACs with a clear description

**REQ-012 — Fix execution plan template gaps**
- AC-012a: `execution-plan.template.md` line 98 references `planifest-orchestrator/SKILL.md` (not `orchestrator/SKILL.md`)
- AC-012b: The `## Functional Requirements Directory` section contains the naming convention `req-{NNN}-{kebab-slug}.md`
- AC-012c: The section contains a note: one requirement file = one user story
- AC-012d: No other sections are altered

**REQ-013 — docs/ must be populated as living documentation**
- AC-013a: `planifest-docs-agent/SKILL.md` contains an explicit section defining docs/ as the living documentation layer, distinct from plan/ (change artifacts) and src/{id}/docs/ (component-local docs)
- AC-013b: The docs-agent skill lists mandatory living docs to maintain on every run: component-registry, dependency-graph, architecture-overview, api-index (conditional), decisions-index
- AC-013c: The docs-agent skill specifies that living docs are updated (not recreated) on each run
- AC-013d: The docs-agent skill specifies the `Last updated: {feature-id}` field requirement for all living docs
- AC-013e: `planifest-framework/templates/architecture-overview.template.md` exists
- AC-013f: `planifest-framework/templates/api-index.template.md` exists
- AC-013g: `planifest-framework/templates/decisions-index.template.md` exists
- AC-013h: `planifest-orchestrator/SKILL.md` references docs/ as the living state layer in at least one coaching or phase description section

**REQ-014 — Standardise archive directory name to plan/_archive/**
- AC-014a: `planifest-orchestrator/SKILL.md` contains no reference to `plan/archive/` — all occurrences read `plan/_archive/`
- AC-014b: `planifest-ship-agent/SKILL.md` contains no reference to `plan/archive/`
- AC-014c: `planifest-build-assessment-agent/SKILL.md` contains no reference to `plan/archive/`
- AC-014d: No template in `planifest-framework/templates/` references `plan/archive/`
- AC-014e: `planifest-framework/migrations/migrate-archive-dirname.sh` exists, is idempotent, and handles the three cases (rename / already correct / both exist)
- AC-014f: `planifest-framework/migrations/migrate-archive-dirname.ps1` exists and is idempotent
- AC-014g: After migration runs on this repo, `plan/_archive/` exists and `plan/archive/` does not
- AC-014h: `grep -r 'plan/archive' planifest-framework/` returns zero results (excluding setup.sh, setup.ps1, and migration scripts)

**REQ-015 — GitHub Copilot hook adapter event name fix**
- AC-015a: `copilot.mjs` reads event type from `hook_event_name` first, falling back to `event` and `hook_event`
- AC-015b: The `userPromptSubmitted` branch matches `"userPromptSubmitted"` (camelCase) as primary condition
- AC-015c: The `preToolUse` branch matches `"preToolUse"` (camelCase) as primary condition
- AC-015d: Both branches retain snake_case fallbacks for compatibility
- AC-015e: No other logic in `copilot.mjs` is changed

**REQ-016 — Windsurf adapter envelope fix + expanded Cascade event routing**
- AC-016a: `windsurf.mjs` reads `hook_event_name` for event dispatch (not a hardcoded constant)
- AC-016b: `pre_write_code` events delegate to `gate-write.mjs`
- AC-016c: `pre_user_prompt` events delegate to `check-design.mjs`
- AC-016d: `pre_mcp_tool_use` events delegate to `gate-write.mjs` for write-type MCP tools
- AC-016e: All other events pass through with exit 0
- AC-016f: Setup scripts write config to `.windsurf/hooks.json` (not any other path)
- AC-016g: Setup is idempotent — running twice does not duplicate hook registrations

**REQ-017 — Roo Code deprecation**
- AC-017a: Running `setup.sh --tool roo-code` prints the deprecation warning and exits 0 without installing anything
- AC-017b: Running `setup.ps1 --tool roo-code` prints the deprecation warning and exits 0 without installing anything
- AC-017c: `roo-code` remains in the valid tool list but routes to a warning-only handler
- AC-017d: `setup/roo-code.sh` (if present) contains only the deprecation warning and `exit 0`
- AC-017e: `setup/roo-code.ps1` (if present) contains only the deprecation warning and exit logic
- AC-017f: Orchestrator skill marks Roo Code as deprecated in the tool tier table
- AC-017g: No Planifest skill or template instructs the agent to detect or configure Roo Code as an active tool

**REQ-018 — Cursor adapter envelope fix + beforeSubmitPrompt routing**
- AC-018a: `cursor.mjs` reads `conversation_id` as the primary session ID field
- AC-018b: `cursor.mjs` reads `workspace_roots[0]` as the primary cwd field
- AC-018c: `cursor.mjs` dispatches `"preToolUse"` events to `gate-write.mjs`
- AC-018d: `cursor.mjs` dispatches `"beforeSubmitPrompt"` events to `check-design.mjs`
- AC-018e: All other event types pass through with exit 0
- AC-018f: `setup/cursor.sh` writes `.cursor/hooks.json` with entries for `preToolUse` and `beforeSubmitPrompt`
- AC-018g: `setup/cursor.ps1` writes `.cursor/hooks.json` with the same entries
- AC-018h: Setup is idempotent

**REQ-019 — Codex adapter envelope fix + UserPromptSubmit routing + deny JSON**
- AC-019a: `codex.mjs` reads `tool_name` as primary field (falls back to `tool`)
- AC-019b: `codex.mjs` reads `tool_input` as primary field (falls back to `input`)
- AC-019c: `codex.mjs` reads `hook_event_name` for event routing
- AC-019d: `"PreToolUse"` events delegate to `gate-write.mjs`
- AC-019e: `"UserPromptSubmit"` events delegate to `check-design.mjs`
- AC-019f: All other events pass through with exit 0
- AC-019g: When gate-write exits 2, the adapter writes Codex `hookSpecificOutput` deny JSON to stdout
- AC-019h: `setup/codex.sh` writes `.codex/hooks.json` with entries for `PreToolUse` and `UserPromptSubmit`
- AC-019i: Windows guard (`platform() === "win32"`) remains in place

### Constraints
- Double-hyphen flag convention (`--include-full-skill-library`) — must match `while`/`switch` parser pattern already in use
- Idempotent re-run: external skill dirs must be cleaned up on re-run via `.planifest-manifest`
- Only `SKILL.md` and `attribution.txt` copied per skill (ADR-001, ADR-002) — no other files
- No new external dependencies introduced

## Architecture Layer
- Latency target: not applicable (CLI script)
- Availability target: not applicable
- Scalability target: not applicable
- Security: no auth; scripts run locally; no credentials
- Data privacy: no regulated data
- Observability: standard shell/PowerShell console output; exit codes
- Cost boundary: not constrained

## Engineering Layer
- Stack: PowerShell (setup.ps1 primary), Bash (test scripts), no database, no IaC, local execution
- Components:
  - `planifest-framework/setup.ps1` — primary target; REQ-001, REQ-002, REQ-003, REQ-017
  - `planifest-framework/setup.sh` — dispatch additions only; REQ-015, REQ-017
  - `planifest-framework/external-skills/README.md` — doc fix; REQ-004
  - `planifest-framework/tests/test_setup.ps1` — test coverage; REQ-005
  - `planifest-framework/tests/test-0000009-rail-tightening.sh` — test assertion; REQ-006
  - `planifest-framework/templates/requirement.template.md` — add user story section; REQ-007
  - `planifest-framework/templates/feature-brief.template.md` — user story format; REQ-008
  - `planifest-framework/skills/planifest-spec-agent/SKILL.md` — user story instruction; REQ-007
  - `planifest-framework/skills/planifest-orchestrator/SKILL.md` — standalone skills, P0 gate, docs/ layer, tool tier table; REQ-009, REQ-010, REQ-013, REQ-015, REQ-017
  - `planifest-framework/templates/design.template.md` — user story list field; REQ-010
  - `planifest-framework/skills/planifest-validate-agent/SKILL.md` — AC coverage check; REQ-011
  - `planifest-framework/templates/execution-plan.template.md` — stale link + FR section; REQ-012
  - `planifest-framework/skills/planifest-docs-agent/SKILL.md` — living docs mandate; REQ-013
  - `planifest-framework/templates/architecture-overview.template.md` — new template; REQ-013
  - `planifest-framework/templates/api-index.template.md` — new template; REQ-013
  - `planifest-framework/templates/decisions-index.template.md` — new template; REQ-013
  - `planifest-framework/skills/planifest-ship-agent/SKILL.md` — archive naming; REQ-014
  - `planifest-framework/skills/planifest-build-assessment-agent/SKILL.md` — archive naming; REQ-014
  - `planifest-framework/migrations/0003-archive-dirname.md` — migrator instruction doc; REQ-014
  - `planifest-framework/migrations/migrate-archive-dirname.sh` — manual shell migration; REQ-014
  - `planifest-framework/migrations/migrate-archive-dirname.ps1` — manual PowerShell migration; REQ-014
  - `planifest-framework/hooks/adapters/copilot.mjs` — event name fix; REQ-015
  - `planifest-framework/hooks/adapters/windsurf.mjs` — envelope fix + expanded event routing; REQ-016
  - `planifest-framework/setup/windsurf.sh` — hooks.json path + new events; REQ-016
  - `planifest-framework/setup/windsurf.ps1` — hooks.json path + new events; REQ-016
  - `planifest-framework/setup/roo-code.sh` — deprecation handler; REQ-017
  - `planifest-framework/setup/roo-code.ps1` — deprecation handler; REQ-017
  - `planifest-framework/hooks/adapters/cursor.mjs` — envelope fix + beforeSubmitPrompt routing; REQ-018
  - `planifest-framework/setup/cursor.sh` — register preToolUse + beforeSubmitPrompt; REQ-018
  - `planifest-framework/setup/cursor.ps1` — register preToolUse + beforeSubmitPrompt; REQ-018
  - `planifest-framework/hooks/adapters/codex.mjs` — envelope fix + UserPromptSubmit routing + deny JSON; REQ-019
  - `planifest-framework/setup/codex.sh` — register PreToolUse + UserPromptSubmit; REQ-019
  - `planifest-framework/setup/codex.ps1` — register PreToolUse + UserPromptSubmit; REQ-019
- Data ownership: none (stateless scripts)
- Deployment: scripts run from repo root
- API versioning: not applicable

## Scope
- In: REQ-001 through REQ-019 as defined above
- Out:
  - Changes to setup.sh (reference only, not modified except REQ-015/017 dispatch additions)
  - New external skills added to `external-skills/`
  - New flags not already present in setup.sh
  - opencode bespoke handling in setup.ps1 (opencode.ps1 config handles this; not a gap)
  - Full reimplementation of any existing hook adapter (update only — no rewrites from scratch)
- Deferred: none

## Assumptions
- `setup/roo-code.ps1` is complete and correct; only `$ValidTools` needs updating (AC-002)
- skill-sync.ps1 interface matches skill-sync.sh: `skill-sync.ps1 sync <tool>` — impact if wrong: AC-003 needs adjustment
- The stale req-005 link in README should be removed, not redirected — impact if wrong: easy to adjust

## Risks
- skill-sync re-run (REQ-003) may surface an untested code path in skill-sync.ps1 — likelihood: low, impact: low (guarded, non-fatal)
- REQ-005 test runs setup.ps1 in a temp dir; if external-skills/ copy is large it may be slow — likelihood: low, impact: negligible

## Dependencies
- Upstream: `planifest-framework/external-skills/` populated (confirmed: all dirs have SKILL.md + attribution.txt)
- Upstream: `planifest-framework/scripts/skill-sync.ps1` exists (confirmed)
- Downstream: framework users on Windows using setup.ps1

## Active Skills
None

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| REQ-001 — setup-ps1-flag | planifest-codegen-agent | direct implementation, clear spec from setup.sh reference |
| REQ-002 — roo-code-valid-tools | planifest-codegen-agent | single-line change |
| REQ-003 — skill-sync-dispatch | planifest-codegen-agent | direct implementation, clear spec from setup.sh reference |
| REQ-004 — stale-readme-link | planifest-codegen-agent | doc edit |
| REQ-005 — test-ps1-coverage | planifest-codegen-agent | test authoring |
| REQ-006 — test-rail-assertion | planifest-codegen-agent | test authoring |
| REQ-007 — requirement-template-user-stories | planifest-codegen-agent | template edit + skill instruction update |
| REQ-008 — feature-brief-user-story-format | planifest-codegen-agent | template edit |
| REQ-009 — non-pipeline-skills-routing | planifest-codegen-agent | skill doc update |
| REQ-010 — design-template-user-story-body | planifest-codegen-agent | template edit + skill instruction update |
| REQ-011 — validate-agent-ac-coverage | planifest-codegen-agent | skill instruction update |
| REQ-012 — execution-plan-template-gaps | planifest-codegen-agent | template edit |
| REQ-013 — docs-living-documentation | planifest-codegen-agent | skill update + 3 new templates |
| REQ-014 — archive-naming-consistency | planifest-codegen-agent | skill edits + 2 migration scripts |
| REQ-015 — copilot-event-names | planifest-codegen-agent | three-line fix to copilot.mjs event name strings |
| REQ-016 — windsurf-expanded-hooks | planifest-codegen-agent | adapter envelope fix + event routing expansion |
| REQ-017 — roo-code-deprecation | planifest-codegen-agent | setup handler replacement |
| REQ-018 — cursor-adapter-envelope | planifest-codegen-agent | adapter envelope fix + beforeSubmitPrompt routing |
| REQ-019 — codex-adapter-envelope | planifest-codegen-agent | adapter envelope fix + UserPromptSubmit routing + deny JSON |

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. You don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 2026-05-16
