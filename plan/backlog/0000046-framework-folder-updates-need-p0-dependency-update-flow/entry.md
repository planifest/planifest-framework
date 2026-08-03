---
title: "Backlog Entry: 0000046 - Repo workflows treat framework-folder updates as unknown-source code pushes instead of a dependency update"
summary: "Downstream adopters' repo workflows (gates/hooks/CI) apparently have no distinct handling for 'update the planifest-framework/ dependency to a newer version' versus 'someone pushed arbitrary code' — the human wants this handled explicitly at P0, with human confirmation of both the update and its source, likely via a new dedicated update agent."
status: "open"
---
# Backlog Entry: 0000046 - Repo workflows treat framework-folder updates as unknown-source code pushes instead of a dependency update

**Source feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source phase:** P6

**Date filed:** 2026-08-03

---

## Problem

Filed directly by the human on the loop: repo workflows (enforcement hooks, CI gates, or both) currently have no distinct treatment for "the `planifest-framework/` folder is being updated to a newer framework version" versus "unrecognised code is being pushed from an unknown source." A framework-folder update is fundamentally a **dependency update** — the framework version bump should be trusted and routine like any other declared dependency bump, not treated with the same suspicion as an arbitrary, unattributed code change.

This term surfaces already in this repo's own backlog: two downstream-filed entries (0000040, 0000041) both reference "this repo's Framework Update Policy" as the mechanism governing how a downstream project's local `planifest-framework/` copy gets updated — but a grep across this canonical framework repo turns up no other definition of that policy. The policy is referenced by name from the consumer side without a documented, canonical mechanism on the framework side describing what it actually is or how it's meant to work.

## Suggested Action

Handle framework-dependency updates explicitly at P0, per the human's direction:
1. When a framework-folder update is detected or proposed (new framework version available, or an update artifact/migration present), surface it to the human at P0 as its own distinct decision — not silently applied, not conflated with a feature-brief coaching question.
2. Require explicit human confirmation of **both** the update itself and its **source/provenance** (which upstream release, commit, or migration produced these files) before it's applied — trust is established by the human confirming provenance, not assumed from the file's presence.
3. Consider whether this warrants a new, dedicated skill/agent (an "update agent") separate from the existing `planifest-migrator` (which handles a specific pending-migration-file flow) — scope and exact relationship between the two mechanisms (is this a superset of migrator's job, a distinct concept, or should migrator itself gain this provenance-confirmation step?) is a design decision for whoever picks this up, not decided here.
4. Document the resulting mechanism as this repo's actual "Framework Update Policy" so downstream entries referencing it (0000040, 0000041, and any future ones) point at something real.

## Why Deferred

This is a governance/mechanism gap spanning P0 coaching flow, enforcement hooks, and possibly a new skill — larger in scope than a single requirement and unrelated to 0000025's 7 already-confirmed stories (all `planifest-framework` skill/script correctness fixes, not update-provenance governance). Filed directly by the human for pickup in a future run, not designed here.
