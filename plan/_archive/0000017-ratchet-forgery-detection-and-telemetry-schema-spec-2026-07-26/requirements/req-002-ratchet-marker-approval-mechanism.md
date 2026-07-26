---
title: "Requirement: req-002 - ratchet-marker-approval-mechanism"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-002 - ratchet-marker-approval-mechanism

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000017-ratchet-forgery-detection-and-telemetry-schema-spec
**Source:** US-002
**Priority:** must-have

---

## User Story

As a human approver, I can authorize a ratchet weakening in the moment by telling the agent to write `.ratchet-approve` with my reason, so that the approval is transcribed exactly and lands in its own commit before the weakening edit proceeds — and if I forget to commit it, the hook catches that before letting the edit through.

---

## Functional Requirements
- Agent may write `plan/current/.ratchet-approve` only when the human explicitly instructs it in the moment (states path, reason, and go-ahead in the same turn)
- Line format: `path | reason | timestamp`, using the human's exact reason text verbatim — never paraphrased
- The write must be committed immediately, in its own dedicated commit, before any further work (including the guarded weakening edit) proceeds
- The same-uncommitted-changeset backstop (ADR-004) is kept at consumption time: if the weakening edit is attempted while an approval line is still uncommitted, the hook blocks the edit AND surfaces an explicit message naming the pending path and instructing the approver to commit it first — never a silent block
- `.ratchet-approve` is git-tracked (not gitignored), created fresh on first use, not pre-seeded by setup
- On the guarded weakening edit, the hook consumes the approval line and copies the full record (path, reason, timestamp) into a permanent audit log before deleting the line

## Acceptance Criteria
- [ ] Agent writes to `.ratchet-approve` only after explicit human instruction in the same turn
- [ ] Written line matches `path | reason | timestamp` with the human's verbatim reason text
- [ ] Weakening edit is blocked with an explicit message when the approval is uncommitted
- [ ] Audit log receives the full record before the approval line is deleted
- [ ] `.ratchet-approve` is tracked in git, not gitignored

## Dependencies
- ADR amending ADR-004 (produced at P2) — this requirement's mechanism supersedes ADR-004's original forgery-detection design

## Input Validation
- [ ] Input source: filesystem read of `plan/current/.ratchet-approve` — a pipe-delimited line `path | reason | timestamp`
- [ ] Allowed character pattern: reason and path fields are copied verbatim into the permanent audit log (file-to-file copy, not shell interpolation) — no character stripping needed for the audit-log write itself
- [ ] Maximum length: reason field capped at 500 characters in the audit-log entry — content beyond this is truncated with a trailing marker
- [ ] Failure behaviour: a malformed line (missing a `|` delimiter, or missing a field) is treated as no approval present — the standard same-uncommitted-changeset backstop applies as if the marker did not exist
- [ ] Logging policy: the full record (path, reason, timestamp) is written to the permanent audit log by design — this is the intended durable record, not an unintended leak
