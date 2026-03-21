# Pipeline Run - Guide

> The audit trail written at the end of every pipeline run.

*Related: [Docs Agent Skill](../skills/docs-agent-SKILL.md) | [Orchestrator Skill](../skills/orchestrator-SKILL.md)*

---

## Purpose

The Pipeline Run document is the audit trail. It records what happened during the pipeline: which phases completed, what self-corrections were needed, what quirks were discovered, and what the agent recommends the human review. It's the first thing a human reads before approving a PR.

---

## Who Writes It

The **docs-agent** writes it during Phase 6 (the final phase). If the pipeline is interrupted before Phase 6, the last active agent writes it.

---

## What It Captures

### Phases Completed

A checklist of all pipeline phases. Unchecked items tell the reviewer what didn't run - and therefore what hasn't been validated.

### Self-Correct Log

Every failure and recovery. This is not embarrassing - it's valuable. Knowing that "the validate-agent caught a missing index and added it on attempt 3" tells the reviewer exactly what was auto-fixed.

Include:
- The error message
- What the agent tried
- Whether it succeeded
- How many attempts it took

### Quirks

Anything unusual the agent noticed during the run. These are also written to `quirks.md` and the component's `component.json`. Examples:
- "The ORM generates a LEFT JOIN where an INNER JOIN would be correct - worked around with a raw query"
- "The test framework doesn't support parallel execution with this database driver"

### Recommended Improvements

Not blockers, but things the human should consider. These are flagged for attention at the PR gate:
- "The auth token TTL is hardcoded - consider making it configurable"
- "Test coverage for the error paths is thin - 3 out of 7 error cases have tests"

---

## Reading a Pipeline Run

When reviewing a PR that was produced by Planifest:

1. **Check the phases** - are all boxes checked?
2. **Read the self-correct log** - were there many retries? Were they for the same issue? This signals a spec gap, not an agent failure.
3. **Read the quirks** - these are tech debt items. Decide whether to address them now or later.
4. **Read the recommendations** - these are the agent's judgment calls flagged for human review.

---

## File Location

`plan/changelog/{initiative-id}-<YYYY-MM-DD>.md`

If phased: `plan/pipeline-run-phase-{n}.md`

---

*Template: [pipeline-run.template.md](pipeline-run.template.md)*
