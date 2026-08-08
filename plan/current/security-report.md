# Security Report - 0000028-telemetry-hardening-and-enforcement-fixes

Reviewed range: `b393dd1..HEAD` (P3 plus P4 implementation, 41 commits). The scope of the
change is local tooling running on the machine of the human on the loop: Node ESM hook
scripts, `setup.sh` / `setup.ps1`, and a
punctuation cleanup across markdown artifacts. There is no auth surface, no API, no PII, no
database, and no deployed endpoint in this feature. Severities are rated against that
reality and are not inflated. One High finding is reported, and it is a control that
silently fails open rather than an exploitable vulnerability; the distinction is stated
explicitly in the finding itself.

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| `setup.sh` wires every `hooks/enforcement/` hook into `.claude/settings.json` as a bare `.mjs` path with no interpreter, while the hook files are committed non-executable. The wired command exits 126 and the hook never runs. This feature's own new enforcement hook is affected, along with the pre-existing write gate and both telemetry backstops. | Tampering (enforcement control defeated) | **High** | **Not mitigated.** See SEC-001. Proven by execution, not inference. |
| The new stderr fallback in `record-telemetry-failure.mjs` (req-003) emits a line on a failed marker write. stderr is not gitignored the way `plan/.telemetry-failures/` is, so anything it interpolates reaches the terminal and the session transcript. | Information Disclosure | Low | Verified what it actually interpolates (`record-telemetry-failure.mjs:115-121`): the hook name (a hard-coded literal at each of the 4 call sites), the marker path, and the *write* error's constructor name and message. It does not interpolate `BACKEND_URL`, the event body, request headers, or any environment value. The write error is a filesystem error (`EACCES`, `ENOSPC`, `EROFS`), whose message carries a path, not remote configuration. The one residual channel is the marker path, whose filename slug derives from the *original* error message. See SEC-002. |
| `emit-event-receipt.mjs` builds a receipt path from the agent-supplied `envelope.phase`. Its `KNOWN_PHASES` closed-set guard (the CWE-22 defence added at 0000027's P5) was rewired by req-002 to derive from the new shared `phase-enum.mjs`. A refactor of a path-traversal guard is the highest-consequence change in this diff. | Tampering (CWE-22, Path Traversal) | Not weakened | **Verified intact.** `PHASE_ENUM` (`phase-enum.mjs:34-42`) holds exactly the same 7 values as the inline `new Set([...])` literal it replaced: `spec`, `adr`, `codegen`, `validate`, `security`, `docs`, `ship`. `KNOWN_PHASES` is still `new Set(PHASE_ENUM)`, still consulted at `emit-event-receipt.mjs:93`, and the reject branch still throws before the `join()` at line 104. `KNOWN_EVENT_TYPES` was not touched. The guard is byte-equivalent in effect; the refactor only removed the possibility of it drifting out of step with `check-telemetry-receipts.mjs` and `resolve-phase.mjs`. |
| Bounded retry (req-001) could be used to amplify outbound traffic, or could stall a hook past its budget and wedge a session. | Denial of Service | Low | Amplification is bounded at 3x and fires only on a network-level failure, and the events themselves are rare: `context-pressure.mjs` posts only above 70 percent context fill (`context-pressure.mjs:101`), and `emit-phase-start.mjs` is guarded by a per-session-per-phase dedup flag written before the POST. Not a viable amplification vector. Exit-zero-on-every-path holds: `postEvent`'s loop terminates deterministically (it throws once `attempt >= RETRY_DELAYS_MS.length`), `clearTimeout` runs in a `finally` on every path including the `return`, and all 3 callers wrap the `await` in a top-level `try/catch` that routes to `recordTelemetryFailure()` and falls through to a normal exit. No path can hang. The worst-case wall time is understated in the risk register; see SEC-003. |
| A slow but live backend produces an `AbortError` at the 3s timer, which the retry predicate classifies as a network-level failure, so the same event is POSTed up to 3 times against a listener that may already have processed each one. | Repudiation (telemetry audit trail) | Low | The envelope is byte-identical across retries, because `timestamp` is fixed before the first attempt in all 3 callers. A listener can therefore deduplicate on `(session_id, phase, event, timestamp)`. There is no explicit idempotency key in the envelope, so this is the listener's choice rather than a contract. See SEC-004. |
| `em-dash-guard.mjs` can block Write and Edit with exit 2. A defect or an abuse could deny legitimate writes, or could disable the enforcement hooks it sits beside. | Denial of Service | Low | It exits 2 only when all of: the target resolves under one of 5 fixed relative prefixes, the content contains U+2014, and the sentinel is absent. Every other path, including a malformed stdin envelope and any thrown error, exits 0 (`em-dash-guard.mjs:123-125`). It is wired as *additional* `PreToolUse` entries (`setup.sh:612-613`), not as a replacement for or a modification of `gate-write.mjs` or `ratchet-check.mjs`, so a defect in it cannot disable either. It follows `gate-write.mjs`'s existing convention exactly (message on stdout, exit 2). |
| The em dash guard's bypass sentinel is matched anywhere in the content being written, including inside prose that merely discusses the sentinel. Any document explaining the rule exempts itself from the rule. | Elevation (of a control) | Low | Reproduced accidentally while writing this report. See SEC-005. Kept at Low deliberately: this is a formatting rule about one character, not an authorisation control. |
| The sentinel is agent-writable, reusable, and not human-gated. | Elevation (of a control) | None | Proportionate assessment: an em dash carries no weakening semantics, so there is nothing here that needs a human-only single-use marker. The guard is also trivially bypassable in two other ways by construction (writing the file via Bash, since the hook only matches `Write` and `Edit`; or passing an absolute path outside `cwd`, since `relTarget` then falls back to an absolute path that can never match a relative prefix). The contrast that matters is that `plan/current/.ratchet-approve`, which *is* a governance control, remains human-only and single-use. ADR-003 draws that distinction correctly and does not model the sentinel as an auth control. |
| Hooks are installed as copies into `.claude/hooks/`, which is gitignored and untracked. After req-002 a single shared module backs up to 12 hooks, so one tampered file has a wider blast radius than before, and `git status` will not show it. | Tampering | Low | Does not cross a trust boundary: anyone with write access to `.claude/hooks/` already has arbitrary local code execution on that machine. Verified live that the current install has zero drift, zero missing modules, and zero orphans against `planifest-framework/hooks/`, and that installed copies are `0644`, not group- or world-writable. R-003 already documents the recovery path (re-run setup). |
| A telemetry hook could import a shared module that the install never copied, which fails at ESM module-load time before the hook's own `try/catch` runs, defeating the exit-zero invariant. | Denial of Service | None | Verified the install topology holds. `install_tier1_hooks()` copies `hooks/enforcement/*.mjs` (`setup.sh:433`) before `hooks/telemetry/*.mjs` (`setup.sh:455`), and `install_enforcement_hooks()` is called unconditionally for Claude Code (`setup.sh:1197`). `hooks/telemetry/` is therefore never present without `hooks/enforcement/`, so the cross-directory imports (`../enforcement/read-stdin.mjs`, `../enforcement/phase-enum.mjs`) always resolve. ADR-002's placement argument is sound, and the `setup.sh:455` / `setup.ps1:706` glob widening is what makes it true for Cursor, Windsurf and Cline. |
| The em dash cleanup rewrote roughly 100 markdown artifacts. A mechanical replacement could have changed the meaning of a security-relevant or governance-relevant document rather than only its punctuation (R-002, A-004). | Tampering (governance integrity) | None found | Analysed all 104 changed markdown files programmatically, comparing word-token streams either side of every changed line. 41 line pairs differ in word content. 14 are an em dash used as a "not applicable" table cell, replaced with `N/A` (semantically identical). The rest are a heading restructure, the rule statement in `language-quirks-en-gb.md` being rewritten and strengthened, a new `Em Dash Prohibition` section in `formatting-standards.md`, a `writtenAt` timestamp bumped by the req-004 install refresh, and artifacts authored fresh by this feature. See SEC-006 for the single governance-relevant document touched. |
| `setup.sh` was modified by this feature; 0000027's P5 fix validated `--backend-url` against a URL regex before it reaches a hook `command` string that the shell executes. | Tampering / Elevation (command injection) | None | Verified the fix is intact and untouched: `setup.sh:1443` and `setup.ps1:51` still validate `^https?://[A-Za-z0-9.-]+(:[0-9]+)?(/[A-Za-z0-9._/-]*)?$` and exit 1 otherwise. This feature's `setup.sh` diff does not reference `backend_url` at all. The new `em_dash_cmd` follows the established safe pattern for the value itself: it is a literal derived from a call-site argument, passed to `node -e` through an environment variable rather than interpolated into the script text. |

## Findings

### SEC-001 (High) - every `hooks/enforcement/` hook is wired to a command that cannot execute, so the enforcement layer silently does not run

This is the most consequential finding in the review, and it is proven by execution rather
than inferred.

**The defect.** `setup.sh:576-578` builds the enforcement hook commands as bare paths:

```
local gate_cmd="$hooks_dir_rel/gate-write.mjs"
local ratchet_cmd="$hooks_dir_rel/ratchet-check.mjs"
local em_dash_cmd="$hooks_dir_rel/em-dash-guard.mjs"
```

and pushes them into `.claude/settings.json` verbatim (`setup.sh:607-614`). No `node`
prefix. Meanwhile 9 of the 10 files in `planifest-framework/hooks/enforcement/` are
committed with git mode `100644`, and `setup.sh` copies them with a plain `cp` that never
sets an exec bit (the only `chmod +x` calls in the file, lines 846 to 848, 1420 and 1516,
cover the git hooks and the sync script, not these). The shell therefore cannot execute the
wired command.

**Proof.** Same payload, same file, two invocations:

```
$ printf '%s' '{"cwd":"...","tool_input":{"file_path":"plan/current/zz.md","content":"a <U+2014> b"}}' \
    | .claude/hooks/enforcement/em-dash-guard.mjs
exit=126                                    <- the wired form: permission denied

$ ... | node .claude/hooks/enforcement/em-dash-guard.mjs
[Planifest] Em dash (U+2014) found in 'plan/current/zz.md' at line(s): 1. ...
exit=2                                      <- blocks correctly when it can run
```

`gate-write.mjs` returns 126 identically. Claude Code treats any exit other than 2 as
non-blocking, so all of these fail open with no signal:

| Hook | Wired as | Effect |
|---|---|---|
| `gate-write.mjs` | `PreToolUse(Write,Edit)` | Design-conformance write gate, inert |
| `em-dash-guard.mjs` | `PreToolUse(Write,Edit)` | This feature's REQ-006 deliverable, inert |
| `auto-trigger-orchestrator.mjs` | `UserPromptSubmit` | Inert |
| `check-orchestrator-presence.mjs` | `UserPromptSubmit` | Inert |
| `check-design.mjs` | `UserPromptSubmit` | Inert |
| `check-telemetry-failures.mjs` | `UserPromptSubmit` | Inert |
| `check-telemetry-receipts.mjs` | `UserPromptSubmit` | Inert |
| `ratchet-check.mjs` | `PreToolUse(Write,Edit)` | **Works**, solely because its source file happens to carry mode `100755` |

**Why this is in scope rather than local machine state.** The root cause is entirely repo
state: the committed file modes under `planifest-framework/hooks/enforcement/`, and the
command string generated by `setup.sh:576-578`. Both reproduce deterministically on every
consumer's install, because `cp` propagates the source mode (which is exactly why
`ratchet-check.mjs` alone survives). This is not a stale `.claude/` directory.

**`setup.ps1` already does it correctly**, which makes the fix unambiguous.
`setup.ps1:528` builds the same hook as `"node $HooksDir/gate-write.mjs"`. `setup.sh` also
already uses the `node` prefix for its telemetry hooks, for example the `Skill` matcher
entry `PLANIFEST_TELEMETRY_URL=... node .claude/hooks/telemetry/resolve-phase.mjs`. The
bare-path form is an outlier confined to the enforcement block.

**Why High, and what High means here.** There is no exploitable vulnerability and no
attacker in this model. The severity comes from two properties: several security-adjacent
and governance controls do not run at all, and they fail open in complete silence, which is
precisely the failure mode this framework's own ADR-005 and NFR-001 discipline exists to
prevent everywhere else. Two of the inert hooks, `check-telemetry-failures.mjs` and
`check-telemetry-receipts.mjs`, are the deterministic backstops that catch an orchestrator
claiming `Telemetry: emitted` when no event was sent, so the repudiation gap that feature
0000027 was built to close is currently open again.

It also means REQ-006 is not satisfied in the installed state. The write-time em dash guard
this feature ships does not fire. The P4 test suite could not have caught this, because
`test-0000028-req-006-em-dash-guard.sh` invokes the hook as `node em-dash-guard.mjs`, which
is the form that works, rather than through the command string `setup.sh` actually writes.
That gap between "tested form" and "wired form" is worth closing on its own.

**Recommended fix.** Prefix the three enforcement command strings with `node ` in
`setup.sh:576-578` and the `UserPromptSubmit` equivalents alongside them, matching
`setup.ps1:528`. This is preferable to a `chmod +x` on the sources because Windows has no
exec bit, so the interpreter prefix is the only portable form. Add a test asserting that
the command string written into `settings.json` is itself executable and returns 2 on a
violating payload, rather than testing the hook only via a hand-built `node` invocation.

### SEC-002 (Low) - stderr fallback can echo a slugified fragment of a malformed backend URL

`planifest-framework/hooks/telemetry/record-telemetry-failure.mjs:115-121`.

The line interpolates `hookName`, `markerPath`, and the marker-write error's type and
message. Three of those four are safe by construction. `markerPath` is the residual: its
filename slug derives from the original error's message, and while a normal `fetch`
transport failure in Node produces `fetch failed` with the useful detail nested in
`err.cause` (so no URL reaches the message), a malformed `PLANIFEST_TELEMETRY_URL` produces
`Failed to parse URL from <url>`, which does. A lowercase-hex token embedded in such a URL
could survive slugification within the 60-character cap.

Why this stays Low: the same string was already the gitignored marker file's own filename
before this feature, so the content is not new, only the channel is. Both destinations are
local. No credential value is constructed here, and the backend URL is not printed anywhere
directly. Cross-references R-008, which is otherwise confirmed closed.

No change required. If the human on the loop wants the residual removed, the narrow fix is
to print the marker's *directory* rather than the full path, since the slug is the only
part carrying error-derived content.

### SEC-003 (Low) - R-007 understates the retry's worst-case latency by an order of magnitude

`plan/current/risk-register.md`, R-007 mitigation column states "2 attempts, 300ms budget,
600ms worst-case latency".

600ms is the sleep budget, not the wall time. Each of the 3 attempts gets its own
`AbortController` and its own 3s abort timer (`emit-event.mjs:31-32, 41-42`). Against a host
that blackholes packets rather than refusing the connection, every attempt runs to the full
3s abort, so the worst case is 3 x 3s plus 2 x 300ms, which is 9.6s of hook wall time
against 3s before this feature. That is still well inside the hook timeout and cannot wedge
a session, so the exit-zero invariant is unaffected.

It matters because R-007's entire argument for accepting the "retry masks a degraded
backend" tradeoff rests on the bound being small. Against a refusing listener on localhost
(the common case, since `ECONNREFUSED` returns immediately) the real cost is indeed about
600ms, which is presumably where the figure came from. Recommend recording both figures so
the accepted tradeoff sits against the true bound.

### SEC-004 (Low) - an aborted-then-retried POST can duplicate a telemetry event

`planifest-framework/hooks/telemetry/emit-event.mjs:60`.

The retry predicate is `!(err?.name ?? "").startsWith("http_")`, which correctly excludes
HTTP error statuses. It does not exclude `AbortError`. An abort means the 3s timer fired,
which is the signature of a backend that received the POST and was slow to answer, not of a
listener gap. Retrying re-sends an event the listener may already have recorded.

The design rationale in `emit-event.mjs:12-24` reasons only about `ECONNREFUSED` and does
not address the abort case. Telemetry is the governance audit trail, so duplicates are a
records-integrity matter rather than a pure nuisance.

Mitigating, and why this stays Low: the envelope is byte-identical across retries because
`timestamp` is set before the first attempt in all 3 callers, so `(session_id, phase, event,
timestamp)` is a usable natural dedup key. If the human on the loop wants this closed rather
than accepted, the options are to exclude `AbortError` from the retry predicate, or to add
an explicit event id to the envelope.

### SEC-005 (Low) - the sentinel matches inside prose, so any document explaining the rule exempts itself

`planifest-framework/hooks/enforcement/em-dash-guard.mjs:107` tests
`content.includes(SENTINEL)` against the whole payload, with no requirement that the
sentinel appear on its own line or outside a code span.

Reproduced accidentally: the first draft of this security report described the bypass token
in prose, which silently exempted the entire report from the guard. The same applies to
`plan/current/adr/0000028-ADR-003-*`, to the new `Em Dash Prohibition` section in
`formatting-standards.md`, to the guard's own block message (which prints the sentinel, so
any content quoting that message is exempt), and to the test fixtures. The documents that
define the rule are the ones the rule cannot reach.

Kept at Low deliberately, and arguably this is Informational: the guard enforces a
formatting convention, not an authorisation decision, and the same document class was
already outside the guard's reach through several other trivial routes. It is recorded
because it is a concrete, reproducible weakening of a control this feature introduces, and
because the fix is cheap: require the sentinel to occupy its own line, or ignore matches
inside fenced code blocks.

### SEC-006 (Informational) - the one governance-relevant document in the em dash cleanup preserves its meaning

`planifest-framework/skills/planifest-loop-runner/SKILL.md`, rule 2 on
`plan/current/.ratchet-approve`, had its em dash replaced with a comma in the clause
prohibiting agents from writing that file on their own initiative. The prohibition is
identical before and after; nothing else on the line changed.

This is the only security-relevant or governance-relevant artifact the cleanup touched.
R-002 and A-004 are confirmed with no meaning change found anywhere in the 104-file diff.
Recorded so the check is on the record rather than assumed.

### SEC-007 (Informational) - two hardening nits in the new shared modules

Neither is exploitable. Recorded for consistency rather than as required work.

1. `phase-enum.mjs:34` exports `PHASE_ENUM` as a plain mutable array, and `KNOWN_PHASES`
   (line 48) is a mutable `Set`, while its two siblings `PHASE_NUMBER_TO_ENUM` and
   `PHASE_SKILLS` are both `Object.freeze`d. Since `KNOWN_PHASES` is the CWE-22 guard's
   membership set, freezing it and the array behind it would be consistent with the other
   two exports. Not exploitable: each hook runs as its own process, the only importer is the
   hook's entry file, and mutating the set would require already controlling hook source.
2. `setup.sh` copies hook modules but never prunes. A module renamed or deleted upstream
   leaves a stale copy behind in `.claude/hooks/`. Verified there are currently no orphans,
   so this is latent. It does mean an install can accumulate `.mjs` files that no longer
   correspond to reviewed source, which is worth knowing now that the glob is `*.mjs` rather
   than an implicit allowlist.

## Considered and Dismissed

**Widening the tier-1 telemetry glob from `emit-phase-*.mjs` to `*.mjs` is not a
supply-chain widening of consequence.** It looked like one at first pass: any `.mjs` dropped
into `planifest-framework/hooks/telemetry/` now reaches every consumer's install on their
next setup run, where before it had to match `emit-phase-*`. It does not change the trust
boundary, for three reasons. `hooks/enforcement/` already used `*.mjs` before this feature
(`setup.sh:433`), so this only makes telemetry consistent with the always-installed tree.
Copying a file does not execute it; execution requires explicit by-name wiring in
`settings.json`, which `setup.sh` performs for a fixed list of hooks. And for a copied module
to be *imported* rather than merely present, a wired hook's source must change too. Anyone
able to commit either change can already modify `gate-write.mjs` directly. The effective
control remains commit review of `planifest-framework/hooks/`, unchanged by this feature.

## Dependency Audit

No dependency manifest was added or modified. `package.json`, lockfiles, `go.mod` and
equivalents are all untouched by the reviewed range. All 7 new modules (`read-stdin.mjs`,
`phase-enum.mjs`, `em-dash-guard.mjs`, `emit-event.mjs`, `record-telemetry-failure.mjs`,
`read-product-id.mjs`, `get-flag-path.mjs`) use only Node builtins (`node:fs`, `node:os`,
`node:path`) plus the global `fetch` and `AbortController`. No third-party code, no new
vulnerability surface, no new permissions requested.

## Secrets Management

No hardcoded credentials, API keys or tokens anywhere in the reviewed diff.
`PLANIFEST_TELEMETRY_URL` is an endpoint URL rather than a credential, is read from the
environment, and is never logged, never written to a marker or receipt, and never
interpolated into the new stderr line. `context-pressure.mjs:62` retains its pre-existing
`http://localhost:3741` default; the two `emit-phase-*` hooks exit 0 when the variable is
unset. Neither behaviour changed this feature.

R-008 required this review to confirm the gitignore entries. **Confirmed.**
`plan/.telemetry-receipts/` is ignored at `.gitignore:32`, alongside the pre-existing
`plan/.telemetry-failures/` at line 27, and `.claude/` at line 2. No marker or receipt
content is transmitted beyond local disk.

## Authentication & Authorisation Review

Not applicable. No API surface was added or modified, and no OpenAPI spec exists for this
feature (confirmed against `design.md`, which declares no frontend, no database, no cloud
and no IaC).

## Input Validation Review

Every externally-supplied value that reaches a path or a decision in the changed code:

- `emit-event-receipt.mjs`: `envelope.phase` and `envelope.event` are agent-supplied
  `emit_event` arguments. Both are checked against closed sets (`KNOWN_PHASES`,
  `KNOWN_EVENT_TYPES`) before path construction, and the guard is verified unweakened by
  the req-002 refactor. This is the review's headline check and it passes.
- `em-dash-guard.mjs`: `tool_input.path` / `file_path` and `content` / `new_string` are
  host-supplied hook fields. The path is normalised through `resolve()` and matched against
  a fixed prefix list; it never reaches a filesystem write, since the hook only reads stdin
  and decides an exit code. Content is scanned for one literal character and one literal
  sentinel, with no regex constructed from input, so there is no ReDoS surface.
- `read-product-id.mjs`: parses `product.yml` line by line with anchored regexes and throws
  on unbalanced quoting or an empty value rather than falling back silently. The returned
  value reaches the envelope body only, never a path or a command.
- `record-telemetry-failure.mjs`: the error message is slugified twice before it reaches a
  filename, with every character outside `[a-zA-Z0-9_-]` collapsed, so `..` and `/` cannot
  survive into the marker path. Path length is bounded by the 60-character cap, so
  `ENAMETOOLONG` is not reachable.
- `readStdin()` now rejects on a stream error in all 12 hooks rather than hanging in 10 of
  them. Every caller converts that rejection into an exit-0 path, so the consolidation
  resolved the discrepancy in the safe direction.

## Network Policy

No new network-facing surface, no new listener, no new port. The single egress point
(`POST {PLANIFEST_TELEMETRY_URL}/emit`) is pre-existing. This feature changes only its retry
behaviour, addressed under SEC-003 and SEC-004.

## Infrastructure as Code Review

Not applicable. No IaC exists in this stack; `design.md`'s Engineering Layer declares no IaC
and no cloud.

## Risk Register Cross-Reference

| Risk | Status after this review |
|---|---|
| R-001 half-applied extraction leaves a hook importing a missing module | Module resolution verified sound (`setup.sh:433` before `:455`, `:1197` unconditional; zero drift, zero missing, zero orphans in the live install). The risk's underlying worry, that a broken hook degrades to a silent no-op the human would not notice, is nonetheless realised by a different mechanism: see SEC-001. |
| R-002 mechanical cleanup alters meaning | Confirmed closed. All 104 files analysed; no meaning change found. See SEC-006. |
| R-003 `.claude/` is gitignored wholesale, no `git checkout` recovery | Unchanged and accepted. Re-run setup is the documented recovery. Note that re-running setup does not currently repair SEC-001, since setup is what produces the defective wiring. |
| R-007 retry masks a degraded backend | Accepted tradeoff stands, but the stated bound is wrong. See SEC-003. |
| R-008 markers and receipts echo user-configured strings verbatim | Gitignore entries confirmed present. Partially extended by SEC-002, which adds stderr as a second local channel for a slugified subset of the same content. |

## Summary

Overall risk rating: **High**

The rating is driven entirely by SEC-001 and should be read precisely: there is no
exploitable vulnerability anywhere in this change, and no confidentiality, integrity or
availability impact on any data. What SEC-001 describes is seven enforcement hooks, one of
them this feature's own REQ-006 deliverable, wired to a command string that exits 126 and
therefore never runs, silently and with no signal. A governance framework whose enforcement
layer fails open without telling anyone warrants the flag, and the fix is a one-word change
in `setup.sh` that `setup.ps1` already gets right.

The headline check this review was commissioned for came back clean. The req-002 refactor
did **not** weaken the CWE-22 path-traversal guard in `emit-event-receipt.mjs`: the shared
`PHASE_ENUM` carries exactly the seven values the inline literal did, and the guard still
runs before path construction. The em dash cleanup changed no document's meaning across all
104 files. R-008's gitignore requirement is confirmed. The remaining findings are Low: a
narrow local information-disclosure residual, an inaccurate latency bound in an already
accepted risk, a duplicate-event case the retry rationale did not consider, and a sentinel
that matches inside prose.

Top actions before production:

1. **SEC-001.** Prefix the enforcement hook command strings in `setup.sh:576-578` and the
   `UserPromptSubmit` block with `node `, matching `setup.ps1:528`, then re-run setup and
   confirm a violating Write is actually blocked. Add a test that exercises the command
   string as written into `settings.json`, not a hand-built `node` invocation, so this class
   of defect cannot recur undetected.
2. **SEC-003.** Correct R-007's stated worst-case latency in `risk-register.md` from 600ms
   to the true 9.6s wall-time bound, so the accepted tradeoff sits against the real figure.
3. **SEC-004.** Decide explicitly whether `AbortError` should stay inside the retry
   predicate. Accepting it is defensible given the envelope is byte-identical across
   retries, but the decision should be deliberate rather than incidental.
