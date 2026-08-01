---
title: "Build Report — 0000020-setup-refresh-skill — 01 Aug 2026"
date: "2026-08-01"
feature_id: "0000020-setup-refresh-skill"
---

# Build Report — 0000020-setup-refresh-skill — 01 Aug 2026

## Model Usage

| Model tier | Concrete model | Phases used | Agent call count |
|------------|----------------|-------------|------------------|
| Primary    | claude-sonnet-4-6 | P0, P1, P2, P3, P4, P5, P6, P7 | 8 |
| Cheaper    | claude-haiku-4-5 | P8 | 1 |

---

## Skills Invoked

| Phase | Skill | Load pattern |
|-------|-------|--------------|
| P0 | planifest-orchestrator | Session start |
| P0 | planifest-scope-lock-agent | Subagent, dispatched x4 sequentially per contract |
| P1 | planifest-spec-agent | JIT |
| P2 | planifest-adr-agent | JIT |
| P3 | planifest-codegen-agent | JIT |
| P4 | planifest-validate-agent | JIT |
| P5 | planifest-security-agent | JIT |
| P6 | planifest-docs-agent | JIT |
| P7 | planifest-ship-agent | JIT |
| P8 | planifest-build-assessment-agent | JIT (this agent) |

---

## Subagent Dispatch

| Phase | Agent type | Count | Purpose |
|-------|-----------|-------|---------|
| P0 | planifest-scope-lock-agent | 4 | Scope Lock drafting: one per backlog item (happy path, first-run path, error/sad path, cross-session continuity) |
| P8 | planifest-build-assessment-agent | 1 | Build efficiency assessment (this report) |

**Total agents spawned:** 5

---

## MCP Tool Usage

| Tool | Call count | Phase(s) | Purpose |
|------|-----------|----------|---------|
| (deviation event) | 1 | P3 | Emitted: design.md component paths incorrectly listed .claude/skills/; corrected in-run |
| (security_finding) | 2 | P5 | Emitted: (1) deletion allowlist enforcement, (2) .planifest-setup-flags gitignore for copilot/opencode |

**Total MCP calls:** 3 (deviation and finding events only; no context-mode tools, no web fetch/search)

---

## Parallel Task Bursts

| Phase | Batch count | Tasks parallelised |
|-------|------------|-------------------|
| (none recorded) | — | — |

**Phases with no parallelism:** P0, P1, P2, P3, P4, P5, P6, P7, P8

---

## Self-Corrections

| Phase | Count | Summary |
|-------|-------|---------|
| P4 | 1 | Structural test assertions (3 failures): literal-substring mismatches against markdown bold syntax and incorrect assumption about assert_contains function behavior (treated as regex when it performs plain substring matching). Fixed needle text, reran, all 34 passed. |

**Total self-corrections:** 1

---

## Artifact Counts

| Category | Count |
|----------|-------|
| Requirements | 10 |
| ADRs | 5 |
| Executable tests (bash/sh) | 2 suites (21 live assertions + 34 structural assertions = 55 total) |
| Documentation artifacts updated | 7 (component-registry, dependency-graph, architecture-overview, decisions-index, purpose, interface-contract, scope, risk, test-coverage, data-contract, quirks) |
| New skill | 1 (planifest-refresh-setup SKILL.md) |
| New scripts | 2 (refresh-delete-boot-files.sh/.ps1) |

---

## Efficiency Observations

### Model Routing

**Finding: Defensive primary-tier allocation; cheaper tier underutilised.**

- **Primary tier usage (P0–P7):** All design, implementation, and validation work used the primary model (claude-sonnet-4-6). This is defensible for P2 (ADRs, architectural decisions require deep analysis), P3 (code generation with security implications), and P5 (security review). However, the following phases were primary-tier candidates for cheaper-tier delegation:
  - **P1 (Spec):** Generated 10 independent requirement documents, operational/SLO/cost-model artifacts, and data contracts. Requirement writing is structured template filling; SLO/cost-model artifacts were marked "not applicable" (CLI tool, no service surface). Cheaper tier could have handled requirement document production, leaving primary for complexity assessment and cross-cutting decisions.
  - **P4 (Validate):** Ran structural test assertions and bash syntax checks; this is mechanical validation (substring matching, exit-code checks). No logical ambiguity requiring inference or domain reasoning. Cheaper tier was appropriate here and was not used.
  - **P6 (Docs):** Consolidated existing component knowledge, updated living docs, and produced recommendations. This is knowledge synthesis and transcription, not novel analysis. Primary tier was defensible but not essential.
- **Cheaper tier usage (P8 only):** Correctly reserved for this assessment agent, which performs post-hoc analysis of build-log data (no design decisions, no new requirements discovery).
- **Verdict:** Primary tier was over-allocated by 1–2 phases. Expected model routing for a future feature of similar scope: P0–3, P5, P7 primary; P1 (spec template filling), P4 (validate), P6 (docs sync) cheaper. The decision to run full primary is defensible for a feature introducing new framework patterns (setup refresh, hook wiring), but should not be the default for routine features.

### Parallelism

**Finding: Significant parallelism gaps across all phases; contradictory logging on P2.**

- **P1 (Spec):** Produced 11 independent artifacts (execution-plan.md, 10 requirements, scope.md, risk-register.md, domain-glossary.md, operational-model.md, SLO-definitions.md, cost-model.md, and data-contract.md). Build log records "Parallel task batches | 0". These artifacts have no dependencies; they must be written in a single parallel Write batch. **Gap evidenced.**
- **P2 (ADRs):** Build log records "Parallel task batches | 0", but notes text states "All written in a single parallel batch, no cross-references requiring sequential drafting." This is a **contradiction**: either 1 parallel batch was used (notes correct, log missing), or 0 batches were used (log correct, notes inaccurate). The discrepancy reduces build-log accountability; the true state is unclear from the record.
- **P3 (Codegen):** Generated setup.sh/setup.ps1 (multi-stage script), test suite, SKILL.md, and component updates. No parallelism recorded despite multiple independent file writes (setup.sh and setup.ps1 are independent; SKILL.md is independent). **Gap evidenced.**
- **P4 (Validate):** Ran two independent test suites (test-0000020-req-008 with bash invocation, test-0000020-req-001-010 with bash invocation) and a syntax check on setup.ps1. These are independent executables; bash test runs must be parallelised. "Parallel task batches | 0" indicates sequential execution. **Gap evidenced.**
- **P6 (Docs):** Updated 7+ component and living-docs artifacts (component-registry, dependency-graph, architecture-overview, decisions-index, src/setup-hook-integration/docs/* updates). No parallelism recorded. These are independent artifact writes. **Gap evidenced.**
- **Verdict:** Parallelism was not applied or not recorded in P1, P3, P4, P6. P0's scope-lock agent correctly ran sequentially per its dispatch contract (one item at a time). P2's logging is contradictory and must be clarified in a future audit. Expected improvement: batch all independent Write calls within each phase into a single parallel call; batch all independent Agent calls within a phase (e.g., running multiple agents in parallel where dependency order permits). This pipeline had multiple opportunities to reduce wall-clock time and did not take them.

### Phase Gate Audit

**Finding: No violations; continuous-run pre-authorisation was explicit at P0.**

- **Phase gates P1→P7:** All recorded as "Continuous run mode, proceeding without phase-gate stop per P0 authorization." Corroboration from P0 notes: "Run mode: continuous. Design confirmed 01 Aug 2026 @ 12:07 AM BST." Pre-authorisation is documented.
- **Phase gate P7→P8/P9:** The log explicitly notes "Continuous run mode does not bypass this gate (Hard Limit); presenting full P7/P8/P9 outcome to human before considering shipped." P7 was not skipped; it has a recorded start time (2026-08-01T01:10:00Z) and notes explaining the gate was honoured.
- **Verdict:** No process violations. Human authorization for continuous run was obtained at P0 and was not exceeded. P7's mandatory human gate before P8/P9 was respected (this report is being produced by P8, which is executing as designed).

### Self-Correction Audit

**Finding: 1 self-correction; avoidable with better initial test-framework understanding.**

- **P4, cycle 1:** Test author wrote assertions that failed because:
  1. Markdown bold syntax (e.g., `**text**`) was not matched by needle text using `\*\*` escaping (literal-string assumption error).
  2. Incorrect assumption that `assert_contains` uses regex pattern matching when it performs plain substring matching (no regex support).
  - These errors stem from insufficient review of the test framework's documented behavior. The test framework is established (used in prior feature suites); better initial spec reading would have prevented both failures.
  - **Avoidability:** High. The error was not due to spec ambiguity or a misunderstanding of requirements — it was a misunderstanding of available tools. A single pre-write pass of test-framework documentation would have eliminated both failures.
- **Total self-corrections:** 1 (low for a multi-phase pipeline). The count is healthy; the one correction was avoidable.

### Build Log Integrity

**Finding: Good completeness, one contradictory entry (P2 parallelism), no critical gaps.**

- **Phase coverage:** All 8 phases (P0–P8) are represented with start times and per-phase fields.
- **Per-phase fields populated:**
  - Model tier: ✓ all phases
  - Skills loaded: ✓ all phases
  - Agents spawned: ✓ all phases
  - MCP calls: ✓ all phases
  - Parallel task batches: ✓ all phases (but P2 contradicts notes)
  - Telemetry: ✓ all phases (noted as "emitted")
  - Notes: ✓ all phases
- **Contradictions:** P2 records "Parallel task batches | 0" but notes text claims "written in a single parallel batch". This ambiguity means accountability cannot be verified from the log alone.
- **Missing data:** None critical; all required fields are populated.
- **Verdict:** Build log is substantially complete. The P2 parallelism discrepancy should be resolved in a post-run audit or clarification from the agent that ran P2 (planifest-adr-agent). For future runs, re-emphasize that "parallel batch count" in the table must exactly match the execution pattern described in notes (i.e., if notes say "parallel batch", table must show ≥1, not 0).

---

## Summary

| Dimension | Grade | Evidence |
|-----------|-------|----------|
| Model routing | Acceptable | Primary tier justified for architectural work; 1–2 phases were cheaper-tier eligible but not flagged for cost optimisation. No miscalibration. |
| Parallelism | Poor | 5 phases show zero recorded parallelism despite multi-artifact generation or multi-task execution. Contradictory logging on P2 prevents verification. Significant wall-clock time penalty. |
| Phase gates | Excellent | Continuous-run authorisation explicit at P0; P7 hard-limit gate respected; no violations. |
| Self-corrections | Good | 1 correction in P4; avoidable with better test-framework documentation review. Low count is healthy. |
| Build-log integrity | Good | All fields populated; one internal contradiction (P2 parallelism table vs. notes). Process-level accountability is present; data quality is high. |

**Overall:** The pipeline executed successfully and delivered all required artifacts (10 requirements, 5 ADRs, working code, comprehensive tests, updated docs, and 1 new skill). Model routing and phase gating were sound. Parallelism was significantly underutilised across all phases — this is the primary efficiency gap for future runs. Self-correction rate was low and the one correction was avoidable.
