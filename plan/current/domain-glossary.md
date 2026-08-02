---
title: "Domain Glossary - orchestrator-redundancy-removal"
summary: "Definitions of domain terms used within this feature."
status: "draft"
version: "0.1.0"
---
# Domain Glossary - orchestrator-redundancy-removal

**Skill:** [spec-agent](../skills/spec-agent-SKILL.md) (updated by any agent that introduces a new domain term)
**Feature:** 0000022-orchestrator-redundancy-removal
**Version:** 0.22.0

## Terms

| Term | Definition | Aliases | Used In |
|------|-----------|---------|---------|
| Canonical owner | The single file where a given rule or instruction is authoritatively stated; every other file that needs the rule points to it rather than restating it | Canonical location, canonical home | planifest-orchestrator, all phase skills, standards files |
| Class 1 removal | A section of orchestrator content whose canonical owner already exists elsewhere; removed and replaced with a one-line pointer | n/a | req-002 |
| Class 2 relocation | Reference data (model-tier table, parallelism rules) with no canonical owner yet; moved into a new standards file that becomes its canonical owner | n/a | req-003 |
| Class 3 trim | Expository or explanatory prose that carries no operative instruction; removed outright with no relocation needed | n/a | req-004 |
| Baseline-gated trim process | The 0000021 ADR-002 process requiring a recorded regression-pack run before any trim edit and a comparison re-run after, with zero enforcement-content loss as the pass condition | n/a | req-001, req-005, all requirements |
| Enforcement-content loss | A rule that was operative before a trim and is no longer stated anywhere after it - the failure condition this feature's dual-detector approach exists to prevent | n/a | risk-register R-001, req-005 |
| Pointer | A short sentence in the orchestrator (or another file) directing the reader to the canonical owner of a rule, replacing a full restatement | n/a | req-002, req-003 |
| Second detector | The P4 diff review, confirmed during Scope Lock as resolving identically to a failed regression test: a lost rule found by either detector is restored, never rationalised | n/a | risk-register R-001, Phase 4 gate |
