# Design - 0000007-agent-optimisation

## Feature
- Problem: Agents check host runtimes when building in Docker (irrelevant); skill files contain implicit model knowledge and hook-duplicated instructions that add token cost without value
- Adoption mode: retrofit
- Feature ID: 0000007-agent-optimisation

## Product Layer
- User stories confirmed: 3
- Acceptance criteria confirmed: 9
- Constraints: optimise-agent only suggests — never auto-removes; human confirms each item
- Integrations: existing orchestrator, codegen-agent, validate-agent, feature-brief template

## Architecture Layer
- Security: no new attack surface
- Data privacy: n/a

## Engineering Layer
- Stack: Markdown, Bash (existing)
- Components: planifest-framework (existing component-pack)
- New artefacts:
  - `planifest-framework/standards/build-target-standards.md`
  - `planifest-framework/standards/telemetry-standards.md`
  - `planifest-framework/templates/design.template.md`
  - `planifest-framework/skills/planifest-optimise-agent/SKILL.md`
  - Updated: `planifest-framework/templates/feature-brief.template.md`
  - Updated: `planifest-framework/skills/planifest-orchestrator/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-codegen-agent/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-validate-agent/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-spec-agent/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-adr-agent/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-security-agent/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-docs-agent/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-ship-agent/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-build-assessment-agent/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-change-agent/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-test-writer/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-implementer/SKILL.md`
  - Updated: `planifest-framework/skills/planifest-refactor/SKILL.md`
  - Updated: `planifest-framework/setup.sh`
  - Updated: `planifest-framework/setup.ps1`
  - New test suite: `planifest-framework/tests/test-0000007-agent-optimisation.sh`

## Spelling Convention
- `artifact` / `artifacts` throughout (American English — industry standard for technical documentation)

## Confirmed Requirements (from live optimisation review)

### req-001 — Remove standard Hard Limits boilerplate
Remove the identical 6-item `## Hard Limits` section from:
`spec-agent`, `adr-agent`, `codegen-agent`, `validate-agent`, `security-agent`, `docs-agent`, `change-agent`
These limits are already enforced by CLAUDE.md hooks and are implicit model knowledge.

### req-002 + req-004 — Extract telemetry section boilerplate to telemetry-standards.md
Create `planifest-framework/standards/telemetry-standards.md` containing:
- (a) Full event envelope structure (schema_version, event, agent, phase, tool, model, mcp_mode, session_id, timestamp, data)
- (b) Gate conditions: "Emission is mandatory when both conditions are met…" (emit_event present + .claude/telemetry-enabled exists)
- (c) phase_start/phase_end ownership note: emitted by orchestrator, not phase skills

In each of the following skills, replace those three blocks with a single pointer:
"See `planifest-framework/standards/telemetry-standards.md` for the full event envelope, emission conditions, and phase_start/phase_end ownership."
Per-skill event definitions (e.g. `validation_failure`, `self_correction`) stay in the skill.

Applies to: `orchestrator`, `spec-agent`, `adr-agent`, `codegen-agent`, `validate-agent`, `security-agent`, `docs-agent`, `ship-agent`, `change-agent`

### req-019 — Create language-quirks-en-gb.md
New file `planifest-framework/standards/language-quirks-en-gb.md` with YAML frontmatter declaring `locale: en-GB`. Documents deliberate spelling/terminology decisions for this locale. Naming convention `language-quirks-{locale}.md` is intentional — other locales add their own file. Agents and humans consult the file matching the project's declared locale before writing framework content.

Contents:
- **Category 1 — Code is never corrected**: fenced code blocks, inline code spans, file paths, variable/function names, API endpoint strings, HTTP header names, config keys, YAML/JSON values.
- **Category 2 — American spelling exceptions (always, even in prose)**: `artifact`/`artifacts` (not `artefact`); `initialize`/`initialization`; `serialize`/`deserialize`; `disk` (storage); `program` (software).
- **Category 3 — American spelling in code/named technical concepts only**: `color` (British: `colour`); `center` (British: `centre`); `fiber` (British: `fibre`, except named concepts e.g. Node.js Fiber).
- **Category 4 — British noun/verb distinction preserved**: `licence` (noun) / `license` (verb). In code identifiers (e.g. `package.json` `"license"` field) Category 1 applies.
- **Category 5 — Capitalisation in prose**: `ID`, `URL`, `API`, `CLI`, `SDK`, `MCP`, `PR`, `CI`, `CD`, `IaC`, `ORM`.
- **Category 6 — Countability**: `data` and `metadata` are uncountable ("the data is", not "the data are").

### req-018 — Normalise spelling: artefact → artifact
Global find/replace across all `planifest-framework/` skill files, standards, and templates:
- `artefact` → `artifact`
- `artefacts` → `artifacts`

### req-003 — Remove standard footer
Remove the `*This skill is invoked by… See [Orchestrator Skill]…*` footer line from:
`spec-agent`, `adr-agent`, `codegen-agent`, `validate-agent`, `security-agent`, `docs-agent`, `ship-agent`, `build-assessment-agent`, `change-agent`, `test-writer`, `implementer`, `refactor`

### req-005 — Remove Role Boundary section from security-agent
Remove the `## Role Boundary` section entirely from `planifest-security-agent/SKILL.md`.

### req-006 — Remove stale external-skills.json references
- `ship-agent`: remove entire Step 6 ("Remove plan-scoped external skills")
- `orchestrator` Capability Skill Intake step 4: replace JSON file update instructions with direct directory moves only — "plan" → move to `plan/current/capability-skills/{name}/`; "permanent" → move to `planifest-overrides/capability-skills/{name}/`. No JSON file update.
- `orchestrator` Skill Discovery: remove the `Check planifest-framework/external-skills.json` line.

### req-007 — Remove Templates list from orchestrator References
Remove the `**Templates** (agents should follow these…)` bulleted subsection from `## References` in `planifest-orchestrator/SKILL.md`. Keep "Core Principles" and "Phase skills" subsections.

### req-008 — Replace skill-sync.sh references with manual copy instructions
- `orchestrator` Skill Discovery: replace `skill-sync.sh add {skill-name} {tool}` with: copy the skill directory to `planifest-overrides/capability-skills/{name}/` (permanent) or `plan/current/capability-skills/{name}/` (plan-scoped), then re-run setup.sh for permanent installs.

### req-009 — Setup writes .planifest-manifest; re-run removes only managed directories
`setup.sh` and `setup.ps1`: after installing, write `.planifest-manifest` listing all directories installed. On re-run, read the manifest and remove only those directories before reinstalling. Never removes directories not listed in the manifest.

### req-010 — Extract inline design.md template to design.template.md
Extract the inline `plan/current/design.md` format block from orchestrator "What you produce at the end of Phase 0" to a new file `planifest-framework/templates/design.template.md`.
Add JIT Loading row: "Write confirmed design to plan/current/design.md" → `planifest-framework/templates/design.template.md`.
Replace inline block in orchestrator with: "Read `planifest-framework/templates/design.template.md` now."

### req-011 — Remove (ADR-001) / (ADR-002) internal labels from codegen-agent
`**TDD Inner Loop Protocol (ADR-001):**` → `**TDD Inner Loop Protocol:**`
`**Sub-agent model tier (ADR-002):**` → `**Sub-agent model tier:**`

### req-012 — Fix stale path references (validate-agent, security-agent)
- `validate-agent` Rules: "this goes into `pipeline-run.md`" → "this goes into `plan/current/build-log.md`"
- `security-agent` Input: `plan/current/design-requirements.md` → `plan/current/design.md`

### req-013 — Fix stale path reference (adr-agent)
- `adr-agent` Input: `plan/current/design-requirements.md` → `plan/current/design.md`

### req-014 — Remove inline iteration log template from docs-agent
Remove the inline markdown template block from the `### Audit trail` section of `planifest-docs-agent/SKILL.md`. Replace with: "Read `planifest-framework/templates/iteration-log.template.md` now before producing the audit trail."

### req-015 — Remove generic context-mode block from spec-agent Retrofit Mode
Remove the `> **Context-Mode Protocol:** When ctx_batch_execute is available, use it for codebase discovery…` blockquote from the `## Retrofit Mode` section of `planifest-spec-agent/SKILL.md`. Covered by AGENTS.md.

### req-016 — Remove redundant standards list from validate-agent
Remove the bulleted links list (`[Code Quality Standards]`, `[Testing Standards]`, `[API Design Standards]`, `[Database Standards]`) from `## Standards References` in `planifest-validate-agent/SKILL.md`. Keep the paragraph about when standards apply.

### req-017 — Fix stale pipeline-run.md reference in orchestrator
`## Mid-Pipeline Requirement Changes` step 3: "Add a 'Requirement Change' entry to `pipeline-run.md`" → "Add a 'Requirement Change' entry to `plan/current/build-log.md`"

## Build Target Stream Requirements

### req-bt-001 — Add Build target row to feature-brief.template.md
New row in the Stack table: `Build target | local \| docker \| ci-only`

### req-bt-002 — Orchestrator P0 coaching for Build target
Orchestrator coaches human to declare Build target at P0 when compute or IaC implies Docker.

### req-bt-003 — Codegen-agent Build target: docker behaviour
When `Build target: docker` — never check host runtimes; scaffold Dockerfile-first; run checks via `docker build`/`docker run`.

### req-bt-004 — Validate-agent Build target: docker behaviour
When `Build target: docker` — run CI checks inside container, not against host.

### req-bt-005 — build-target-standards.md
New file `planifest-framework/standards/build-target-standards.md` defining all three tiers (local, docker, ci-only) and per-tier agent behaviour.

## Optimise Agent Requirements

### req-oa-001 — planifest-optimise-agent/SKILL.md
New skill targeting `planifest-framework/skills/` only. Presents one suggestion at a time in chat. Human confirms or rejects each. Accumulates confirmed items into a numbered list. Produces confirmed-changes summary as input to a Change Pipeline run at the end.

## Component Paths
- planifest-framework/

## Active Skills
None

## Repo Instructions
None

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 04 May 2026
