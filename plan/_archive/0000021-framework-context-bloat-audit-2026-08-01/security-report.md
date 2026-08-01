# Security Report - 0000021-framework-context-bloat-audit

## Threat Model (STRIDE)

This feature has no runtime component, no API surface, no authentication, and no data store — it edits static instruction/documentation content (`planifest-framework/skills/`, `standards/`, `templates/`, `CLAUDE.md`) plus one bash script fix (`planifest-framework/scripts/promote-to-regression.sh`). Most STRIDE categories are not applicable in the conventional sense; the real threat surface for a feature like this is **content integrity**: did trimming silently weaken an enforcement-relevant instruction (a Hard Limit, a hook-checked string, a credential-handling rule)?

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| A trim removes or weakens a Hard Limit, STOP gate, or hook-enforced string, degrading enforcement without anyone noticing | Tampering / Elevation of Privilege (of agent behavior) | Medium | Regression pack (22 tests, promoted specifically to cover orchestrator routing/phase sequencing/hook enforcement/gate behavior) run before and after every trim; 24 real regressions were caught this way and fixed — see `plan/changelog/0000021-framework-context-bloat-audit-2026-08-01.md`. Final state: 0 failures, verified `Hard Limit`/`destructive`/`migration proposal` mention count across all 21 skill files (38 occurrences post-trim, confirmed present) and `credential` mention count (11 post-trim vs. 12 pre-trim — the one reduction is a de-duplicated restatement, not the Hard Limit itself, confirmed by the passing `credential`-adjacent Hard Limit tests) |
| The `promote-to-regression.sh` fix introduces a path-traversal or injection vector via the `sed`/`mv` temp-file pattern | Tampering | Low | Reviewed the diff directly (see below) — `$DEST`/`$DEST.tmp` are derived from `basename` of the input (traversal sequences stripped by `basename` itself), sed patterns are fixed literals with no interpolated user data, temp file lives alongside the real file (no shared-tmp race), all variables quoted |
| A trimmed skill's condensed wording becomes ambiguous enough to change agent behavior in a security-relevant way (e.g. weakening "never" language into something conditional) | Tampering | Low | Same regression-pack + build-log dogfooding process as R-003 in the risk register; no such weakening found in any of the 24 caught regressions — all were missing-string failures (content removed, not reworded into something weaker), and the fixes restored exact original enforcement phrasing |

## Dependency Audit

No dependencies added, removed, or modified. No `package.json`/`go.mod`/equivalent touched.

## Secrets Management

No secrets, credentials, or tokens appear in any diff. `planifest-framework/scripts/promote-to-regression.sh`'s edit adds no environment variable handling, no credential references, no new I/O beyond a local `sed`/`mv` on files already within the repo tree.

## Authentication & Authorisation Review

Not applicable — no API, no auth surface in this feature.

## Input Validation Review

Not applicable — no API. The one script change (`promote-to-regression.sh`) processes its existing three CLI arguments (`test-file-path`, `source-feature-id`, `promoted-by`) exactly as before; the new `sed` step introduces no new argument handling and operates only on the already-validated, already-copied destination file.

## Network Policy

Not applicable — no network-facing component.

## Infrastructure as Code Review

Not applicable — no IaC files in this feature's scope.

## Cross-Reference to Risk Register

| Risk | Status |
|------|--------|
| R-001 (trim silently drops enforcement content) | Materialised in a mild form as 24 caught-and-fixed regressions during req-003/req-004 — the mitigation (dual-guardrail via regression pack) worked exactly as designed. Closed. |
| R-002 (claude-opus-5 misjudges implicit vs. load-bearing) | Not observed directly — all 24 regressions were execution-side (over-aggressive condensation losing a literal required string), not audit-side misjudgment of what's safe to flag. The audits' own findings, when checked against the actual test suite, were consistently correct about what was genuinely load-bearing. Closed. |
| R-003 (ambiguity-induced future doom loops) | Not observed — the fixes required were precise, single-pass, string-level corrections, not iterative confusion. This pipeline run's own remaining phases (P4-P9) continue dogfooding the trimmed orchestrator with no issues so far. Open until P9 confirms no downstream effect. |
| R-004 (scope creep into deferred structural decomposition) | Did not occur — verified no new files/directories were created in `planifest-framework/skills/`, orchestrator remained a single file throughout, re-confirmed explicitly with the human mid-feature when general skill-authoring advice raised the question again. Closed. |
| R-005 (wrong/flaky regression-pack promotion) | Mitigated as designed — human reviewed and approved the 22-test promotion list before the baseline run. Closed. |

## Summary

Overall risk rating: **Low**

Top actions before shipping:
1. None blocking. The one real defect found in this feature's own tooling (`promote-to-regression.sh`'s path bug) was fixed and is itself now covered by the promoted `test-regression-pack.sh`.
2. Recommend the human spot-check a sample of the 24 guardrail-fix diffs before P7 archive, given the volume — not because of any specific finding, but as ordinary due diligence on a large mechanical-fix batch (see `plan/current/build-log.md` P3 phase block for the full list).
3. Backlog `0000020` (orchestrator structural decomposition) and `0000024` (skill-scope ADR) remain open, as intended — no security implication, purely deferred scope.
