# Risk Register — 0000006-build-assessment-phase

| ID | Risk | Category | Likelihood | Impact | Mitigation |
|----|------|----------|-----------|--------|-----------|
| R-001 | Orchestrator forgets to update build-log.md at phase boundaries — instruction-only enforcement | operational | medium | low | Explicit per-phase instruction in orchestrator; P8 skill notes missing entries as an efficiency observation |
| R-002 | Model tier rules ignored if orchestrator doesn't consult table before every agent spawn | operational | medium | medium | Decision table placed prominently at top of routing section; build-log tier field creates accountability |
| R-003 | Tool doesn't support `model` parameter on Agent calls — tier selection has no effect | technical | low | medium | Rules note: "if the active tool does not support model selection, record the constraint in the build log and use the primary model" |
| R-004 | Build log grows unboundedly on long pipeline runs | technical | low | low | Each phase appends one small block; typical pipeline is 8–9 phases; acceptable size |
| R-005 | Parallelism directives conflict with tool limitations (e.g. tool serialises all tool calls) | technical | low | medium | Directives scoped to "where the tool supports it"; no hard failure if tool serialises |
| R-006 | P8 invoked before P7 archive is complete — report references wrong archive path | operational | low | high | Ship agent instruction: P8 is the last action, after archive confirmed; orchestrator checks archive path exists |
