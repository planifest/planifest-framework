---
title: "ADR-005: gate-write Windows path normalisation via posix-norm before startsWith"
summary: "The gate-write hook normalises both the cwd and target path to forward-slash form before the startsWith comparison, eliminating the mixed-separator bug that caused always-permitted paths to be blocked on Windows."
status: "accepted"
version: "0.1.0"
---
# ADR-005 - gate-write Windows path normalisation via posix-norm before startsWith

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000009-framework-rail-tightening
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-05-09

---

## Context

REQ-012 identifies a Windows-specific bug in `planifest-framework/hooks/enforcement/gate-write.mjs`. The hook computes a relative path from the absolute target path by stripping the cwd prefix:

```js
const cwdWithSep = cwd + "/";
const relTarget = absTarget.startsWith(cwdWithSep)
  ? absTarget.slice(cwdWithSep.length)
  : rawTarget;
```

On Windows, `path.resolve()` returns backslash-separated paths (`C:\d\planifest\plan\archive\...`) while `cwd` may be a forward-slash string or mixed. The `startsWith` comparison fails silently — `relTarget` falls back to the raw target, which is an absolute path, not a relative one. The subsequent always-permitted prefix checks (`plan/`, `plan/archive/`, etc.) test for relative prefixes and fail. When `design.md` is absent (e.g., after P7 clears `plan/current/`), Check 2 then blocks the write entirely.

The bug manifests specifically during P7 when `design.md` is deleted before archive writes complete, making it a ship-blocker for all Windows users.

A decision is needed on the normalisation approach.

---

## Decision

Both `cwd` and `absTarget` are normalised to forward-slash form using `path.posix`-style replacement before the `startsWith` comparison:

```js
const norm = (p) => p.replace(/\\/g, "/");
const absTarget = resolve(cwd, rawTarget);
const normCwd = norm(cwd);
const normAbs = norm(absTarget);
const cwdPrefix = normCwd.endsWith("/") ? normCwd : normCwd + "/";
const relTarget = normAbs.startsWith(cwdPrefix)
  ? normAbs.slice(cwdPrefix.length)
  : norm(rawTarget);
```

The `norm()` helper is a one-liner that replaces all backslashes with forward slashes. This is safe for path comparison purposes on Windows because Windows accepts forward slashes in path operations, and the normalised string is used only for prefix comparison — never passed to a native I/O call.

The fix is applied to both the deployed hook (`.claude/hooks/enforcement/gate-write.mjs`) and the source copy (`planifest-framework/hooks/enforcement/gate-write.mjs`) so future setup runs deploy the fixed version.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Use `path.relative(cwd, absTarget)` instead of `startsWith` | Standard Node.js API; no manual normalisation | `path.relative` on Windows returns backslash-separated relative paths (e.g. `plan\archive\...`); the always-permitted checks use forward slashes — same mismatch, different location | Moves the problem, doesn't solve it |
| Normalise only `cwdWithSep` (not `absTarget`) | Smaller change | `absTarget` still has backslashes; `startsWith` still fails | Incomplete fix |
| Use `fileURLToPath` / `pathToFileURL` | Platform-agnostic | Not applicable here — inputs are filesystem paths, not URLs; adds unnecessary indirection | Wrong tool for the job |
| Maintain two code paths (Windows vs POSIX) | Explicit platform handling | More complex; diverging paths create future maintenance burden; the `norm()` approach already handles both platforms without branching | Over-engineered |
| Switch to `path.win32` / `path.posix` explicitly | Explicit | Requires knowing the platform at runtime; `norm()` is platform-agnostic and always safe for comparison | Unnecessary complexity |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | `hooks/enforcement/gate-write.mjs` updated with `norm()` helper and normalised `startsWith` comparison; `.claude/hooks/enforcement/gate-write.mjs` (deployed copy) receives the same fix |

---

## Consequences

**Positive:**
- P7 archive writes succeed on Windows regardless of `design.md` state
- Always-permitted path checks work correctly on both Windows and POSIX without platform branching
- Fix is minimal — 5 lines changed; easy to review and audit
- No new dependencies; `norm()` is a pure string operation

**Negative:**
- Two copies of `gate-write.mjs` must be kept in sync (source and deployed); mitigated by setup copying the source to the deployed location

**Risks:**
- If a future contributor modifies only one copy and not the other, the bug could reappear in the source while the fix is live (or vice versa); mitigated by a comment in both files noting the dual-copy relationship

---

## Related ADRs

- None

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by planifest-adr-agent.*
