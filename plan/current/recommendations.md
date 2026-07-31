---
title: "Recommendations - 0000019-self-description-and-session-hygiene-fixes"
summary: "Suggested improvements for future iterations, surfaced during this feature's pipeline run."
status: "active"
version: "0.1.0"
---
# Recommendations - 0000019-self-description-and-session-hygiene-fixes

**Skill:** [docs-agent](../skills/planifest-docs-agent-SKILL.md)
**Feature:** 0000019-self-description-and-session-hygiene-fixes

---

## For a future pass

1. **Anchor the `component.yml` matcher.** `.github/workflows/planifest.yml`, `planifest-framework/hooks/planifest.yml`, `hooks/pre-push`, and `hooks/pre-commit` all use `.*component\.yml` with no end-anchor, so `foo/component.yml.bak` would still match. Pre-existing behaviour (inherited unchanged from the `component.json` version fixed in req-002), noted in the P5 security report as low-severity and out of this batch's scope. Worth a small follow-up if anyone ever relies on the matcher being exact.

2. **The context-pressure→telemetry-backend port mismatch is unresolved.** This feature's own P0 (backlog item 0000027, folded in and fixed directly — see `plan/current/build-log.md`'s P0 block) traced the original HTTP 400 to an invalid `phase` enum value and fixed exactly that — but the investigation also surfaced that the hook's direct `fetch` (`PLANIFEST_TELEMETRY_URL` unset, defaulting to `http://localhost:3741`) and the MCP tool's call path aren't confirmed to be hitting the same configuration in every environment. That specific question was resolved for this session (both reached the same backend, and the real bug was the enum value) but the general "are these two emission paths guaranteed to agree on environment config" question wasn't fully chased down. Worth a dedicated look if a future session sees a `context-pressure` failure that *isn't* the enum-value bug.

3. **`self-description-check.mjs`'s diagram parser is deliberately minimal.** It only recognises two levels of nesting (root `├──`/`└──` and one level of `│   ├──`/`│   └──` children) because that's what the current README diagram uses. If the structure diagram ever grows a third nesting level, the parser will silently stop attributing paths correctly past that depth rather than erroring. Not a problem today; worth a comment-driven guard or a depth-count assertion if the diagram grows.

4. **Operational Model, SLO Definitions, and Cost Model were not produced for this feature** — recorded explicitly (not a silent gap) in `plan/current/design.md`'s Architecture Layer and `plan/current/execution-plan.md`'s Non-Functional Requirements section: this batch has no runtime component, so none of the three apply. Flagged here per the docs-agent's "note absences explicitly" rule, for anyone auditing this feature's artifact completeness against the standard P1 list.

5. **This feature is itself a small demonstration of backlog item 0000021's problem** (define a minimal artifact set) — still open, not part of this batch. Several P1 artifacts here (Operational Model, SLO Definitions, Cost Model) were explicitly reasoned through as N/A rather than mechanically produced, which is exactly the conditional-artifact behaviour 0000021 asks the framework to formalise. Worth revisiting once 0000021 is picked up.
