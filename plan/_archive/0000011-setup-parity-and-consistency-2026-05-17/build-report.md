# Build Report — 0000011-setup-parity-and-consistency — 17 May 2026

## Model Usage

| Model tier | Concrete model | Phases used | Agent call count |
|------------|---------------|-------------|-----------------|
| Primary    | claude-sonnet-4-6 | P0, P1, P2, P3, P4, P5, P6, P7, P8 | not captured |
| Cheaper    | claude-haiku-4-5  | none recorded | 0 (not evidenced) |

> **Finding:** Cheaper tier usage is zero. The build log records no agent calls at the cheaper tier. Per codegen-agent directive, TDD sub-agents (planifest-test-writer, planifest-implementer, planifest-refactor) declare `recommended_model: haiku` and must be invoked at the cheaper tier. No sub-agents were dispatched in this pipeline (the feature modified framework files directly, not application code), so the absence of cheaper-tier calls is partially explained — but is not evidenced in the build log.

---

## Skills Invoked

| Phase | Skill | Load pattern |
|-------|-------|-------------|
| P0    | planifest-orchestrator        | Session start (resumed) |
| P1    | planifest-spec-agent          | JIT |
| P2    | planifest-adr-agent           | JIT |
| P3    | planifest-codegen-agent       | JIT |
| P4    | planifest-validate-agent      | JIT |
| P5    | planifest-security-agent      | JIT |
| P6    | planifest-docs-agent          | JIT |
| P7    | planifest-ship-agent          | JIT |
| P8    | planifest-build-assessment-agent | JIT (this report) |

> Source: iteration log. Build log only captured P0.

---

## Subagent Dispatch

| Phase | Agent type | Count | Purpose |
|-------|-----------|-------|---------|
| P3    | planifest-test-writer  | 0 | No TDD sub-agents: framework file edits, not application code |
| P3    | planifest-implementer  | 0 | Same reason |
| P3    | planifest-refactor     | 0 | Same reason |

**Total agents spawned:** 0

> No Agent tool calls were made. All implementation work was direct file edits by the primary-tier orchestrator session. This is appropriate for a framework maintenance feature with no application code generation.

---

## MCP Tool Usage

| Tool | Call count | Purpose |
|------|-----------|---------|
| ctx_execute | multiple | Shell command execution (tests, grep) |
| ctx_execute_file | not captured | File analysis |
| ctx_search | not captured | Knowledge base queries |

> **Finding — Build log integrity:** MCP call counts are not captured per-phase in the build log. Only P0 records `MCP calls: 0`. All other phases have no build log entry. Actual MCP usage across P1–P8 cannot be verified from the build log. Evidence from the iteration log confirms ctx_execute was used for test runs during P4, and the context-mode hook blocked certain commands (requiring workarounds). Per-phase MCP call counts are unrecorded — treat as not captured.

---

## Parallel Task Bursts

| Phase | Batch count | Tasks parallelised |
|-------|------------|-------------------|
| P0    | 2 (build log) | Not specified |
| P1    | not captured | 20 requirement files written |
| P2    | not captured | 3 ADRs written |
| P3    | not captured | Multi-file framework edits across 8 skills + multiple adapters |
| P4    | not captured | Test suite runs |
| P5    | not captured | Security scans |
| P6    | not captured | Per-component docs, registry, dependency graph |
| P7    | not captured | Changelog, test report, archive |

**Phases with no parallelism recorded:** P1, P2, P3, P4, P5, P6, P7 (not captured)

> **Finding — Parallelism accountability gap:** Only P0 has a build log entry recording parallel batches. All other phases have no build log entry. Parallelism cannot be confirmed or denied for P1–P7. The iteration log notes that P3 involved editing 8 SKILL.md files (emission gate text) and multiple adapter files. These edits are independent and should have been dispatched in parallel batches. Whether they were is not recorded.

> **Finding — P1 requirement files:** 20 requirement files (REQ-001 through REQ-020) were produced. Per the spec-agent Parallelism Directive, independent requirement files MUST be written in a single parallel batch. The build log does not evidence this. If they were written sequentially (one per Write call), this was a process violation.

> **Finding — P3 SKILL.md edits:** 8 SKILL.md files received identical emission gate paragraph insertions. These are independent edits across independent files and MUST be parallelised per the codegen-agent directive. Not evidenced in the build log.

---

## Self-Corrections

| Phase | Count | Summary |
|-------|-------|---------|
| P4    | 3 fix sets | (1) 8 SKILL.md files missing emission gate text — 24 failures fixed; (2) copilot.mjs missing Copilot event name variants — 2 failures fixed; (3) test-0000005 migration path assertions pointing to wrong directory — 2 failures fixed |
| P4    | 2 false positives | test-gate-write-windows.sh and test-setup-telemetry.sh appeared to fail; confirmed passing via direct Bash; no fix needed |

**Total self-corrections:** 3 substantive fix sets (28 test failures resolved)

> **Note:** The 3 fix sets were for pre-existing failures (not regressions introduced by this feature). The user explicitly directed that pre-existing failures are "not a reason not to fix them." All 3 fix sets were correctly resolved within the 5-attempt ceiling.

---

## Artefact Counts

| Category | Count |
|----------|-------|
| Requirements | 20 (REQ-001 through REQ-020) |
| ADRs | 3 |
| Framework files modified (SKILL.md) | 8 |
| Hook adapters modified | 5 (copilot.mjs, cursor.mjs, windsurf.mjs, codex.mjs, roo-code.sh/.ps1) |
| Templates modified/created | 7 |
| Test files modified | 3 |
| Living docs created | 2 (architecture-overview.md, decisions-index.md) |
| Living docs updated | 2 (component-registry.md, dependency-graph.md) |
| Setup files modified | 2 (setup.sh, setup.ps1) |
| Migration scripts | 3 (0003 + .sh + .ps1) |
| Changelog entries | 3 (iteration log, changelog, test report) |
| Archive entries | 32 files |

---

## Efficiency Observations

### Model routing

**Finding:** Cheaper tier usage is zero — not evidenced in the build log. The codegen-agent directive specifies TDD sub-agents at `recommended_model: haiku`. However, this feature involved no application code generation (only framework file edits), so TDD sub-agents were not applicable. The absence of cheaper-tier usage is structurally expected for this feature type, not a process violation. However, the build log provides no evidence either way — the summary fields remain `pending`.

**Recommendation:** The build log template should distinguish between "cheaper tier not applicable (no sub-agents)" and "cheaper tier eligible but not used." Current template does not capture this distinction.

### Parallelism

**Finding — P1 (20 requirement files):** Not evidenced as parallelised. If written sequentially, this is a violation of the spec-agent Parallelism Directive. 20 sequential Write calls for independent files is measurably slower than a single parallel batch.

**Finding — P3 (8 SKILL.md edits):** 8 independent files receiving identical edits. Should be a single parallel batch. Not evidenced.

**Finding — P6 (docs):** Per-component documentation artifacts and drift checks are explicitly required to be parallelised. Not evidenced in the build log.

**Overall:** Parallelism compliance cannot be confirmed for any phase except P0 (which recorded 2 batches). The accountability gap is structural — the build log was not updated past P0.

### MCP usage

**Finding:** ctx_execute was used during P4 for test execution and grep operations, which is correct usage (keeps large output out of context). The context-mode hook blocked `ctx_execute` for certain commands mid-session, requiring direct Bash fallbacks. This is a known quirk (recorded in the iteration log). No evidence of raw tool output flooding context for large files.

**Finding:** The build log records 0 MCP calls for P0, and no entries for P1–P7. MCP usage cannot be audited per-phase.

### Self-corrections

**Assessment:** 3 fix sets for 28 pre-existing failures. All were structural issues in framework files that predated this feature. None were introduced by this feature's implementation. The fixes were correctly diagnosed (root cause identified, not symptom suppressed). 2 false positives were correctly dismissed after direct verification.

**Were they avoidable?** The SKILL.md emission gate failures (24 failures) represent a gap between the telemetry-standards.md approach (reference-based) and what the test suite expects (inline text). This is a spec design inconsistency that could have been caught in P1 if the test suite's expectations had been read before writing the requirement. Partially avoidable.

The copilot.mjs event name failures represent a documentation gap — the Copilot adapter was written against Claude Code event names rather than Copilot's documented names. Avoidable with a spec-time check of Copilot's hook documentation.

### Phase gate audit

**Finding:** This pipeline ran across multiple sessions (compacted mid-run). Phase gates are not explicitly recorded in the build log. The iteration log records all phases as passing sequentially (P0→P1→P2→P3→P4→P5→P6→P7). Human confirmation gates are not evidenced in the build log between phases — it is unclear whether gates were explicitly confirmed or the pipeline ran continuously.

**Recommendation:** The build log should capture phase gate decisions (human confirmed / continuous_run pre-authorised / skipped with reason) at each phase boundary.

### Build log integrity

**Finding — critical gap:** The build log was initialised at P0 but not updated past the P0 entry. All summary fields remain `pending`. This is a process violation — the orchestrator is required to append to the build log at each phase boundary. The build log as filed has 7 of 8 pipeline phases completely unrecorded.

**Impact:** The build-assessment-agent cannot audit model routing, MCP call counts, or parallelism evidence for P1–P7. All assessments in this report for those phases are derived from the iteration log (which is a narrative document, not a structured telemetry log) or are marked "not captured."

**Action required:** The orchestrator skill should enforce build log updates at each phase boundary, not just at P0 initialisation. This is the single highest-priority improvement for pipeline observability.

---

*Generated by planifest-build-assessment-agent at P8. Archive: `plan/_archive/0000011-setup-parity-and-consistency-2026-05-17/`*
