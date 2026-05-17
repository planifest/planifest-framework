---
title: "ADR-005 - Locale-tagged language quirks files"
status: "accepted"
date: "04 May 2026"
feature: "0000007-agent-optimisation"
---
# ADR-005 — Locale-tagged language quirks files for multilingual readiness

## Context

The framework needed to document deliberate spelling and terminology decisions (e.g. `artifact` preferred over `artefact`). The question was how to name and structure this file to accommodate potential future multilingual support without over-engineering for a single use case.

## Decision

Name the file `language-quirks-{locale}.md` using the ISO 639-1 + ISO 3166-1 locale code (e.g. `language-quirks-en-gb.md`). Include `locale: en-GB` in the YAML frontmatter. This is the only such file created in this feature; the naming convention positions future locales to add their own files.

## Alternatives Considered

| Option | Pros | Cons | Rejected because |
|--------|------|------|-----------------|
| Single `language-quirks.md` with no locale | Simpler | Cannot scale to multiple locales; conflates language choice with quirks specific to one locale | Locale-neutral naming would require restructuring if a second locale is ever added |
| Directory per locale (`language-quirks/en-gb/quirks.md`) | Extensible | More complex for a single file per locale | Unnecessary structure for a flat list of rules |
| Locale-tagged single file (chosen) | Flat, simple; locale explicit in filename and frontmatter; pattern is clear for future additions | Slightly longer filename | Clean extension path with no restructuring needed |

## Affected Components

- `planifest-framework/standards/language-quirks-en-gb.md` — new file

## Consequences

**Positive:**
- Future locales add `language-quirks-{locale}.md` without restructuring
- Agents and tools can identify the locale from the filename without reading content
- ISO locale code in frontmatter enables programmatic filtering

**Negative:**
- Locale declaration is slightly redundant (in both filename and frontmatter) — acceptable: filename enables discovery, frontmatter enables programmatic access

**Risks:**
- No mechanism currently exists to tell agents which locale file to load — agents default to `en-GB` unless the project declares otherwise. A future feature can add a locale field to `feature-brief.template.md` if multilingual support is needed.

## Related ADRs

- None
