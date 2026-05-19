---
title: "Risk Register - 0000015-pipeline-session-cleanup"
---
# Risk Register - 0000015-pipeline-session-cleanup

| ID | Category | Risk | Likelihood | Impact | Mitigation |
|----|----------|------|-----------|--------|-----------|
| R-001 | Technical | Orchestrator SKILL.md edit conflicts with 0000014 changes — large file, multiple recent edits | Low | Medium | Read full relevant sections before editing; verify no regressions |
| R-002 | Technical | Interrupted P9 detection signal (empty plan/current/ + .orchestrator-active) may false-positive if a human manually clears plan/current/ for other reasons | Low | Low | Signal is conservative — worst case is an extra cleanup run with no side effects |
| R-003 | Operational | Human ignores new-session recommendation and starts next feature in the same session — context pressure degrades P0 quality | Medium | Low | Recommendation is clear; cannot enforce without blocking, which is out of scope |
| R-004 | Technical | REQ-001 build log enforcement may cause confusion if an agent resumes mid-phase and writes a duplicate block | Low | Low | Blocks are append-only; duplicate blocks are visible but harmless for P8 assessment |
