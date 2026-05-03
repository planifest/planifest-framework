---
title: "Requirement: REQ-009 - copilot-adapter"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-009 - copilot-adapter

**Feature:** 0000005-framework-governance
**Source:** GitHub Copilot adapter user story (feature-brief.md)
**Priority:** should-have

---

## Functional Requirements

- `planifest-framework/hooks/adapters/copilot.mjs` must be created, wiring gate-write and check-design enforcement into Copilot Agent Hooks (Preview 2025 — `agent_hooks` API)
- The adapter must map Copilot hook events to the same enforcement logic as the Claude Code hooks
- The adapter must degrade gracefully when Copilot hooks are disabled by org policy: exit 0, no session blocking
- setup.ps1 / setup.sh must register the copilot adapter in `.github/hooks/` (or equivalent Copilot hook config path)
- `tool-setup-reference.md` must be updated to document Copilot hook setup and known limitations (Preview status)

## Acceptance Criteria

- [ ] `planifest-framework/hooks/adapters/copilot.mjs` exists
- [ ] Adapter exits 0 gracefully when hooks are disabled by org policy
- [ ] setup registers the adapter in the correct Copilot config path
- [ ] `tool-setup-reference.md` documents Copilot setup

## Dependencies

- REQ-007 (orchestrator-sentinel) — gate-write logic being wired
- REQ-008 (check-design inject) — check-design logic being wired
