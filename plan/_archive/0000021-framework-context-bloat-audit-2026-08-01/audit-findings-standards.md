# Audit Findings: `planifest-framework/standards/`

Feature 0000021, req-002. Fresh-context content audit of standards files.

Standards files load only when a skill's frontmatter `bundle_standards:` declares them, or when read explicitly. Leverage therefore varies sharply by file: `telemetry-standards.md` is bundled by 16 of 18 skills, `formatting-standards.md` by 8, `code-quality-standards.md` by 3 (codegen, validate, change), while `deployment-standards.md` and `infrastructure-standards.md` are bundled by none.

## Summary table

| File / group | Current lines | Recommended target | Reduction | Treatment |
|---|---:|---:|---:|---|
| api-design-standards.md | 90 | 62 | 31% | full |
| build-target-standards.md | 62 | 55 | 11% | full |
| code-quality-standards.md | 937 | 330 | 65% | full |
| commit-standards.md | 71 | 62 | 13% | full |
| database-standards.md | 60 | 40 | 33% | full |
| deployment-standards.md | 65 | 34 | 48% | full |
| formatting-standards.md | 114 | 72 | 37% | full |
| infrastructure-standards.md | 67 | 40 | 40% | full |
| language-quirks-en-gb.md | 93 | 72 | 23% | full |
| monorepo-standards.md | 63 | 45 | 29% | full |
| observability-standards.md | 72 | 50 | 31% | full |
| stack-summary.md | 34 | 34 | 0% | full |
| telemetry-standards.md | 102 | 85 | 17% | full |
| testing-standards.md | 117 | 78 | 33% | full |
| library-standards/_version-policy.md | 39 | 33 | 15% | full |
| library-standards content files (13 files) | 554 | 465 | 16% | full |
| library-standards TODO stubs (30 files) | 210 | 120 | 43% | 3 full, 27 light |
| **Total in scope for trimming (58 files)** | **2750** | **1677** | **39%** | |
| reference/backend-stack-evaluation.md | 1987 | no action | 0% | excluded |
| reference/frontend-stack-evaluation.md | 1035 | no action | 0% | excluded |

## Cross-file duplication register

Flagged once here rather than repeated per file. Every item below is near-verbatim or semantically identical content appearing in two or more in-scope files.

1. **Test guidance duplicated in full.** `code-quality-standards.md` § 10 (lines 548 to 637, 90 lines) restates `testing-standards.md` almost point for point: test pyramid, Arrange/Act/Assert, test behaviour not implementation, test naming as a sentence, minimal test data, colocation. Both files are bundled together by codegen-agent and validate-agent, so the duplication is loaded twice in the same context. Resolve by deleting § 10 from code-quality and pointing to testing-standards.
2. **Security defaults triplicated.** Least privilege, secrets never in code, encryption, input validation at the boundary appear in `code-quality-standards.md` § 11.3 and § 14, `infrastructure-standards.md` § 3, and `deployment-standards.md` § 4.
3. **Connection pooling.** `database-standards.md` § 5 and `infrastructure-standards.md` § 6 both state "connection pooling configured for all database connections".
4. **N+1 queries are a defect.** `database-standards.md` § 4 and `code-quality-standards.md` § 16.6.
5. **Structured logging rules.** `observability-standards.md` § 2 and `code-quality-standards.md` § 16.5 both define the required log fields and JSON-only rule.
6. **British English exception tables.** `formatting-standards.md` § 2 (lines 43 to 67) reproduces `language-quirks-en-gb.md` Categories 1, 2 and 3, then links to it for "the full exception list". One of the two should hold the tables; the other should hold only the pointer.
7. **Container build rules.** `deployment-standards.md` § 2 overlaps `build-target-standards.md` docker tier.
8. **Error response shape.** `api-design-standards.md` § 3 and `code-quality-standards.md` § 16.4 both define the response envelope.
9. **Footer boilerplate.** Six files end with an identical-format line, `*Referenced by X and Y. Source of truth: planifest-framework/standards/{self}.md*` (api-design 89, database 60, deployment 65, infrastructure 67, monorepo 63, observability 72, testing 117). Self-referential and stale in places. Remove all seven.
10. **Telemetry emission-gate paragraph.** The identical ~90-word "Emission gate (0000018, ADR-001/ADR-002)" paragraph is pasted into 8 skill files while also living in `telemetry-standards.md`. Out of scope for this file (skills are req-001) but recorded here because `telemetry-standards.md` is the canonical source that makes the skill copies removable.

---

## planifest-framework/standards/api-design-standards.md

**Current line count:** 90
**Recommended target:** 62 (31% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 3: "APIs are contracts... hard to misuse" preamble, motivational framing with no rule content.
- Line 13: full enumeration of nine standard HTTP status codes and their meanings, universally known; "use standard codes" is the only instruction.
- Lines 11 to 12: plural nouns, kebab-case, and GET/POST/PUT/PATCH/DELETE semantics, generic REST knowledge.
- Lines 23 to 24: "bodies use JSON", "dates use ISO-8601", generic defaults a model already applies.
- Line 50: "never expose stack traces, SQL queries, or internal paths", duplicated in code-quality § 14 and infrastructure § 3.
- Lines 75 to 79: definition of what a breaking change is, generic API knowledge; the requirement list at 81 to 86 is the load-bearing part.
- Line 68 to 69: "use `$ref`", "include example values", generic OpenAPI practice.
- Line 89: footer boilerplate (see duplication register item 9).

### Load-bearing content confirmed present (do not touch)
- URL-path versioning `/api/v1/` and "never break a published version" (line 14).
- Pagination must include `total`, `next`, `previous` (line 15) and sort syntax `?sort=field:desc` (line 17).
- Null fields omitted from responses; collection envelope `{ "data": [...], "pagination": {...} }` (lines 26 to 27).
- The error envelope shape and `code` as UPPER_SNAKE_CASE constant (lines 35 to 47).
- Authorization checks at handler level, not middleware alone (line 58), a non-obvious project convention.
- OpenAPI 3.1 spec path `plan/{feature-id}/openapi-spec.yaml` and spec-is-source-of-truth (lines 65 to 66).
- Breaking-change process: ADR, human approval, new version, migration period (lines 81 to 86).

---

## planifest-framework/standards/build-target-standards.md

**Current line count:** 62
**Recommended target:** 55 (11% reduction)

Nearly all content is project-specific behavioural instruction with no generic filler. Only marginal condensation is available.

### Redundant sections (candidates for removal/condensation)
- Lines 15, 26, 45: the one-line restatement of each tier's meaning immediately above the "Agent behaviour" list; the tier name plus the bullets already carry it.
- Lines 35 to 38: the `docker build` / `docker run` snippet, the prose at line 32 already says validation runs via docker build and docker run.
- Line 31: "multi-stage where applicable" parenthetical, generic Docker practice.

### Load-bearing content confirmed present (do not touch)
- The instruction to read `Build target` explicitly and never infer it from `compute` or `iac` (line 7).
- The three tier names `local`, `docker`, `ci-only` and the hard negatives under docker: never check host runtimes, never fail because a runtime is absent (lines 29 to 30). This is the whole point of the file.
- Dockerfile-first scaffolding order: Dockerfile and compose before source code (lines 31, 33).
- The `ci-only` rule to flag any acceptance criterion requiring local execution as a scope mismatch (line 52).
- The exact read path `plan/current/design.md → Engineering Layer → Stack → Build target` (line 59).
- The pre-0000007 fallback to `local` with the assumption noted in the build log (line 62).

---

## planifest-framework/standards/code-quality-standards.md

**Current line count:** 937
**Recommended target:** 330 (65% reduction)

By far the largest trimming opportunity in the standards tree. The file is a general-purpose senior-engineering style guide; the overwhelming majority is knowledge a current-generation model applies without instruction. The genuinely Planifest-specific content is perhaps 15% of the file, and the agent-specific anti-pattern section is worth keeping in condensed form because it targets known model failure modes rather than restating general craft.

### Redundant sections (candidates for removal/condensation)
- Lines 7 to 19: "Why This Matters for Agent-Generated Code", 13 lines justifying the existence of the document to its own reader.
- Lines 22 to 42: table of contents. Navigational aid for a human browsing in a renderer; pure overhead in an agent's context window.
- Lines 45 to 87: § 1 Guiding Principles in full (43 lines). Clarity over cleverness, small units, explicit over implicit, composition over inheritance, design for deletion. Every one is universal and already default behaviour. Condense the entire section to 6 one-line bullets, or delete.
- Lines 96 to 129: the two 14-line and 15-line directory trees contrasting feature-organised against type-organised layout, plus 1 line of explanation. The rule "organise by feature, not by type" needs no worked example.
- Lines 137 to 149: § 2.3 shallow hierarchies, including a 7-line annotated tree to illustrate "three levels deep".
- Lines 161 to 171: § 2.5 barrel exports, generic ES-module guidance.
- Lines 177 to 185: § 3.1 Single Responsibility with three worked examples (OrderValidator, PaymentGateway, UserProfile).
- Lines 236 to 254: § 3.5 prefer pure functions, plus a 13-line pure/impure code example.
- Lines 258 to 313: § 4 Functions and Methods in full (56 lines, 4 code blocks). Do one thing, short parameter lists, guard clauses, avoid boolean parameters, command/query separation. Entirely generic; condense to 5 bullets.
- Lines 320 to 330: § 5.1 intent-not-implementation naming with a 9-line code block.
- Lines 347 to 361: § 5.3 boolean predicates with an 11-line code block; the rule is one line.
- Lines 375 to 425: § 6 Type Safety in full (51 lines, 3 code blocks). Parse-don't-validate, discriminated unions, derive types. Generic typed-language practice.
- Lines 428 to 481: § 7 Error Handling in full (54 lines, 3 code blocks including a 16-line "never swallow errors" demonstration).
- Lines 484 to 509: § 8 State Management in full. Also names specific libraries (TanStack Query, Zustand, SWR), which duplicates and risks drifting from `library-standards/javascript/react/prefer-avoid.md`, the actual source of truth for library choice.
- Lines 512 to 545: § 9 Dependencies and Coupling in full. Depend on abstractions, no cycles, wrap external deps, dependency count discipline.
- Lines 548 to 637: § 10 Testing Architecture in full (90 lines, 6 code blocks). Duplicates `testing-standards.md` (duplication register item 1). Highest single-section win; delete and cross-reference.
- Lines 639 to 664: § 11 Configuration. Fail-fast config loading with an 11-line example; § 11.3 secrets duplicates infrastructure § 3 and deployment § 4.
- Lines 667 to 704: § 12 Comments and Self-Documentation in full (38 lines). Comments explain why not what, no commented-out code.
- Lines 707 to 729: § 13 Performance by Default in full. Don't SELECT *, don't block the event loop, paginate, lazy-load, optimise assets. § 13.2 pagination duplicates api-design § 1.
- Lines 732 to 749: § 14 Security by Default in full. Duplicates infrastructure § 3, deployment § 4, api-design § 4 (duplication register item 2).
- Lines 771 to 793: § 15.2 to § 15.5 (typed props, accessibility, responsive, CSS discipline), generic frontend practice; § 15.5 also names Tailwind and shadcn/ui, duplicating react/prefer-avoid.md.
- Lines 810 to 814: three paragraphs restating in prose exactly what the § 16.1 table above them already states in three rows.
- Lines 816 to 856: § 16.2 to § 16.5 with three code blocks. Declarative routes, middleware ordering, consistent response shapes (duplicates api-design § 2 and § 3), structured logging (duplicates observability § 2).
- Line 863: the explicit-transactions rule is load-bearing but is delivered as a single 240-word paragraph inside a bullet list. Condense to the rule plus the two-clause why, roughly 4 lines, without weakening the "must" on multi-statement mutations.
- Lines 920 to 933: § 18 The Review Test, 8 self-assessment questions. Generic review heuristics; item 8 (can the agent regenerate this module from the spec) is the only Planifest-specific one. Condense to 3 lines or fold into § 17.
- Line 937: footer linking to six `pNNN-planifest-*.md` documents that do not exist anywhere in this repository. Stale reference, remove.
- Line 345: cross-reference to `p003-planifest-functional-decisions.md#fd-009`, another dead link. The instruction to use domain glossary terms is load-bearing; the link target is not.

### Load-bearing content confirmed present (do not touch)
- § 3.2 module size threshold table (lines 191 to 197): specific numeric thresholds for function, component, module, and test file size, with "investigate if" triggers. Non-obvious and project-calibrated.
- § 5.2 consistent vocabulary table (lines 336 to 344): the pick-one verb set find/create/update/delete/validate/transform. A project convention, not general knowledge.
- § 5.2 instruction to use Domain Glossary terms in code identifiers (line 345, minus the dead link).
- § 5.4 file naming conventions (lines 365 to 371): kebab-case default, the `.test.ts` / `.types.ts` / `.schema.ts` / `.config.ts` suffix set, and the explicit ban on `utils.ts` / `helpers.ts` / `misc.ts`.
- § 15.1 component decomposition table (lines 760 to 767): the Page / Feature / UI / Layout taxonomy.
- § 16.1 Handler to Service to Repository table (lines 804 to 808): the mandated backend layering.
- § 16.6 explicit transactions rule (line 863): "default to explicit transactions for all write operations" with the agent-incrementality rationale, plus "multi-statement mutations must be transactional, non-negotiable" and the ADR requirement for exceptions. This is a genuine non-obvious project WHY. Keep the rule and the reasoning; only compress the wording.
- § 17 Anti-Patterns for Agent-Generated Code (lines 868 to 916): targets specific known model failure modes (god component, copy-paste variation, catch-all error handling, stringly typed interfaces, over-abstraction, orphaned code, inconsistent patterns across features). Keep as a labelled list; the per-item explanatory paragraphs can shrink to one line each.
- § 1.4 "read existing patterns before generating new code" (line 78) and § 17.8's restatement: an operative instruction to the agent, not general advice. Keep once.

---

## planifest-framework/standards/commit-standards.md

**Current line count:** 71
**Recommended target:** 62 (13% reduction)

Low trim ceiling. `planifest-framework/hooks/commit-msg` cites this file by section number (`commit-standards.md §1`, `§3`, `§4` in its warning strings), so the section numbering and the substance of rules 1, 3 and 4 are hook-bound and must survive verbatim in meaning and position.

### Redundant sections (candidates for removal/condensation)
- Line 3: "Planifest commit standard, applies to all commits" preamble, restates the title.
- Lines 19 to 24: four worked examples where two suffice.
- Lines 30 to 36: rules 1 and 2 each have a heading plus an explanatory sentence restating the heading. Collapse each to a single line.
- Line 59: rule 5 (no contradictory messaging) is the only rule the hook does not check and overlaps rule 4's "objective and scope-focused". Candidate for merging into rule 4.
- Line 63: the parenthetical explaining that the subject line already states what, self-evident given the preceding clause.
- Line 71: install instruction. Belongs in setup documentation, not in the standard the hook enforces.

### Load-bearing content confirmed present (do not touch)
- The `type(scope): short description` format and the closed `type` set (lines 10, 13).
- Scope is feature ID or component ID (line 14).
- Rule 1: 72-character subject limit. Hook-enforced, cited as §1.
- Rule 2: imperative mood, present tense.
- Rule 3: the AI-attribution prohibition and its concrete pattern list. Hook-enforced, cited as §3. Also mirrored in CLAUDE.md and `templates/standard-boot.md`.
- Rule 4: the affirmatory-language prohibition and its concrete phrase list. Hook-enforced, cited as §4.
- Line 47: "the commit is owned by the human practitioner, the AI tool is an instrument". Non-obvious WHY behind rule 3, worth its two lines.
- Line 69: the hook exits 1 and blocks, ADR-008, `--no-verify` bypass.

---

## planifest-framework/standards/database-standards.md

**Current line count:** 60
**Recommended target:** 40 (33% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 3: "The data layer is the hardest part to change..." preamble.
- Lines 9 to 12: snake_case naming, every table has a primary key, define foreign key constraints, `created_at` / `updated_at`. Universal relational practice.
- Line 14: "create indexes for every foreign key and every column used in WHERE clauses", generic; "document index rationale" is the only instruction worth keeping.
- Lines 20 to 23: migrations go in files, forward-only, numbered sequentially, idempotent. Generic migration practice.
- Lines 43 to 47: § 4 query patterns. Parameterized queries, use the ORM, N+1 are defects (duplicates code-quality § 16.6), query timeouts. Condense to the timeout rule and the "document the rationale for raw SQL" rule.
- Lines 53 to 56: § 5 connection management in full. Pooling duplicates infrastructure § 6; retry with backoff and closing connections are generic.
- Line 60: footer boilerplate.

### Load-bearing content confirmed present (do not touch)
- Soft deletes via `deleted_at` unless the data contract requires hard deletes (line 13): a project default that overrides the common convention.
- The destructive-operations block (lines 25 to 28): migration proposal at `src/{component-id}/docs/migrations/proposed-{desc}.md`, human approval, backup plan. This is CLAUDE.md Hard Limits 3 and 4. Do not touch.
- § 3 Data Contracts in full (lines 34 to 37): the `src/{component-id}/docs/data-contract.md` path, contract-is-source-of-truth, ORM schema must match, changes require a migration proposal. Supports Hard Limit 5 (data owned by one component).

---

## planifest-framework/standards/deployment-standards.md

**Current line count:** 65
**Recommended target:** 34 (48% reduction)

No skill declares this file in `bundle_standards:`, and no skill body references it. It loads only on explicit read, so the practical context saving is small, but the redundancy is high.

### Redundant sections (candidates for removal/condensation)
- Line 3: "Deployment is the last mile between code and value..." preamble.
- Lines 11 to 15: the rolling / blue-green / canary table with "when to use" and "rollback speed". Textbook deployment-strategy knowledge.
- Lines 23 to 28: § 2 container standards. Multi-stage builds, minimal base images, non-root, healthcheck, no secrets in images, pin versions. Generic, and overlaps `build-target-standards.md` docker tier.
- Lines 36 to 43: the eight-step CI pipeline list. Generic pipeline shape; a model produces this ordering unprompted.
- Lines 49 to 51: config via environment variables, secrets in a secrets manager, per-environment config. Duplicates infrastructure § 3 and code-quality § 11.3.
- Lines 59 to 61: keep previous artifacts 7 days, backward-compatible migrations, document rollback procedures. The 7-day figure is a specific threshold; the other two are generic.
- Line 65: footer boilerplate.

### Load-bearing content confirmed present (do not touch)
- "Use the strategy declared in the operational model" (line 9): the pointer to the authoritative source.
- Feature flag naming format `FEATURE_{NAME}_ENABLED=true|false` (line 52).
- "Every deployment must be reversible within 5 minutes" (line 58) and the 7-day artifact retention (line 59): specific numeric thresholds.

---

## planifest-framework/standards/formatting-standards.md

**Current line count:** 114
**Recommended target:** 72 (37% reduction)

Bundled by 8 skills, so trims here compound. The date-format section is genuinely non-obvious and must survive intact.

### Redundant sections (candidates for removal/condensation)
- Lines 43 to 54: the British/American spelling examples table. Duplicates `language-quirks-en-gb.md` Categories 2 and 3 while line 55 already links there for "the full exception list". Keep the rule and the pointer, drop the table.
- Lines 57 to 67: § 2 code identifier exception, including a 7-row table. Duplicates `language-quirks-en-gb.md` Category 1. Reduce to one sentence plus the pointer.
- Lines 69 to 73: "Current language support". Roadmap prose about planned multilingual support and a future `planifest-overrides/` mechanism. Not a rule, and describes something that does not exist.
- Lines 89 to 107: three verbose/brief example pairs (19 lines) illustrating response verbosity. One pair conveys the rule; two of the three examples are the same lesson restated.
- Line 21: the sentence spelling out that the day is zero-padded, the month is a three-letter capitalised abbreviation, and the year is four digits. The table at 15 to 19 already shows this.
- Line 3: "They are not suggestions" preamble.

### Load-bearing content confirmed present (do not touch)
- The three-way date convention: DD MMM YYYY in body text, YYYY-MM-DD as filename prefix, YYYY-MM-DD in frontmatter and JSON (lines 11 to 31). Genuinely non-obvious, and the split by context is the whole rule.
- The explicit forbidden-format list including ISO 8601 in body text (line 35). Counter-intuitive enough that stating it prevents drift.
- British English default (line 41) and the five American exceptions named inline at line 55 (`artifact`, `initialize`, `serialize`, `disk`, `program`), with the pointer to language-quirks for the full list.
- § 3 Response Verbosity rules 1 to 5 (lines 83 to 87): brevity default, explain only non-obvious why, do not narrate, no affirmatory padding, the human can ask for more. Referenced by name from `planifest-migrator/SKILL.md` line 104.
- "When explanation is appropriate" list (lines 111 to 114): the four exceptions that keep the brevity rule from suppressing necessary output.

---

## planifest-framework/standards/infrastructure-standards.md

**Current line count:** 67
**Recommended target:** 40 (40% reduction)

Not declared in any skill's `bundle_standards:`. Loads on explicit read only.

### Redundant sections (candidates for removal/condensation)
- Line 3: "Infrastructure is code. It is versioned, reviewed, tested..." preamble.
- Lines 18 to 22: the dev/staging/production table (purpose, data, access). Universally understood.
- Lines 31 to 36: § 3 security defaults. Least privilege, no public access, encryption at rest and in transit, no default credentials, audit logging. Generic cloud baseline, and duplicated in deployment § 4 and code-quality § 14.4.
- Lines 42 to 45: § 4 networking. Private subnets for compute, public only for load balancers, no `0.0.0.0/0`. Generic.
- Lines 52 to 54: health checks, resource limits, auto-scaling. Generic; only "auto-scaling based on metrics identified in the SLO definitions" carries a project pointer.
- Lines 60 to 63: § 6 data stores. Backups, PITR, connection pooling (duplicates database-standards § 5), read replicas.
- Line 67: footer boilerplate.

### Load-bearing content confirmed present (do not touch)
- IaC file location `src/{component-id}/infra/` or a dedicated infrastructure component (line 11).
- "Use the IaC tool declared in the stack" and "use the compute model declared in the stack" (lines 10, 51): pointers to the confirmed design as authority.
- "Environment-specific values use variables/parameters, never conditional logic in IaC" (line 24): a specific prohibition, not a generic default.
- "Production infrastructure changes require human approval" (line 25): human-on-the-loop gate.

---

## planifest-framework/standards/language-quirks-en-gb.md

**Current line count:** 93
**Recommended target:** 72 (23% reduction)

Almost entirely load-bearing. The exception lists are the file's reason to exist and cannot be inferred. Only presentational padding is trimmable. Bundled by `planifest-optimise-agent`.

### Redundant sections (candidates for removal/condensation)
- Line 8: preamble restating that the framework default is British English, which `formatting-standards.md` § 2 already establishes and which the filename states.
- Lines 14 to 22: Category 1's seven-bullet enumeration of what counts as code (fenced blocks, inline spans, paths, URLs, identifiers, endpoint strings, config keys, CLI flags). Two lines suffice: "code and identifiers are never spelling-corrected" plus the boundary cases.
- Lines 42, 59, 69: three separate sentences re-explaining that Category 1 applies to code identifiers. State the Category 1 precedence once at the top.
- Lines 77 to 80: four ✓/✗ examples for `data`/`metadata` uncountability. The rule is one line; one example pair is enough.
- Lines 88 to 91: four ✓/✗ examples for the em dash prohibition. Reduce to one.
- Line 93: "in code em dashes are not corrected if they appear as literal string content", covered by the Category 1 precedence statement.

### Load-bearing content confirmed present (do not touch)
- Category 2 American-spelling exception table (lines 30 to 36): `artifact`, `initialize`, `serialize`, `disk`, `program`, each with its reason. Not derivable.
- Category 3 code-versus-prose split for `color`/`colour`, `center`/`centre`, `fiber`/`fibre` (lines 44 to 48).
- Category 4 `licence` (noun) versus `license` (verb) (lines 56 to 57).
- Category 5 always-uppercase acronym list (line 67).
- Category 6 `data` and `metadata` are uncountable (line 75).
- Category 7 em dash prohibition (line 86) including the stated why (no meaning a colon or comma cannot carry, and strong association with AI-generated text). This is an active house rule applied to every artifact the framework produces.

---

## planifest-framework/standards/monorepo-standards.md

**Current line count:** 63
**Recommended target:** 45 (29% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 3: "When multiple components live in the same repository, clear boundaries prevent coupling" preamble.
- Lines 21 to 23: the inline annotations on the `shared/` subtree (`types/ - shared type definitions`, etc.), self-evident from the directory names.
- Line 33: workspace tools bullet naming npm/pnpm/Go workspaces, generic tooling knowledge.
- Lines 39 to 42: § 3 build and test isolation in full. Independent builds, independent tests, CI runs affected component only, full run on shared change. Generic monorepo practice.
- Lines 49 to 51: API contracts in OpenAPI (duplicates api-design § 5), event contracts in schemas, one-owner-exposes-an-API (restates line 48 and Hard Limit 5).
- Lines 58 to 59: semver for shared packages, update all consumers in the same PR. Generic.
- Line 63: footer boilerplate.

### Load-bearing content confirmed present (do not touch)
- The `src/{component}/` directory tree (lines 9 to 24) showing `component.yml`, `src/`, `tests/`, `docs/` per component. This is the layout `gate-write.mjs` matches against and that CLAUDE.md Hard Limit 2 assumes.
- "Components never import from each other's `src/` directory" (line 30).
- "Shared code must be genuinely shared, used by 2+ components. Do not preemptively create shared modules" (line 31): a specific numeric threshold and an explicit anti-anticipation rule.
- Per-component dependency manifests with independently varying versions (line 32).
- "Data ownership is per-component, one component, one database/schema" (line 48): CLAUDE.md Hard Limit 5.
- Each component versions itself in `component.yml` (line 57).

---

## planifest-framework/standards/observability-standards.md

**Current line count:** 72
**Recommended target:** 50 (31% reduction)

Declared in `planifest-orchestrator`'s `bundle_standards:` and cross-referenced from its P1 question list (SKILL.md line 301), so the file is genuinely reached.

### Redundant sections (candidates for removal/condensation)
- Line 3: "If you can't observe it, you can't operate it" preamble.
- Lines 11 to 15: the three-pillars table with tool examples (Pino, Winston, zerolog, slog, Prometheus, Jaeger). The pillars are universally known; the tool lists duplicate and risk drifting from `library-standards/*/prefer-avoid.md`, which is the actual authority on library choice.
- Line 23: the log-level definitions (`error` means action required, `warn` means degraded, etc.). Generic.
- Lines 46 to 49: § 4 tracing. Use OpenTelemetry, propagate context, span the obvious operations. Generic, though the specific attribute list at line 49 is mildly conventional.
- Line 62: readiness checks verify database, cache, downstream health. Generic elaboration of "can it serve traffic?".
- Line 72: footer boilerplate.

### Load-bearing content confirmed present (do not touch)
- Required log fields `timestamp`, `level`, `message`, `service`, `requestId` (line 22): a specific field set, not a generic gesture at structured logging.
- The "never log" list, credentials, PII, full bodies, stack traces at info level (line 24), and the "always log" list (line 25).
- The required metrics table (lines 35 to 38): the exact metric names `http_requests_total`, `http_request_duration_seconds`, `http_requests_in_flight`, `errors_total` with their types. Names are a contract.
- The `/health` versus `/ready` split with expected status codes (lines 59 to 60).
- § 6 alerting ownership boundary (line 68): the codegen-agent emits metrics, the human configures thresholds and channels. A responsibility split an agent would otherwise get wrong.

---

## planifest-framework/standards/stack-summary.md

**Current line count:** 34
**Recommended target:** no meaningful reduction available

Two ranked tables, a five-line decision guide, and two links. Every line carries data (rank, suitability, first-pass rate, typical iterations) that cannot be inferred and is not duplicated elsewhere in the loaded set. The file already does exactly what a summary should: it holds the compact form so the 3022-line `reference/` evaluations stay unloaded. Bundled by orchestrator and codegen-agent.

### Redundant sections (candidates for removal/condensation)
- None. Line 3 is a genuine routing instruction (where the full evaluations live), not a preamble.

### Load-bearing content confirmed present (do not touch)
- Backend and frontend tier ranking tables with first-pass rates and iteration counts (lines 7 to 24).
- The five-line key decision guide (lines 28 to 32).
- The pointers to `reference/backend-stack-evaluation.md` and `reference/frontend-stack-evaluation.md` (lines 3, 34). These are what keep the excluded files excluded.

---

## planifest-framework/standards/telemetry-standards.md

**Current line count:** 102
**Recommended target:** 85 (17% reduction)

The single most-loaded standards file: 16 of 18 skills declare it in `bundle_standards:`, and 10 skill bodies reference it by name. Trims here have the widest reach but the least headroom, because almost every line encodes hook behaviour or an ADR-backed rule.

### Redundant sections (candidates for removal/condensation)
- Line 18: the historical account of the pre-0000018 `--context-mode-mcp` coupling and why it was wrong. This is changelog content. The rule is line 13; the history belongs in ADR-001, which line 11 already cites. Removing it costs nothing and saves the longest paragraph in the file.
- Lines 48 to 51: the "Emission Gate (Tool Availability, Agent-Driven Only)" section restates line 20 and the agent-driven half of line 36. Fold into the "Failure Detection" section as a clause.
- Line 20: partially overlaps lines 13 and 50 on the same two-condition point. One statement of the two conditions suffices.
- Line 34: the parenthetical explaining that the marker write is itself best-effort and never causes the hook to throw is a correct and necessary rule, but the surrounding sentence restates the hook-never-blocks principle already given in the same line's first clause.
- Line 26: "When the unified signal is genuinely absent... pipeline proceeds exactly as if telemetry didn't exist" is restated at line 44's `confirmed-disabled` definition and again in the emission-gate paragraph pasted into every skill.

### Load-bearing content confirmed present (do not touch)
- The unified signal definition: `--structured-telemetry-mcp` alone writes the sentinel and wires the hooks (lines 13 to 17). ADR-001.
- "Emission is mandatory when enabled, failure is never silent" (line 24). ADR-002.
- The two failure paths and their different handling: hooks write a durable marker and stay exit-zero, agents stop and ask inline (lines 34, 36). The orchestrator checks `plan/.telemetry-failures/` at every phase start (SKILL.md line 1136 depends on this).
- The exact block-or-proceed question wording and the once-per-root-cause-per-run rule (line 38).
- The `Telemetry` build-log field and its three permitted values `emitted`, `failed-with-recorded-choice`, `confirmed-disabled` (line 44).
- `phase_start` and `phase_end` are orchestrator-owned; phase skills must not emit them (line 56).
- The event envelope JSON with all ten fields (lines 64 to 77) and the note that per-skill snippets show `data` only (line 79).
- Loop and reversal event payloads with their enumerated `loop_id` values (lines 87 to 100), consumed by `planifest-loop-runner` and P8 build assessment.

---

## planifest-framework/standards/testing-standards.md

**Current line count:** 117
**Recommended target:** 78 (33% reduction)

Bundled by codegen-agent, validate-agent, and verify-by-execution. The requirement-traceability rule is the file's irreplaceable content.

### Redundant sections (candidates for removal/condensation)
- Line 3: "Tests are the requirements' executable counterpart..." preamble.
- Lines 7 to 9: "Why This Matters for Agent-Generated Code", justifying the document's existence.
- Lines 44 to 48: the Arrange/Act/Assert comments inside the traceability example. The example exists to show the requirement ID in the suite name; the AAA comments are separate, generic, and duplicated in code-quality § 10.3.
- Lines 53 to 56: the four rules under Agentic TDD (behavioural test names, one assertion concept, no shared state, no interdependence). All four restate code-quality § 10.4 to § 10.6.
- Lines 62 to 72: § 3 What to Test / Never Test. Happy path, error cases, boundaries, state transitions; don't test framework internals or third-party libraries. Generic testing knowledge.
- Lines 78 to 82: § 4 Test Data. Factories over literals, minimal data, no production data, no hardcoded dates, clean up. Duplicates code-quality § 10.6.
- Lines 88 to 90: § 5 Mocking. Mock at the boundary, integration tests use real dependencies. Generic; only the contract-test clause (line 90) states a specific obligation.
- Lines 96 to 99: § 6 Flakiness Policy. A flaky test is worse than no test, fix or delete, avoid time-dependence and shared state. Generic.
- Line 23: the E2E aside about the orchestrator possibly requesting E2E tests in Phase 3, hedged to the point of carrying no instruction.
- Line 117: footer boilerplate.

### Load-bearing content confirmed present (do not touch)
- The test pyramid table (lines 17 to 21) with required coverage per level: every exported pure function, every endpoint and query, every consumed interface. These are obligations, not descriptions.
- § 2 Agentic TDD loop, the five ordered steps (lines 32 to 36). This is the contract that `planifest-test-writer` (RED) and `planifest-implementer` (GREEN) implement.
- The requirement-traceability rule (line 39): the requirement ID must appear in the test description or suite name, and the `plan/current/requirements/req-*.md` source path. Uniquely Planifest; nothing else in the framework enforces it.
- The `req-001-auth: user login flow` example naming pattern (line 43), minus the generic AAA comments.
- § 7 coverage thresholds table (lines 107 to 111): 80/90 line, 70/85 branch, 100/100 critical path, plus the definition of "critical path" as the acceptance-criteria flows (line 113).
- "Coverage is a proxy, not a target" (line 105): a non-obvious framing that prevents an agent gaming the numbers.

---

## planifest-framework/standards/library-standards/_version-policy.md

**Current line count:** 39
**Recommended target:** 33 (15% reduction)

Bundled by orchestrator, codegen-agent, and validate-agent, and cited by path from `planifest-codegen-agent/SKILL.md` line 104.

### Redundant sections (candidates for removal/condensation)
- Line 3: the enumeration of nine manifest filenames. "Any dependency manifest" carries the same instruction.
- Lines 24 to 26: Rule 3 (read the changelog before a major bump). Generic practice; only the "record the review in `quirks.md`" clause is project-specific.
- Lines 28 to 30: Rule 4 (peer dependency satisfaction). Generic, though "mismatched peers are a CI failure, not a warning" is a stance worth one line.
- Line 22: the lockfile-versus-manifest explanation. One clause, not two sentences.

### Load-bearing content confirmed present (do not touch)
- Rule 1: target latest stable, do not pin to an old major unless the constraint is documented in `quirks.md`.
- Rule 2 and its four-ecosystem table: exact or tilde pinning, explicit rejection of `^`, `latest`, `*`, and unbounded `>=` ranges. This contradicts the npm ecosystem default, so it must be stated.
- Rule 5 avoid-list exception: record in `src/{component-id}/docs/quirks.md` with the library and version, why no alternative exists, and the re-evaluation trigger. "Do not silently use an avoided library" backs the validate-agent's library audit (SKILL.md step 0).

---

## planifest-framework/standards/library-standards/{lang}/prefer-avoid.md and test-frameworks.md, populated files

**Files in group (13):** `databases/prefer-avoid.md` (120), `typescript/prefer-avoid.md` (61), `typescript/test-frameworks.md` (22), `javascript/nodejs/prefer-avoid.md` (58), `javascript/nodejs/test-frameworks.md` (18), `javascript/react/prefer-avoid.md` (39), `javascript/react/test-frameworks.md` (19), `python/prefer-avoid.md` (51), `python/test-frameworks.md` (28), `go/prefer-avoid.md` (51), `go/test-frameworks.md` (19), `java/prefer-avoid.md` (49), `java/test-frameworks.md` (19)

**Treatment:** full. All 13 read in full.

**Current line count:** 554
**Recommended target:** 465 (16% reduction)

These files are the densest, best-targeted content in the standards tree. They are near-pure data: a library choice per concern, which is exactly the kind of opinionated, time-sensitive judgement a model should not be left to guess. Only one library file loads at a time (per the component's declared language), so per-file size matters less than elsewhere. The recommended trim is modest and mechanical.

### Redundant sections (candidates for removal/condensation)
- **Self-evident `Reason` cells across all files.** Roughly a third of the reason column restates the verdict or states a fact any current model holds: "TSLint is deprecated" (typescript/prefer-avoid line 43), "Prettier is the de facto standard" (line 44), "Official driver" (databases lines 46, 72 to 74, 95 to 97), "boto3 is the standard" (databases line 61), "v2 is modular" (databases line 62), "go-sql-driver is the standard" (databases line 26), "Alembic is the SQLAlchemy standard" (python line 32), "validator is the de facto standard" (go line 32), "Consumer-driven contract testing" (repeated verbatim in the Notes column of typescript, python, go, java and nodejs test-frameworks). Leave the cell empty where the Prefer/Avoid pair is self-explanatory; keep it where it encodes a real trade-off ("Pydantic v2 is rewritten in Rust, 5 to 50x faster", "H2 dialect differences cause false passes", "gorm's magic causes subtle bugs", "CRA unmaintained since 2023"). Saves roughly 0 lines directly but is a prerequisite for the table merges below.
- **Single-row sections with their own H2 heading.** `typescript/prefer-avoid.md` has 8 headings over 6 tables, several covering one or two rows (Logging, 1 row over 5 lines of scaffolding; HTTP Client, 1 row over 5 lines). Same shape in `python/prefer-avoid.md` (HTTP Client, CLI), `go/prefer-avoid.md` (HTTP Client, Validation, Logging, Configuration), `java/prefer-avoid.md` (Validation, Serialisation, Logging, Build), `javascript/nodejs/prefer-avoid.md` (Validation, Logging, Environment, Queues). Each single-row section costs 5 lines of heading plus table header to deliver 1 line of data. Merging same-shape tables under one heading with the concern column doing the grouping saves 4 lines per merged section, roughly 60 lines across the six files.
- **`databases/prefer-avoid.md`** (120 lines) carries 10 separate H3 sections each with its own 3-line table header for 2 to 5 rows. Same merge opportunity, roughly 25 lines. The Firestore, Neo4j and Time-Series tables have Avoid columns that are entirely empty or "Official driver", so those sections collapse to one row each.
- **Duplicated pointer preambles.** Every file opens with 2 to 4 blockquote lines repeating the `_version-policy.md` pointer, the `planifest-overrides/library-standards/{path}` precedence rule, and, in test-frameworks files, the `testing-standards.md` pointer. The override precedence rule is already specified operationally in `planifest-codegen-agent/SKILL.md` lines 100 to 104 and `planifest-validate-agent/SKILL.md` line 43, which is where the agent actually reads it. Reduce each file's preamble to one line. Saves roughly 15 lines across 13 files.
- **`javascript/nodejs/prefer-avoid.md` line 33** defers to typescript standards for validation but restates the whole row anyway. Keep the deferral, drop the row.
- **`typescript/prefer-avoid.md` line 11 and 12** both resolve to zod; the form-validation row adds only the `react-hook-form` pairing, which is also stated in `javascript/react/prefer-avoid.md` line 14. Cross-file duplication.

### Load-bearing content confirmed present (do not touch)
- Every Prefer and Avoid verdict. These are opinionated, versioned, and time-sensitive (`pydantic` v2 not v1, `pgx` v5, `redis` v5, AWS SDK v3 not v2, `react-router` v7, `tailwind` v4, `mongo-driver` v2, Spring Boot 3.x). A model left to choose would produce defensible but different and inconsistent answers.
- The explicitly archived, deprecated, or unmaintained callouts: `gorilla/mux` archived, `reach/router` archived, Create React App unmaintained since 2023, `bull` deprecated, `request` deprecated, `mysql` deprecated, `py2neo` unmaintained, `aioredis` merged into redis-py, `enzyme` deprecated.
- The Patterns tables that state hard prohibitions rather than preferences: `javascript/react/prefer-avoid.md` lines 36 to 39 (no class components, no `useEffect` for data fetching, no prop drilling beyond 2 levels, no `any`); `go/prefer-avoid.md` lines 50 to 51 (`errgroup` for concurrent goroutines, never fire-and-forget; always pass `context`).
- `typescript/prefer-avoid.md` TypeScript Config table (lines 56 to 61): `strict` must be true, enable `noUncheckedIndexedAccess`, enable `exactOptionalPropertyTypes`, never `any`. Specific compiler settings with a stated threshold for each.
- The `quirks.md` escape hatches: "if the project predates Vitest and Jest is deeply integrated, jest is acceptable, record in `quirks.md`" (typescript/test-frameworks line 21) and the equivalent "record choice in ADR" clauses (go line 12, nodejs line 13).
- Testing notes that state non-obvious mechanics: `pytest-asyncio` required for async FastAPI tests, do not mock `httpx` at module level (use `respx`), `testcontainers` over mocked DB and over H2, `@DynamicPropertySource` for Java DB tests, `msw` at the network layer not module level, no snapshot tests for component HTML.
- The `databases/prefer-avoid.md` per-language matrix structure itself. It is the only place the framework maps a database paradigm to a client per language, and codegen-agent is directed to it explicitly (`SKILL.md` line 102).

---

## planifest-framework/standards/library-standards/{lang}/prefer-avoid.md and test-frameworks.md, TODO stubs

**Files in group (30):** `c`, `cpp`, `csharp`, `dart`, `elixir`, `fsharp`, `haskell`, `kotlin`, `php`, `r`, `ruby`, `rust`, `scala`, `shell`, `swift`, each with both `prefer-avoid.md` and `test-frameworks.md`.

**Treatment:** 3 read in full (`c/prefer-avoid.md`, `c/test-frameworks.md`, `rust/prefer-avoid.md`); 27 light pass. The light pass confirmed via content match that all 30 files use the identical `TODO: populate` template with only the language name and the two file paths substituted. Nothing surprising was found, so a single proportional recommendation covers the whole set rather than 30 separate entries.

**Current line count:** 210 (30 files x 7 lines)
**Recommended target:** 120 (30 files x 4 lines, 43% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 5 of every file: the second blockquote paragraph explaining that content can be added either framework-wide or via `planifest-overrides/library-standards/{lang}/{file}.md`. The override precedence mechanism is already specified in `planifest-codegen-agent/SKILL.md` lines 100 to 104 and `planifest-validate-agent/SKILL.md` line 43, which is where an agent encounters it in the flow that matters. Restating it 30 times in files whose entire purpose is to say "nothing here yet" is the definition of redundancy.
- Line 7 of every file: the `_version-policy.md` / `testing-standards.md` pointer. Both files are already declared in `bundle_standards:` for the agents that reach these stubs, so the pointer resolves to something already in context.
- Blank separator lines 4 and 6.
- Suggested shape, 4 lines: title, blank, the `TODO: populate` line, and the override path. This keeps the stub detectable, which matters because `planifest-validate-agent/SKILL.md` line 43 instructs the agent to "skip if the language subdir is a stub".

### Load-bearing content confirmed present (do not touch)
- The `TODO: populate` marker string itself. The validate-agent's stub detection depends on the file being recognisable as unpopulated.
- The per-language override path, retained so an agent that lands on a stub knows where to look next.
- The files' existence. Deleting empty stubs would change the codegen-agent's fallback lookup from "found a stub, skip" to "path missing", which is a behavioural change outside the remit of a content trim.

### Note on leverage
Only one language's pair loads in any given run, so the real-world context saving is roughly 6 lines per pipeline. The reduction is genuine and harmless but should be ranked last for implementation effort.

---

## Excluded from trim recommendations

Audited for size only. Both are in `planifest-framework/standards/reference/`, which `.cursorindexingignore` removes from the default semantic index; they are reachable only by explicit `@`-mention. Trimming them would not reduce what any agent loads by default.

| File | Lines | Status |
|---|---:|---|
| planifest-framework/standards/reference/backend-stack-evaluation.md | 1987 | no action, already excluded from default context loading |
| planifest-framework/standards/reference/frontend-stack-evaluation.md | 1035 | no action, already excluded from default context loading |

`stack-summary.md` (34 lines) is the always-available compact substitute for both, and its links at lines 3 and 34 are the intended access route. Preserving those links is what keeps 3022 lines out of default context.
