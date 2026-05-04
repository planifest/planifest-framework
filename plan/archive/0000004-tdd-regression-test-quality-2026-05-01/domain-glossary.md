---
title: "Domain Glossary - 0000004-tdd-regression-test-quality"
status: "active"
version: "0.1.0"
---
# Domain Glossary - 0000004-tdd-regression-test-quality

**Feature:** 0000004-tdd-regression-test-quality

> Ubiquitous language for this feature. All agents and humans use these terms consistently. Terms are additive — prior-feature terms carry forward.

---

## Terms

### RED phase
The first phase of the TDD sub-loop. A single failing test is written and confirmed to exit non-zero before any implementation code is written. A test that passes before implementation is not RED — it is invalid.

### GREEN phase
The second phase of the TDD sub-loop. The minimum implementation code required to make the failing test pass is written. The test is confirmed to exit zero. No additional code is written beyond what is needed to pass.

### REFACTOR phase
The third phase of the TDD sub-loop. Code quality is improved — readability, structure, naming, duplication — while all tests remain passing. No new behaviour is introduced during this phase.

### TDD inner loop / TDD sub-loop
The per-requirement sequence of RED → GREEN → REFACTOR, orchestrated by the codegen-agent. One sub-loop runs per functional requirement. Synonym: red-green-refactor loop.

### sub-agent
An agent invoked by the codegen-agent (the orchestrator) to perform a single, narrow phase of the TDD loop. The three TDD sub-agents are: `planifest-test-writer`, `planifest-implementer`, `planifest-refactor`. Sub-agents use a cheaper model tier than the orchestrator.

### recommended_model
A YAML frontmatter field in a skill's SKILL.md that signals the preferred model tier for that skill. Convention, not hard enforcement. Value is typically `haiku` for narrow sub-agent skills.

### regression pack
The long-term, curated set of tests in `planifest-framework/tests/regression/`. Unlike feature-specific tests (which are archived with their feature), regression pack tests survive P7 archive operations and run on every P4 validation.

### regression candidate
A test produced during P3 codegen that the agent identifies as a good candidate for promotion to the regression pack. Candidates are presented to the human at P7 Step R for confirmation.

### promotion (regression)
The act of copying a test from a feature's test suite into the regression pack and recording the event in `regression-manifest.json`. Performed by `promote-to-regression.sh`. Can be initiated by the ship-agent (on human confirmation) or by a human directly.

### regression-manifest.json
The JSON file at `planifest-framework/tests/regression/regression-manifest.json` that tracks all promoted regression tests with their provenance (source feature, promotion date, promoted by).

### test report
A Markdown artefact generated at P7 ship time, written to `plan/changelog/{feature-id}-test-report-{YYYY-MM-DD}.md`. Covers all tests run in P4, full regression pack state, and newly promoted tests. Consumed by human reviewers.

### Step R (ship-agent)
The regression confirmation step added to the ship-agent. Runs before the archive step. Presents regression candidates to the human and triggers promotion for confirmed candidates.

### Step T (ship-agent)
The test report generation step added to the ship-agent. Runs after Step R and before the archive step. Generates the test report artefact using the test-report template.

### idempotent (promotion)
A property of `promote-to-regression.sh`: running it twice with the same arguments produces the same result as running it once. No duplicate manifest entries, no duplicate files.

### stack capability skill
An optional skill (e.g. `webapp-testing`) that encodes craft knowledge for a specific technology stack. Loaded alongside a TDD sub-agent when available. Provides test patterns, framework-specific guidance. Not required for the TDD loop to function.
