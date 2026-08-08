---
title: "ADR 003: Em dash guard attachment point and bypass"
summary: "Attach the em dash guard as a PreToolUse(Write, Edit) hook sibling to gate-write.mjs, scoped to Planifest prose paths, bypassed by an in-content sentinel comment rather than a CLI flag."
status: "proposed"
version: "0.1.0"
---
# ADR-003 - Em dash guard attachment point and bypass

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Component:** planifest-framework
**Date:** 2026-08-08

## Context

REQ-006 asks for a deterministic check that rejects U+2014 (em dash) in Planifest artifacts at write time, since instructing the rule in skill prose has demonstrably failed: the rule is re-explained every session and still gets violated. Two choices are forced together here, because the bypass a guard needs depends on where it attaches.

`commit-msg` already blocks AI attribution and affirmatory language, with a proven bypass: `git commit --no-verify`. That bypass is provided by Git itself, not designed by this repo. A `PreToolUse(Write, Edit)` hook has no equivalent. Claude Code offers no per-call "skip this hook" flag, so if the guard attaches there, a bypass has to be designed rather than inherited. Without one, any legitimate em dash becomes unwritable, including a quoted excerpt, a code sample containing the character, or this hook's own test fixtures.

## Decision

**Attachment point:** a `PreToolUse(Write, Edit)` hook, `planifest-framework/hooks/enforcement/em-dash-guard.mjs`, sibling to `gate-write.mjs` and `ratchet-check.mjs`, not a git hook. It reads `tool_input.content` (Write) or `tool_input.new_string` (Edit) from the same JSON envelope `gate-write.mjs` already reads, scans for U+2014, and exits 2 to block. It is a new sibling file, not a modification of `gate-write.mjs`, so a defect in one never disables the other.

Scope: `plan/current/`, `docs/`, `planifest-framework/skills/`, `planifest-framework/templates/`, `planifest-framework/standards/`. Outside those five paths the hook passes without inspecting content at all. Source code, `plan/_archive/`, `plan/changelog/`, and this repo's own test fixtures under the hook's test directory are exempt. Only the write being made right now is scanned; the hook never retroactively scans the existing file or the repo, matching the `commit-msg` precedent of inspecting only what is being committed right now.

**Bypass mechanism:** a single-line sentinel comment, `<!-- planifest-em-dash-allow -->`, present anywhere in the content being written, allows that write through regardless of em dash matches. It is reusable, not single-use: a literal quotation containing an em dash is not a one-off event the way a ratchet weakening is, and may recur across many writes to the same artifact. The sentinel is typed into the artifact's own content, not passed as a hook config flag or environment variable, so the bypass is visible in the artifact's diff rather than invisible in tool configuration. Any agent or human may write the sentinel; it carries no approval semantics, only a declaration that the em dash at that location is intentional.

**Self-reference (fixtures and this ADR):** the hook's own test fixtures, and any Planifest artifact discussing the em dash character itself (such as this ADR), fall inside the scoped paths if they live under `plan/current/`, `planifest-framework/standards/`, etc. Two different escapes apply depending on which:
- Test fixture files under the hook's own test directory are placed outside the five scoped path prefixes entirely (structural exemption, not a bypass), since a guard's fixtures must be able to contain the exact character it is designed to catch without asserting anything about the sentinel path.
- Any prose artifact that must discuss or display U+2014 while remaining inside a scoped path (this ADR, `standards/` documentation of the guard itself) uses the sentinel comment. This ADR's own prose avoids the character rather than invoking the sentinel, since none of the four em dashes above are needed for the argument to hold.

**Asymmetry considered and rejected:** `ratchet-check.mjs` has a precedent where the bypass marker (`.ratchet-approve`) is human-written only, agents are forbidden to write it, and it is single-use and consumed. That asymmetry fits a ratchet, where the thing being bypassed is a deliberate weakening of a commitment the human made earlier. An em dash is not a commitment being weakened; it is a style rule about a single character, and the correct replacement is frequently not obvious from a mechanical rule (a comma, a colon, or a sentence break, decided per sentence). Requiring a human-only, single-use marker here would make every legitimate quotation or fixture block on a human round-trip, for a rule with no weakening semantics to guard. The sentinel is therefore reusable and writable by either party, unlike `.ratchet-approve`.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| `commit-msg` style git hook | Proven bypass (`--no-verify`) already exists, no new bypass to design | Only sees content at commit time; the artifact is already written to disk and may already have been read by another agent or session before any check runs | The guard exists to stop the character landing in the file at all, not to catch it after the fact. A write-time gap defeats the purpose REQ-006 states directly. |
| `validate-agent` CI check at P4 | Latest possible feedback point, catches anything upstream hooks miss | Would fail against the 99 existing live files immediately unless cleanup runs first; also only fires once per pipeline run, not per write, so drift accumulates between P4 checks | Too late and too coarse. The write-time hook is the primary control; a CI check does not replace it and is not requested by REQ-006's acceptance criteria. |
| Instruction-only in skill prose | No new code, no hook to maintain | This is the status quo, and it demonstrably fails: the rule is re-explained every session and still violated | REQ-006 exists specifically because this alternative already failed in practice. |
| Path allowlist as the bypass (instead of a sentinel) | No visible marker text needed in the artifact | An allowlisted path exempts every future write to that path, not just the one write with a legitimate reason; the exemption lives in hook config, invisible in the artifact's own diff | Fails the same auditability requirement the sentinel is designed to satisfy: the reason for a bypass should be visible where the em dash actually is. |
| Environment variable as the bypass | Trivial to implement, no content scanning needed for the escape path | Invisible in the artifact's diff and in version control; any process in the session's environment can set it, with no per-write scoping | Same auditability failure as the path allowlist, and strictly less scoped: an env var bypasses every write in the process, not one file. |
| No bypass at all | Simplest possible hook, nothing to misuse | A legitimate em dash, in a quotation, a code sample, or the hook's own fixtures, becomes permanently unwritable inside the scoped paths | Directly contradicts the requirement's own critical self-reference: the fixtures for this very hook need to contain the character it blocks. |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | New file `hooks/enforcement/em-dash-guard.mjs`. `setup.sh`/`setup.ps1` gain a registration entry following the `gate-write.mjs` pattern. `standards/` documents the sentinel bypass alongside the other enforcement hooks. No change to `gate-write.mjs` or `ratchet-check.mjs` themselves. |

## Consequences

**Positive:**
- The em dash rule is enforced deterministically instead of re-explained every session.
- A legitimate em dash (quotation, fixture, this ADR's own discussion) stays writable via a visible, auditable marker rather than being permanently blocked or requiring a config change.
- A defect in this hook cannot disable `gate-write.mjs` or `ratchet-check.mjs`, since it is a separate sibling file.

**Negative:**
- The hook fires on every Write/Edit within five path prefixes, adding a small fixed scan cost per call.
- The sentinel is reusable and not scoped per-instance, so a sentinel added for one legitimate em dash also silently permits any other em dash later added to the same write, with no per-occurrence tracking.

**Risks:**
- An agent could add the sentinel to bypass the rule broadly rather than for a genuine case, since nothing prevents its use beyond the rule stated in this ADR and in `standards/`. Mitigation: the sentinel is visible in the diff, so P4 human review of the cleanup and ordinary code review both surface a misused sentinel.
- If a future write path reaches the hook with content under a key other than `content` or `new_string`, the hook fails open (exit 0, per ADR-005) and the em dash passes through unnoticed. Mitigation: acceptance criteria for req-006 assert against both `Write` and `Edit` envelopes directly.

## Related ADRs

- ADR-004 (framework governance feature) - depends-on, for the always-permitted-paths and exit-code convention this hook follows.
- ADR-005 (framework rail tightening feature) - depends-on, for the fail-open-on-unexpected-error convention this hook follows.
- ADR-001 (0000017, ratchet approval mechanism) - related-to, as the source of the human-marker precedent this ADR considers and departs from.

## Supersedes

- None.

## Superseded By

- None.
