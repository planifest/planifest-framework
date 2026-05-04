---
title: "ADR-001: Per-language directory tree for library standards"
status: "accepted"
version: "0.1.0"
---
# ADR-001 - Per-language directory tree for library standards

**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000005-framework-governance
**Status:** accepted
**Date:** 02 May 2026

---

## Context

Agents scaffolding dependency manifests apply their own judgment on library choices, reaching for deprecated or unsuitable libraries with no standard to check against. A machine-readable library standards document is needed that agents can look up before writing any manifest. The question is how to structure that document — as a single file covering all languages, or as a directory tree.

---

## Decision

A per-language directory tree at `planifest-framework/standards/library-standards/{language}/` with two files per language: `prefer-avoid.md` and `test-frameworks.md`. A `_version-policy.md` lives at the root. A `databases/` subtree covers database client choices across paradigms.

The human-owned parallel tree lives at `planifest-overrides/library-standards/{language}/` and takes precedence.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Single `library-standards.md` file | Simple, one file to load | Grows unbounded as languages are added; entire file loaded into agent context even when only one language is needed; no partial-loading possible | Context window cost grows with every language added; not scalable to 21 languages |
| Per-stack sections in `code-quality-standards.md` | Collocated with existing standards | Already large; mixes structural/quality concerns with library choices; harder to extend independently | Separation of concerns — library choices evolve independently of coding patterns |
| Registry database (JSON/YAML) | Machine-parseable without natural language | Loses human readability; harder to write nuanced rationale per library | Agents read Markdown natively; rationale is as important as the list |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-codegen-agent | Reads `{language}/prefer-avoid.md` before writing any dependency manifest |
| planifest-validate-agent | Reads `{language}/prefer-avoid.md` during library audit CI step |
| planifest-orchestrator | Reads `{language}/prefer-avoid.md` during stack selection coaching |
| setup.ps1/setup.sh | Copies `library-standards/` to tool skill directories; must not overwrite `planifest-overrides/` |

---

## Consequences

**Positive:**
- Agents load only the language subdir relevant to the current stack — no unnecessary context
- Humans can extend any language or add new languages without modifying framework files
- 16 unpopulated language stubs degrade gracefully — agents skip audit rather than erroring

**Negative:**
- More files to maintain than a single document
- P3 must populate 6 languages fully and stub 16 — non-trivial initial content effort

**Risks:**
- Language subdirs may diverge from each other in format over time — mitigated by `_version-policy.md` and consistent template per subdir

---

## Related ADRs

- ADR-002 — depends-on (planifest-overrides structure governs where human overrides live)
