---
title: "Backlog Entry: 0000062 - No lightweight track exists for projects with no src/ components"
summary: "Fast Path requires an existing feature with code at src/{component-id}/ and Change Pipeline requires 1-2 existing components. A project whose work is governance, tooling or documentation has neither, so every change however small is forced down the Feature Pipeline and rescued by skipping P2, P4 and P5 by hand."
status: "open"
---
# Backlog Entry: 0000062 - No lightweight track exists for projects with no src/ components

**Source feature:** filed from downstream repo `rapid-prototypes`, feature `0000002-backlog-reframe`
**Source phase:** P0 (routing), reconfirmed at P8
**Deferral source:** discovered mid-flight
**Date filed:** 2026-08-08

---

## Problem

Three tracks exist; two are unreachable for a project with no `src/` components.

| Track | Gate |
|-------|------|
| Fast Path | Prerequisite: *"An existing feature with code at `src/{component-id}/`"* (`workflows/fast-path.md`) |
| Change Pipeline | *"a bug fix or targeted change to 1–2 existing components"* |
| Feature Pipeline | The only one left |

Downstream, `rapid-prototypes` has hit this on two consecutive runs. `0000001` delivered one 6 KB markdown instruction; `0000002` edited four backlog entries and repaired ten links. Both were routed to the full Feature Pipeline and made tractable only by skipping P2, P4 and P5 — each skip requiring its own human decision and its own `.skips` justification.

That is not a lightweight track. It is the heavyweight one with holes punched in it by hand, per run.

**The saving is partly repaid in paperwork.** Every skipped phase produces an artifact explaining the skip. And skipping P2 has a real cost: with no ADRs, the reasoning behind that project's naming rule and path-nesting choice had to be recorded under a "Decisions made without an ADR" heading invented for the purpose — captured, but less discoverably than an ADR would have been.

**This is not confined to unusual projects.** Any repository whose product is tooling, configuration, or documentation has the same shape — including this one. A change to a skill, a template, or a standard here is exactly the case Fast Path's four criteria describe (no new dependencies, no schema change, no security or routing change, confined to copy or isolated logic) and exactly the case its prerequisite excludes.

## Suggested Action

Decide what track a documentation-only or governance-only change should take, then make the framework say it. Options:

- **Relax Fast Path's prerequisite** so it admits changes with no `src/` target, rather than requiring an existing component. Its four criteria already fit this class; only the prerequisite excludes them.
- **Add a documentation track** with its own short phase set, so governance changes stop being Feature Pipeline runs in disguise.
- **State the status quo explicitly** — governance work uses the Feature Pipeline with a standard, pre-approved skip set — so the decision stops being re-litigated at every P0.

Any of the three beats the current position, where each run rediscovers the dead end and improvises around it.

## Why Deferred

Filed from a downstream repo that does not maintain this framework. The fix belongs to the orchestrator's routing directive and `workflows/fast-path.md`.

The downstream project is not blocked — it has written a repo-level `governance-runs.md` override that fixes the track choice and skip set once instead of per-run. That override is a workaround for one project, not a fix; this entry exists because the gap is general.

Related, filed from the same downstream analysis: `0000060-p7-crossref-check-cannot-detect-relative-link-breakage`, `0000061-component-manifest-path-inconsistent-with-framework-self-manifest`. All three were found while running the framework against a repository with no `src/` components, and are worth picking up together.
