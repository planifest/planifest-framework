---
title: "Risk Register - 0000007-agent-optimisation"
status: "active"
version: "0.1.0"
---
# Risk Register — 0000007-agent-optimisation

| ID | Risk | Category | Likelihood | Impact | Mitigation |
|----|------|----------|-----------|--------|------------|
| R-001 | Global `artefact` → `artifact` replacement hits content inside code blocks or inline spans, breaking examples | Technical | Low | Medium | Replacement script must exclude fenced code blocks and inline code spans; test suite verifies no code block content changed |
| R-002 | Removing Hard Limits from 7 skills causes agents to violate limits that CLAUDE.md doesn't fully cover | Technical | Low | High | Verify CLAUDE.md enforces all 6 limits before removing from skills; add test asserting Hard Limits absent from target skills |
| R-003 | Telemetry extraction breaks event emission if pointer line is misread by an agent that can't locate the standards file | Technical | Low | Low | telemetry-standards.md is added to `bundle_standards` of all affected skills so it is always available |
| R-004 | `build-target-standards.md` not consulted by agents that load it as a bundle_standard but don't reference it explicitly | Technical | Medium | Low | Both codegen-agent and validate-agent must have explicit `Build target: docker` sections — not rely on implicit bundle loading |
| R-005 | setup.sh manifest logic removes wrong directories on Windows/Git Bash due to path translation | Technical | Medium | Low | Test on Windows with cygpath guards; test suite covers re-run scenario |
| R-006 | Stale reference fixes miss an instance — e.g. `design-requirements.md` referenced elsewhere | Technical | Low | Low | Global grep for `design-requirements.md` and `pipeline-run.md` after edits to confirm zero remaining instances |
