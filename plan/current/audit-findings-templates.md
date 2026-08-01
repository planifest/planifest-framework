# Audit Findings — Templates and Root CLAUDE.md

Feature 0000021-framework-context-bloat-audit, req-002. Fresh-context content audit
of `planifest-framework/templates/` and the repo-root `CLAUDE.md`.

Templates are loaded just-in-time by the orchestrator's Framework Index immediately
before an agent writes the corresponding artifact, so every redundant line is paid
for at the exact moment the agent should be concentrating on content.

---

## Summary Table

| File | Current | Target | Reduction |
|------|---------|--------|-----------|
| `planifest-framework/templates/about.template.md` | 17 | 15 | 12% |
| `planifest-framework/templates/adr.template.md` | 87 | 55 | 37% |
| `planifest-framework/templates/api-index.template.md` | 35 | 28 | 20% |
| `planifest-framework/templates/architecture-overview.template.md` | 59 | 45 | 24% |
| `planifest-framework/templates/backlog-entry.template.md` | 41 | 32 | 22% |
| `planifest-framework/templates/build-log.template.md` | 73 | 70 | 4% |
| `planifest-framework/templates/change-summary.template.md` | 68 | 50 | 26% |
| `planifest-framework/templates/component.template.yml` | 95 | 85 | 11% |
| `planifest-framework/templates/cost-model.template.md` | 66 | 50 | 24% |
| `planifest-framework/templates/cursor-boot.md` | 30 | 30 | none |
| `planifest-framework/templates/data-contract.template.md` | 57 | 42 | 26% |
| `planifest-framework/templates/decisions-index.template.md` | 29 | 25 | 14% |
| `planifest-framework/templates/defect-report.template.md` | 46 | 40 | 13% |
| `planifest-framework/templates/design.template.md` | 61 | 57 | 7% |
| `planifest-framework/templates/discovery.template.md` | 53 | 48 | 9% |
| `planifest-framework/templates/domain-glossary.template.md` | 29 | 22 | 24% |
| `planifest-framework/templates/execution-plan.template.md` | 103 | 72 | 30% |
| `planifest-framework/templates/feature-brief.template.md` | 186 | 120 | 35% |
| `planifest-framework/templates/iteration-log.template.md` | 69 | 50 | 28% |
| `planifest-framework/templates/loop-state.template.md` | 46 | 42 | 9% |
| `planifest-framework/templates/operational-model.template.md` | 55 | 42 | 24% |
| `planifest-framework/templates/pause.template.md` | 31 | 26 | 16% |
| `planifest-framework/templates/recommendations.template.md` | 43 | 32 | 26% |
| `planifest-framework/templates/requirement.template.md` | 63 | 42 | 33% |
| `planifest-framework/templates/revision-log.template.md` | 27 | 24 | 11% |
| `planifest-framework/templates/risk-register.template.md` | 40 | 32 | 20% |
| `planifest-framework/templates/scope.template.md` | 43 | 34 | 21% |
| `planifest-framework/templates/security-report.template.md` | 57 | 44 | 23% |
| `planifest-framework/templates/slo-definitions.template.md` | 51 | 43 | 16% |
| `planifest-framework/templates/standard-boot.md` | 41 | 37 | 10% |
| `planifest-framework/templates/test-report.template.md` | 81 | 60 | 26% |
| **Templates subtotal** | **1782** | **1394** | **21.8%** |
| `CLAUDE.md` (repo root) | 52 | 50 | 4% |
| **TOTAL** | **1834** | **1444** | **21.3%** |

### Guide files — audit only, no action

Already excluded from default context loading by `.cursorindexingignore`
(`*-guide.md`). Accessed only via explicit @-mention. No trim recommended.

| File | Lines | Status |
|------|-------|--------|
| `planifest-framework/templates/adr-guide.md` | 83 | excluded |
| `planifest-framework/templates/component-guide.md` | 165 | excluded |
| `planifest-framework/templates/data-contract-guide.md` | 86 | excluded |
| `planifest-framework/templates/domain-glossary-guide.md` | 76 | excluded |
| `planifest-framework/templates/execution-plan-guide.md` | 92 | excluded |
| `planifest-framework/templates/feature-brief-guide.md` | 117 | excluded |
| `planifest-framework/templates/iteration-log-guide.md` | 72 | excluded |
| `planifest-framework/templates/risk-register-guide.md` | 74 | excluded |
| `planifest-framework/templates/scope-guide.md` | 69 | excluded |
| **Guides subtotal (excluded from targets)** | **834** | — |

---

## Cross-Template Duplication (flagged once, applies to many files)

These patterns repeat near-identically across the template set. Each is listed
again under its file, but the pattern is the finding.

**D1 — Provenance header block.** `**Tool:** {{agentic-tool-name}}` and
`**Model:** {{model-name-and-version}}` appear in 12 templates (adr,
change-summary, cost-model, data-contract, domain-glossary, execution-plan,
iteration-log, operational-model, recommendations, risk-register, scope,
security-report, slo-definitions). Nothing in `planifest-framework/skills/`,
`planifest-framework/standards/`, `planifest-framework/hooks/`, or
`planifest-framework/tests/` reads or asserts on either placeholder — verified by
grep for `agentic-tool-name` and `model-name-and-version` outside
`templates/`. Two lines x 12 files = 24 lines of unenforced boilerplate. The
`**Skill:**` and `**Feature:**` lines are worth keeping (traceability); Tool and
Model are not.

**D2 — Self-referential footers.** `*Generated by {agent}. Path: ...*` /
`*Template: {name}.template.md*` closes 15 templates. The producing agent already
knows which template it loaded and which path it writes to (the orchestrator's
Framework Index states both). Roughly 3 lines each including the blank-line
padding = ~45 lines.

**D3 — Horizontal-rule padding.** Most templates put `\n---\n\n` between every
H2. At ~2 lines of pure separator per section boundary, this is 100+ lines across
the set. Markdown H2s already delimit sections; the rules add nothing a model
uses. This is the single largest recoverable block and it is entirely
content-free.

**D4 — Trailing blank lines.** 17 templates end with 1-2 trailing blank lines
after the footer (visible as the final numbered empty line). Trivial per file,
~20 lines across the set.

**D5 — Section lead-in questions that restate the heading.** e.g. `## Context` /
"What is the technical or architectural question that needed a decision?";
`## Decision` / "What was decided and why?"; `## Consequences` / "What follows
from this decision - both positive and negative?". Present in adr,
architecture-overview, feature-brief, execution-plan, recommendations. A current
model fills these correctly from the heading and the placeholder alone.

**D6 — `standard-boot.md` line 36 / `CLAUDE.md` line 36.** The same three-clause
sentence appears in both and restates the `gate-write` and `check-design` bullets
that sit six lines above it. Its closing clause ("Manual scope checks in these
instructions are retained as documentation") refers to manual scope checks that no
longer exist in either file. Stale and self-duplicating in both places.

---

## `planifest-framework/templates/about.template.md`

**Current line count:** 17
**Recommended target:** 15 (12% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 9-10: "Written by the ship-agent at P7. Read by the orchestrator at P0. / Do not edit manually — version changes are confirmed during P0 coaching." — the write/read choreography is already owned by `planifest-ship-agent` and the orchestrator; condense to one line preserving only "do not edit manually".

### Load-bearing content confirmed present (do not touch)
- YAML frontmatter `version` / `feature` / `updated` — read by the orchestrator's P0 discovery (`Current version (docs/about.md)`).
- The Field/Value table restating the same three values: the frontmatter is machine-read, the table is the human-read surface. Duplication is intentional, keep both.
- Line 8 "canonical version record" — establishes precedence over other version sources.

---

## `planifest-framework/templates/adr.template.md`

**Current line count:** 87
**Recommended target:** 55 (37% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 10-11: `**Tool:**` / `**Model:**` — D1.
- Line 14 `**Status:** proposed | accepted | deprecated | superseded` — duplicates frontmatter line 4 `status:` AND disagrees with it (frontmatter says `rejected`, body says `deprecated`). Keep one; the frontmatter is the machine-readable one.
- Line 21: "What is the technical or architectural question that needed a decision?" — D5.
- Line 29: "What was decided and why?" — D5.
- Line 46: "Which components are impacted by this decision?" — D5, and the table columns already say it.
- Line 56: "What follows from this decision - both positive and negative?" — D5, and the Positive/Negative/Risks sub-headings below already say it.
- Line 40: second identical `| {{option}} | {{pros}} | {{cons}} | {{reason}} |` row — one example row suffices.
- Lines 17-18, 25-26, 33-34, 42-43, 52-53, 67-68, 73-74, 83-84: eight `---` separators plus padding — D3, ~16 lines.
- Lines 85-87: footer + trailing blanks — D2/D4.

### Load-bearing content confirmed present (do not touch)
- YAML frontmatter (`title`, `summary`, `status`, `version`).
- `## Context`, `## Decision`, `## Alternatives Considered`, `## Affected Components`, `## Consequences`, `## Related ADRs`, `## Supersedes`, `## Superseded By` — the ADR structure the adr-agent and decisions-index depend on.
- The relationship vocabulary on line 71 (`extends | conflicts-with | depends-on | related-to`) — a closed enum a model would otherwise invent freely.
- The Positive / Negative / Risks three-way split under Consequences.

---

## `planifest-framework/templates/api-index.template.md`

**Current line count:** 35
**Recommended target:** 28 (20% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 16: second endpoint example row — one row demonstrates the shape.
- Line 22: the versioning-strategy example is 30 words where 8 would do.
- Lines 9, 18, 24, 32: `---` separators — D3.
- Lines 34-35: footer + trailing blank — D2/D4.

### Load-bearing content confirmed present (do not touch)
- Lines 3-5 blockquote: "Living document" + **"Omit this file if no component exposes a public API"** + **"Updated after every pipeline run — do not archive"**. Both the omit rule and the do-not-archive rule are non-obvious lifecycle constraints an agent would otherwise get wrong (it would archive it with the rest of `plan/current/`).
- `Last updated: {feature-id}` marker.
- Table column set including `Auth`.

---

## `planifest-framework/templates/architecture-overview.template.md`

**Current line count:** 59
**Recommended target:** 45 (24% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 52: "Reference ADRs from `docs/decisions-index.md` that shaped this architecture." — the heading `## Key Architectural Decisions` plus the `{ADR-001}` placeholder on line 54 already convey this.
- Lines 8, 14, 22, 32, 40, 48, 56: seven `---` separators — D3, ~14 lines.
- Lines 58-59: footer + trailing blank — D2/D4.

### Load-bearing content confirmed present (do not touch)
- Lines 3-4: "Living document ... **Do not archive this file — update it in place**" — non-obvious lifecycle rule.
- The mermaid `flowchart LR` skeleton — sets the diagram dialect; without it agents produce inconsistent diagram types across runs.
- `## Data Ownership` table with the Owner/Consumers split — enforces hard limit 5 (one owner per data store).

---

## `planifest-framework/templates/backlog-entry.template.md`

**Current line count:** 41
**Recommended target:** 32 (22% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 9-11: "Any phase agent may file an entry at any time. Filing is non-blocking and never modifies the active feature's scope. Acting on an entry is human-gated at the next feature's P0 pickup (pull-in / leave / discard)." — this is orchestrator policy, stated in full in `planifest-orchestrator/SKILL.md`; the template does not need to re-teach the governance model to the agent that is already following it.
- Lines 13-19: the seven-line ID-collision essay. The *rule* is non-obvious and must survive, but it can be stated in two lines ("`{id}` is its own sequence — collisions with feature IDs are expected. Next `{id}` = highest ever allocated + 1, including picked-up and discarded entries.") instead of seven with a worked example.

### Load-bearing content confirmed present (do not touch)
- Line 8 path convention `plan/backlog/{id}-{slug}/entry.md` with zero-padded `{id}` and kebab-case `{slug}`.
- `**Source feature:**`, `**Source phase:**`, `**Date filed:**` — asserted verbatim by `planifest-framework/tests/test-0000016-pipeline-governance.sh` (req-001: "Source feature", "Source phase", "Date filed").
- `## Problem` — also asserted by the same test.
- Lines 29-30: "Specific enough that a future P0 — with no memory of this session — can judge whether to pull it in" — the fresh-context sufficiency constraint is the whole point of the artifact.
- `## Suggested Action`, `## Why Deferred`.

---

## `planifest-framework/templates/build-log.template.md`

**Current line count:** 73
**Recommended target:** 70 (4% reduction) — effectively no meaningful reduction available

### Redundant sections (candidates for removal/condensation)
- Lines 7-8: "Created at P0. Appended by the orchestrator at each phase boundary. Survives session changes. / Filed to the archive at P7. Read by the build-assessment-agent at P8." — condense to one line; the P7/P8 handoff is orchestrator and ship-agent policy.
- Line 24: `<!-- Orchestrator: append one block per phase using the template below. -->` — line 41 says the same thing.

### Load-bearing content confirmed present (do not touch)
- **Lines 41-56, the commented-out per-phase block.** This looks like verbatim duplication of the P0 block (lines 26-38) and would otherwise be the obvious trim, but `planifest-framework/tests/test-0000018-req-005-build-log-telemetry-record.sh` asserts `grep -c '| Telemetry |' >= 2`. Removing the comment block drops the count to 1 and fails the test. **Do not remove without a paired requirement to change that test.**
- Line 36 / 53 exact string `emitted / failed-with-recorded-choice / confirmed-disabled` — asserted verbatim by the same test.
- Line 72 `Phases with a recorded telemetry gap` — asserted verbatim by the same test.
- The Header table field names and the Summary metric names — consumed by `planifest-build-assessment-agent` at P8.

---

## `planifest-framework/templates/change-summary.template.md`

**Current line count:** 68
**Recommended target:** 50 (26% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 10-11: `**Tool:**` / `**Model:**` — D1.
- Line 16: "Produced by the change-agent after completing a change. This is the audit trail for post-feature modifications." — the `**Skill:**` line 9 already names the producer; the audit-trail framing changes nothing about how the artifact is filled.
- Lines 18-19, 27-28, 35-36, 43-44, 53-54, 64-65: six `---` separators — D3, ~12 lines.
- Lines 66-68: footer + trailing blanks — D2/D4.

### Load-bearing content confirmed present (do not touch)
- `## Blast Radius` with the direct/indirect and low/medium/high enums — the change-agent's core discipline.
- `## Artifacts Updated` checklist (component.yml bump, design requirements, ADR, data contract, risk register) — this is a completeness gate, not prose; each unchecked box is a real failure mode.
- `## Validation` check table.
- Classification enum on line 25.

---

## `planifest-framework/templates/component.template.yml`

**Current line count:** 95
**Recommended target:** 85 (11% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 2: `# See p007 for the full Domain Knowledge Service schema.` — dangling reference; no `p007` document exists anywhere in the repo. Stale pointer, remove.
- Lines 14-15 / 18-19: paired "First thing / Second thing" and "Explicit exclusion / Another exclusion" placeholders — one example each suffices, and line 19's "equally important as responsibilities" is rationale, not instruction.
- Lines 68-69 (`"Item 1"` / `"Item 2"`), line 77 (`"Debt item 1"`), line 79 (`"Quirk 1"`) — contentless filler that teaches nothing about what belongs in the field. Either give one real-shaped example or none.
- Lines 60-63: `outOfScope` / `deferred` single-item placeholders restate the same three-way split already defined in `scope.template.md`; the field names alone are sufficient here.
- Line 94-95: trailing blanks — D4.

### Load-bearing content confirmed present (do not touch)
- Every key name — the manifest is machine-read by the docs-agent, the component registry, and `gate-write` scope resolution.
- All pipe-delimited enums (`status`, `type`, `stack.*`, `breakingChangePolicy`, `featureMode`, `createdBy`) — these are closed vocabularies; without them agents invent values and the registry fragments.
- `contract.apiSpec`, `data.dataContract`, `data.migrationPath` path conventions.
- `exceptions:` as a first-class sibling of `responsibilities:` — the negative-space declaration is a deliberate framework choice.

---

## `planifest-framework/templates/cost-model.template.md`

**Current line count:** 66
**Recommended target:** 50 (24% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 4-5: `**Tool:**` / `**Model:**` — D1.
- Line 9: "Estimates must be based on the design requirements's scale requirements. State assumptions explicitly. Use monthly costs unless otherwise noted." — "state assumptions explicitly" is fully covered by the `## Assumptions` section that exists at line 57; "use monthly costs" is already enforced by every column header saying "Monthly Cost". Keep only the "base on the design's scale requirements" clause. (Also note the typo `requirements's`.)
- Lines 11-12, 23-24, 31-32, 39-40, 47-48, 55-56, 62-63: seven `---` separators — D3, ~14 lines.
- Lines 64-66: footer + trailing blanks — D2/D4.

### Load-bearing content confirmed present (do not touch)
- The five-category Summary table with a bolded Total row — the rollup shape.
- `Scaling Trigger` and `Growth Rate` columns — these force forward-looking estimates rather than point-in-time snapshots, which a model would otherwise skip.
- `## Assumptions` numbered list.

---

## `planifest-framework/templates/cursor-boot.md`

**Current line count:** 30
**Recommended target:** no meaningful reduction available

### Redundant sections (candidates for removal/condensation)
- None within the file. Every line is a hard rule, an operational directive, or the escalation clause.
- **Observation, not a recommendation:** lines 7-25 are near-verbatim identical to `standard-boot.md` lines 1-20 (minus the commit-message and context-mode directives and the whole Hook Enforcement section). This is intentional per-tool duplication — Cursor gets a frontmatter-wrapped variant without Claude-Code-specific hook documentation. Consolidating the two into one shared body would be a structural change to the setup flow, not a content trim, and is out of scope for this audit.

### Load-bearing content confirmed present (do not touch)
- Lines 1-5 Cursor rule frontmatter (`description`, `globs`, `alwaysApply`) — required for Cursor to load the file at all.
- All seven Hard Limits.
- Line 25 `.cursorindexingignore` directive — this is the mechanism that keeps guide files and `standards/reference/` out of Cursor's index; removing it defeats the exclusion this audit relies on.
- Escalation clause.

---

## `planifest-framework/templates/data-contract.template.md`

**Current line count:** 57
**Recommended target:** 42 (26% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 10-11: `**Tool:**` / `**Model:**` — D1.
- Line 14 parenthetical "(data is always owned by exactly one component)" — restates Hard Limit 5, which is in every boot file and therefore in context already.
- Lines 15-16: `**Schema Version:** {{semver}}` and `**Version:** {{semver}}` on consecutive lines, plus `version:` in the frontmatter — three version fields with no stated distinction between them. Keep `Schema Version` (it is the one `component.yml.data.schemaVersion` mirrors) and the frontmatter; drop the bare `**Version:**`.
- Line 18: "Any schema change requires a migration proposal - never modify the schema directly." — verbatim restatement of Hard Limit 3, already in context from the boot file on every turn.
- Line 40: "Rules the data must always satisfy, regardless of how it is accessed." — the word "Invariants" carries this.
- Lines 20-21, 36-37, 45-46, 53-54: `---` separators — D3.
- Lines 55-57: footer + trailing blanks — D2/D4.

### Load-bearing content confirmed present (do not touch)
- `## Tables` / `### {{table-name}}` nesting with the Column/Type/Nullable/Default/Constraints columns.
- `**Indexes:**` and `**Relationships:**` sub-blocks.
- `## Migration History` table including the **Destructive** column — this column is what makes Hard Limit 4 (destructive ops need human approval) auditable after the fact.
- `**Owner:**` field.

---

## `planifest-framework/templates/decisions-index.template.md`

**Current line count:** 29
**Recommended target:** 25 (14% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 8, 16, 26: `---` separators — D3.
- Lines 28-29: footer + trailing blank — D2/D4.

### Load-bearing content confirmed present (do not touch)
- Lines 3-4: "Living document ... **Do not archive this file — update it in place**" — non-obvious lifecycle rule.
- **Lines 18-24 `## Status Definitions` table.** This looks like explanatory prose but it is a closed vocabulary with a genuinely non-obvious third value: `amended` ("core decision unchanged but conditions or scope updated") is not a status a model would invent, and without the table it would collapse `amended` into `superseded`. Keep in full.

---

## `planifest-framework/templates/defect-report.template.md`

**Current line count:** 46
**Recommended target:** 40 (13% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 9-11: "Filing halts the reporting agent's current task and hands control to the orchestrator, which spawns a fresh-context `planifest-reversal-assessor` (never the filer) to judge it (ADR-006)." — the dispatch mechanics belong to the orchestrator and `planifest-reversal-assessor`; the filing agent needs to know it must stop, not the full spawn choreography. Condense to one clause.
- Line 45 parenthetical "(the assessor recomputes this from traceability)" — tells the filer about the assessor's internals, which does not change what the filer writes.

### Load-bearing content confirmed present (do not touch)
- All five section headers — asserted verbatim by `planifest-framework/tests/test-0000016-pipeline-governance.sh` req-015: `What Is Blocked`, `Binding Upstream Artifact`, `Attempts Made`, `Evidence`, `Proposed Correction Scope`.
- Line 11-12: "**All five sections are required** — an incomplete report is returned to the filer, not assessed."
- Lines 12-14: the validity window ("Valid only from P3–P6 against live P0–P6 artifacts; nothing archived at P7 can be the subject of a report") and the re-file escalation rule. Both are non-obvious governance constraints.
- Line 18 `**Reversal budget remaining before this petition:** {{n}} of 2`.
- Line 33 "At least one required" on Attempts Made.
- Line 38-39 "verbatim where possible. The assessor judges on this, not on the narrative." — this materially changes what the filer writes.

---

## `planifest-framework/templates/design.template.md`

**Current line count:** 61
**Recommended target:** 57 (7% reduction) — little meaningful reduction available

### Redundant sections (candidates for removal/condensation)
- Lines 11-12: two identical `US-00N: As a [role], I [action], so that [outcome]` placeholder lines — one demonstrates the format.
- Line 54: the Skill Map example row is a single row already; fine. No further trim.

The file is already a dense bullet skeleton with almost no explanatory prose. It is
one of the best-behaved templates in the set.

### Load-bearing content confirmed present (do not touch)
- **`## Scope`** — parsed verbatim by BOTH `planifest-framework/hooks/enforcement/gate-write.mjs` (`PATHS_SECTION_RE = /^##\s+(Component Paths|Scope)\s*$/im`) and `check-design.mjs` (`SCOPE_SECTION_RE`, same pattern). Renaming or removing this heading breaks write enforcement outright.
- **`## Skill Map`** — asserted verbatim by `test-0000009-rail-tightening.sh` (`grep_has "## Skill Map"`).
- **`discovery.md` reference on line 7** — asserted by `test-0000017-req-006-structured-discovery-pass.sh` (`grep_has "discovery.md" "$DESIGN_TPL"`). The parenthetical "raw P0 findings — do not embed them here; this document records confirmed decisions only" is the anti-bloat rule for design.md itself; keep.
- Line 5 adoption-mode enum (`greenfield | standard-iterative | retrofit | external-anchor`).
- Line 60 Confirmation line — the human-confirmation gate the whole framework hinges on, including its date/time format.
- The four-layer structure (Product / Architecture / Engineering) and the "deferred - recorded in scope" fallback phrasing on lines 18-20.

---

## `planifest-framework/templates/discovery.template.md`

**Current line count:** 53
**Recommended target:** 48 (9% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 8-9: "Raw findings only — decisions belong in `design.md`, the Q&A audit trail in `build-log.md`. / Fresh each pipeline run: filed to the archive at P7, recreated at the next P0." — the first half is worth keeping (it is the separation-of-concerns rule); the P7/P0 lifecycle half is orchestrator policy. Merge to one line.
- Line 10: "A section whose signal could not be read states that plainly — coaching proceeds on the rest." — condensable to "Unreadable signal: say so; coaching proceeds."

### Load-bearing content confirmed present (do not touch)
- **Section headers `Header (all modes)`, `Greenfield`, `Standard Iterative`, `Retrofit`, `External Anchor`** — all five asserted verbatim by `planifest-framework/tests/test-0000017-req-006-structured-discovery-pass.sh` (loop over `for section in ...`).
- Line 7: "Created at the start of P0, **before the first coaching question**, in every adoption mode" — the ordering constraint is the entire point of the discovery pass.
- Lines 23-25 HTML comment: "Populate the subsection for the confirmed adoption mode; delete the others. External Anchor keeps its own subsection PLUS whichever underlying mode's subsection applies." The External Anchor compound rule is genuinely non-obvious and would be got wrong without it.
- The per-mode source-path annotations (`docs/about.md`, `plan/_archive/`, `planifest-overrides/instructions/`, `package.json / go.mod / git tags / README`) — these tell the agent where to look, which it cannot infer.

---

## `planifest-framework/templates/domain-glossary.template.md`

**Current line count:** 29
**Recommended target:** 22 (24% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 10-11: `**Tool:**` / `**Model:**` — D1.
- Line 15: 60-word blockquote. The rule inside it ("if the glossary says Order, the code says `Order`; never invent new terms without adding them here") is load-bearing; the enumeration of where the terms apply ("in code, comments, file names, variable names, and documentation") is padding. Condense from ~5 rendered lines to 2.
- Lines 17-18, 25-26: `---` separators — D3.
- Lines 27-29: footer + trailing blanks — D2/D4.

### Load-bearing content confirmed present (do not touch)
- The ubiquitous-language rule itself (the `Order` not `Purchase`/`Transaction` example is the clearest possible statement of it — keep the example, drop the surrounding scaffolding).
- Terms table columns including `Aliases` and `Used In` — `Used In` is what makes the glossary traceable back to components.
- Line 9 "(updated by any agent that introduces a new domain term)" — establishes that this is not spec-agent-exclusive.

---

## `planifest-framework/templates/execution-plan.template.md`

**Current line count:** 103
**Recommended target:** 72 (30% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 6-7: `**Tool:**` / `**Model:**` — D1.
- Line 3: "Written by the spec-agent. Derived from the Feature Brief - not invented." — the first clause duplicates line 5's `**Skill:**`; keep only "Every requirement must be traceable to a user story or acceptance criterion", which is the actual constraint.
- Line 17: "Capability skills loaded for this pipeline run (populated by orchestrator at P0)." — the table columns (Skill / Scope / Purpose) plus the `plan | permanent` enum say all of it.
- Line 50: "Endpoints derived from the functional requirements." — D5; keep only "The full contract is in `openapi-spec.yaml`" (that is a pointer, not prose).
- Line 61: "Entities derived from the functional requirements." — same treatment; keep the data-contract pointer.
- Line 71: "How components interact to fulfil the requirements. Maps to the integration points in the feature brief."
- Line 83: "Assumptions made during requirements phase." — D5. Keep "Each is a risk item with likelihood: medium" (that is a concrete cross-artifact rule matching `risk-register.template.md` line 30).
- Line 93: "Material gaps that could not be resolved from the brief." — D5. Keep "Reported to the orchestrator - not filled in by assumption", which is the real behavioural rule.
- Line 42 and line 55: second example rows (NFR-002, GET endpoint) — one row per table suffices except where the second demonstrates a distinct shape. NFR-002 does show a second category, so this one is borderline; the GET row is pure repetition.
- Lines 13-14, 23-24, 35-36, 46-47, 57-58, 67-68, 79-80, 89-90, 99-100: nine `---` separators — D3, ~18 lines.
- Lines 101-103: footer + trailing blanks — D2/D4. Note the footer also points at `../skills/planifest-orchestrator/SKILL.md` while line 5 points at `../skills/planifest-spec-agent/SKILL.md` — neither is needed.

### Load-bearing content confirmed present (do not touch)
- **`## Active Skills`** — asserted verbatim by `planifest-framework/tests/test-0000005-framework-governance.sh` req-012 (`assert_contains "Active Skills" "$EXEC_TPL"`).
- **Line 29 naming convention `req-{NNN}-{kebab-slug}.md`** and the `plan/current/requirements/` path — the spec-agent and orchestrator both resolve requirement files by this exact pattern.
- **Line 44: "'The system should be fast' is not a requirement. 'p95 latency < 200ms for the primary endpoint' is."** — this is the highest-value line in the file. It prevents a specific, common, expensive failure. Keep verbatim.
- Line 27: "one user story per file" — the split rule.
- NFR table columns including `Measurement`; Assumptions and Open Questions ID prefixes (`A-001`, `Q-001`).
- The mermaid `flowchart LR` skeleton.

---

## `planifest-framework/templates/feature-brief.template.md`

**Current line count:** 186
**Recommended target:** 120 (35% reduction)

The largest template in the set and the one with the most explanatory prose per
placeholder. It is also human-authored input, which is the argument for keeping
guidance — but the orchestrator loads it as a *template* at P0 to coach against,
and the human-facing long-form version already exists as
`feature-brief-guide.md` (117 lines, excluded from indexing). The guidance essays
here are therefore duplicated into an already-excluded file.

### Redundant sections (candidates for removal/condensation)
- **Line 37: a stale worked example bleeding a prior feature into every new brief** — `| {{feature-name}} | As a developer, I can run setup.ps1 with --include-full-skill-library, so that external skills are installed without manual copying | must-have | 1 |`. This is a real user story from a past Planifest feature sitting in the template as the first example row. Lines 38-39 already show the generic `As a [role], I [action], so that [outcome]` shape twice. Remove line 37 outright.
- **Line 49: "(Waves were previously called 'Phases' in this template — renamed to avoid collision with the P0–P9 pipeline phases.)"** — pure archaeology. Nobody filling a brief today needs the rename history.
- **Lines 47-48: the "Why waves matter" essay** — "An agent working on wave 2 only needs the context from wave 2's brief plus the component manifests from wave 1. It doesn't need to hold the entire feature in context. This is how Planifest manages context at scale." This is framework advocacy, not instruction. The rule that matters (line 45: ">5-6 features → split into waves; earlier waves ship before later begin") survives without it.
- Line 11: "Written by a human. This is the input document that kicks off the confirmed design Agentic Iteration Loop. The orchestrator reads this and coaches you through any gaps before passing it to the spec-agent." — process narration.
- Line 13 second half: "The numeric prefix keeps features in chronological order when sorted alphabetically." — rationale for a format rule that is already fully specified by the preceding clause and the two examples.
- Line 19: "What problem does this feature solve? Who benefits and how?" — D5, immediately followed by line 21 which says it better.
- Line 29: "Break the feature into discrete features. Each feature should be small enough that an agent can implement it within a single session (roughly: one API endpoint with its data model, validation, tests, and docs - or one UI screen with its state management and tests)." — the parenthetical sizing analogy is ~30 words doing the work that the line-31 "more than 3 user stories → split" rule does precisely.
- Line 60: "What architectural decisions have you already made? The agent implements within these constraints - it does not choose the architecture." — the second clause is worth one short line; the question is D5.
- Line 64: "What components does this feature create or modify?" — the table's `New or Existing` column says it.
- Line 72: "Which components own which data? Each data store is owned by exactly one component." — restates Hard Limit 5, in context on every turn.
- Line 80: "How do components communicate?" — the `Method` column says it.
- Line 90: "What technology stack has been decided? The agent builds with this - it does not choose a different stack." — near-verbatim repeat of line 60's second clause.
- Line 113: "What is explicitly in scope, out of scope, and deferred?" — the three sub-headings immediately below say it.
- Line 142: "Anything the agents need to know that doesn't fit elsewhere."
- Line 176: "How do you know this feature is done?"
- Lines 15-16, 41-42, 56-57, 86-87, 109-110, 125-126, 138-139, 150-151, 172-173, 182-183: ten `---` separators — D3, ~20 lines.
- Lines 184-186: footer + trailing blanks — D2/D4. The footer path `../skills/orchestrator/SKILL.md` is also stale (actual path is `planifest-orchestrator/SKILL.md`).

### Load-bearing content confirmed present (do not touch)
- **`## Waves` heading and the `| Wave |` column in the Features table** — both asserted verbatim by `planifest-framework/tests/test-0000016-pipeline-governance.sh` req-006 (`assert_contains "| Wave |"`, `assert_contains "## Waves"`).
- **Line 13 Feature ID format**: "7-digit zero-padded number followed by a kebab-case name" with the two examples. Directory naming across `plan/` depends on it.
- **Line 31**: "If a feature has more than 3 user stories, it's too big. Split it further." — hard splitting rule.
- **Line 33**: user story format string + "If a story implies more than 3 acceptance criteria, split it into two stories" — this is the rule `requirement.template.md` line 18 depends on.
- **Line 92**: "If you haven't decided yet, leave this section empty. The orchestrator will ask you to fill it before the pipeline proceeds." — tells the human that blank is a legal, handled state. Non-obvious.
- **Line 129**: "If you don't have a target, leave it blank - the spec-agent will ask." — same rationale.
- **Lines 152-170 Scenario Paths** — all four paths (happy / first-run / error-sad / cross-session-continuity) plus line 154's statement that empty entries become P0 gaps. This section directly drives the Scope Lock Challenge; the four prompts are each doing distinct work and none is inferable from a heading.
- Line 21: the "Reduce checkout latency from 3s to under 500ms because 40% of users abandon at payment" counterexample.
- The Stack table's closed concern list including `Build target | local \| docker \| ci-only`.
- `## Acceptance Criteria` checkbox list.

---

## `planifest-framework/templates/iteration-log.template.md`

**Current line count:** 69
**Recommended target:** 50 (28% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 13-14: `**Tool:**` / `**Model:**` — D1. Line 14's three-model example list (`claude-sonnet-4-20250514, gpt-4.1, gemini-2.5-pro`) is stale-prone as well as unnecessary.
- Line 9: the audience blockquote is ~4 rendered lines. The disambiguation ("this is NOT the PR changelog; the PR changelog is written by ship-agent Step 1") is genuinely load-bearing because two similar artifacts exist. The rest ("machine-readable execution trace — it records *how* the pipeline ran") is padding. Condense to 2 lines.
- **Lines 59-63 `## Next Step` with `git push origin feature/{{feature-id}}`** — remove entirely. Three problems: (a) it is not part of the iteration log's job, (b) pushing is the ship-agent's P9 responsibility, and (c) it directly contradicts the repo-root `CLAUDE.md` "Local Git Only" override which forbids agents from running push at all. A template that ends by suggesting a forbidden command is worse than one that ends silently.
- Lines 17-18, 31-32, 39-40, 45-46, 51-52, 57-58, 65-66: seven `---` separators — D3, ~14 lines.
- Lines 67-69: footer + trailing blanks — D2/D4.

### Load-bearing content confirmed present (do not touch)
- The seven-row Iteration Steps table with per-phase Gate Result semantics — this is the structured trace the build-assessment-agent reads at P8.
- `## Requirement Changes During Run` with the `cosmetic / additive / contradictory` classification enum — a closed vocabulary tied to the reversal protocol.
- `## Self-Correct Log`, `## Quirks` (with its "written to docs/quirks.md and component.yml" routing note — that is a pointer, not prose), `## Recommended Improvements`.

---

## `planifest-framework/templates/loop-state.template.md`

**Current line count:** 46
**Recommended target:** 42 (9% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 10-11: "An interrupted session resumes mid-loop by reading this file per the existing `Px: Resuming…` convention." — the resume convention is owned and stated by `pause.template.md` and the orchestrator's Resume Detection section; a pointer would do.
- Lines 39-40: "Carries full context so the human (or a resumed session) needs nothing from the dead conversation." — rationale; the four bullets below define what to write.

### Load-bearing content confirmed present (do not touch)
- **Field labels `Iteration`, `Reversal budget`, `Run Log`, `Append-only`, `Decision`** — all five asserted verbatim by `planifest-framework/tests/test-0000016-pipeline-governance.sh` req-010.
- Frontmatter `status: active | done | escalated` — **`status: active` is read by `planifest-framework/hooks/enforcement/ratchet-check.mjs`** to decide whether the ratchet is armed. Do not touch.
- Lines 8-9: "Git-tracked; committed after every update so budget/iteration counters survive interrupt/resume (ADR-007)" — the commit-every-update rule is what makes the counters trustworthy.
- Line 12: "While a loop-state file has `status: active`, the ratchet hook is armed for `plan/current/` artifact writes." — tells the agent why its writes may be blocked.
- Loop id enum (`p0_completeness | design_critic | reversal_protocol | verify_by_execution | cross_model_review`) and the cap note `3 (default) — P4 validate keeps 5`.
- Line 28 "Append-only — one record per iteration. Never rewrite a prior record."
- The Action / Observation / Decision triple.
- Stop-rule enumeration on line 42.

---

## `planifest-framework/templates/operational-model.template.md`

**Current line count:** 55
**Recommended target:** 42 (24% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 4-5: `**Tool:**` / `**Model:**` — D1.
- Line 9: "Defines how this system is operated in production. Every component must have clear ownership, alerting, and runbook triggers." — the three section headings below are literally Component Ownership, Runbook Triggers, and Alerting Thresholds.
- Lines 11-12, 19-20, 27-28, 35-36, 43-44, 51-52: six `---` separators — D3, ~12 lines.
- Lines 53-55: footer + trailing blanks — D2/D4.

### Load-bearing content confirmed present (do not touch)
- Every table's column set. `Escalation Path`, `Automated?`, `Rollback Plan`, `Health Check`, `RTO`/`RPO` are each a field a model would omit if not named.
- The deployment strategy enum (`rolling / blue-green / canary`).
- The warning/critical two-threshold split in Alerting.

---

## `planifest-framework/templates/pause.template.md`

**Current line count:** 31
**Recommended target:** 26 (16% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 13-19: the seven-line "Include:" bullet list. The four bullets (which requirement, what was completed, what remains, blockers/decisions pending) are largely inferable from "what was partially completed", and the operative constraint is the closing sentence on lines 18-19 ("detailed enough for the orchestrator to reconstruct full execution context on resume without re-reading prior conversation"). Condense the four bullets to one line, keep the constraint verbatim.

### Load-bearing content confirmed present (do not touch)
- **Frontmatter `active_task`** — asserted verbatim by `planifest-framework/tests/test-0000009-rail-tightening.sh` (`grep_has "active_task" "$PAUSE_TPL"`).
- Frontmatter `phase` and `last_artifact`.
- **Lines 25-27: the exact resume banner format `{phase-id}: Resuming — {active_task}`** — the orchestrator's Resume Detection reproduces this string; it must stay verbatim including the em dash.
- Line 30: "Delete this file once the interrupted task has been re-engaged." — without it, stale pause files accumulate and mis-trigger resume.
- Lines 18-19: the fresh-context sufficiency constraint.

---

## `planifest-framework/templates/recommendations.template.md`

**Current line count:** 43
**Recommended target:** 32 (26% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 4-5: `**Tool:**` / `**Model:**` — D1.
- Line 9: "Improvement suggestions discovered during the pipeline. These are not blockers - they are opportunities for future work. Each recommendation must be actionable and specific." — the "not blockers" clause is worth one short line; "actionable and specific" is already carried by the table's `{{specific, actionable recommendation}}` placeholder.
- Line 23: "Items from the scope document's 'Deferred' list that should be revisited:" — the heading `## Deferred Items` plus the `Scope Item` column say it.
- Line 33: "Items identified during implementation that should be addressed:" — the heading `## Tech Debt` says it.
- Lines 11-12, 19-20, 29-30, 39-40: `---` separators — D3.
- Lines 41-43: footer + trailing blanks — D2/D4.

### Load-bearing content confirmed present (do not touch)
- The category enum (`performance / security / maintainability / testing / observability / cost`) and effort enum (`small / medium / large`) — closed vocabularies.
- ID prefixes `REC-001` / `TD-001`.
- The three-table split (Recommendations / Deferred Items / Tech Debt) — these are distinct backlogs with different downstream consumers.
- `Impact if Ignored` column — forces a consequence statement.

---

## `planifest-framework/templates/requirement.template.md`

**Current line count:** 63
**Recommended target:** 42 (33% reduction)

### Redundant sections (candidates for removal/condensation)
- **Lines 35-51: the 17-line HTML comment block.** This is the single clearest instance of near-verbatim self-duplication in the template set. The comment explains the conditional rule for the Input Validation section and then gives a fully worked five-bullet example — and lines 53-61 immediately below are that same five-bullet section in placeholder form, with its own one-line conditional note at line 55 saying the same thing. Every one of the five fields appears twice within 25 lines. Remove the comment block entirely.
  - **Test safety check:** `planifest-framework/tests/test-0000010-framework-quality-improvements.sh` greps this file for `## Input Validation` (line 53 ✓), `conditional\|only required\|only include` (line 55 contains both "conditional" and "only include" ✓), `allowed character\|...\|pattern` (line 58 ✓), `max.*length\|maximum.*length` (line 59 ✓), `failure.*behav\|...\|default.*value` (line 60 ✓), `^## Functional Requirements` (line 24 ✓) and `^## Acceptance Criteria` (line 28 ✓). **All seven assertions are satisfied by lines 53-61 alone.** Removing lines 35-51 is test-safe.
- Line 18: "One requirement doc = one user story. If this story implies more than 3 acceptance criteria, split it into two requirement docs." — this is a verbatim restatement of `feature-brief.template.md` line 33, and the split decision has already been made by the time a requirement doc is being written from a confirmed design. Condense to "One requirement doc = one user story."
- Lines 14-15, 21-22: `---` separators — D3.
- Lines 62-63: trailing blanks — D4.

### Load-bearing content confirmed present (do not touch)
- `^## Functional Requirements` and `^## Acceptance Criteria` — asserted with anchored greps by test-0000010.
- `## Input Validation` heading — asserted by test-0000010.
- Line 55 conditional note and lines 57-61's five bullets (source / allowed characters / max length / failure behaviour / logging policy) — each individually grepped by test-0000010.
- **`## Acceptance Criteria` with `- [ ]` checklist items** — `planifest-framework/hooks/enforcement/ratchet-check.mjs` defines weakening as "removing a `- [ ]` checklist line from an `## Acceptance Criteria` section". Both the heading and the checkbox syntax are hook-load-bearing.
- Frontmatter, `**Source:**` (user story ID traceability to design.md), `**Priority:**` enum.
- `## Dependencies`.

---

## `planifest-framework/templates/revision-log.template.md`

**Current line count:** 27
**Recommended target:** 24 (11% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 9-10: "Together with the defect report, verdict, cascade list, and gate record this makes each reversal reconstructable from artifacts alone (NFR-005)." — rationale for the artifact's existence; does not change how a row is filled. The NFR-005 tag could be preserved in a shorter form if traceability matters.

### Load-bearing content confirmed present (do not touch)
- Line 7-8: path `plan/current/revision-log.md`, "Created on the first granted reversal", "exactly one entry per revision" — lifecycle rules with no other source.
- The table column set including `Classification` with the `additive | altering` enum.
- **Line 20: "One block per granted reversal — written *before* any re-work starts (ADR-005)."** — an ordering constraint that is easy to violate and expensive when violated.
- Line 25: the cascade-count human gate rule (`{{n}} artifacts{{; >3 = human gate}}`).
- Line 26: the four-way Human gate condition (`not required (additive, ≤3 cascade, continuous run) | approved by human {{date}}`).

---

## `planifest-framework/templates/risk-register.template.md`

**Current line count:** 40
**Recommended target:** 32 (20% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 10-11: `**Tool:**` / `**Model:**` — D1.
- Lines 18-19, 26-27, 36-37: `---` separators — D3.
- Lines 38-40: footer + trailing blanks — D2/D4. Note the footer's "Updated by any agent that identifies a new risk" is a verbatim repeat of line 9's parenthetical.

### Load-bearing content confirmed present (do not touch)
- **Line 16: "Every entry must be specific to this feature. Do not produce generic risks."** — this counters a real and very common model failure (emitting boilerplate risks like "the database might go down"). Keep verbatim.
- **Line 30: "Documented assumptions from the specification are logged here with likelihood: medium."** — a concrete cross-artifact rule that pairs with `execution-plan.template.md` line 83. Keep.
- Category enum (`technical / operational / security / compliance`), status enum (`open / mitigated / accepted`), ID prefixes `R-001` / `A-001`.
- `**Overall Risk Level:**` header field.

---

## `planifest-framework/templates/scope.template.md`

**Current line count:** 43
**Recommended target:** 34 (21% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 10-11: `**Tool:**` / `**Model:**` — D1.
- Line 30: "equally important as in-scope - prevents agents from building beyond the boundary" — rationale for why Out of Scope matters, addressed to an agent that is already writing the section.
- Line 37: "note what is blocked until each deferred item is resolved" — this one is closer to a real instruction than line 30; consider keeping if a choice must be made between the two.
- Lines 18-19, 25-26, 32-33, 39-40: `---` separators — D3.
- Lines 41-43: footer + trailing blanks — D2/D4.

### Load-bearing content confirmed present (do not touch)
- **`## In Scope`** — `planifest-framework/hooks/enforcement/ratchet-check.mjs` defines weakening as "removing a bullet from an `## In Scope` / `## Scope` section". Hook-load-bearing heading.
- **Line 16: "All three sections must be present. If 'Deferred' is empty, state 'Nothing deferred.'"** — explicitly non-obvious: it forbids the natural behaviour of omitting an empty section, and specifies the exact filler string.
- All three section headings (`## In Scope`, `## Out of Scope`, `## Deferred`).
- **Line 23: "be specific - 'authentication' is vague; 'JWT-based auth with refresh tokens, scoped to the auth-service component' is clear"** — a concrete good/bad pair that measurably changes output quality. Keep.
- `**Wave:**` field.

---

## `planifest-framework/templates/security-report.template.md`

**Current line count:** 57
**Recommended target:** 44 (23% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 4-5: `**Tool:**` / `**Model:**` — D1.
- **Line 10 vs line 55: verbatim self-duplication within the file.** Line 10 says "It is advisory - no code changes are made. All findings require human review before action." and line 55 (the footer) says "This report is advisory only - no code changes are made by the security review." The same rule twice, 45 lines apart. Keep line 10, drop the footer.
- Line 10's "This report is produced by the security-agent during Phase 5" — line 3's `**Skill:**` already names the producer.
- Lines 12-13, 20-21, 28-29, 36-37, 44-45, 53-54: six `---` separators — D3, ~12 lines.
- Lines 55-57: footer + trailing blanks — D2/D4.

### Load-bearing content confirmed present (do not touch)
- The advisory / no-code-changes / human-review-required rule (once).
- Severity enum including `informational`, and category enum (`auth / injection / data-exposure / config / dependency / iac`) — closed vocabularies.
- Status enum including `false-positive` — a value a model would not invent but genuinely needs.
- `## Dependency Audit` CVE table and `## Threat Model` table; the `Existing Mitigation` / `Gap` column pair is what turns a threat list into an actionable one.
- Line 48: "Ordered by priority (critical first)".
- `**Review Scope:**` enum.

---

## `planifest-framework/templates/slo-definitions.template.md`

**Current line count:** 51
**Recommended target:** 43 (16% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 4-5: `**Tool:**` / `**Model:**` — D1.
- Line 9 first clause: "Every SLO must have a measurable SLI, a concrete target, and a defined error budget." — the three tables below have exactly those columns. Keep only "Do not produce aspirational targets - base them on the design requirements's NFRs", which is the real constraint. (Same `requirements's` typo as cost-model.)
- Lines 11-12, 19-20, 27-28, 38-39, 47-48: five `---` separators — D3, ~10 lines.
- Lines 49-51: footer + trailing blanks — D2/D4.

### Load-bearing content confirmed present (do not touch)
- **Lines 29-36 `## Error Budget Policy` and lines 40-45 `## Burn Rate Alerts`** — these are NOT placeholders and NOT explanation. They are prefilled prescriptive defaults (the 14.4x/6x multiwindow burn-rate values are the standard SRE pair). Deleting them would force each run to reinvent thresholds inconsistently. Keep both tables intact.
- The SLI table's `Good Event Definition` / `Valid Event Definition` column pair — this is the precise SLI formulation that makes an SLO computable; a model omits it if not named.
- The worked placeholder on line 17 (`0.1% = ~43 min/month`) — teaches the error-budget arithmetic in six characters.
- ID prefixes `SLO-001` / `SLI-001`.

---

## `planifest-framework/templates/standard-boot.md`

**Current line count:** 41
**Recommended target:** 37 (10% reduction)

### Redundant sections (candidates for removal/condensation)
- **Line 36** — "Hook enforcement is active: `gate-write.mjs` blocks writes outside confirmed design scope; `check-design.mjs` injects scope context on every turn. Manual scope checks in these instructions are retained as documentation but are now redundant enforcement." Clauses one and two restate the `gate-write` bullet (line 27) and the `check-design` bullet (line 29) that appear seven lines earlier. Clause three refers to "manual scope checks in these instructions" that no longer exist anywhere in the file — a dangling reference to removed content. Remove the whole line (D6).
- Line 25: "Planifest installs deterministic enforcement hooks via `setup.sh`. These run automatically:" — condensable to a short lead-in; "these run automatically" is implied by the word hooks.

### Load-bearing content confirmed present (do not touch)
- **`auto-trigger-orchestrator`** and **`planifest-orchestrator skill`** — both asserted verbatim by `planifest-framework/tests/test-0000009-rail-tightening.sh` against `$STANDARD_BOOT`.
- All seven Hard Limits.
- Line 28's non-Claude-Code fallback instruction ("For tools without `UserPromptSubmit` hook support (Cursor, Windsurf, Cline, etc.): at the start of every session ... load the `planifest-orchestrator` skill") — this is the only trigger mechanism for several supported tools.
- Line 30 `commit-msg` bullet including the `--no-verify` escape hatch.
- Line 31 ratchet-check bullet including **"Agents must never write that marker"** — a prohibition with no other source.
- Line 34: "Enforcement failures exit 2 ... All unexpected errors exit 0 — hooks never block your session unexpectedly." — the exit-code contract.
- Escalation clause.

---

## `planifest-framework/templates/test-report.template.md`

**Current line count:** 81
**Recommended target:** 60 (26% reduction)

### Redundant sections (candidates for removal/condensation)
- **Line 5: `**Pipeline run:** P1 Spec → P2 ADRs → P3 Codegen → P4 Validate → P5 Security → P6 Docs → P7 Ship`** — a static restatement of the pipeline that is byte-identical in every report ever generated. Zero information content per instance, and the pipeline is already in the orchestrator's context whenever this template is loaded.
- Line 11 first sentence: "All test files executed during Phase 4 validation." — the heading says "Tests Run This Plan (P4 Results)". Keep only the second sentence ("Every functional requirement must appear here"), which is the completeness rule.
- Line 25: "Full state of `planifest-framework/tests/regression/` at ship time." — the heading `## 2. Regression Pack State` plus the path in the table columns cover it.
- Line 53: "Tests confirmed for promotion to the regression pack during Step R of this P7 run." — the heading says it; keep only the `Step R` pointer if the step reference is needed.
- **Lines 45-47 and 59-61: two near-identical handlebars empty-state blocks** (`{{#if no-regression-tests}}` / "No tests have been promoted..." and `{{#if no-promotions}}` / "No tests were promoted..."). Six lines expressing one convention. Collapse to a single stated rule, or drop both — a model writing a report with nothing to list will say so.
- **Lines 65-76 `## 4. Summary`** — every one of the six metrics is a recomputation of a number already stated in sections 1-3 (`Total tests run (P4)` = line 17; `Regression pack size` = line 27; `Newly promoted tests` = the section 3 row count; `Regression failures blocking ship` = the section 2 failure table). A rollup is defensible for a human skimming, but it is 12 lines of duplicated arithmetic and a common source of internal inconsistency when the two disagree. Candidate for reduction to a 3-line health verdict.
- Lines 7, 21, 49, 63, 78: `---` separators — D3.
- Line 80: footer — D2.

### Load-bearing content confirmed present (do not touch)
- The four numbered section structure (`## 1.` … `## 4.`) — ship-agent P7 Step R writes against these numbers.
- **Line 19: "⚠ If any requirement from `plan/current/requirements/` is absent from this table, the report is incomplete."** — the completeness gate, and the only line that ties the report back to the requirements directory.
- The `Requirement ID(s)` column in section 1 — the traceability link.
- Section 2's `Source feature` / `Promoted by` / `Promotion date` columns — the regression-pack provenance record.
- Section 3's `Decision rationale` column — forces a stated reason for each promotion.
- The `{{#if regression-failures}}` block (lines 35-43) with "These must be triaged before archiving" — a genuine ship gate, unlike the two empty-state blocks above.
- Line 76 overall-health verdict line.

---

## `CLAUDE.md` (repo root)

**Current line count:** 52
**Recommended target:** 50 (4% reduction) — the file is already tight; no forced reduction

This file is loaded at the start of every session and is dense with hard rules,
enforcement contracts, and repo-specific overrides. Only one genuinely redundant
line was found. The `planifest-framework/standards/commit-standards.md` reference
on line 18 is intentional delegation and is correctly not flagged.

### Redundant sections (candidates for removal/condensation)
- **Line 36** — identical finding to `standard-boot.md` line 36 (D6). "Hook enforcement is active: `gate-write.mjs` blocks writes outside confirmed design scope; `check-design.mjs` injects scope context on every turn. Manual scope checks in these instructions are retained as documentation but are now redundant enforcement." The first two clauses restate the `gate-write` bullet on line 27 and the `check-design` bullet on line 29, nine lines above. The third clause points at "manual scope checks in these instructions" which do not exist in this file. Remove the line.
- Line 25 lead-in: "Planifest installs deterministic enforcement hooks via `setup.sh`. These run automatically:" — one line could carry this; minor.

### Load-bearing content confirmed present (do not touch)
- All seven Hard Limits (lines 7-13) — every one is a distinct prohibition with real enforcement or real consequence.
- Line 18 commit-message directive — the `commit-msg` hook is blocking, so this prevents a hard failure every commit. The delegation to `commit-standards.md` is correct and should stay a pointer rather than being inlined.
- Line 20 `.cursorindexingignore` directive — the mechanism keeping `*-guide.md` and `standards/reference/` out of the index; this audit's guide-file exclusion depends on it.
- Line 21 context-mode directive — behaviour-changing tool-routing instruction.
- Lines 27-32 hook bullets — each documents a distinct enforcement point with its own trigger and failure mode. `ratchet-check`'s "Agents must never write that marker" and `commit-msg`'s `--no-verify` note have no other source in context.
- Line 34 exit-code contract.
- Line 40 escalation clause.
- **Lines 42-51 the `planifest-overrides:instructions` block** — machine-delimited by start/end markers (setup re-injects between them) and containing two repo-specific overrides ("Local Git Only", "Commit Granularly, Continuously") that contradict default agent behaviour and therefore must be stated. Do not touch the markers.

### Observation (not a bloat finding, no edit recommended here)
- Line 21 names the tool `mcp__context-mode__ctx_batch_execute`, but the tool is currently exposed as `mcp__plugin_context-mode_context-mode__ctx_batch_execute`. This is a correctness drift, not redundancy — noted for whoever owns that directive.

---

## Aggregate

| | Lines |
|---|---|
| Templates audited (31 files), current | 1782 |
| Templates audited, recommended target | 1394 |
| `CLAUDE.md`, current | 52 |
| `CLAUDE.md`, recommended target | 50 |
| **Total current** | **1834** |
| **Total target** | **1444** |
| **Reduction** | **390 lines (21.3%)** |
| Guide files (excluded from default context loading, no action) | 834 |
