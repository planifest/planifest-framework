---
title: "Build Report — 0000017 — 26 Jul 2026"
summary: "Phase 8 build efficiency audit and findings."
---

# Build Report — 0000017-ratchet-forgery-detection-and-telemetry-schema-spec — 26 Jul 2026

## Model Usage

| Model tier | Concrete model | Phases used | Agent call count |
|------------|---|---|---|
| Primary    | claude-sonnet-5 | P0, P1, P2, P3 (partial), P4, P5, P6, P7 | 12 |
| Cheaper    | claude-haiku-4-5 | P3 (req-001) | 1 |
| Fallback   | claude-fable-5 | P3 (req-002/003/004 inline recovery) | 3 (inline) |

---

## Skills Invoked

| Phase | Skill | Load pattern |
|---|---|---|
| P0 | planifest-orchestrator | Session start (auto-trigger) |
| P1 | planifest-spec-agent | JIT |
| P2 | planifest-adr-agent | JIT |
| P3 | planifest-codegen-agent | JIT |
| P4 | planifest-validate-agent | JIT |
| P5 | planifest-security-agent | JIT |
| P6 | planifest-docs-agent | JIT |
| P7 | planifest-ship-agent | JIT |
| P8 | planifest-build-assessment-agent | Dispatch from P7 |

---

## Subagent Dispatch

| Phase | Agent type | Count | Purpose |
|---|---|---|---|
| P0 | planifest-scope-lock-agent | 8 | Scope Lock Challenge Q1–Q4 for items 1–6 |
| P3 | planifest-codegen-agent | 5 | Req-001 (cheaper), req-002/003/004 (primary batch), req-005 (foreground) |
| **Total agents spawned** | | **13** | |

---

## MCP Tool Usage

| Tool | Call count | Purpose |
|---|---|---|
| ctx_execute, ctx_execute_file | Not separately tracked | Analysis, grep, parsing during multiple phases |
| ctx_fetch_and_index | Not separately tracked | Web research (if any) |
| ctx_search | Not separately tracked | Knowledge base queries (if any) |
| **Note** | — | **MCP usage not captured per-phase in build log; no file-write MCP calls recorded.** |

---

## Parallel Task Bursts

| Phase | Batch count | Tasks parallelised |
|---|---|---|
| P3 | 2 | req-001 (haiku) + req-002/003/004 (sonnet batch) dispatched together; req-005 foreground after batch completion |
| **Phases with no parallelism** | — | P0, P1, P2, P4, P5, P6, P7 (7/8 phases) |

---

## Self-Corrections

| Phase | Count | Summary |
|---|---|---|
| P3 | 3 | Spend-limit recovery: req-002/003/004 agents interrupted mid-run; restarted inline with claude-fable-5 as fallback model. Req-005/006/007 completed inline after subagent dispatch failures. *Note: exigency recovery, not design-phase error correction.* |
| P4 | 1 | Semantic traceability: req-003 (docs-only sweep) had no mapped executable test. Added `test-0000017-req-003-phase-wave-sweep.sh` (9 assertions). Root cause: manual verification not tied to test. |

**Total self-corrections:** 4

---

## Artifact Counts

| Category | Count |
|---|---|
| Requirements (P1) | 6 (req-001..006 in plan/current/) |
| Bundled backlog item (P3) | 1 (req-007, change-agent archive step) |
| ADRs (P2) | 4 (ADR-001 ratchet-approve, ADR-002 hook unification, ADR-003 scope-lock agent, ADR-004 discovery pass) |
| Test suites (P3) | 21 feature + 1 regression = 22 total; +1 new at P4 for req-003 traceability |
| Component manifests updated | 1 (context-mode-hooks) |
| Security findings | 0 critical/high/medium; 3 low/informational (reported in P5 security-report.md) |

---

## Efficiency Observations

### Model Routing

**Primary tier usage:** P0–P7 (all discovery, spec, ADR, codegen, validation, security, docs, shipping phases). Primary tier dominated across 7/8 working phases (P0 is human-coaching; P8 is read-only assessment).

**Cheaper tier usage:** 1 agent call (req-001, haiku, regression promotion). This is a low-cost mechanical task with no ambiguity — appropriate use of cheaper tier.

**Finding:** Model tier decisions were not recorded per agent call during P3's codegen; the log shows "primary + cheaper (per Model Tier Decision Table)" but the actual decision rationale is not captured. Req-001 (haiku) is the only cheaper-tier call on a multi-agent phase — appropriate for that specific task. However, req-002/003/004 were all dispatched on primary tier (sonnet) initially, then salvaged with fable (fallback due to spend limit, not a planned decision). 

**Verdict:** Acceptable. Cheaper tier was not underused — the feature is complex (6 independent requirements affecting orchestrator, hooks, tests, docs, and a cross-repo RCA handoff). The single haiku call on req-001 (regression promotion) is the right call for a mechanical task. Fallback to fable was exigency-driven, not a model-routing decision.

### Parallelism

**Phases with recorded parallelism:**
- **P3 only:** 2 parallel batches (req-001 background, req-002/003/004 background batch; req-005 foreground after completion). Independent requirements dispatched together. ✓

**Phases with zero recorded parallelism:**
- **P0:** Inherently sequential — human coaching, Scope Lock Challenge Q/A pairs, design confirmation. No parallelism opportunity. ✓
- **P1 (Spec):** 6 independent requirement files written. Log shows 0 parallel task batches. **Data gap:** Did the spec-agent write all 6 files in one parallel call, or 6 sequential Write calls? Build log does not record file-write granularity. Cannot confirm whether parallelism was applied. ⚠
- **P2 (ADRs):** 4 independent ADRs written (ADR-001/002/003/004). Log shows 0 parallel task batches. **Data gap:** Same issue — no recording of write granularity. Cannot confirm whether ADRs were written in parallel or sequentially. ⚠
- **P4 (Validate):** CI validation noted as "Batch 1 (parallel): bash -n on all touched .sh ... node --check on all .mjs hooks" — this is validation execution (framework test suite + component-pack suite + syntax checks), not code dispatch. Appropriate for validation phase. ✓
- **P5–P7:** Single-purpose phases (security review, docs reconciliation, archiving) — no multi-task parallelism required. ✓

**Finding:** P1 and P2 lack granular write-call tracking. Both phases produced multiple independent artifacts (6 requirement files, 4 ADRs) but the build log does not disambiguate whether these were written in a single parallel batch or sequential calls. Per the Parallelism Directive (mentioned in P3 notes for codegen: "6 independent requirements, no cross-dependencies — dispatching in parallel"), parallel dispatch of independent artifacts is the expected pattern. The absence of parallelism entries for P1/P2 suggests either (a) parallelism was not applied, or (b) it was applied but not logged. **Treat as not evidenced — accountability gap.**

### Phase Gates

- **P0 → P1:** Design confirmed by human at line 74 ("Gate accepted: P0 — 2026-07-25. P0 complete, proceeding to P1."). Gate honoured. ✓
- **Continuous run authorization:** Human confirmed at line 71 (`plan/.run-mode` written with `continuous`). P1–P6 gates bypassed as pre-authorized. Per Hard Limit exception, continuous_run does not bypass P7 (shipping). ✓
- **P7 (Shipping gate):** Log states "P7 is always a confirmation gate (Hard Limit exception — continuous_run does not bypass shipping)" but does not explicitly confirm the gate was honoured at the moment of execution. The archive happened (verified in P7 notes), but the gate confirmation is not logged as an explicit action/timestamp. ⚠ *Minor audit note: Hard Limit exception correctly applied, but log could have recorded explicit gate confirmation.*

**Verdict:** Phase gates applied correctly. Continuous run was authorized. P7 hard gate respected (inferred from archive completion, explicit confirmation would strengthen audit trail).

### Self-Corrections

**P3 spend-limit recovery (3 occurrences):**
- req-002/003/004 agents dispatched to primary tier (sonnet) in background batch; interrupted mid-run by account monthly spend limit.
- **Root cause:** External constraint (spend limit), not implementation error or spec ambiguity.
- **Mitigation:** Model switched to fable tier inline; all three requirements completed and committed.
- **Avoidability:** No — spend limits are infrastructure constraints, not avoidable via better spec clarity or initial prompting.
- **Log fidelity:** Spend-limit event is documented; recovery action (fable fallback) is documented; final commits are referenced. ✓

**P4 semantic traceability correction (1 occurrence):**
- req-003 (Phase/Wave terminology sweep in docs) is a documentation-only requirement with manual verification (sweep report at `plan/current/req-003-phase-wave-sweep-report.md`) but no mapped executable test.
- **Root cause:** Docs-only requirements verified manually at P3 but not given executable traceability tests per semantic-validation spec.
- **Mitigation:** Added `test-0000017-req-003-phase-wave-sweep.sh` with 9 assertions (corrected files use Wave, no stragglers outside external-skills, pipeline-phase headings untouched, report records dispositions).
- **Avoidability:** Partially. P1 spec-agent could have flagged docs-only requirements as needing executable validation, prompting explicit test authoring at P3. P3 codegen-agent could have cross-checked all 6 requirements against the test file map. The omission was avoidable with tighter spec or checklist discipline.
- **Log fidelity:** Error clearly documented; fix applied and verified; result passed all assertions. ✓

**Summary:** 3 spend-limit recoveries (unavoidable), 1 test-coverage correction (avoidable with better spec/checklist). **Total self-corrections: 4.** Low count for a 7-requirement bundled release. Inline recoveries due to exigency, not design error — pipeline was otherwise proceeding normally.

### Build Log Integrity

| Phase | Log detail | Data completeness |
|---|---|---|
| P0 | 72 lines of Q/A + decision log | Excellent — Scope Lock Challenge fully documented, 6-item scope confirmed per-item |
| P1 | 4 lines | Sparse — artifacts produced listed but no per-file write granularity, no parallelism entries |
| P2 | 3 lines | Sparse — ADRs produced listed but no per-ADR detail, no parallelism entries |
| P3 | Long narrative | Good — agent dispatch, spend-limit recovery, inline completions documented; parallelism shown as "TBD" then filled in post-hoc ("2 parallel batches") |
| P4 | 4 lines + self-correction cycle | Good — CI validation batched, traceability error documented with root cause + fix |
| P5 | 2 lines + security surfaces | Good — risk surfaces listed, low-severity findings stated |
| P6 | 8 lines + sync details | Good — specific files synced, drift checks performed, recommendations/changelog noted |
| P7 | 4 lines + archive verification | Good — diff-verified archive, cross-reference checks, sentinel removal logged |
| **Overall** | | **Moderate** — P1/P2 lack write-call granularity; MCP usage not tracked per-phase |

**Key gaps:**
1. **Write-call granularity not recorded** — P1 produced 6 requirement files, P2 produced 4 ADRs, but no log entry for each file/ADR write. Cannot verify whether parallel batch writes were used.
2. **MCP tool usage not separately tracked** — Summary states "numerous read-only `ctx_execute` calls" but no per-phase counts, no breakdown by tool. Renders MCP-efficiency audit incomplete.
3. **Model-tier decision rationale not captured** — P3 shows "primary + cheaper (per Model Tier Decision Table)" but the table itself and per-agent-call decisions are not in the log.

**Verdict:** Build log provides adequate high-level phase sequencing and phase-transition auditing. Lacks fine-grained artifacts and tool-usage tracking needed for detailed efficiency analysis. **Acceptable for pipeline accountability, with noted data-collection improvements for future releases.**

---

## Audit Summary: Evidence-Based Findings

### Finding 1: Parallelism Not Evidenced for Multi-Artifact Phases (P1, P2)

| Phase | Artifact count | Parallelism recorded | Verdict |
|---|---|---|---|
| P1 (Spec) | 6 independent requirement files | 0 batches | **Not evidenced — treat as sequential unless proven otherwise.** |
| P2 (ADRs) | 4 independent ADRs | 0 batches | **Not evidenced — treat as sequential unless proven otherwise.** |

**Per the Parallelism Directive (P3 notes), independent artifacts must be dispatched in parallel. Absence of recorded batches + absence of per-file write granularity = accountability gap. Recommend P1/P2 future runs log individual Write calls or explicit parallel-batch confirmation.**

### Finding 2: MCP Tool Usage Not Tracked Per-Phase

| Metric | Recorded | Required for audit |
|---|---|---|
| ctx_execute, ctx_execute_file call count | "Not separately tracked" | ✓ (efficiency assessment) |
| ctx_fetch_and_index call count | "Not separately tracked" | ✓ (context-prevention assessment) |
| Tool usage per phase | — | ✓ (identify phases with high context-mode load) |

**MCP usage summary at P7 acknowledges numerous read-only calls during multiple phases but provides no per-phase breakdown. Cannot assess whether context-mode was used to prevent context flood or whether any phase over-relied on naive file reads. Recommend adding per-phase MCP call tracking to future build logs.**

### Finding 3: Model-Tier Decision Table Not Documented

**P3 notes:** `Skills loaded: planifest-codegen-agent; Model tier: primary + cheaper (per Model Tier Decision Table)`

**Actual dispatch:**
- req-001: haiku (cheaper) ✓
- req-002/003/004: sonnet (primary) — initially background batch, then fable (fallback due to spend limit)
- req-005/006/007: completed inline by orchestrator (no distinct model call)

**Gap:** The "Model Tier Decision Table" referenced in P3 is not in the build log. Cannot verify whether decisions were made per requirement or globally per phase. Recommend recording the decision table per-agent or explaining the allocation logic explicitly.

### Finding 4: Spend-Limit Exigency, Not Pipeline Error

**Event:** Req-002/003/004 agents interrupted mid-run by account spend limit. Restarted inline with claude-fable-5 fallback.

**Assessment:** 
- Not a design or implementation error.
- Recovery action (fable fallback, inline completion) was appropriate.
- No self-correction cycle needed — exigency handled as-designed.
- **Does not reflect pipeline inefficiency.**

### Finding 5: Semantic Traceability Gap Caught at P4 (Avoidable)

**Requirement:** req-003 (Phase/Wave terminology sweep in guide files).

**Gap:** Manual verification at P3; no executable test file mapped per semantic-validation spec.

**Correction:** P4 added `test-0000017-req-003-phase-wave-sweep.sh` (9 assertions).

**Assessment:** Avoidable. Better spec instruction or P3 codegen checklist (all requirements must have mapped test files) would have caught this at codegen time, not validation time. Low severity — requirement was implemented correctly, only the test was deferred.

---

## Overall Efficiency Rating: GOOD with Data-Collection Gaps

| Category | Status |
|---|---|
| **Model routing** | ✓ Appropriate — primary tier for complex phases, cheaper for mechanical task (req-001). Fable fallback correctly applied to exigency. |
| **Parallelism (evidenced)** | ✓ P3 correctly parallelised 4+ independent requirements. **⚠ P1/P2 parallelism not recorded — treat as gap, not approval.** |
| **Phase gates** | ✓ Continuous run authorised; P7 hard gate respected. |
| **Self-corrections** | ✓ Low count (4 total). 3 exigency-driven (unavoidable), 1 test-coverage (avoidable but caught early). |
| **Build log integrity** | ⚠ Adequate high-level tracking; lacks MCP-call granularity and P1/P2 write-call granularity. |

**Pipeline executed efficiently under constraints. Data collection could be tightened for future accountability.**

---

**P8: Complete — build-report.md filed to `/Users/martinmayer/d/planifest/framework/plan/_archive/0000017-ratchet-forgery-detection-and-telemetry-schema-spec-2026-07-26/`**
