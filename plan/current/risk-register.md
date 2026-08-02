---
title: "Risk Register - 0000024-declared-product-id-for-telemetry"
summary: "Technical, operational, and security risks with their mitigations."
status: "draft"
version: "0.1.0"
---
# Risk Register - 0000024-declared-product-id-for-telemetry

**Skill:** [spec-agent](../skills/spec-agent-SKILL.md) (updated by any agent that identifies a new risk)
**Feature:** 0000024-declared-product-id-for-telemetry
**Version:** 0.24.0
**Overall Risk Level:** low

## Risks

| ID | Category | Description | Likelihood | Impact | Mitigation | Status |
|----|----------|------------|------------|--------|-----------|--------|
| R-001 | operational | Removing the git-path fallback is a behavioural regression for any existing downstream Planifest-managed project that hasn't declared a `product.yml` `id` yet — their telemetry silently stops resolving `product_id` (routed to failure markers) until they run a P0 or manually add `product.yml`. | medium | low | Non-blocking behaviour preserved (ADR-005); the gap is surfaced via the existing `plan/.telemetry-failures/` marker mechanism, not silent data loss — a human reviewing markers will see it. The orchestrator's P0 hard-stop prevents this for any project that runs a pipeline. | open |
| R-002 | technical | Auditing all 8 phase skills' `## Telemetry` sections (req-002) may surface more stale argument references than the "zero findings expected" assumption from 0000023 ADR-002's centralisation — expanding req-002's actual file count beyond `telemetry-standards.md` alone. | low | low | 0000023 ADR-002 specifically centralised telemetry docs to avoid duplication; if findings do surface, the fix is mechanical (same corrected wording per file). | open |
| R-003 | operational | The new P2 ADR extends an already-accepted architectural decision (0000016 ADR-002, "single-component projects keep component.yml behaviour") for every downstream adopter, not just this repo — a behavioural change to established, shipped guidance. | low | medium | The extension is additive (single-component projects gain a minimal `product.yml`, they don't lose `component.yml` behaviour) and only activates when telemetry needs a declared id — documented explicitly in the new ADR with a reference back to 0000016 ADR-002. | open |
| R-004 | technical | Live re-verification (req-002) may surface that Root Cause B from the 0000017 RCA (missing `loop_iteration`/`phase_reversal_*` schema entries) is still broken in the deployed backend schema. | medium | low | Explicitly out of scope to fix here — the requirement mandates filing a fresh backlog entry describing the finding rather than attempting an in-repo fix (the fix belongs in `structured-telemetry-mcp`). | open |

## Assumptions Logged as Risks

| ID | Assumption | Impact if Wrong | Status |
|----|-----------|----------------|--------|
| A-001 | `structured-telemetry-mcp`'s `emit_event` fix (real object schema, `envelope` argument) is stable/deployed, not a transient state that could regress. | req-002's live re-verification step fails immediately and visibly — not a silent risk, since the acceptance criterion requires a confirmed `query_telemetry` match, not just a lack of error. | open |
| A-002 | Every pipeline run has an orchestrator-led P0 phase, so a once-per-run hard-stop prompt is sufficient coverage for resolving a missing declared product id. | A hook-only invocation with no prior P0 in that session hits the failure-marker path instead of the interactive prompt — this is the designed fallback behaviour (R-001's mitigation), not a gap, so "wrong" here degrades gracefully rather than breaking. | open |
