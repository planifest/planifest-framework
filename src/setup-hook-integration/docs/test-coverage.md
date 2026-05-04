# Test Coverage — setup-hook-integration

## Coverage Summary

| Type | Coverage | Notes |
|---|---|---|
| Unit | 0% | No unit tests for individual bash functions |
| Integration | Partial | `test-setup-telemetry.sh` covers telemetry flag behaviour; 2/11 pass (Windows git env issue — TD-004) |
| E2E | Partial | `test_setup.sh` / `test_setup.ps1` validate basic setup paths for tool targets |

## What is tested

- `--structured-telemetry-mcp` flag creates `.claude/telemetry-enabled` sentinel (REQ-004) — covered, blocked by TD-004
- `--context-mode-mcp` + `--structured-telemetry-mcp` installs `context-pressure.mjs` (REQ-010) — covered, blocked by TD-004
- PostToolUse `settings.json` wiring with correct URL (REQ-008) — covered, blocked by TD-004
- Idempotency: re-run produces exactly one PostToolUse entry (REQ-001) — covered, blocked by TD-004
- Basic tool target setup (claude-code, cursor, etc.) — covered by `test_setup.sh`

## What is not tested

- `skill-sync.sh` operations (add, remove, preserve, sync) — no automated tests
- `commit-msg` hook warning output — no automated tests
- `gate-write.mjs` and `check-design.mjs` enforcement — no automated tests
- Setup.ps1 correctness — partially covered by `test_setup.ps1`

## Recommendation

Add a `test-skill-sync.sh` covering: add (mock curl), install, remove, sync, preserve/unpreserve, and validate_skill_name rejection.
