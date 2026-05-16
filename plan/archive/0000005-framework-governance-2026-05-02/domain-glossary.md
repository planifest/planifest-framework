---
title: "Domain Glossary - framework-governance"
status: "draft"
version: "0.1.0"
---
# Domain Glossary - 0000005-framework-governance

**Feature:** 0000005-framework-governance
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Version:** 0.1.0

---

## Terms

| Term | Definition | Aliases | Used In |
|------|-----------|---------|---------|
| library-standards | The directory tree at `planifest-framework/standards/library-standards/` containing per-language prefer/avoid lists and test framework choices | library standards, avoid list | codegen-agent, validate-agent, orchestrator |
| library-standards-custom | The parallel human-owned directory at `planifest-framework/standards/library-standards-custom/` that overrides framework defaults for any language | custom overrides | codegen-agent, validate-agent |
| prefer list | The set of recommended libraries for a given language and concern in `prefer-avoid.md` | preferred libraries | codegen-agent, validate-agent |
| avoid list | The set of deprecated or unsuitable libraries for a given language in `prefer-avoid.md` | avoided libraries, blocklist | codegen-agent, validate-agent |
| version policy | The rules in `_version-policy.md` governing how agents pin library versions — latest stable, exact or tilde, no `^latest` | versioning policy | codegen-agent |
| sentinel | The file `plan/.orchestrator-active` whose presence signals the orchestrator has been loaded for the current pipeline run | orchestrator sentinel | gate-write.mjs, orchestrator |
| skills-inbox | The drop-zone directory `planifest-framework/skills-inbox/` where humans place SKILL.md files for intake | skill inbox | orchestrator |
| capability skill | An external skill introduced by a human via the skills-inbox, classified as either plan-scoped or permanent | external skill | orchestrator, all phase agents |
| plan-scoped skill | A capability skill stored at `plan/current/capability-skills/` and available only for the current pipeline run | one-time skill | orchestrator, ship-agent |
| permanent skill | A capability skill stored at `planifest-framework/capability-skills/` and available to all future pipeline runs | global skill | orchestrator, setup |
| skill registry | A JSON file listing available capability skills — either `plan/current/external-skills.json` (plan-scoped) or `planifest-framework/external-skills.json` (permanent) | external-skills.json | orchestrator, all phase agents |
| Active Skills | The `## Active Skills` section of `plan/current/design.md` listing all capability skills in play for the current run | active skills manifest | orchestrator, all phase agents |
| migration | A Markdown file in `planifest-framework/migrations/` describing a corrective change to be applied to existing framework artifacts | migration file | orchestrator, planifest-migrator |
| planifest-migrator | The skill that reads a pending migration, executes it interactively with human confirmation, and archives it to `_done/` | migrator | orchestrator |
| formatting standards | `planifest-framework/standards/formatting-standards.md` — the single source of truth for date format, locale, and response verbosity rules | formatting-standards | all agents |
| DD MMM YYYY | The human-readable date format used in all document body text (e.g. 02 May 2026) — unambiguous across locales | body-text date format | all agents, all artifacts |
| YYYY-MM-DD | The machine-readable date format used in filename prefixes and frontmatter/JSON fields only (e.g. `2026-05-02-changelog.md`) | filename date format | all agents, filenames |
| British English | The locale standard for all Planifest prose, labels, comments, and documentation — American English spelling is acceptable in code identifiers where it is the ecosystem norm | locale standard | all agents, all artifacts |
| response verbosity | The principle that agent responses default to the shortest form that fully communicates the outcome — explanation only when needed | brevity standard | all agents |
| planifest-overrides | The repo-root directory (`planifest-overrides/`) containing all human customisations — library overrides, capability skills, and instruction files — that survive framework upgrades | overrides directory | orchestrator, codegen-agent, validate-agent, setup |
| instruction override | A `.md` file in `planifest-overrides/instructions/` declaring a repo-specific rule that all agents must follow for every pipeline run in this repo | repo instruction | orchestrator, all phase agents |
| Repo Instructions | The `## Repo Instructions` section of `plan/current/design.md` where the orchestrator records all active instruction overrides at P0; read by all agents as hard constraints | repo instructions | orchestrator, all phase agents |
| quirks.md | The file at `src/{component-id}/docs/quirks.md` where agents record exceptions to framework standards with justification | quirks | codegen-agent |
