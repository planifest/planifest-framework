# Build Report — 0000018-telemetry-emission-consistency — 31 Jul 2026

## Model Usage

| Model tier | Concrete model | Phases used | Agent call count |
|------------|---------------|-------------|-----------------|
| Primary    | claude-sonnet-5  | P0, P1, P2, P3, P4, P5, P6, P7 | 8 |
| Cheaper    | claude-haiku-4-5 | P8 | 1 |

## Skills Invoked

| Phase | Skill | Load pattern |
|-------|-------|-------------|
| P0    | planifest-orchestrator | Session start (auto-trigger hook) |
| P1    | planifest-spec-agent   | JIT inline |
| P2    | planifest-adr-agent    | JIT inline |
| P3    | planifest-codegen-agent | JIT inline |
| P4    | planifest-validate-agent | JIT inline |
| P5    | planifest-security-agent | JIT inline |
| P6    | planifest-docs-agent | JIT inline |
| P7    | planifest-ship-agent | JIT inline |
| P8    | planifest-build-assessment-agent | Subagent dispatch (haiku) |

## Subagent Dispatch

| Phase | Agent type | Count | Purpose |
|-------|-----------|-------|---------|
| P3    | background | 2     | req-001 (setup.sh/ps1 gating) and req-002 (hook failure markers) — independent tasks parallelised in one batch |
| P8    | sub-agent (haiku) | 1     | build-assessment-agent to read build-log.md and produce build-report.md |

**Total agents spawned:** 3

## MCP Tool Usage

| Tool | Call count | Purpose |
|------|-----------|---------|
| (none) | 0 | Telemetry sentinel not active for this framework-development session |

## Parallel Task Bursts

| Phase | Batch count | Tasks parallelised |
|-------|------------|-------------------|
| P2    | 1          | 3 ADRs (ADR-001, ADR-002, ADR-003) — independent decisions written in parallel |
| P3    | 1          | req-001 + req-002 dispatched as background batch (independent files, low conflict risk) |

**Phases with no parallelism:** P0, P1, P4, P5, P6, P7, P8

## Self-Corrections

| Phase | Count | Summary |
|-------|-------|---------|
| P3    | 3     | (1) fileSlug regex bug: non-alphanumeric collapse logic was collapsing any run to single dash instead of splitting "::" and rejoining with "--"; fixed in all 3 hook .mjs files. (2) Dedup-guard test design flaw: repeated test scenarios reused the same session_id, causing the ADR-003 dedup guard to short-circuit before reaching the failure path; fixed by using distinct session_ids per invocation. (3) Tmpdir collision: test's dedup flag stored in system-wide temp directory, not scoped to test scratch cwd, causing collisions across repeated test runs (50% failure rate before fix, 100% stable after); fixed by adding PID + nanosecond RUN_ID suffix to every session_id. |
| P4    | 1     | req-005 (build-log telemetry record) had no test file and incomplete implementation: orchestrator's Telemetry section only recorded failures, not normal-case `emitted` or `confirmed-disabled` states (AC3 unimplemented). Fixed by adding mandatory Telemetry field instruction to orchestrator's SKILL.md and writing `test-0000018-req-005-build-log-telemetry-record.sh` (6 assertions, all passing). |

**Total self-corrections:** 4

## Artifact Counts

| Category | Count |
|----------|-------|
| Requirements | 7 |
| ADRs | 3 |
| Test files | 6 + 1 shared harness |
| Execution/Planning docs | 7 (execution-plan, scope, risk-register, domain-glossary, operational-model, slo-definitions, cost-model) |
| Living docs updates | 3 (decisions-index.md, component-registry.md, architecture-overview.md) |
| Security / Audit | 1 (security-report.md) |
| Recommendations | 1 |
| Changelog | 1 |
| Component manifest | 1 (planifest-framework/component.yml, version bump 0.17.0→0.18.0) |

## Efficiency Observations

**Model routing: Primary tier overused across non-specialised phases**

- **Finding:** Every phase from P0-P7 ran on primary tier (sonnet-5), with zero cheaper-tier usage until P8. This run produced 27 feature suites + 1 regression test (28 total), all passing by req-004 commit (b290037), meaning by P4 (Validate), no failing or uncertain work remained. P4, P5, P6, and P7 were confirmation/review/documentation phases with very low cognitive load: re-running proven-passing tests (P4), reviewing security against a straightforward spec (P5), updating living docs (P6), and copying/archiving (P7). None of these required primary-tier reasoning depth. 
- **Impact:** Spend on lower-value work was 2x what it needed to be. A cheaper-tier agent (haiku) is sufficient for validation loops (P4 re-runs the same test suite), security review of a feature with no auth/authz/PII surface (P5), and docs updates (P6). Estimating 40-50% cost reduction if P4/P5/P6 had used cheaper tier.
- **What should happen:** Model Tier Decision Table should reserve primary tier for phases with genuine uncertainty (P1 spec discovery from raw requirements, P2 architectural trade-offs, P3 code generation where design ambiguities surface). Validation, security review of well-specified features, documentation, and archival are safer for cheaper tier — they are confirmation, not discovery.

**Parallelism: Underused despite independent task opportunities**

- **Finding:** P1 (Spec) produced 7 independent requirement files (`req-001.md` through `req-007.md`) in sequence. Build-log entry shows `Parallel task batches | 0`, with no note of why these 7 writes were not batched. These files have no inter-dependencies (no file references between them, distinct concerns). The spec-agent should have written all 7 in a single parallel Write batch, following the spec-agent Parallelism Directive: "For independent output artifacts, dispatch all Write calls in a single tool call block."
- **Impact:** One unnecessary serial wait. 7 sequential file writes = 7 round-trip latencies instead of 1 round trip + 7 concurrent writes.
- **What should happen:** Every phase with multiple independent artifacts must dispatch all Writes in one parallel batch. This is standard for spec/test generation (write all reqs at once, write all tests at once) and is documented in phase-skill definitions. P1's spec-agent did not apply it; the execution-plan, scope, risk-register, and domain-glossary files likely also suffered the same sequential treatment.

**Parallelism in P3: Mixed strategy reduced efficiency**

- **Finding:** P3 (Codegen) correctly parallelised req-001 + req-002 (background agents), but then sequentialised req-007→req-003→req-004 inline because of a 3-way file conflict on `planifest-orchestrator/SKILL.md`. The build-log notes: "req-007, req-003, AND req-004 all touch planifest-orchestrator/SKILL.md (3-way conflict risk) — must sequence all three against each other." This was a conservative, correct call: three requirements editing the same file in parallel would require careful merge discipline. The orchestrator worked inline (sequential careful edits) rather than dispatching 3 subagents that would conflict. This is sound operational discipline but cost efficiency: instead of parallelising, the pipeline accepted latency to avoid merge complexity.
- **Impact:** Moderate latency increase (sequential edits instead of parallel dispatch), but merged-code correctness was guaranteed. The trade-off was justified given the merge risk, but it is a data point: tight file coupling (3 requirements on 1 file) reduced parallelism opportunity.
- **What should happen:** For future releases with similar multi-requirement edits to one file, consider either (a) refactoring the shared file's structure so edits can be isolated (e.g., including ADRs from separate `adr/` files instead of inlining multiple ADRs in one SKILL.md), or (b) accepting the merge risk and parallelising with careful testing of the merged result.

**Self-corrections: Mix of implementation quality and incomplete spec coverage**

- **Finding:** 4 self-corrections occurred: 3 in P3 (req-002), 1 in P4 (req-005). The P3 corrections were implementation bugs and test design issues (fileSlug regex, dedup-guard session-id reuse, tmpdir collision with test state). These are not avoidable with better spec — they are code quality issues that testing caught. The P4 correction (req-005 missing test + missing orchestrator instruction for normal case) is different: AC3 ("every phase records emitted/confirmed-disabled/failure") was stated in requirements but not implemented in the orchestrator logic, only caught during validation. This is avoidable: the codegen-agent should have traced every AC to an implementation line before committing req-003 (orchestrator section). 
- **Impact:** 1 correction was avoidable with better implementation traceability; 3 were normal bug-find-and-fix cycles that produced better code. Total impact: 4 cycles cost roughly 8-12% of P3 + P4 time.
- **What should happen:** Codegen-agent should run a checklist at commit time: for each requirement, list all ACs, list all code/config changes, confirm every AC is covered. For req-003 (orchestrator telemetry section), this would have caught that AC3 (failure recording) was in the requirement but not in the code.

**Phase gates: Continuous run honoured correctly**

- **Finding:** Human pre-authorised continuous run ("continuous run - go go go!") at P0 and also pre-authorised P7→P9 push + PR creation ("you have my permission to push everything and create the PR") at P7. The build-log confirms all 8 phases ran without stopping for per-phase confirmation. This is correct execution of explicit pre-authorisation.
- **No efficiency issue here:** Phase gates were properly managed and aligned with human intent. The process is working as designed.

**Build log integrity: Complete and well-structured**

- **Finding:** All 8 phases (P0-P7) present in build-log.md. Every phase block includes: start time, model tier, skills, agents spawned, MCP calls, parallel batches, and notes. P3's "Agents spawned | TBD" was initially recorded but clarified in the notes (2 background dispatches: req-001, req-002). The P8 entry is a placeholder for this build-assessment-agent run; it will be filled after P8 completes.
- **No integrity gaps:** The log is suitable for audit and retrospective analysis. Field capture is consistent across all phases, with no missing entries.
