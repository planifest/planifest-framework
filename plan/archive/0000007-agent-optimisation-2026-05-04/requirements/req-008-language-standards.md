---
title: "Requirement: req-008 - language-standards"
status: "active"
version: "0.1.0"
---
# Requirement: req-008 — Language standards and spelling normalisation

**Feature:** 0000007-agent-optimisation
**Source:** Confirmed optimisation items req-018, req-019 from live optimise-agent review
**Priority:** must-have

---

## Functional Requirements

### Create language-quirks-en-gb.md (design req-019)

Create `planifest-framework/standards/language-quirks-en-gb.md` with YAML frontmatter `locale: en-GB`.

File MUST document the following categories:

**Category 1 — Code is never corrected**
Fenced code blocks, inline code spans, file paths, variable/function names, API endpoint strings, HTTP header names, config keys, YAML/JSON values. These are identifiers, not prose — spelling correction tools must skip them entirely.

**Category 2 — American spelling exceptions (always, even in prose)**

| Use | Not | Note |
|-----|-----|------|
| `artifact` / `artifacts` | `artefact` / `artefacts` | Industry standard |
| `initialize` / `initialization` | `initialise` / `initialisation` | Tooling, function names |
| `serialize` / `deserialize` | `serialise` / `deserialise` | Codec naming |
| `disk` | `disc` | Storage (SSD, disk I/O) |
| `program` | `programme` | Software context only |

**Category 3 — American spelling in code/named technical concepts only**

| American form | British form (use in prose) | Named concept example |
|---|---|---|
| `color` | `colour` | CSS `color` property |
| `center` | `centre` | CSS `text-center` |
| `fiber` | `fibre` | Node.js `Fiber` |

**Category 4 — British noun/verb distinction preserved**
`licence` (noun) / `license` (verb). Never flatten to American `license` for both. In code identifiers (e.g. `package.json` `"license"` field) Category 1 applies.

**Category 5 — Capitalisation in prose**
`ID`, `URL`, `API`, `CLI`, `SDK`, `MCP`, `PR`, `CI`, `CD`, `IaC`, `ORM` — always uppercase in prose.

**Category 6 — Countability**
`data` and `metadata` are uncountable — "the data is", not "the data are".

### Global spelling normalisation (design req-018)

Replace all instances of `artefact` → `artifact` and `artefacts` → `artifacts` across all files in `planifest-framework/`:
- Skills (`planifest-framework/skills/**/*.md`)
- Standards (`planifest-framework/standards/**/*.md`)
- Templates (`planifest-framework/templates/**/*.md`, `**/*.yml`)
- Hooks (`planifest-framework/hooks/**`)
- Documentation (`planifest-framework/*.md`)

Exclusions (Category 1 from language-quirks-en-gb.md applies):
- Content inside fenced code blocks
- Content inside inline code spans
- File names and paths
- YAML/JSON keys and values that are identifiers

## Acceptance Criteria

- [ ] `planifest-framework/standards/language-quirks-en-gb.md` exists with `locale: en-GB` frontmatter
- [ ] File contains all six categories with the specified content
- [ ] No instance of `artefact` or `artefacts` exists as prose in any `planifest-framework/` file
- [ ] Instances inside code blocks and inline code spans are left unchanged
- [ ] `component.yml` responsibilities entry "Register and sync capability skills" is checked — uses `artifacts` if applicable

## Dependencies

- req-007 (design.template.md must be written before the global replacement runs, to ensure the template uses `artifact` from creation)
- All Track B skill edits must be complete before global replacement (to avoid double-processing)
