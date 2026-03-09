# Pipeline Run — {{initiative-id}}

**Skill:** [docs-agent](../skills/docs-agent-SKILL.md) (or whichever agent completes the final phase)
**Date:** {{ISO-8601}}
**Tool:** {{agentic-tool-name}} (local)
**Model:** {{model-name-and-version, e.g. claude-sonnet-4-20250514, gpt-4.1, gemini-2.5-pro}}
**Phase:** {{phase-number}} (if phased)

---

## Phases Completed

- [ ] Specification
- [ ] ADRs ({{n}} generated)
- [ ] Code generation
- [ ] Validation ({{n}} self-correct cycles)
- [ ] Security review
- [ ] Docs sync

---

## Self-Correct Log

{{what failed and how it was fixed — each attempt with the error and the fix}}

---

## Quirks

{{anything unusual noticed during the run — written to docs/quirks.md and component.json}}

---

## Recommended Improvements

{{what should be reviewed before the PR — these are not blockers, but flagged for human attention}}

---

## Next Step

```bash
git push origin initiative/{{initiative-id}}
```

---

*Written by the agent at the end of every pipeline run. This is the audit trail.*
