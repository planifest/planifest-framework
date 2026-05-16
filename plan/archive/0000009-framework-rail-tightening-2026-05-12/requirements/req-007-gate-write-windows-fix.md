---
title: "Requirement: REQ-007 - gate-write-windows-fix"
status: "active"
version: "0.1.0"
---
# Requirement: REQ-007 - gate-write-windows-fix

**Feature:** 0000009-framework-rail-tightening
**Source:** Bug discovered during 0000008 P7 — gate-write blocks plan/ writes on Windows once design.md is cleared
**Priority:** must-have

---

## Functional Requirements

- `planifest-framework/hooks/enforcement/gate-write.mjs` (the source file) is fixed to use normalised path comparison when computing `relTarget` from an absolute `rawTarget` and `cwd`
- The fix normalises both `cwd` and `absTarget` with `norm()` before the `startsWith` comparison, eliminating the Windows backslash/forward-slash mismatch that causes `relTarget` to resolve as the full absolute path
- Fixed logic (replacing the existing `cwdWithSep` block):
  ```js
  const absTarget = resolve(cwd, rawTarget);
  const normCwd = norm(cwd);
  const normAbs = norm(absTarget);
  const cwdPrefix = normCwd.endsWith("/") ? normCwd : normCwd + "/";
  const relTarget = normAbs.startsWith(cwdPrefix)
    ? normAbs.slice(cwdPrefix.length)
    : norm(rawTarget);
  ```
- `pause.md` is added to `ALWAYS_PERMITTED_FILES` so the orchestrator can write it regardless of design.md state
- The fix is also applied to `.claude/hooks/enforcement/gate-write.mjs` (the deployed copy) so it takes effect immediately without requiring a setup re-run
- A regression test is added to the test suite verifying that a write to `plan/archive/` with no `design.md` present exits 0

## Acceptance Criteria

- [ ] `planifest-framework/hooks/enforcement/gate-write.mjs` contains the normalised `cwdPrefix` comparison
- [ ] `.claude/hooks/enforcement/gate-write.mjs` contains the same fix
- [ ] `ALWAYS_PERMITTED_FILES` in both copies includes `"pause.md"`
- [ ] New regression test: invoke gate-write.mjs with a `plan/archive/foo.md` target and no design.md → expect exit 0
- [ ] New regression test: invoke gate-write.mjs with a `plan/current/foo.md` target (non-feature-brief) and no sentinel → expect exit 2 (sentinel check still works)

## Dependencies

- None (self-contained hook fix)
