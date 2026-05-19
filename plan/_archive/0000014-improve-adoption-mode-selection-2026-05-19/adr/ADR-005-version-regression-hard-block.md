---
title: "ADR-005: Version Regression Hard Block"
summary: "Confirming a version lower than the currently recorded version is a hard block — the orchestrator refuses and does not proceed until the human provides a valid version."
status: "accepted"
version: "0.1.0"
---
# ADR-005 - Version Regression Hard Block

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000014-improve-adoption-mode-selection
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-05-19

---

## Context

With version bump rules defined (ADR-004) and `docs/about.md` as the version source (ADR-003), the orchestrator can detect if a human-confirmed version is lower than the current recorded version. Three responses are possible: silent acceptance, a warning with the option to proceed, or a hard block requiring the human to provide a valid version.

A version regression has concrete negative consequences: the next pipeline run reads a lower version and may suggest an inappropriate bump; the version history becomes misleading; downstream tools that read the version for display or compatibility checks receive incorrect data.

---

## Decision

**Version regression is a hard block.** The orchestrator refuses to record a version lower than the currently recorded version and does not proceed until the human provides a version that is equal to or higher than the current.

The error message:
1. Names the current version from `docs/about.md`
2. Names the version the human attempted to confirm
3. Explains that to reset the version, archives must be re-versioned
4. Asks the human to provide a valid version

A "reset" path exists (re-versioning archives) but is not automated — it requires deliberate human action. This is intentional: version resets are consequential and should not happen accidentally.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Silent acceptance | Zero friction | Corrupts version history silently; next pipeline run sees a lower version | Rejected — unacceptable silent corruption |
| Warning with option to proceed | Human retains control | A human who doesn't understand the warning may accept regression inadvertently | Rejected — warning is insufficient for a consequential irreversible action |
| Hard block (this decision) | Prevents silent version corruption | Friction if the human genuinely needs to reset | Chosen — version regression is always a mistake or a deliberate reset; deliberate resets require re-versioning archives anyway |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-orchestrator skill | Hard block logic added to version confirmation step |

---

## Consequences

**Positive:**
- Version history is monotonically increasing — no accidental regressions
- The block message educates the human on the correct reset procedure

**Negative:**
- A human who legitimately needs to reset the version (e.g. major rewrite starting from 0.1.0) cannot do so without re-versioning archives — this is deliberate friction but may feel heavy for a genuine reset

**Risks:**
- If `docs/about.md` contains an incorrect version from a prior bug, the hard block may trap the human with an invalid baseline; mitigated by the fact that the migration (REQ-008) initialises `about.md` with a human-confirmed version

---

## Related ADRs

- ADR-004 — depends-on (version bump rules define what a "valid" version is)
- ADR-003 — depends-on (docs/about.md is the source of the current version for comparison)

---

## Supersedes

- None

## Superseded By

- None
