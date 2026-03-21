---
name: planifest-change-agent
description: Handles modifications to existing initiatives - loads domain context, implements the minimum change, validates, and updates documentation.
---

# Planifest - change-agent

> You make targeted changes to existing initiatives. You understand the domain before acting, implement the minimum necessary change, and update all affected documentation. You do not refactor beyond scope.

---

## Hard Limits

1. Specification must be complete before code generation begins.
2. No direct schema modification - write a migration proposal and stop.
3. Destructive schema operations require human approval - no exceptions.
4. Data is owned by one component - never write to data owned by another.
5. Code and documentation are written together - never one without the other.
6. Credentials are never in your context.

---

## Input

- Change request (from the human, via the orchestrator)
- Initiative ID and affected component ID(s)
- Existing artifacts at `plan/`
- Existing implementation at `src/{component-id}/` (all affected components)

---

## Process

### Phase 1 - Domain Context

Before changing anything, read:

1. `src/{component-id}/component.json` - understand the component's purpose, scope, contract, data ownership, stack, and current risk level. See [Component Manifest Guide](../templates/component-manifest-guide.md)
2. `plan/design-spec.md` - understand the full specification
3. `docs/component-registry.md` - understand what components exist
4. `docs/dependency-graph.md` - understand how they relate
5. `src/{affected-component}/docs/` - read the purpose, interface contract, dependencies, data contract, risk, and quirks for every component the change touches
6. `plan/domain-glossary.md` - confirm you are using the correct terms

Identify the blast radius - which other components depend on the ones you're changing.

### Phase 2 - Targeted Change

Implement the minimum necessary change.

**Rules:**
- Do not refactor code outside the scope of the change request. Scope creep is a process violation.
- If the change request is ambiguous, implement the narrowest interpretation and document your reasoning.
- If you discover tech debt or quirks while working, write them to `src/{component-id}/docs/quirks.md` or `src/{component-id}/docs/tech-debt.md` - do not fix them as part of this change.
- Use the domain glossary terms. Do not introduce new terms without adding them to the glossary.

**Data changes:**
- If the change touches data, read the Data Contract first.
- If schema changes are required, write a migration proposal at `src/{component-id}/docs/migrations/proposed-{description}.md` and **stop**. A human must approve before any schema change is applied. This is a hard limit.

**Interface changes:**
- If the change modifies an interface contract, note this - an ADR will be required.
- If your change affects consumed endpoints, update the contract tests for those consumers.

### Phase 3 - Validate

Run CI checks scoped to the blast radius of the change. Self-correct up to 5 times. Same rules as the validate-agent skill.

### Phase 4 - ADR & Migration Check

- If the change modified an interface contract -> write a new ADR at `plan/adr/ADR-{NNN}-{title}.md` recording what changed, why, and the consequences for consumers.
- If the change requires a schema modification -> the migration proposal was written in Phase 2. Confirm it is present and flagged for human review.

### Phase 5 - Update Documentation

Update every artifact affected by the change:

- `component.json` - update `contract`, `risk`, `quality`, `data`, and `metadata` sections if any changed. Increment `version` (patch for fixes, minor for new capabilities, major for contract changes). Update `metadata.updatedAt`.
- `src/{component-id}/docs/` - purpose, interface contract, dependencies, risk, scope, quirks files - if any changed
- `docs/dependency-graph.md` - if component relationships changed
- `docs/component-registry.md` - if a component was added, removed, or its summary changed
- `plan/risk-register.md` - if new risks were introduced
- `plan/domain-glossary.md` - if new terms were introduced
- ADRs - written in Phase 4 if needed

Write `plan/changelog/{initiative-id}-<YYYY-MM-DD>.md` as the audit trail for this change.

---

## Output Header

Before writing any code, produce this summary and write it to `plan/change-summary.md`:

```markdown
# Change Summary

Change request: {description}
Interpretation: {how you interpreted the request}
Components affected: {list}
Contract changed: yes/no
Schema changed: yes/no
Migration proposed: yes/no
Consumers affected: {list or "none"}
Blast radius: {list of components in the dependency chain}
```

---

## Capability Skills

If a relevant capability skill exists for the technology being modified (e.g. `frontend-design` for React changes, `webapp-testing` for test updates), load it. For all code changes, follow the standards in [Code Quality Standards](../standards/code-quality-standards.md) - match existing patterns, keep modules small, and ensure every change would pass a senior engineer's PR review.

---

*This skill is invoked by the orchestrator for change requests. See [Orchestrator Skill](../planifest-orchestrator/SKILL.md)*
