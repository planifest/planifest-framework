---
title: "Backlog Entry: 0000012 - Orchestrator context window clearance and dynamic compaction"
summary: "Ensure orchestrator triggers context clear at Phase 0 initiation (or prompts user if unsupported) and performs inline compaction when wasteful context accumulates."
status: "open"
---
# Backlog Entry: 0000012 - Orchestrator context window clearance and dynamic compaction

**Source feature:** N/A - Ad hoc entry by human on loop
**Source phase:** N/A - Ad hoc entry by human on loop
**Date filed:** 2026-07-31

---

## Problem

When starting a new Planifest session at Phase 0, residual context from prior sessions can pollute the agent's context window, leading to hallucination, elevated token costs, or unexpected behavior. Additionally, long-running sessions accumulate stale/wasteful context, degrading performance over time without periodic maintenance.

## Suggested Action

1. **Phase 0 Context Reset:**
   * Configure the orchestrator agent to issue a `/clear` command (or execute an equivalent API/tool operation) at the very start of a session entering Phase 0.
   * If the host platform/environment does not support programmatic context clearing, the orchestrator must explicitly flag this requirement to the human user to execute manually before proceeding.

2. **Dynamic Context Compaction:**
   * Implement context-monitoring logic for ongoing sessions to identify redundant, unneeded, or wasteful context.
   * Automatically compact or prune the context window whenever clear efficiency gains are identified.

3. **P9 Completion Context Clear:**
   * Once the orchestrator has completed the entire cycle (P0-P9) and P9 ship activities finish, issue a `/clear` (or equivalent) so the next session starts cold rather than carrying forward the completed cycle's context.
   * If the host platform does not support programmatic clearing at this point, flag the human to clear manually before starting the next cycle.

## Why Deferred

Discovered outside of normal cycle and needs to be planned.