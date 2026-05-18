# Recommendations — 0000012-docs-restructure-commit-directives

> Produced by docs-agent at P6. These are not blockers — they are flagged for future iteration consideration.

---

## REC-001 — Ship-agent P8 sub-agent model tier not enforced

**File:** `planifest-framework/skills/planifest-ship-agent/SKILL.md` — P8 section

The ship-agent spawns the build-assessment-agent as a sub-agent but does not currently specify `model: cheaper` in the Agent call template. The `planifest-build-assessment-agent` SKILL.md frontmatter declares `recommended_model: haiku` (via the phase hook), but the orchestrator model routing memory in the docs notes "build assessment (P8) — cheaper". Adding an explicit `model: claude-haiku-4-5` to the Agent call in ship-agent P8 section would make tier routing deterministic rather than relying on frontmatter inference.

**Suggested action:** Add `model: claude-haiku-4-5` to the Agent invocation in ship-agent P8 step.

---

## REC-002 — `plan/.run-mode` not in Resume Detection checklist

**File:** `planifest-framework/skills/planifest-orchestrator/SKILL.md` — Resume Detection section

The Resume Detection section does not explicitly list reading `plan/.run-mode` as a resume step. It is mentioned in Phase 0 Start Actions, but the ordered checklist (steps 1–7) omits it. A future agent performing resume detection may re-ask the run-mode question rather than reading the sentinel. Adding a step (e.g. step 6: "Read `plan/.run-mode` if present; restore run mode") would close this gap.

---

## REC-003 — Iteration log and ship-agent changelog overlap

**File:** `planifest-framework/templates/iteration-log.template.md`, `planifest-framework/skills/planifest-ship-agent/SKILL.md`

Both the docs-agent (iteration log) and the ship-agent (Step 1 changelog) write to `plan/changelog/`. Their content partially overlaps (both record phases completed, artifacts produced). A future iteration could clarify which artifact is authoritative for which audience: the iteration log as the machine-readable execution trace, the changelog as the human-readable audit trail for the PR reviewer.
