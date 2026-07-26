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

### TD-003 (RESOLVED, 0000017) — Test suite does not cover `block-bash.sh` node-fallback path

**Files:** `src/context-mode-hooks/tests/test-block-bash.sh`
**Identified by:** docs-agent (Phase 6)
**Severity:** Info

> **Resolution (0000017 req-004, ADR-002):** the dual-path problem no longer exists — the hooks are `.mjs` with a single Node implementation; there is no `jq` path to diverge from. Tests invoke the same `node <script>` path that production uses on every platform.

The original debt, for history: tests exercised the hook scripts in whichever path the test runner resolved (`jq` or `node`), with no explicit test forcing each path.

---

## No Further Debt

No other technical debt was identified during this pipeline run.
