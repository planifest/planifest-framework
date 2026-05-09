---
title: "Risk Register - 0000009-framework-rail-tightening"
version: "0.1.0"
phase: 1
---
# Risk Register — 0000009-framework-rail-tightening (Phase 1)

| ID | Category | Risk | Likelihood | Impact | Mitigation |
|----|----------|------|-----------|--------|------------|
| R-001 | Technical | Open-source skills found via web search have ambiguous, mixed, or non-permissive licenses | Medium | Low | Exclude any skill without a clearly identified permissive license; library ships smaller but clean |
| R-002 | Technical | Curated open-source skills are in a format incompatible with SKILL.md (e.g. different frontmatter, different structure) | Medium | Medium | Adapt minimally to SKILL.md format; document adaptations in attribution.txt; reject skills requiring heavy rewrite |
| R-003 | Technical | UserPromptSubmit hook for auto-trigger fires on every prompt (not just session start), causing repeated orchestrator invocations | Medium | Medium | Hook script checks for sentinel (`plan/.orchestrator-active`) and exits 0 if already active; idempotent |
| R-004 | Technical | gate-write path fix introduces a regression on Unix (where paths are already forward-slash) | Low | High | `norm()` is a no-op on forward-slash paths; regression test covers both Unix and Windows path shapes |
| R-005 | Operational | pause.md left unconsumed across multiple sessions causes stale resume from wrong state | Low | Medium | Resume detection displays pause state and requires explicit human confirmation before consuming; human can reject and start fresh |
| R-006 | Technical | Skill map in design.md becomes stale if requirements change mid-pipeline without triggering re-evaluation | Low | Low | Orchestrator SKILL.md gate protocol re-evaluates at every phase boundary; mid-pipeline change protocol triggers re-evaluation |
| R-007 | Technical | `--include-full-skill-library` flag copies skills to tool dir on re-run without cleaning previously copied external skills that were later removed from external-skills/ | Medium | Low | Setup manifest tracks installed directories; cleanup loop removes previously installed dirs before re-copy |
