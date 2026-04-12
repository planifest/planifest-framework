# Risk — context-mode-hooks

**Component:** context-mode-hooks
**Version:** 0.1.0

Cross-references `plan/current/risk-register.md` and `plan/current/security-report.md`.

---

## Active Risks

| ID | Risk | Severity | Status | Mitigation |
|----|------|----------|--------|------------|
| R-001 | Allowlist too narrow — legitimate Bash commands blocked | Low | Open | Conservative v1 list. Agent can work around by using ctx_execute. Future: configurable allowlist. |
| R-002 | settings.json schema assumption — Claude Code changes format silently | Low | Open | Verified against current Claude Code docs (Q-001 resolved). Smoke test open item. |
| R-003 | Hook stdin payload scope — full tool_input may not be available | Low | Resolved | Confirmed: full tool_input is present on stdin for PreToolUse hooks. |
| R-004 | Windows bash shebang resolution — scripts may not invoke correctly | Low | Open/Accepted | Git Bash / WSL required. Documented in quirks Q-005. PowerShell equivalents deferred to v2. |
| R-005 | settings.json merge overwrites existing hooks | Low | Mitigated | Additive merge implemented in `merge_hook_settings`. Re-run idempotent. |
| R-006 | Agent ignores block message — compliance not guaranteed | Low | Open | Quality concern, not security. Addressed by block message design (explicit ctx_* call shown). |
| R-007 | Upstream script divergence — planifest-framework and mksglu/context-mode drift | Low | Open | Roadmap item. ADR-004 documents split. Contribution planned post-pipeline. |
| R-008 | NFR-001 latency not met on Windows (node fallback 250-310ms) | Low | Accepted | Documented deviation. Install jq to restore fast path. Not a functional regression. |

---

## Resolved Risks

| ID | Risk | Resolution |
|----|------|-----------|
| A-001 | PreToolUse hook output schema format unknown | Resolved — hookSpecificOutput format confirmed via docs research. See ADR-001. |
| R-003 | Hook stdin payload scope | Resolved — full tool_input confirmed on stdin. |

---

## Security Risks (from security-report.md)

All findings are Low or None. No critical or high security risks. See `plan/current/security-report.md` for full STRIDE analysis.

| Threat | Severity |
|--------|----------|
| Stdin payload tampering | Low — same-user invocation only |
| Memory exhaustion via large stdin | Low — Claude Code tool inputs bounded |
| hookSpecificOutput schema change | Low — add smoke test (open item) |
| Concurrent setup.sh execution | Low — not a normal operation |
