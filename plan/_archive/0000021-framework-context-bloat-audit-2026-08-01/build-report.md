# Build Report — 0000021-framework-context-bloat-audit — 01 Aug 2026

## Model Usage

| Model tier | Concrete model | Phases used | Agent call count |
|------------|---------------|-------------|-----------------|
| Primary    | claude-sonnet-4-6 (orchestrator); claude-opus-5 (audit subagents) | P0, P1, P2, P3 (req-002/003 subagents), P4, P5, P6, P7 | 8 |
| Cheaper    | claude-haiku-4-5 | P8 | 1 |

## Skills Invoked

| Phase | Skill | Load pattern |
|-------|-------|-------------|
| P0    | planifest-orchestrator | Session start |
| P1    | planifest-spec-agent | JIT |
| P2    | planifest-adr-agent | JIT |
| P3    | planifest-codegen-agent | JIT |
| P4    | planifest-validate-agent | JIT |
| P5    | planifest-security-agent | JIT |
| P6    | planifest-docs-agent | JIT |
| P7    | planifest-ship-agent | JIT |
| P8    | planifest-build-assessment-agent | Sub-agent dispatch (P7→P8) |

## Subagent Dispatch

| Phase | Agent type | Count | Purpose |
|-------|-----------|-------|---------|
| P3    | claude-opus-5 (fresh-context) | 3 | Parallel audit pass: skills/, standards/, templates/+CLAUDE.md (req-002) |
| P3    | claude-opus-5 (fresh-context) | 2 | Second-round audit pass + trim-closing (req-003, round 2) |
| P8    | planifest-build-assessment-agent | 1 | Build efficiency report (cheaper tier) |

**Total agents spawned:** 6

## MCP Tool Usage

| Tool | Call count | Purpose |
|------|-----------|---------|
| ctx_batch_execute | 3 | P0: codebase discovery scans |
| ctx_batch_execute | several | P3: diagnosis of promote-to-regression.sh path bug |
| Unspecified MCP | 1 | P4: semantic correctness pass |
| Unspecified MCP | 2 | P5: credential/Hard-Limit mention counts + script diff review |
| Unspecified MCP | 2 | P7: cross-reference and regression-candidate checks |

**Total MCP calls:** 8 + "several" (exact P3 count not recorded in log)

## Parallel Task Bursts

| Phase | Batch count | Tasks parallelised |
|-------|------------|-------------------|
| P1    | 2 | 4 requirement files: execution-plan, scope, risk-register, domain-glossary |
| P2    | 1 | ADR-001 and ADR-002 written together (no cross-reference dependency) |

**Phases with no parallelism:** P0, P3, P4, P5, P6, P7, P8

## Self-Corrections

| Phase | Count | Summary |
|-------|-------|---------|
| P3    | 1     | Sed rule-ordering bug in promote-to-regression.sh fix (first attempt; reordered rules and re-ran) |

**Total self-corrections:** 1

## Artefact Counts

| Category | Count |
|----------|-------|
| Requirements | 4 |
| ADRs | 2 |
| Tests promoted to regression | 21 |
| Audit findings reports | 1 (main) + 3 (detail files) |
| Regression baseline records | 1 |
| Recommendations report | 1 |
| Security report | 1 |
| Trim/skill/standards edits | 24 files |

## Efficiency Observations

### Model Routing Audit

**Finding: Primary tier overdeployed; cheaper tier minimally used.**

The build log shows 8 primary-tier orchestrator/sonnet calls across P0–P7, with 5 additional claude-opus-5 calls for the audit subagents (req-002/003). The cheaper tier (claude-haiku-4-5) was used only once, in P8, after all primary work was complete.

All of P0–P7 are legitimate primary-tier work: orchestration, requirement specification, ADR production, and complex codegen/validation/security/docs phases. However, the build log does not record per-phase model assignments at sub-phase granularity, making it impossible to verify whether smaller tasks within those phases (e.g., P1's glossary write, P5's non-applicable sections, P6's registry-only update) could have been delegated to the cheaper tier. The P3 notes explicitly mention "3 parallel claude-opus-5 fresh-context subagents" and "2 more claude-opus-5 fresh-context passes," confirming that stronger models were chosen for the audit rounds — justified by the complexity of detecting redundancy across multiple files in one sweep.

**Verdict:** Model routing is reasonable given the task complexity (audit + guardrailed trim). Cheaper tier usage is nearly zero, but this is not inherently a failure — the feature required high-quality reasoning at every gate. The log's lack of sub-phase granularity prevents confirming whether all P0–P7 work truly required primary tier; recommend adding per-task model tier annotations to future build logs.

### Parallelism Audit

**Finding: Significant parallelism opportunity missed in P3.**

- **P1 (Spec):** 2 parallel batches, 4 independent requirement files. Correct.
- **P2 (ADRs):** 1 batch, 2 ADRs written together. Correct (no cross-dependency).
- **P3 (Codegen):** 0 parallel batches. **Critical issue.** The phase notes show three distinct, independent subagent invocations (skills/, standards/, templates/ audits in req-002; follow-up passes in req-003). These are described as "3 parallel claude-opus-5 fresh-context subagents" and "2 more" in the notes, implying they were intended to run in parallel. However, the log entry records "Parallel task batches | 0 so far (req-001)" — this suggests that parallelism either was not exercised during the initial sequential req-001 phase, or was not logged for the req-002/003 audit rounds.

  The P3 requirement text specifies: "TDD sub-agent loop not applicable, using direct execution + guardrailed-review process from ADR-002." This deviates from the standard parallel-dispatch pattern used in P0–P2. The 3 + 2 = 5 subagent invocations should have been recorded as at least 2 parallel batches (req-002's 3 agents in one batch; req-003's 2 agents in another). Absence of these records in the log is a **process violation** — either the agents ran sequentially (wasteful) or ran in parallel but were not logged (accountability gap).

- **P4–P8:** Single-task phases (validation, security, docs, archive, assessment). Parallelism not applicable.

**Verdict:** P3's parallelism is either not captured or not executed. Recommend: (a) clarify whether the 5 audit subagents ran in parallel or sequentially; (b) if sequential, measure the cost of serializing 5 independent operations; (c) update the build-log template to require explicit parallel-batch recording for multi-subagent phases.

### Phase Gate Audit

**Finding: No phase gates recorded in log; continuous_run setting not documented.**

The build log does not record human confirmation gates at phase transitions (P1→P2, P2→P3, etc.). The P0 notes show extensive AskUserQuestion exchanges (nine questions covering scope, adoption, backlog curation, design corrections, and scope lock scenarios), confirming active human involvement at P0. However:

- No explicit "human gate confirmation at P1→P2" or similar is recorded for downstream phases.
- The P0 notes mention "continuous_run" mode being set as part of adoption (implied by "Human-confirmed. Feature branch feat/0000021-framework-context-bloat-audit created from clean main"), but the build log does not state whether continuous_run was enabled or if this was a manual multi-session run.
- P3 notes describe a complex sequence of req-001 (regression setup), req-002 (initial audit), req-003 (trim attempts), mid-flight human escalations ("Escalated to human: script not in original file-scope list"), and resumption after a rate-limit pause. This narrative strongly suggests active human involvement at multiple checkpoints within P3, but no phase-boundary gates are recorded.

**Verdict:** The log's silence on phase gates is itself a finding. A fully human-gated run should record confirmations; a continuous_run should record that authorization. Neither is present. Recommend: add explicit "Gate: human / continuous_run / skipped" entries to the build-log template for every P1–P9 transition.

### Self-Correction Audit

**Finding: Low self-correction count masks significant rework in P3.**

Recorded self-corrections: 1 (sed rule-ordering bug, P3).

However, the P3 narrative describes far more repair work:
- "First fix attempt had a sed rule-ordering bug (self-correction: reordered rules, re-ran)" — 1 correction (recorded).
- "Second fix attempt surfaced 2 remaining failures with bespoke self-referential path logic (test-regression-pack.sh, test-gate-write-windows.sh/.mjs) needing individual patches" — not recorded as self-corrections, but noted as separate repair work.
- "Post-trim regression run surfaced 24 real guardrail failures (both guardrails' worth)" — 24 failures, each requiring a "minimal, precise restoration" applied directly. These are not recorded as self-corrections; instead, they are characterized as deliberate fixes following test output.
- Round-2 audit (req-003): "Both closing agents independently verified via diff that 100% of the first audit's itemized findings were already applied, and the audit's own summary-table percentages did not reconcile with its itemized detail (aspirational, not achievable in-file). Real floor after exhausting audit-vetted content: ~14.1%. Escalated to human: accept the real number / commission a second deeper audit / human picks per-file. Human chose second audit."

The log conflates "self-correction" (detect own error, fix, re-run) with "defect repair" (external test failure → fix) and "audit mismatch" (audit aspirational vs. achievable). By the strict definition, only the sed fix counts. But the rework footprint is much larger:
- 1 self-correction (sed).
- 2 bespoke repairs (test path logic).
- 24 guardrail failures requiring targeted restorations.
- 1 full second audit round because the first audit's coverage was overstated.

**Verdict:** Self-correction count of 1 is technically correct but misleading. The feature experienced significant iterative rework in P3, driven not by unclear specs or codegen assumptions, but by (a) a pre-existing script bug discovered only when tests ran (promote-to-regression.sh), (b) guardrail test brittleness (24 failures from trim edits), and (c) audit-claimed reductions that did not reconcile with field reality. Recommend: expand the self-correction definition to include "defect repairs" and "rework cycles triggered by external validation," or add a separate "Rework cycles" field to the build log.

### Build Log Integrity

**Finding: Log is sparse on several critical dimensions.**

- **MCP tool usage in P3:** Recorded as "several (ctx_batch_execute diagnosis of promote-to-regression.sh path bug)" with no count. Exact call count unknown.
- **Parallel task batches in P3:** Recorded as 0, but the narrative describes 5 subagent invocations (3 + 2) across req-002 and req-003. No parallel batches logged, despite the notes claiming parallelism.
- **Model tier granularity:** The log records "primary" for most phases, but does not disambiguate between sonnet-4-6 (orchestrator) and opus-5 (audit subagents). Only the P0 Header section mentions the dual-model strategy; P3 does not record which requirements were served by which model.
- **Phase gates:** No phase-boundary gate confirmations or skips recorded anywhere in the log.
- **Rework categories:** No distinction between self-corrections (agent's own error), external defect repairs (pre-existing bug), guardrail failures, and audit reconciliation failures.

**Verdict:** Log capture is inconsistent. Phases P0, P1, P2 are well-structured; P3 has dense prose notes that do not fit the tabular schema; P4–P8 are sparse on non-applicable content. Recommend: (a) enforce tabular capture for all numeric fields (exact MCP counts, parallel batch counts); (b) add a "Rework log" section to record correction reason (self-correction / external defect / guardrail failure / audit gap) and resolution method (self-fix / subagent re-run / manual restoration); (c) add a "Phase gates" row to every phase entry.

---

**Summary:** The pipeline completed all 9 phases with low explicit self-correction (1) but significant hidden rework (24 guardrail failures + 2 audit rounds). Model routing is appropriate to task complexity; cheaper tier saw minimal use, justified by the audit's complexity. Parallelism opportunities in P3 are either unrealized or unlogged, representing a process accountability gap. Build-log structure itself needs strengthening to distinguish rework categories and record phase gates.
