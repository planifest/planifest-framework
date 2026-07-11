# Verify-by-Execution Report — 0000016-pipeline-governance-and-loop-engineering

**Toggle:** `planifest-overrides/loop-toggles.yml` absent → `verify_by_execution: off` (ADR-003). This report is therefore non-gating; it demonstrates the skill's method on this feature's own deliverables and provides the acceptance-criteria evidence for REQ-020's "at least one criterion verified by running the software".
**Software exercised:** the three new executables invoked directly with real inputs; the commit-msg git hook observed blocking a live commit during this run.

## Observations (all real executions, this session)

| Requirement | Criterion | Method | Outcome | Observation evidence |
|-------------|-----------|--------|---------|---------------------|
| REQ-018 | Weakening write blocked with named line | Hook invocation: real stdin JSON payload (Write, criterion removed) piped to `ratchet-check.mjs` in a project fixture with active loop-state | verified | exit 2; deny message names `removed: "criterion beta holds"` and the `.ratchet-approve` instructions |
| REQ-018 | Strengthening write passes | Same, with an added criterion | verified | exit 0 |
| REQ-018 | Marker consumed single-use | Human-style marker line seeded, weakening re-run | verified | exit 0; `.ratchet-approve` empty/deleted afterwards; consumption appended to ratchet-log |
| REQ-018 | Never blocks unexpectedly | Malformed (non-JSON) stdin; and fixture with no active loop-state | verified | exit 0 in both |
| REQ-003/004 | Version derived per policy on a multi-component fixture | CLI: `node product-version.mjs --root <fixture>` across 6 fixtures | verified | `max-component-version`→`1.10.3` (exit 0); `explicit`→`2.5.1` (exit 0); `external`→exit 5; invalid semver→exit 2; unknown policy→exit 2; absent manifest→exit 4 |
| REQ-014 | Seeded defects caught, clean passes | CLI: `node consistency-check.mjs <fixture>` on clean + 5-defect fixtures | verified | clean: exit 0 "clean"; seeded: exit 1 listing all 5 defect classes (missing US source, >3 ACs, orphaned ADR-009, missing mitigation, missing Scope section) |
| (commit standards, pre-existing) | >72-char subject blocked | Live `git commit` during this run | verified | commit-msg hook rejected a 73-char subject with the truncation hint; retried at ≤72 and passed |
| REQ-002/013/016/017/019/021 (behavioural ACs) | Live pipeline-run behaviours (backlog pickup dialogue, critic trial on ≥2 features, seeded reversal end-to-end, gates under continuous run, pre-P7 ordering in anger) | — | not-verifiable (this run) | Deliberately gated by Wave 1's "Ships When" criteria (report-only trials on real features); static text/structure assertions covered in `test-0000016-pipeline-governance.sh` (97/97) |

## Semantic AC-coverage summary (P4 check 1)

Every REQ-001…REQ-021 has test assertions labelled with its req-ID in `planifest-framework/tests/test-0000016-pipeline-governance.sh` (97 assertions, all passing). Static/deterministic ACs are fully covered. Process/live-run ACs are declared not-statically-verifiable and are carried by the Wave 1 "Ships When" gate (feature-brief § Waves) — recorded here rather than silently passed.

## CI check results (P4)

| Check | Result |
|-------|--------|
| Library audit | pass (vacuous — no dependency manifests changed) |
| Semantic traceability | pass (see above; live-run ACs flagged, not silently passed) |
| Lint/syntax — `node --check` ×3 new .mjs | pass |
| Lint/syntax — `bash -n` setup.sh + suite + helper | pass |
| Test — feature suite | pass (97/97) |
| Test — full harness | 7/9 suites pass; 2 pre-existing macOS-only failures (BSD `head -n -1` GNU-ism + pipefail SIGPIPE in suite-local plumbing), unrelated to this feature's files, green in Linux CI — filed to `plan/backlog/0000001-flaky-test-suite-sigpipe/` |
| Build | n/a (markdown component-pack, no build step) |

Self-correction cycles used: 0 (all checks passed first run at P4; the one defect found during P3's TDD — macOS `/var` symlink breaking the ratchet path check — was fixed inside the P3 red→green cycle, not here).
