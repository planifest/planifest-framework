---
name: change-pipeline
description: Modify an existing initiative - implements the minimum change, validates, and updates documentation. Use this instead of the full pipeline for changes to existing work.
---

# Change Pipeline

Execute the Planifest change pipeline for modifications to an existing initiative.

## Prerequisites

- An existing initiative with a confirmed Planifest at `plan/{initiative-id}/planifest.md`
- The component(s) affected by the change exist in `src/{component-id}/`

## Input

Provide all three:
- **Initiative ID**: which initiative to modify
- **Component ID**: which component(s) are affected
- **Change request**: what to change and why

## Steps

1. **Load the orchestrator skill**
2. **Confirm scope** - the orchestrator confirms:
   - Which initiative?
   - Which component(s)?
   - What is the change?
   - If ambiguous, clarify - one question at a time
3. **Invoke the change-agent** - it handles:
   - Load domain context (existing spec, manifests, ADRs)
   - Implement the minimum necessary change
   - Run validation (lint, typecheck, test, build)
   - Check for contract or schema changes - if found, propose migration and stop
   - Update documentation
4. **Review** - the change-agent produces a summary of what changed and why
