# Recommendations - orchestrator-redundancy-removal

**Skill:** [docs-agent](../skills/docs-agent-SKILL.md)
**Feature:** 0000022-orchestrator-redundancy-removal
**Version:** 0.22.0

> These are not blockers - they are opportunities for future work.

## Recommendations

| ID | Category | Priority | Component | Recommendation | Rationale | Effort |
|----|----------|----------|-----------|---------------|-----------|--------|
| REC-001 | maintainability | high | planifest-framework | Pick up backlog 0000020 (structural router decomposition) now. This feature removed duplication (10,379 -> 8,592 words); the file is still one monolithic 8,592-word skill. 0000021's design.md explicitly deferred 0000020 until this de-duplication pass landed - that dependency is now satisfied. | The orchestrator is still ~39% of the total skills corpus by share; a router-plus-references/ pattern is the next lever, and this feature made it safer (smaller diff surface, cleaner sections). | large |
| REC-002 | testing | medium | planifest-framework | Only 10 of 22 regression tests pin orchestrator-specific content, and this feature found two of those ten pinned stale or mischaracterised assertions (test-0000017-req-006's dead sed pattern; test-0000017-req-005's mechanics that turned out to already be correctly placed). Consider a periodic "test health" pass over `tests/regression/` independent of any content-trim feature, to catch drift between what a test claims to check and what it actually scopes. | The dual-detector process compensates for this, but a healthier test suite reduces reliance on manual diff review for future trims. | medium |
| REC-003 | maintainability | low | planifest-framework | `planifest-framework/component.yml`'s version/feature fields were not bumped during P3 as the codegen-agent close-out rule requires (`## Framework component.yml close-out`) - caught and fixed at P6 instead. Consider a regression test asserting `component.yml`'s `feature` field matches the currently active feature branch/design.md at the P3 gate, so this class of miss is caught mechanically rather than by chance during docs review. | This is exactly the kind of self-auditing check the framework already applies elsewhere (e.g. build-log phase-block enforcement, Hard Limit 8); it is currently missing for this specific close-out step. | small |
| REC-004 | testing | low | planifest-framework | The P4 diff review that caught the External Anchor mapping loss was valuable specifically because it was dispatched to a fresh-context subagent independent of the editor (maker-checker). Consider making this the default pattern for `design_critic`-style verification wherever a single agent both authors and would otherwise self-check a content change, not only for the toggled design-critic/cross-model gates. | Confirmed effective in this run: the editing agent's own re-read of its own diff would have carried the same blind spot that produced the original miss. | small |

## Deferred Items

| Scope Item | Recommendation | When to Address |
|-----------|---------------|-----------------|
| Structural router decomposition of the orchestrator (backlog 0000020) | Pick up now - the dependency this feature was blocking on is resolved | Next framework-maintenance feature |
| Backlog 0000029 (Scope Lock drafts always presented) and 0000030 (marker commit at creation) | Both filed during this feature's P0; neither implemented here | Next P0 backlog pickup |

## Tech Debt

No new tech debt introduced by this feature. One pre-existing tech-debt item was fixed as a side effect: `test-0000017-req-006-structured-discovery-pass.sh`'s stale `### Signal Priority Order` sed-range reference (dead since some earlier feature renamed or removed that heading) is now corrected in both `tests/` and `tests/regression/` copies.
