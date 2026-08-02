---
title: "Regression Baseline - 0000022-orchestrator-redundancy-removal"
summary: "Full regression pack run and word counts recorded before any trim edit, per 0000021 ADR-002's baseline-gated trim process."
status: "active"
version: "0.1.0"
---
# Regression Baseline - 0000022-orchestrator-redundancy-removal

**Requirement:** [req-001-regression-baseline.md](requirements/req-001-regression-baseline.md)
**Run date:** 2026-08-02
**Runner:** `bash planifest-framework/tests/run-tests.sh`

## Result

- Feature suites: 33 passed, 0 failed
- Regression suite: 22 passed, 0 failed (individually re-run for confirmation, all 22 PASS)
- Total: 55 passed, 0 failed

## Word Counts

| File | Words |
|------|-------|
| `planifest-framework/skills/planifest-orchestrator/SKILL.md` | 10,379 |
| All `planifest-framework/skills/*/SKILL.md` combined | 26,269 |

Target: orchestrator at or under 7,600 words after trim (feature brief NFR-001).

## Orchestrator-Content-Pinning Test Inventory (corrected)

Discovery (P0) estimated 4 of 22 regression tests pin `planifest-orchestrator/SKILL.md` content. A full `grep -l` against the regression directory at baseline time found **10 of 22** — the discovery estimate was wrong and is superseded by this table. This correction is recorded here as the source of truth for req-004's enumeration.

| Test | Pins (relevant to this feature) | Affected by this feature's plan? |
|------|-------|-----------|
| `test-0000006-build-assessment.sh` | "Model Tier" / "Primary" / "Cheaper" / tier classifications / "Tier-to-model" / "claude-haiku" (req-004 assertions) and "Parallelism Rules" / "Default posture: parallel" / "Dependency test" / "MUST parallelise" / "Cannot parallelise" (req-005 assertions) | **Yes — Class 2 relocation (req-003).** These assertions currently check `$ORCH` (orchestrator content). Must be updated to check the new `standards/agent-dispatch-standards.md` instead. |
| `test-0000017-req-006-structured-discovery-pass.sh` | "Structured Discovery Pass (all modes)" section: shared header, "fresh every pipeline run", "could not be determined", "never a hard block", "trusted as-is", "regenerate it fresh", Resume Detection section, "discovery.template.md" | **Narrowly — Class 1 item 6 must be scoped to avoid this.** This pins the *operative* lifecycle/partial-failure/cross-session rules in the "Structured Discovery Pass (all modes)" preamble, which is orchestrator-owned logic, not a description of template content. Only the four Mode Taxonomy subsections' bullet lists that literally restate `discovery.template.md`'s own per-mode subsections are the actual duplication — req-002 item 6 corrected to target only those, not the preamble. No test update expected if scoped correctly. |
| `test-0000017-req-005-scope-lock-suggested-answers.sh` | "Suggested-answer option" heading, "Want me to suggest an answer", "never silently skipped", "explicit human request", "planifest-scope-lock-agent", "build-log.md", confirmation-recording phrase | **Narrowly — Class 1 item 4 must be scoped to avoid this.** These are the four scenario-path questions' offer text and the ADR-003 ownership statement, explicitly kept per req-002's original scope ("does NOT touch the always-offered, only-drafted-on-request semantics"). No test update expected if scoped correctly - already consistent with req-002 as drafted. |
| `test-0000018-req-003-orchestrator-marker-check-and-prompt.sh` | Content within the `## Telemetry` section: marker location, root_cause_key, block-or-proceed text, "never re-ask", build-log recording, marker deletion, agent-driven failure path, "Unified signal" reference | No conflict - all pinned phrases are in the paragraph req-002 item 1 already keeps ("the failure-marker check duty, the per-phase Telemetry build-log line requirement"). Only the 14-event table and JSON snippets below this paragraph are removed. |
| `test-0000018-req-005-build-log-telemetry-record.sh` | "Every phase records a .Telemetry. line", "not complete until this field is filled", "confirmed-disabled" | No conflict - same kept paragraph as above. |
| `test-0000018-req-007-discovery-md-hard-limit.sh` | Hard Limit 11 (discovery.md), step "3d." cross-reference, Gate Checklist discovery.md item | No conflict - Hard Limit 11 and the P0→P1 Gate Checklist are untouched by this feature's plan. |
| `test-0000016-pipeline-governance.sh` | "plan/backlog/", "product.yml", "every meaningful artifact write" (Hard Limit 7's operative first sentence), **"push the feature branch"** (Hard Limit 7's push-cadence sentence), "planifest-reversal-assessor", "cross-model" | **Correction to the original findings table: Hard Limit 7's push-cadence sentence is operative and tested, not expository.** The original Class 3 trim candidate ("Hard Limit 7's push-cadence paragraph") is withdrawn - it is not cut. Also: **"planifest-reversal-assessor" must remain mentioned** - req-002 item 5's kept scope ("petition receipt step and the four human-gate conditions") is corrected to also keep the Assess step's first line (spawns the reversal-assessor), so this name is not accidentally dropped. |
| `test-0000005-framework-governance.sh` | "formatting-standards.md", "_version-policy.md" (frontmatter bundle_standards), "skills-inbox", "capability-skills" | No conflict - frontmatter and Capability Skills section untouched by this feature's plan. |
| `test-0000009-rail-tightening.sh` | "Skill Map", "Subagent Decomposition", "Pause Command", "orchestrator-ack" | No conflict - none of these sections are touched by this feature's plan. |
| `test-skill-telemetry.sh` | Telemetry section presence/shape across all phase skills including the orchestrator (`## Telemetry` heading exists, references `emit_event`, unified signal, mandatory emission, block-or-proceed protocol, phase_start/phase_end emission) | No conflict - req-002 item 1 keeps a `## Telemetry` heading in the orchestrator with the failure-marker/build-log paragraph; only the event table and JSON snippets move out. |

**No test pins Fast Path criteria/execution text, the reversal execute/assess mechanics detail, or the Change Pipeline confirm-questions text** - confirming these three Class 1 items (3, 5's execute/assess detail, 7) remain genuinely covered only by the P4 diff review (ADR-002's Detector 2), not by any test.

## Corrections Applied Before Any Edit

1. **req-002 item 5** (reversal execute/assess mechanics) narrowed: keep the Assess step's reversal-assessor-spawn mention in addition to the petition receipt step and four human-gate conditions, so `test-0000016-pipeline-governance.sh`'s "planifest-reversal-assessor" assertion is not broken.
2. **req-002 item 6** (retrofit scan + per-mode discovery content) narrowed: target only the four Mode Taxonomy subsections' bullet lists (Greenfield/Standard Iterative/Retrofit/External Anchor) that duplicate `discovery.template.md`'s own per-mode subsections, plus the Retrofit 6-step scan list. The "Structured Discovery Pass (all modes)" preamble (shared header, lifecycle, partial-failure, cross-session rules) is explicitly NOT cut - it is orchestrator-owned operative logic pinned by `test-0000017-req-006-structured-discovery-pass.sh`, not template-content description.
3. **req-004 Class 3 trim candidate "Hard Limit 7's push-cadence paragraph" withdrawn** - confirmed operative and tested by `test-0000016-pipeline-governance.sh`'s "push the feature branch" assertion. Not trimmed.
4. **req-003 (Class 2 relocation) gains an explicit test dependency**: `test-0000006-build-assessment.sh`'s Model Tier and Parallelism Rules assertions must be updated in the same commit that relocates this content, checking the new `standards/agent-dispatch-standards.md` file instead of the orchestrator.
5. **req-004's test enumeration is corrected from 4 candidate tests to the 10-test inventory above**, sourced from this baseline's `grep -l` rather than the P0 discovery estimate.
