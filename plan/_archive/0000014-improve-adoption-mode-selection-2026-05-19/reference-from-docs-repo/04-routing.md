# Routing & Tracks

Not every change needs the full pipeline. Planifest routes each request to one of three tracks based on the nature and scope of the change. The orchestrator evaluates the request and selects the track before doing any other work.

## Decision Tree

| Signal | Track |
|--------|-------|
| UI styling, copy/text changes, or an isolated pure-function bug | Fast Path — if all four criteria are met |
| Dependency version bump with no API changes | Fast Path — if all four criteria are met |
| Bug fix or targeted change to 1–2 existing components | Change Pipeline |
| Adds a new component to an existing feature | Change Pipeline |
| New user stories that fit within an existing feature's scope (< 3 stories) | Change Pipeline |
| New features, new user stories (≥ 3), or new problem statement | Feature Pipeline |
| Touches > 3 components or requires new infrastructure | Feature Pipeline |
| Requires a new stack choice | Feature Pipeline |
| New target users or different domain | Feature Pipeline |

## Fast Path

For trivial, low-risk changes. **All four criteria must be met.** If any criterion fails, the orchestrator routes to the Change Pipeline — no exceptions.

1. Does **not** introduce new external dependencies
2. Does **not** alter, add, or remove database schemas or data models
3. Does **not** change security parameters, authentication, or routing logic
4. Confined to: UI styling, copy changes, or isolated pure-function logic bugs

See [Fast Path](06-fast-path.md) for execution steps.

## Change Pipeline

For targeted modifications to existing features: bug fixes, small additions, updates to 1–2 components, or fewer than three new user stories.

The `planifest-change-agent` loads domain context for the affected component before acting — its manifest, contracts, consumers, and change policy — then implements the minimum necessary change.

See [Change Pipeline](05-change-pipeline.md).

## Feature Pipeline

For new features, significant additions, or changes spanning multiple components. Runs the full P0–P8 pipeline starting with Phase 0 coaching. A Feature Brief is required (or written interactively during coaching).

See [The Pipeline](03-pipeline.md).

## Retrofit

For onboarding an existing codebase into Planifest without a greenfield Feature Brief. The orchestrator reads the codebase first — inferring architecture, patterns, and existing decisions — then proceeds with an informed coaching conversation.

See [Retrofit](07-retrofit.md).
