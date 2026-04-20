# Tech Debt — setup-hook-integration

## TD-001 — Skill name not validated before path operations (Security F-002)

**File:** `planifest-framework/scripts/skill-sync.sh`
**Severity:** Medium
**Impact:** Skill name passed to `rm -rf "$dir/$name"` without sanitisation — path traversal possible via crafted name.
**Fix:** Add `validate_skill_name()` guard: `[[ "$1" =~ ^[a-zA-Z0-9_-]+$ ]]`

## TD-002 — `get_skill_scope()` interpolates `$name` into `node -e` string (Security F-001)

**File:** `planifest-framework/scripts/skill-sync.sh:78`
**Severity:** Medium
**Impact:** Single quotes in skill name could inject arbitrary JS into the node -e subprocess.
**Fix:** Pass `$name` as env var (`SKILL_NAME="$name" node -e "...process.env.SKILL_NAME..."`) consistent with all other manifest functions.

## TD-003 — `--from` URL scheme not validated (Security F-003)

**File:** `planifest-framework/scripts/skill-sync.sh:218–220`
**Severity:** Low-Medium
**Impact:** `curl` would follow `file://` or `ftp://` schemes, enabling local file reads.
**Fix:** `[[ "$from_url" != https://* ]] && die "--from URL must use https://"`.

## TD-004 — `test-setup-telemetry.sh` fails on Windows due to git safe.directory

**File:** `planifest-framework/tests/test-setup-telemetry.sh`
**Severity:** Low
**Impact:** 9/11 tests fail because `git init` in `mktemp` dirs fails with "dubious ownership" on Windows.
**Fix:** Refactor `make_workspace()` to use actual project root with `.claude/` backup/restore, run outside ctx_execute sandbox.

## TD-005 — `test-context-pressure.sh` fails in ctx_execute sandbox

**File:** `planifest-framework/tests/test-context-pressure.sh`
**Severity:** Low
**Impact:** Exit code 1 from `node context-pressure.mjs` in ctx_execute environment; passes when run from project root directly.
**Fix:** Investigate sandbox environment differences; or run tests via `bash` directly rather than inside ctx_execute.

## TD-006 — `setup.ps1` not updated with skill subcommand routing

**File:** `planifest-framework/setup.ps1`
**Severity:** Low
**Impact:** `setup.ps1 add-skill` / `remove-skill` subcommands not implemented; Windows users must use `skill-sync.ps1` directly.
**Fix:** Add equivalent subcommand routing at top of `setup.ps1` to delegate to `skill-sync.ps1`.
