---
title: "Risk Register - backlog-batch-governance-tooling-fixes"
summary: "Technical, operational, and security risks with their mitigations."
status: "active"
version: "0.1.0"
---
# Risk Register - backlog-batch-governance-tooling-fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md) (updated by any agent that identifies a new risk)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Version:** 0.27.0
**Overall Risk Level:** low

## Risks

| ID | Category | Description | Likelihood | Impact | Mitigation | Status |
|----|----------|------------|------------|--------|-----------|--------|
| R-001 | technical | req-002's cline.sh fix might not match Cline's real expected directory layout | low | low | Verified against Cline's official docs (docs.cline.bot): `.clinerules/` supports multiple `.md` files since v3.7; chosen fix relocates the boot file into that directory rather than guessing | mitigated |
| R-002 | technical | req-001's hook entries need a positional `<phase>` CLI argument, but a single static hook command/matcher can't supply it the way `context-pressure.mjs`'s phase-agnostic command does | medium | medium | Resolve at P3 codegen against the `PreToolUse`/`Stop` hook shapes already documented in each script's own header comments; not invented at requirements stage | open |
| R-003 | technical / architectural | req-004's telemetry-compliance backstop mechanism (hook vs. phase-gate lint/check vs. both) is explicitly undecided | medium | medium | P2 ADR resolves the mechanism before P3 implementation begins (Open Question Q-001, execution-plan.md) | open |
| R-004 | technical / architectural | req-005's Framework Update Policy mechanism (extend `planifest-migrator` vs. new dedicated agent) is explicitly undecided | medium | medium | P2 ADR resolves the mechanism before P3 implementation begins (Open Question Q-002, execution-plan.md) | open |
| R-005 | operational | req-003's backlog-ID pre-computation approach (dispatching agent assigns IDs, not subagent self-lookup) could still collide if two orchestrator sessions dispatch subagents concurrently against the same repo | low | low | Existing backlog convention already accepts small collision risk under parallel dispatch, reviewed at the next P0 pickup; unchanged by this feature | accepted |
| R-006 | operational | req-006's backfill could miss a pre-0000025 feature if its `recommendations.md` uses non-standard headings | low | low | Verified by heading match (`## Deferred Items`/`## Tech Debt`) across all pre-0000025 archives during requirements research; exactly 4 features / 7 rows found and enumerated in req-006 | mitigated |

## Assumptions Logged as Risks

Documented assumptions from the specification are logged here with likelihood: medium.

| ID | Assumption | Impact if Wrong | Status |
|----|-----------|----------------|--------|
| A-001 | req-004's and req-005's P2 ADRs will not require re-opening their requirement docs | A second requirements pass would be needed for that item only, not the full batch | open |
| A-002 | Ops model/cost model/SLO definitions are N/A for this feature (zero deployed runtime footprint) | None identified — no deployed service exists regardless of which artifact-set rule eventually governs it | open |
