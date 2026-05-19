---
title: "ADR-010: docs/ Lifecycle Ownership"
summary: "docs/ is created by the orchestrator at P0, owned by the docs-agent at P6, and extended by the ship-agent at P7. The P6 gate fails if docs/ does not exist."
status: "accepted"
version: "0.1.0"
---
# ADR-010 - docs/ Lifecycle Ownership

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000014-improve-adoption-mode-selection
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-05-19

---

## Context

With `docs/about.md` introduced as a living artifact (ADR-003) and `docs/` established as the living state layer, a clear ownership model is needed for when `docs/` is created, who is responsible for it at each phase, and what happens when it is absent at P6.

Previously, `docs/` creation was implicit — it happened whenever the docs-agent ran and happened to write something. This created a failure mode where the docs-agent (P6) or ship-agent (P7) would fail silently if `docs/` was absent.

---

## Decision

**`docs/` lifecycle is owned as follows:**

| Phase | Action | Owner |
|-------|--------|-------|
| P0 | Create `docs/` if absent | planifest-orchestrator |
| P6 | Gate fails if `docs/` absent; docs-agent writes to `docs/` | planifest-docs-agent |
| P7 | Create `docs/` defensively if absent (should never be needed); write `docs/about.md` as blocking step | planifest-ship-agent |

P0 is the creation point because it is the earliest phase and ensures `docs/` is available throughout the pipeline. The P6 gate failure (not a silent create) is intentional: if P0 ran and `docs/` is missing at P6, something unexpected happened, and the agent should surface it rather than silently repair it.

The ship-agent creates `docs/` defensively at P7 as a last-resort guard against the case where `docs/` was deleted between P6 and P7. This should never be needed in normal operation.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Create docs/ at P6 (first use) | docs-agent is the natural owner | docs/ unavailable during P0–P5; orchestrator can't read about.md | Rejected — timing conflict with P0 version read |
| Create docs/ at P7 (ship-agent) | Single owner | P6 docs-agent has no valid target | Rejected — P6 would need to create it too |
| Require human to create docs/ manually | No framework obligation | Friction; easy to forget | Rejected — unnecessary manual step |
| Create at P0, gate at P6 (this decision) | Clear ownership; early creation; gate surfaces unexpected state | Two agents involved in docs/ lifecycle | Chosen — best tradeoff between early availability and clear error surfacing |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-orchestrator skill | Creates docs/ at P0 start |
| planifest-docs-agent skill | P6 gate checks docs/ exists; fails if absent |
| planifest-ship-agent skill | Defensive docs/ create + blocking about.md write at P7 |

---

## Consequences

**Positive:**
- `docs/` is always available when needed throughout the pipeline
- P6 gate failure surfaces unexpected state rather than silently repairing it
- `docs/about.md` write at P7 is guaranteed a valid target directory

**Negative:**
- P0 now has a filesystem side effect (directory creation) beyond writing plan/ artifacts
- P6 gate failure requires human diagnosis; it cannot self-heal

**Risks:**
- If P0 creates `docs/` and a later process deletes it before P6, the gate fails; this scenario is unlikely but the defensive P7 create handles the P7 case

---

## Related ADRs

- ADR-003 — depends-on (docs/about.md is the artifact that drives this lifecycle decision)

---

## Supersedes

- None

## Superseded By

- None
