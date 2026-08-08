---
title: "Risk Register - telemetry-hardening-and-enforcement-fixes"
summary: "Technical, operational, and security risks with their mitigations."
status: "draft"
version: "0.1.0"
---
# Risk Register - telemetry-hardening-and-enforcement-fixes

**Skill:** [spec-agent](../skills/spec-agent-SKILL.md) (updated by any agent that identifies a new risk)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Version:** 0.27.0 to 0.28.0
**Overall Risk Level:** medium

> Every entry must be specific to this feature. Do not produce generic risks.

## Risks

| ID | Category | Description | Likelihood | Impact | Mitigation | Status |
|----|----------|------------|------------|--------|-----------|--------|
| R-001 | technical | This feature edits the hooks running its own build. A half-applied shared-module extraction leaves a hook importing a module that does not exist yet, and because hooks must exit 0 on every path, it degrades to a silent no-op rather than a visible failure. | medium | high | Create shared modules before rewiring any caller. Verify each hook live after each edit rather than trusting test coverage alone; a broken hook fails silently and would not be caught by the human noticing a block. | open |
| R-002 | technical | The em dash cleanup touches roughly 870 live artifact files. Mechanical find-and-replace will get some contextually wrong, altering a sentence's sense rather than just its punctuation. | high | medium | Bound the cleanup to live artifacts only; exclude `plan/_archive/` and `plan/changelog/` as historical record. Review the full diff at P4 rather than trusting the script's output unread. | open |
| R-003 | operational | `.claude/` is gitignored wholesale, so the live hook install cannot be restored with `git checkout`, only by re-running setup. | low | medium | Treat `planifest-framework/hooks/` as the sole source of truth. Recovery procedure is documented in `operational-model.md`: re-run `setup.sh`/`setup.ps1` for the affected tool. | open |
| R-004 | operational | Scope is six requirements against the framework's own three-story heuristic, past the point the heuristic recommends splitting a run. | medium | medium | The telemetry items are one coherent cluster over the same five files; not independent work streams. Documented explicitly in `design.md` Scope as an accepted overrun rather than a silent one. | accepted |
| R-005 | operational | `--structured-telemetry-mcp` was NOT actually passed for this install. `design.md`'s Assumptions section records this as an inference from the backend URL being hard-coded into the one registered hook, not a confirmed fact. If wrong, req-004 (install refresh, phase hook registration) and req-005 (live verification of `resolve-phase.mjs`) are unverifiable this run. | medium | high | Verify the flag directly against `{tool-dir}/.planifest-setup-flags` and installed hook wiring before relying on it, per `planifest-refresh-setup`'s own Step 1/2 recovery check, rather than trusting the P0 inference. If the flag is absent, re-scope req-004/req-005 as installation work rather than treating them as already satisfied. | open |
| R-006 | technical | `resolve-phase.mjs`'s `PreToolUse(Skill)` matcher and `tool_input.skill` field assumption has never been observed firing. If wrong, req-005 changes from a verification task into a fix, expanding P3 scope beyond what was estimated. | medium | medium | Observe a live Skill invocation and inspect the actual `PreToolUse` payload before trusting the matcher. Budget P3 contingency for a fix path, not only a verification pass. | open |
| R-007 | operational | Retry absorbs a listener gap (backend mid-restart) by design, which is the point of req-001. The same mechanism can mask a genuinely degraded backend, since a slow-but-eventually-responding listener now looks identical to a healthy one from the human's vantage point, delaying recognition of real degradation. | medium | medium | Retry is bounded (2 attempts, 300ms budget, 600ms worst-case latency) and retry exhaustion still writes a durable marker, so a truly degraded backend is still recorded, just after one extra round trip rather than zero. Do not widen the retry budget further without revisiting this tradeoff; see `slo-definitions.md`. | open |
| R-008 | security | Failure markers under `plan/.telemetry-failures/` and receipts under `plan/.telemetry-receipts/` echo user-configured URL and error strings verbatim. If either directory were ever committed, that content would leak into repo history. | medium | medium | Both directories remain gitignored (existing entry for failures, new entry for receipts added by req-003/this feature). No marker or receipt content is transmitted anywhere beyond local disk. Confirm the gitignore entries land as part of P5 security review. | open |

## Assumptions Logged as Risks

Documented assumptions from the specification are logged here with likelihood: medium.

| ID | Assumption | Impact if Wrong | Status |
|----|-----------|----------------|--------|
| A-001 | `--structured-telemetry-mcp` was passed for this install, inferred from the backend URL being hard-coded into the one registered hook. | Install refresh does not register the phase hooks at all; US-004, US-005, and `0000053` become unverifiable this run. | open |
| A-002 | `resolve-phase.mjs`'s `PreToolUse(Skill)` matcher and `tool_input.skill` field assumption is correct, though neither has ever been observed firing. | US-005 becomes a fix rather than a verification, expanding P3 beyond estimate. | open |
| A-003 | The downstream retry fix in `0000063` (2 attempts, 300ms budget) is a sound starting point, verified there against a controllable backend. | The attempt count and timing budget need re-derivation for this repo's conditions, though the network-versus-HTTP-status distinction holds regardless. | open |
| A-004 | The one-off em dash cleanup can be applied mechanically to live artifacts without changing meaning. | A replacement alters the sense of a sentence; only caught if P4/P5 review the diff rather than trusting the script. | open |

