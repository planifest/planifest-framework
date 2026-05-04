---
title: "Requirement: REQ-004 - Hook scripts exit silently when telemetry absent"
summary: "Telemetry hook scripts never block the agent session regardless of environment state."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-004 - Hook scripts exit silently when telemetry absent

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-4; NFR table
**Priority:** must-have

---

## Functional Requirements

- Both `emit-phase-start.mjs` and `emit-phase-end.mjs` check for the presence of a sentinel before any emission attempt.
- The sentinel is defined as: `PLANIFEST_TELEMETRY_URL` environment variable is set AND is a non-empty string.
- If the sentinel is absent, the script exits 0 immediately with no stdout, no stderr, no network call.
- All network errors, JSON parse errors, and filesystem errors are caught; the script logs nothing and exits 0.
- HTTP requests use an AbortController with a 3-second timeout; timeout triggers a silent exit 0.
- Scripts have no `npm install` dependencies — only Node.js built-ins (`fs`, `path`, `os`, `http`, `https`) are used.

## Acceptance Criteria

- [ ] Running `emit-phase-start.mjs spec` with no env vars set produces no output and exits 0.
- [ ] Running `emit-phase-start.mjs spec` with a non-existent `PLANIFEST_TELEMETRY_URL` host exits 0 within 3 seconds.
- [ ] No `node_modules` directory is required adjacent to the scripts.
- [ ] CI environments without telemetry configured are unaffected by hook presence.

## Dependencies

- None beyond Node.js runtime (≥18 for built-in `fetch` or `http` module).
