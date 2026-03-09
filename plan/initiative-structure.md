# Planifest — Repository Structure

> The canonical layout for a Planifest-managed repository. Three top-level folders, three concerns.

---

## The Three Folders

```
repo/
├── planifest-framework/        ← The framework (skills, templates, schemas, standards)
│                                 Drop this in. Don't modify it per-project.
│
├── plan/                       ← The specifications (organized by initiative)
│                                 Plans, briefs, specs, ADRs, risk, scope, glossary.
│                                 Everything that describes WHAT to build and WHY.
│
└── src/                        ← The code (organized by component)
                                  Implementation, tests, config, manifests.
                                  Everything that IS the built thing.
```

---

## `planifest-framework/` — The Framework

This folder is the Planifest framework itself. It is the same across every project. You do not modify it per-initiative — you update it when the framework evolves.

```
planifest/
├── skills/           ← Agent instructions (orchestrator + phase skills)
├── templates/        ← File format templates for every artifact
├── schemas/          ← JSON Schema validation definitions
├── standards/        ← Code quality standards
└── spec/             ← This file — the canonical structure definition
```

---

## `plan/` — The Plan/Specifications

Organized by initiative. Each initiative gets a subfolder. This is where humans write briefs and agents write specs. No code lives here.

```
plan/
└── {initiative-id}/
    ├── initiative-brief.md          ← Human input (start here)
    ├── planifest.md                 ← Validated plan (orchestrator output)
    ├── pipeline-run.md              ← Audit trail (per run)
    ├── pipeline-run-phase-2.md      ← Phase 2 audit (if phased)
    │
    ├── design-spec.md               ← Functional & non-functional requirements
    ├── design-spec-phase-2.md       ← Phase 2 spec (if phased)
    ├── openapi-spec.yaml            ← API contract
    ├── scope.md                     ← In / Out / Deferred
    ├── risk-register.md             ← Risk items with likelihood & impact
    ├── domain-glossary.md           ← Ubiquitous language
    ├── security-report.md           ← Security review findings
    ├── quirks.md                    ← Quirks and workarounds
    ├── recommendations.md           ← Improvement suggestions
    │
    └── adr/
        ├── ADR-001-{title}.md       ← Architecture decision records
        ├── ADR-002-{title}.md
        └── ...
```

### Path Rules — plan/

1. **Initiative ID** is kebab-case, human-chosen, and stable.
2. **No nesting** — specs, ADRs, and supporting docs are flat within the initiative folder. One level of subfolders only (adr/).
3. **No code** — nothing executable lives in `plan/`. If it runs, it belongs in `src/`.
4. **Phased initiatives** append the phase number: `design-spec-phase-2.md`, `pipeline-run-phase-2.md`. The `planifest.md` is updated per phase, not duplicated.
5. **ADRs** are numbered sequentially. Never renumber. Superseded ADRs stay with `status: superseded`.

---

## `src/` — The Code

Organized by component. Each component is a subfolder at the top level of `src/`. The component manifest lives with the code, not with the plan.

```
src/
└── {component-id}/
    ├── component.json               ← Component manifest (from template)
    ├── package.json                  ← (or equivalent for the stack)
    │
    ├── src/                          ← Implementation (structure varies by stack)
    │   └── ...
    │
    ├── tests/                        ← Tests
    │   └── ...
    │
    └── docs/
        ├── data-contract.md          ← Schema ownership & invariants
        └── migrations/
            └── proposed-{desc}.md    ← Migration proposals
```

### Path Rules — src/

1. **Component ID** is kebab-case, matches the `id` in `component.json`.
2. **component.json is mandatory** — every component has one. Read it before any work; update it after every build.
3. **Component-specific docs** live with the component at `src/{component-id}/docs/`. These describe the component's data contract, migrations, and technical specifics.
4. **Initiative-level docs** live in `plan/`. The component's `component.json` references the initiative via the `initiative` field.
5. **Existing components** that predate Planifest are retrofitted by adding a `component.json` at their root.

---

## How the Three Folders Connect

```
plan/{initiative-id}/planifest.md
    └── lists component IDs → src/{component-id}/component.json
                                    └── references initiative → plan/{initiative-id}/

plan/{initiative-id}/design-spec.md
    └── functional requirements → implemented in → src/{component-id}/src/

plan/{initiative-id}/adr/ADR-001-*.md
    └── decisions → followed by → src/{component-id}/src/

plan/{initiative-id}/openapi-spec.yaml
    └── API contract → implemented in → src/{component-id}/src/
```

The relationship is bidirectional:
- `planifest.md` lists all component IDs
- Each `component.json` references its initiative ID
- The plan describes WHAT; the code IS the WHAT

---

## Retrofit — Adding Planifest to an Existing Repo

If the repo already has code:

1. Drop `planifest/` into the repo root
2. Create `plan/` for the first initiative
3. Move existing components under `src/` (or leave them if they're already there)
4. Add a `component.json` to each existing component
5. The orchestrator's retrofit mode will read the codebase and infer the existing architecture

---

*Templates for each file are in [planifest/templates/](../templates/). Skills reference these paths.*
