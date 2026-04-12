# Tech Debt — context-mode-hooks

**Component:** context-mode-hooks
**Version:** 0.1.0

---

## Acknowledged Debt

### TD-001 — No input size guard on `command=$(cat)`

**File:** `planifest-framework/hooks/context-mode/block-bash.sh`
**Identified by:** security-agent (Phase 5), security-report.md
**Severity:** Low

`command=$(cat)` reads all of stdin into a variable with no maximum length guard. A command string exceeding available memory would cause the script to hang or crash.

**Why accepted:** Claude Code tool call inputs are bounded in practice. In the intended deployment context (same-user, local dev tool), inputs are short. No known path to trigger this in normal operation.

**Remediation:** Add `head -c 65536` or equivalent to cap stdin before variable assignment. Implement in a future patch when taking up the upstream contribution (ADR-004).

---

### TD-002 — `component.yml` contract outputs description uses deprecated schema

**File:** `src/context-mode-hooks/component.yml`, line 49
**Identified by:** docs-agent (Phase 6) — drift detection
**Severity:** Low (documentation drift only — no functional impact)

The `contract.outputs` description reads:
```
"JSON decision object: {decision: block|allow, reason?: string}"
```
This references the **deprecated** top-level format. The actual output format is:
```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}
```
See ADR-001 and `interface-contract.md`.

**Remediation:** Update `component.yml` line 49 to reflect the correct `hookSpecificOutput` schema.

---

### TD-003 — Test suite does not cover `block-bash.sh` node-fallback path

**Files:** `src/context-mode-hooks/tests/test-block-bash.sh`
**Identified by:** docs-agent (Phase 6)
**Severity:** Info

Tests exercise the hook scripts in whichever path the test runner resolves (`jq` or `node`). There is no explicit test that forces the `node` fallback path when `jq` is present, or vice versa.

**Why accepted:** The node fallback was validated on the Windows dev machine where `jq` is absent (all 55 tests pass in that environment). Dual-path testing is a future hardening concern.

**Remediation:** Add a `FORCE_NODE_FALLBACK=1` env var to hook scripts and corresponding test assertions.

---

## No Further Debt

No other technical debt was identified during this pipeline run.
