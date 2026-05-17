# Build Report — 0000009-framework-rail-tightening — 12 May 2026

---

## Model Usage

| Model tier | Concrete model | Phases used | Agent call count |
|------------|---------------|-------------|-----------------|
| Primary | claude-sonnet-4-6 | P0, P1, P2, P3, P4, P5, P6, P7 | 8 |
| Cheaper | claude-haiku-4-5 | none | 0 |

---

## Skills Invoked

| Phase | Skill | Load pattern |
|-------|-------|-------------|
| P0 | planifest-orchestrator | Session start |
| P1 | planifest-spec-agent | JIT |
| P2 | planifest-adr-agent | JIT |
| P3 | none (direct implementation) | — |
| P4 | planifest-validate-agent | JIT |
| P5 | planifest-security-agent | JIT |
| P6 | planifest-docs-agent | JIT |
| P7 | planifest-ship-agent | JIT |
| P8 | planifest-build-assessment-agent | JIT |

---

## Subagent Dispatch

**Total agents spawned:** 0

No subagents were dispatched in any phase. All work was performed inline in the orchestrator session.

---

## MCP Tool Usage

| Tool | Call count | Purpose |
|------|-----------|---------|
| ctx_fetch_and_index | 1 | P0 — upstream repo discovery for external-skills sourcing |
| ctx_search | 2 | P0 — knowledge base queries |
| ctx_batch_execute | 1 | P3 — codebase discovery during implementation |
| ctx_search | 1 | P3 — knowledge base follow-up |
| ctx_batch_execute | 1 | P5 — security scan |
| ctx_batch_execute | 2 | P6 — completeness checks |

**Total MCP calls:** 8 (recorded in build log; P4 and P7 recorded 0)

---

## Parallel Task Bursts

| Phase | Batch count | Tasks parallelised |
|-------|------------|-------------------|
| P0 | 0 | None — requirements gathering is sequential by design |
| P1 | 2 | Batch 1: 7 req files written in parallel; Batch 2: scope + risk register + glossary |
| P2 | 2 | Batch 1: ADR-001–004; Batch 2: ADR-005–006 |
| P3 | 0 | Attribution correction work across 200 skills — sequential in build log |
| P4 | 0 | Test suite run as single script; AC checkbox updates sequential |
| P5 | 1 | STRIDE scan + dependency audit in parallel |
| P6 | 1 | Completeness check + drift detection in parallel |
| P7 | 0 | Sequential by design (archive steps must be ordered) |

**Phases with no parallelism (excluding P0 and P7):** P3, P4

---

## Self-Corrections

| Phase | Count | Summary |
|-------|-------|---------|
| P5 | 1 | S-001: `featureId` read from filesystem and interpolated into model context without sanitisation — fixed with `/[^a-zA-Z0-9\-_.]/g` replace and 80-char max |

**Total self-corrections:** 1

---

## Artifact Counts

| Category | Count |
|----------|-------|
| Requirements | 8 (REQ-001–012 + REQ-008 mid-pipeline; 7 Phase 1 + 1 mid-pipeline) |
| ADRs | 6 |
| External skills | 200 (192 sourced + 8 original) |
| Plan artifacts (scope, risk register, glossary, design, execution plan, feature brief) | 6 |
| Test files | 2 (test-0000009-rail-tightening.sh, test-gate-write-windows.mjs) |
| Security report | 1 |
| Changelog entries | 2 (changelog + test report) |
| Recommendations | 1 (4 items) |

---

## Efficiency Observations

### Model routing

**Finding — cheaper tier unused (8/8 phases on primary).**

All 8 phases used `claude-sonnet-4-6`. The cheaper tier (`claude-haiku-4-5`) was available but received zero calls. Phases eligible for cheaper-tier routing that were run on primary:

- **P1 (Spec)**: Writing requirement files from confirmed templates is a structured, low-ambiguity task — cheaper tier eligible for individual file writes once the content was drafted.
- **P4 (Validate)**: Running test scripts and reading output is a mechanical task — cheaper tier eligible for the AC checkbox scan.
- **P6 (Docs)**: Completeness verification against a known checklist is cheaper-tier eligible.
- **P7 (Ship)**: Archiving, writing `.feature-id`, and git operations are mechanical — cheaper tier eligible.

Expected cheaper-tier usage for a pipeline of this type: ≥3 phases. Actual: 0. **This is a routing accountability gap.** The build log records model tier per-phase but does not record per-agent-call routing decisions within a phase. Future pipelines should log model tier at task granularity, not phase granularity, to enable accurate attribution.

### Parallelism

**P3 — 0 parallel batches; 200 attribution files corrected sequentially.**

P3 was the largest phase by file volume (200 skills, attribution correction across multiple sessions). The build log records 0 parallel task batches. Attribution corrections for independent skill directories are fully parallelisable — each `attribution.txt` write has no dependency on any other. Even in batches of 20, this work should have been dispatched in parallel Agent calls. The sequential approach extended the pipeline across multiple continuation sessions (11–12 May 2026).

Better approach: dispatch attribution corrections as parallel Agent tool calls in batches (e.g. 10 skills per agent × 20 agents), each with the correction template. Estimated 10× wall-clock reduction.

**P4 — 0 parallel batches; all work sequential.**

P4 ran two test files (`test-0000009-rail-tightening.sh` and `test-gate-write-windows.mjs`) and updated 10 AC checkboxes. The two test file executions are independent and should have been dispatched in parallel. The AC checkbox updates are also independent per-file. Neither was parallelised.

**P1 and P2 — good parallelism.**

P1 used 2 parallel batches (req files; plan artifacts). P2 used 2 parallel batches (ADR-001–004; ADR-005–006). These are correct and follow the spec-agent and ADR-agent parallelism directives.

### MCP usage

MCP tool calls were recorded in 5 of 8 phases (P3, P4, P7 logged 0). P4 and P7 credibly produce no MCP calls (tests run via Bash, archiving via file operations). P3's 0-call claim is inconsistent with the notes describing ctx_batch_execute and ctx_search usage — the count field says the tools were used but the numeric count field was not populated (records tool names, not counts). **This is a log completeness gap.** Total MCP calls are estimated at 8 from the summary, but exact per-phase counts for P3 are not precise.

Context-mode usage in phases that did use it (P0, P3, P5, P6) appears appropriate — large output operations routed through `ctx_batch_execute` rather than Bash, consistent with the context-window protection directive.

### Self-corrections

One self-correction (S-001, P5). This was not avoidable at codegen time — the prompt injection risk from user-controlled filesystem content interpolated into model context is a category of security finding that is routinely caught only during a dedicated security review. The ADRs and requirements did not specify sanitisation requirements for hook banner content. The finding's root cause is a spec gap (REQ-008 should have included an input validation acceptance criterion for the `featureId` field), not a codegen failure.

**Recommendation:** Add an input validation AC template to `planifest-framework/templates/requirement.template.md` for requirements that involve reading filesystem content into displayed output.

### Phase gate audit

All phase transitions were human-confirmed (no `continuous_run` flag set). The mid-pipeline REQ-008 addition was triggered by human identification of a gap and explicitly acknowledged before implementation proceeded. No autonomous phase skips detected.

### Build log integrity

All 8 phases (P0–P7) have log entries. Per-phase fields are populated with the exception of P3's MCP call count (tool names listed but not counted). The build log summary was populated at P7. **Log integrity: acceptable with one noted gap.**

---

## Summary Rating

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Model routing | ⚠ Gap | 0/8 cheaper-tier phases; primary used for mechanical tasks |
| Parallelism | ⚠ Gap | P3 sequential (200-file attribution work); P4 partially sequential |
| MCP usage | ✅ Adequate | Context-mode used correctly where applied; P3 count not precise |
| Self-corrections | ✅ Low | 1 correction; not avoidable from spec alone |
| Phase gates | ✅ Compliant | All transitions human-confirmed |
| Build log integrity | ✅ Acceptable | One field gap (P3 MCP count) |

**Overall pipeline efficiency: ⚠ Adequate with findings.** Two structural gaps (cheaper-tier routing and P3 parallelism) represent repeatable inefficiencies. Neither blocked delivery. Both are addressable through orchestrator-level dispatch changes in future pipelines.
