---
title: "Requirement: req-003 - Subagent Out-of-Scope Backlog Filing"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-003 - Subagent Out-of-Scope Backlog Filing

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source:** US-003 (0000035)
**Priority:** should-have

## User Story

> One requirement doc = one user story.

As a dispatched phase-agent subagent, I want explicit instruction to file an out-of-scope discovery to `plan/backlog/` directly, so that discovered bugs enter the Planifest backlog-pickup protocol instead of bypassing it via a host-tool mechanism.

## Functional Requirements

- `planifest-framework/standards/agent-dispatch-standards.md`'s Agent Dispatch Template MUST gain an explicit out-of-scope-discovery clause: when a dispatched subagent discovers an out-of-scope bug or gap during its task, it MUST file `plan/backlog/{id}-{slug}/entry.md` per `templates/backlog-entry.template.md`, with `Deferral source: discovered mid-flight`, `Source feature` set to the active feature ID, and `Source phase` set to the phase active at discovery — not report it back for the dispatching agent to relay via a host-tool side channel (e.g. `spawn_task`), and not silently drop it.
- The dispatching agent (orchestrator or phase skill placing the `Agent()` call) MUST pre-compute the next available backlog ID before dispatch and pass it explicitly in the subagent's prompt as the ID to use if a discovery needs filing. Subagent self-lookup of `plan/backlog/` at file-time is rejected for this requirement: picked-up entries are removed from `plan/backlog/` once folded into a design (confirmed by this feature's own `0000035`/`0000044` entries, no longer present in that directory), so a subagent scanning only `plan/backlog/` would systematically undercount the true "highest ever allocated" and risk reusing a retired ID — a risk avoided entirely once the dispatching agent, which has visibility into `design.md`/`build-log.md` history at dispatch time, assigns the ID upfront.
- When the dispatching agent dispatches multiple subagents in parallel (per the Parallelism Rules), each MUST receive a distinct pre-assigned backlog ID (or a reserved contiguous block, one per subagent) so that no two subagents can independently file under the same ID.
- The Agent Dispatch Template's **Self-contained prompt rule** MUST be updated to list "the backlog ID to use if filing an out-of-scope discovery" as one of the required elements of a self-contained dispatch prompt, alongside the requirement file path, relevant ADR paths, stack constraint, and definition of done.
- At least one phase skill's own dispatch guidance section (`planifest-codegen-agent`'s Parallel Dispatch Checklist, or the Parallelism Directive in `planifest-spec-agent`, `planifest-validate-agent`, `planifest-security-agent`, or `planifest-docs-agent`) MUST reference this out-of-scope-discovery instruction — a cross-reference to the updated `agent-dispatch-standards.md` section is sufficient; the instruction does not need to be duplicated in full in every phase skill.

## Acceptance Criteria

- [ ] `agent-dispatch-standards.md`'s Agent Dispatch Template includes an explicit out-of-scope-discovery clause instructing subagents to file `plan/backlog/{id}-{slug}/entry.md` per `templates/backlog-entry.template.md`, not a host-tool mechanism
- [ ] The clause states the dispatching agent pre-computes the next backlog ID and passes it in the subagent's prompt (subagent self-lookup of `plan/backlog/` is explicitly rejected, with the picked-up-entries-disappear rationale recorded)
- [ ] The clause covers the parallel-dispatch case: each subagent in a parallel batch receives a distinct pre-assigned ID or reserved block, not a shared one
- [ ] The Self-contained prompt rule list is updated to include the pre-assigned backlog ID as a required prompt element
- [ ] At least one phase skill's own dispatch section (`planifest-codegen-agent`, `planifest-spec-agent`, `planifest-validate-agent`, `planifest-security-agent`, or `planifest-docs-agent`) references the out-of-scope-discovery instruction, at minimum by cross-reference to `agent-dispatch-standards.md`
- [ ] No dispatched-subagent prompt template or dispatch guidance still names `spawn_task` or an equivalent host-tool mechanism as the way to file discoveries

## Dependencies

- `planifest-framework/standards/agent-dispatch-standards.md` (Agent Dispatch Template, Parallelism Rules, Self-contained prompt rule) — the primary artifact this requirement amends.
- `templates/backlog-entry.template.md` (fields: `Source feature`, `Source phase`, `Deferral source`, ID sequencing note) — the filing format subagents must follow.
- Phase skill dispatch sections: `.claude/skills/planifest-codegen-agent/SKILL.md` (Parallel Dispatch Checklist), `.claude/skills/planifest-spec-agent/SKILL.md`, `.claude/skills/planifest-validate-agent/SKILL.md`, `.claude/skills/planifest-security-agent/SKILL.md`, `.claude/skills/planifest-docs-agent/SKILL.md` (each has its own Parallelism Directive referencing the standards doc).
- No dependency on the other 7 requirements in this feature; can be actioned independently and in parallel with any of them.
