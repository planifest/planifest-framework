---
title: "Feature Brief - framework-governance"
summary: "Add library versioning policy, per-stack avoid/prefer lists, hook-based orchestrator enforcement, capability skill intake, formatting standards (date format + British English locale + response verbosity), a migration system, and a planifest-overrides directory for human customisations and repo-specific instruction overrides."
status: "draft"
version: "0.1.0"
---
# Feature Brief - framework-governance

**Feature ID:** 0000005-framework-governance

## Business Goal

Five gaps exist in the current framework.

**1. Library and test framework choices are non-deterministic.** Agents scaffolding dependency manifests apply their own judgment — they reach for deprecated libraries (`moment`, `request`, `sequelize`), outdated majors, or wrong test frameworks, with no standard to stop them. This compounds across every project run through the pipeline.

**2. The orchestrator can be bypassed.** Nothing prevents an agent from skipping the orchestrator and writing plan artifacts directly, as demonstrated in a Claude Code session on 02 May 2026. The framework's discipline is instruction-based only — there is no hard gate.

**3. Capability skills cannot be introduced mid-pipeline.** There is no supported path for a human to drop in an external skill and have agents use it — whether for the current plan only or permanently. The existing capability skill mechanism is hardcoded and not extensible by the human.

**4. Date formats are inconsistent across artifacts.** Plans, ADRs, changelogs, and templates use a mix of date formats (ISO 8601, MM/DD/YYYY, DD/MM/YYYY) making artifacts harder to read and cross-reference. No standard exists. The framework will adopt two formats: DD MMM YYYY (e.g. 02 May 2026) for human-readable dates in document body text — unambiguous across all locales — and YYYY-MM-DD as a filename prefix only, where chronological sort order must match filesystem sort order.

**5. There is no migration system.** As the framework evolves, existing artifacts drift out of compliance with new standards. There is no mechanism to detect, report, and correct non-compliant artifacts — meaning every new standard immediately creates a backlog of silent violations.

**6. The framework has no declared locale standard.** Framework guidance, templates, skills, and generated prose mix British and American English spellings. No standard is documented, so agents default to training-data norms — typically American English. Planifest defaults to British English for all prose, labels, comments, and documentation; code identifiers follow ecosystem conventions where American English is the norm (e.g. `color` in CSS, `initialize` in Ruby).

**7. Agent responses are unnecessarily verbose.** No response style standard exists, so agents narrate reasoning, summarise what they just did, and pad with affirmatory language — wasting output tokens and slowing the human down.

**8. Human customisations live inside the framework directory and are lost on upgrade.** Library overrides, capability skills, and repo-specific configuration currently sit inside `planifest-framework/` — the directory a team replaces when upgrading the framework. There is also no mechanism for a human to override core framework instructions for a specific repo (e.g. "no git push or pull — local git operations only").

This feature closes all eight gaps: a `planifest-overrides/` directory separates human customisations from the replaceable framework; a `library-standards/` directory tree makes library and test framework choices deterministic across 21 languages and all database paradigms; a sentinel-based write gate forces the orchestrator to be loaded before any plan work begins; a skills-inbox system lets humans introduce capability skills at any phase with automatic classification into plan-scoped or permanent registries; a formatting standard mandates DD MMM YYYY for human-readable dates, British English for all prose, and brevity as the default response mode across all artifacts; and a migration infrastructure lets the framework ship corrective migrations that the orchestrator detects and executes interactively.

---

## Features

| Feature | User Stories | Priority | Phase |
|---------|-------------|----------|-------|
| library-standards doc | As an agent on any supported language project, I look up preferred and avoided libraries by reading `planifest-framework/standards/library-standards/{language}/prefer-avoid.md`. The framework ships standards for: Python · JavaScript (react/, nodejs/) · TypeScript · Java · C# · C++ · C · Go · Rust · PHP · Shell · Ruby · Swift · Kotlin · R · Dart · Scala · Elixir · Haskell · F# — each in its own subdirectory. C and C++ are separate subdirectories despite shared tooling | must-have | 1 |
| library-standards doc | As a human, I extend or override library standards for any language — or add a language not in the framework list — by adding a subdirectory to `planifest-framework/standards/library-standards-custom/{language}/`. Agents check the custom directory first and fall back to the framework directory; custom entries take precedence over framework defaults for the same language | must-have | 1 |
| library-standards doc | As an agent scaffolding any dependency manifest, I follow the version policy in `planifest-framework/standards/library-standards/_version-policy.md` — latest stable, exact or tilde pinning, no `^latest` | must-have | 1 |
| library-standards doc | As an agent encountering an avoid-listed library with no alternative, I record an exception in `quirks.md` with justification rather than silently using it | must-have | 1 |
| database-standards coverage | As an agent selecting a database client or ORM, I look up preferred and avoided libraries for each database paradigm: SQL implementations (PostgreSQL, MySQL/MariaDB, SQLite, SQL Server, Oracle), NoSQL (MongoDB, Redis, DynamoDB, Cassandra), document stores (Firestore, CouchDB), data lakes (Delta Lake, Apache Iceberg), graph (Neo4j, ArangoDB), time-series (InfluxDB, TimescaleDB), and search (Elasticsearch, OpenSearch) | must-have | 1 |
| database-standards coverage | As an agent, when a database paradigm has an existing `database-standards.md` entry, I defer to it for schema/query patterns and use library-standards.md only for client library prefer/avoid choices | must-have | 1 |
| test framework coverage | As an agent scaffolding a test suite, I look up the preferred test framework per language and test type (unit, integration, contract, E2E, performance/load) so I never default to training-data-era choices (e.g. Jest when Vitest is preferred, `unittest` when pytest is standard). Not all types apply to every language — only applicable types are listed per language | must-have | 1 |
| test framework coverage | As an agent, I use `library-standards/{language}/test-frameworks.md` for *which* test framework to choose and `testing-standards.md` for *how* to write tests — I never duplicate structure/pattern guidance in library-standards | must-have | 1 |
| codegen-agent wiring | As the codegen-agent, before writing any dependency manifest (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, `composer.json`, `pom.xml`, `build.gradle`, `pubspec.yaml`, or equivalent), I cross-reference every dependency against the avoid list for the declared stack and substitute the preferred alternative if a match is found | must-have | 1 |
| codegen-agent wiring | As the codegen-agent, I fail and escalate if I cannot find a non-avoided library to satisfy a requirement | must-have | 1 |
| validate-agent wiring | As the validate-agent, I fail the library-audit CI check and report the specific library and its preferred alternative when an avoid-listed library is present in the installed manifest | must-have | 1 |
| orchestrator wiring | As the orchestrator, I surface library preferences during stack selection coaching | should-have | 1 |
| orchestrator sentinel | As gate-write, I block writes to plan/current/ (except feature-brief.md) unless plan/.orchestrator-active exists | must-have | 1 |
| orchestrator sentinel | As the ship-agent at P7, I delete `plan/.orchestrator-active` as the final archive step so the sentinel does not persist into the next pipeline run | must-have | 1 |
| check-design hard inject | As check-design hook, I inject a hard STOP directive when no feature-brief exists and no orchestrator sentinel is present | should-have | 1 |
| GitHub Copilot adapter | As gate-write, I run via a new copilot adapter so enforcement works on Copilot Agent Mode (2025 hooks) | should-have | 1 |
| capability skill intake | As a human, I can drop a SKILL.md into `planifest-framework/skills-inbox/` (or upload it directly in my coding tool) at any point during a pipeline run and the orchestrator will process it at the next phase boundary | must-have | 1 |
| capability skill intake | As the orchestrator, I check `planifest-framework/skills-inbox/` at the start of every phase transition — not just P0 — so a human can introduce a skill mid-pipeline and have it available from the next phase onward | must-have | 1 |
| capability skill intake | As the orchestrator, when I detect a skill in the inbox, I read its frontmatter, summarise what it does, and ask the human: "Use this for the current plan only, or add it permanently for all future plans?" | must-have | 1 |
| capability skill intake | As the orchestrator, after the human answers, I move the skill to the correct location — `plan/current/capability-skills/{name}/` for one-time, `planifest-framework/capability-skills/{name}/` for permanent — clear it from the inbox, and update the appropriate registry | must-have | 1 |
| plan-scoped skill registry | As an agent in any phase, I check `plan/current/external-skills.json` for skills available to this plan run only; these skills are used exactly like permanent capability skills but are scoped to this pipeline run | must-have | 1 |
| plan-scoped skill registry | As the ship-agent at P7, I include `plan/current/capability-skills/` and `plan/current/external-skills.json` in the plan archive so one-time skills are preserved with the run that used them | must-have | 1 |
| permanent skill registry | As an agent in any phase, I check `planifest-framework/external-skills.json` for permanently installed capability skills available to all plans; setup.ps1/setup.sh regenerates this file by scanning `planifest-framework/capability-skills/` | must-have | 1 |
| permanent skill registry | As the orchestrator at each phase transition, I merge both registries (plan-scoped + permanent) and surface only skills relevant to the upcoming phase and declared stack — I do not list all skills indiscriminately | must-have | 1 |
| skill manifest in design | As the orchestrator, I record all active capability skills (both plan-scoped and permanent) in `plan/current/design.md` under a `## Active Skills` section before P1 begins, and update it when new skills are added mid-pipeline | must-have | 1 |
| skill manifest in design | As any agent, I read the `## Active Skills` section of `design.md` at phase start so I know which capability skills are in play without re-scanning registries | must-have | 1 |
| locale standard | As an agent producing any artifact, I write all prose, labels, comments, and documentation in British English (e.g. "colour" not "color", "organise" not "organize", "licence" not "license" as a noun). Code identifiers follow the conventions of the language/framework in use — American English spelling in identifiers is acceptable where it is the ecosystem norm (e.g. `color` in CSS, `initialize` in Ruby) | must-have | 1 |
| locale standard | As a human reading the framework docs, I can see clearly that Planifest currently supports English only, defaults to British English, and that multilingual support is planned for a future release | must-have | 1 |
| date format standard | As an agent producing any artifact (plans, docs, ADRs, changelogs, commit messages, templates), I write human-readable dates as DD MMM YYYY (e.g. 02 May 2026) — unambiguous across locales, easy to read. Exception: filename prefixes where ordering matters use YYYY-MM-DD so filesystem sort equals chronological sort (e.g. `2026-05-02-changelog.md`) | must-have | 1 |
| date format standard | As an agent, I never write dates in MM/DD/YYYY, DD/MM/YYYY, YYYY/MM/DD, or ISO 8601 (`2026-05-02`) in document body text — only in filenames and machine-readable fields (frontmatter `date:`, JSON) where YYYY-MM-DD is correct | must-have | 1 |
| migration infrastructure | As the orchestrator, I scan `planifest-framework/migrations/` at every session start for any `.md` files not in `_done/`; if found, I immediately invoke the `planifest-migrator` skill before proceeding | must-have | 1 |
| migration infrastructure | As the planifest-migrator skill, I read the pending migration file, describe what it will change, execute the migration interactively (asking the human to confirm each change or batch), then move the migration file to `planifest-framework/migrations/_done/` when complete or explicitly skipped by the human | must-have | 1 |
| migration infrastructure | As a human, I can add a new migration by dropping a `.md` file into `planifest-framework/migrations/` — the orchestrator will detect and trigger it on the next session start | must-have | 1 |
| date format standard | As the planifest-migrator executing `0001-date-format.md`, I scan all files in `plan/`, `docs/`, and `planifest-framework/` for dates in document body text that do not match DD MMM YYYY, and present each finding to the human with the current value, the file and line, and the proposed correction | must-have | 1 |
| date format standard | As the planifest-migrator, after the human reviews the findings, I apply all confirmed corrections, skip any the human declines, report a summary of changes made, then move `0001-date-format.md` to `planifest-framework/migrations/_done/` | must-have | 1 |
| response verbosity standard | As an agent in any phase, I default to the shortest response that fully communicates the outcome — partial sentences and single-line confirmations are correct when no explanation is needed; I do not summarise what I just did, narrate my reasoning, or pad with affirmatory language | must-have | 1 |
| response verbosity standard | As a human reading the framework docs, I see a response style guide with clear rules: when to be brief, when to explain, and concrete examples showing both | must-have | 1 |
| planifest-overrides | As a human, I store all my customisations (library overrides, capability skills) in `planifest-overrides/` at the repo root so they survive a framework upgrade — replacing `planifest-framework/` never touches my content | must-have | 1 |
| planifest-overrides | As a human, I can add a `.md` file to `planifest-overrides/instructions/` to declare a repo-specific rule that overrides or extends core framework behaviour (e.g. "no git push or pull — local git operations only") | must-have | 1 |
| planifest-overrides | As the orchestrator at P0, I read all files in `planifest-overrides/instructions/` and record them in `plan/current/design.md` under `## Repo Instructions` so every agent in every phase sees them | must-have | 1 |
| british english rewrite | As P3, I rewrite all prose in `planifest-framework/` — skill SKILL.md files, standards docs, templates, and hook comments — to use British English spellings, correcting American English in non-identifier text | must-have | 1 |
| british english migration | As the planifest-migrator executing `0002-british-english.md`, I scan all files in `plan/`, `docs/`, and `planifest-framework/` for American English spellings in prose (not identifiers), present each finding with file, line, current value, and proposed correction, apply confirmed changes, then move `0002-british-english.md` to `_done/` | must-have | 1 |

---

## Phases

Single phase — all features ship together.

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| library-standards directory | standards directory tree | new | `planifest-framework/standards/library-standards/{language}/prefer-avoid.md` and `test-frameworks.md` per language; `_version-policy.md` at root; `databases/` subtree |
| planifest-overrides directory | repo-root directory | new | `planifest-overrides/` — human-owned, lives next to `planifest-framework/`, never touched by framework upgrades; contains `library-standards/`, `capability-skills/`, and `instructions/` subdirs |
| gate-write hook | enforcement hook (MJS) | existing — extend | Add sentinel check for plan/current/ writes |
| check-design hook | enforcement hook (MJS) | existing — extend | Inject hard STOP when orchestrator not yet loaded |
| planifest-orchestrator skill | skill (Markdown) | existing — extend | Write plan/.orchestrator-active on P0 start; check skills-inbox at every phase transition; maintain Active Skills section in design.md |
| planifest-codegen-agent skill | skill (Markdown) | existing — extend | Check library-standards (custom first, framework fallback) before scaffolding any dependency manifest |
| planifest-validate-agent skill | skill (Markdown) | existing — extend | Library audit CI check against avoid lists |
| planifest-ship-agent skill | skill (Markdown) | existing — extend | Archive plan/current/capability-skills/ and external-skills.json with the plan at P7 |
| GitHub Copilot adapter | adapter hook (MJS) | new | Wire gate-write + check-design into Copilot Agent Hooks (Preview 2025) |
| skills-inbox | drop-zone directory | new | `planifest-framework/skills-inbox/` — human drops SKILL.md files here; cleared by orchestrator after processing |
| formatting-standards | standards doc (Markdown) | new | `planifest-framework/standards/formatting-standards.md` — defines DD MMM YYYY for body text, YYYY-MM-DD for filename prefixes and machine-readable fields; declares British English as the default locale; response verbosity rules (brief by default, explain when needed, human can ask for more) with examples; states multilingual support is deferred |
| migrations directory | directory | new | `planifest-framework/migrations/` — pending migrations as .md files; `_done/` subdir for completed ones |
| planifest-migrator skill | skill (Markdown) | new | Reads a migration file, executes interactively with human confirmation, moves to _done/ on completion |
| planifest-orchestrator skill | skill (Markdown) | existing — extend (additional) | Scan migrations/ at session start; invoke planifest-migrator if pending migrations found |
| 0001-date-format.md | migration file (Markdown) | new | First migration — scans plan/, docs/, planifest-framework/ for non-compliant body-text dates and corrects with human confirmation |
| 0002-british-english.md | migration file (Markdown) | new | Second migration — scans plan/, docs/, planifest-framework/ for American English spellings in prose and corrects with human confirmation |
| capability-skills (permanent) | skill directory | new | `planifest-overrides/capability-skills/{name}/SKILL.md` — permanent skills; setup regenerates `external-skills.json` by scanning this |
| capability-skills (plan-scoped) | skill directory | new | `plan/current/capability-skills/{name}/SKILL.md` — one-time skills for this run; archived at P7 |
| external-skills.json (permanent) | registry file | new | `planifest-framework/external-skills.json` — auto-generated by setup from capability-skills scan |
| external-skills.json (plan-scoped) | registry file | new | `plan/current/external-skills.json` — written by orchestrator when a one-time skill is processed |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| plan/.orchestrator-active | orchestrator skill (writes) | gate-write hook (reads) |
| planifest-framework/standards/library-standards/ | framework (setup-managed) | codegen-agent, validate-agent (read-only, fallback) |
| planifest-overrides/library-standards/ | human (never overwritten) | codegen-agent, validate-agent (read-only, checked first) |
| planifest-overrides/capability-skills/ | human (writes) | setup (scans to generate registry) |
| planifest-overrides/instructions/ | human (writes) | orchestrator (reads at P0, writes to design.md) |
| planifest-framework/skills-inbox/ | human (writes, transient) | orchestrator (reads + clears) |
| planifest-framework/external-skills.json | setup (generates) | orchestrator, all phase agents (read-only) |
| plan/current/capability-skills/ | orchestrator (writes) | all phase agents (read-only); ship-agent (archives) |
| plan/current/external-skills.json | orchestrator (writes) | all phase agents (read-only); ship-agent (archives) |
| plan/current/design.md §Active Skills | orchestrator (writes + updates) | all phase agents (read-only) |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| orchestrator | plan/.orchestrator-active | Write on P0 start | Sentinel — presence = orchestrator loaded |
| gate-write.mjs | plan/.orchestrator-active | existsSync check | Exit 2 if absent and target is plan/current/** |
| check-design.mjs | plan/current/feature-brief.md | existsSync check | Inject STOP if absent and no sentinel |
| orchestrator | planifest-framework/skills-inbox/ | Scan at each phase transition | Process any SKILL.md found; clear after classification |
| orchestrator | plan/current/design.md | Write/update §Active Skills | Before P1; updated on each mid-pipeline skill intake |
| codegen-agent | planifest-overrides/library-standards/ then library-standards/ | Read prefer-avoid.md | Overrides take precedence; fallback to framework |
| orchestrator | planifest-overrides/instructions/ | Read all .md files at P0 | Write to design.md §Repo Instructions; all agents read from there |
| setup.ps1/sh | planifest-overrides/capability-skills/ | Scan on every run | Regenerate external-skills.json |
| ship-agent | plan/current/capability-skills/ + external-skills.json | Copy to archive | Preserved with plan run at P7 |

---

## Stack

| Concern | Decision |
|---------|----------|
| Language | JavaScript ESM (.mjs) for hooks; Markdown for standards and skill edits |
| Runtime | Node.js (existing hook runtime) |
| Framework | n/a |
| Frontend | n/a |
| Database | n/a |
| Testing | Existing regression suite (planifest-framework/tests/) |
| IaC | n/a |
| Cloud | n/a |
| CI | Existing |

---

## Scope Boundaries

### In Scope
- `planifest-framework/standards/library-standards/` — new directory tree, one subdir per language + databases/
- `planifest-overrides/` — new repo-root directory with subdirs: `library-standards/`, `capability-skills/`, `instructions/`; human-owned, never touched by framework upgrades; `.gitkeep` in each subdir initially
- `planifest-framework/skills/planifest-codegen-agent/SKILL.md` — library lookup + pre-scaffold check
- `planifest-framework/skills/planifest-validate-agent/SKILL.md` — library audit CI step
- `planifest-framework/skills/planifest-orchestrator/SKILL.md` — sentinel write; read `planifest-overrides/instructions/` and write `## Repo Instructions` to design.md at P0; inbox scan at every phase; Active Skills in design.md; migrations scan at session start
- `planifest-framework/skills/planifest-ship-agent/SKILL.md` — archive plan-scoped skills at P7; delete plan/.orchestrator-active
- `planifest-framework/templates/execution-plan.template.md` — add `## Active Skills` section to design template
- `planifest-framework/hooks/enforcement/gate-write.mjs` — sentinel check
- `planifest-framework/hooks/enforcement/check-design.mjs` — hard STOP injection
- `planifest-framework/hooks/adapters/copilot.mjs` — new Copilot Agent Hooks adapter
- `planifest-framework/skills-inbox/` — new drop-zone directory (.gitkeep)
- `planifest-overrides/capability-skills/` — permanent skills directory (within planifest-overrides)
- `planifest-framework/standards/formatting-standards.md` — date format, locale (British English default), and response verbosity standard
- `planifest-framework/migrations/` — new migrations directory
- `planifest-framework/migrations/_done/` — completed migrations subdir
- `planifest-framework/migrations/0001-date-format.md` — first migration file
- `planifest-framework/migrations/0002-british-english.md` — second migration file; also, P3 rewrites all planifest-framework/ prose to British English as part of codegen
- `planifest-framework/skills/planifest-migrator/SKILL.md` — new skill
- `planifest-framework/external-skills.json` — generated by setup by scanning `planifest-overrides/capability-skills/`; initially empty `{}`
- setup.ps1 / setup.sh — scan capability-skills/, regenerate external-skills.json, register Copilot adapter

### Out of Scope
- Automated version freshness checks against npm/PyPI at runtime
- Changes to any application src/ code
- Roo-Code enforcement — no hook API; tool is sunset May 2026
- Cursor hook mechanism verification — existing cursor.mjs adapter retained as-is

### Deferred
- Full content for all 21 language subdirs — P3 creates the directory structure and populates the 5 highest-priority languages (TypeScript, JavaScript, Python, Go, Java) with complete prefer/avoid and test-framework content; remaining 16 languages get stub files with a `TODO: populate` note
- Cursor adapter audit — verify whether cursor.mjs enforcement actually works
- Multilingual support — `formatting-standards.md` documents this as a planned future release; no implementation in this feature

---

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Hook latency | gate-write check adds < 5ms | manual timing |
| Regression | All 17 existing regression tests continue to pass | CI |
| False positives | Sentinel check must not block plan/current/feature-brief.md writes | regression test |

---

## Adoption Mode

Retrofit — modifying an existing framework codebase. No greenfield components; all changes extend existing hooks and skills.

---

## Risks

| Risk | Likelihood | Impact |
|------|-----------|--------|
| Sentinel false positive: gate-write blocks plan/current/ writes if .orchestrator-active is stale or missing after a clean checkout | Medium | High — blocks the session |
| Hook performance regression: sentinel existsSync adds latency to every Write/Edit call | Low | Low — sub-millisecond |
| Setup sync gap: developer edits planifest-framework/hooks/ but forgets to re-run setup.ps1, so .claude/hooks/ are stale | Medium | Medium — changes silently don't apply |
| Avoid list over-reach: a listed "avoid" library is the only viable option for a specific requirement | Low | Medium — requires quirks.md escape hatch |

---

## Constraints and Assumptions

### Constraints
- Hooks must follow ADR-005: never block session on unexpected errors (exit 0 on non-enforcement failures)
- Exit code 2 = block; exit code 0 = pass — no other codes
- plan/.orchestrator-active is a session-scoped sentinel — it must be cleared/ignored between pipeline runs (or keyed to feature-id)
- Roo-Code has no hook API and is sunset May 2026 — no enforcement possible; instruction-based only
- GitHub Copilot Agent Hooks are Preview in 2025 — copilot adapter should degrade gracefully if hooks are disabled by org policy
- Tool enforcement coverage: Claude Code ✅ | Windsurf ✅ | Cline ✅ | Codex ✅ | OpenCode ✅ | Copilot ✅ (new) | Cursor ⚠️ | Roo-Code ❌

### Assumptions
- The canonical source for hooks is `planifest-framework/hooks/enforcement/` — setup copies to `.claude/hooks/enforcement/`
- setup.ps1/setup.sh automatically pick up new bundle_standards entries without modification

---

## Acceptance Criteria

- [ ] `planifest-framework/standards/library-standards/` exists with a subdirectory for each of the 21 languages plus `databases/`; each language subdir contains `prefer-avoid.md` and `test-frameworks.md` (where applicable); `_version-policy.md` exists at the root
- [ ] `planifest-overrides/` exists at repo root with subdirs `library-standards/`, `capability-skills/`, `instructions/` — each with `.gitkeep`; never touched by setup or framework upgrades
- [ ] Agents check `planifest-overrides/library-standards/` first and fall back to `planifest-framework/standards/library-standards/` for the same language
- [ ] Orchestrator reads all `.md` files in `planifest-overrides/instructions/` at P0 and writes them to `plan/current/design.md` under `## Repo Instructions`
- [ ] All agents read `## Repo Instructions` from design.md and apply them for the duration of the pipeline run
- [ ] Database section covers all listed paradigms: SQL implementations, NoSQL, document stores, data lakes, graph, time-series, search
- [ ] codegen-agent checks library-standards before writing any dependency manifest; substitutes preferred alternatives for avoid-list matches
- [ ] validate-agent fails the library-audit CI check and names the avoid-listed library and its preferred alternative
- [ ] orchestrator writes `plan/.orchestrator-active` at Phase 0 start
- [ ] gate-write blocks writes to `plan/current/**` (except `plan/current/feature-brief.md`) when `plan/.orchestrator-active` is absent
- [ ] check-design injects a hard STOP directive when no feature-brief and no sentinel exist
- [ ] orchestrator scans `planifest-framework/skills-inbox/` at every phase transition and processes any SKILL.md found
- [ ] orchestrator asks one-time vs permanent and moves the skill to the correct location, clearing the inbox
- [ ] `plan/current/design.md` contains an `## Active Skills` section written before P1 and updated on mid-pipeline intake
- [ ] ship-agent archives `plan/current/capability-skills/` and `plan/current/external-skills.json` at P7 and deletes `plan/.orchestrator-active`
- [ ] `planifest-framework/external-skills.json` is regenerated by setup on every run by scanning `planifest-overrides/capability-skills/`
- [ ] copilot.mjs adapter wires gate-write and check-design; degrades gracefully when hooks are disabled by org policy
- [ ] setup.ps1 / setup.sh registers copilot adapter in `.github/hooks/`
- [ ] `planifest-framework/standards/formatting-standards.md` defines DD MMM YYYY for body text and YYYY-MM-DD for filename prefixes and machine-readable fields; declares British English as the default locale; lists code-identifier exceptions (American English acceptable where it is the ecosystem norm); states that multilingual support is planned for a future release
- [ ] All existing framework prose, skill guidance, and templates use British English spellings; any American English spellings in non-identifier prose are corrected
- [ ] `formatting-standards.md` includes a response verbosity section with rules and concrete examples (brief confirmation vs. explanation) that agents can reference
- [ ] All skill SKILL.md files reference the response verbosity standard in their `bundle_standards`
- [ ] orchestrator scans `planifest-framework/migrations/` at session start and invokes planifest-migrator when pending migrations are found
- [ ] planifest-migrator presents each non-compliant date with file, line, and proposed correction; applies confirmed changes; moves migration to `_done/` on completion
- [ ] `0001-date-format.md` migration runs successfully against this repo's existing artifacts
- [ ] All prose in `planifest-framework/` uses British English spellings after P3 (skill files, standards docs, templates, hook comments)
- [ ] `0002-british-english.md` migration runs successfully against `plan/` and `docs/` artifacts
- [ ] P3 delivers fully populated content for TypeScript, JavaScript (React + Node.js), Python, Go, and Java; all other 16 language subdirs exist with stub files
- [ ] `planifest-framework/templates/execution-plan.template.md` includes an `## Active Skills` section
- [ ] All 17 existing regression tests pass; new regression test covers sentinel enforcement path
