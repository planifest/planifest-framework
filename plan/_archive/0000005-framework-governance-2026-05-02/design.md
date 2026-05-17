---
title: "Design - framework-governance"
status: "confirmed"
version: "0.1.0"
---
# Design - 0000005-framework-governance

## Feature
- **Problem:** Seven governance gaps — non-deterministic library choices, bypassable orchestrator, no capability skill intake path, inconsistent date formats, no migration system, undeclared locale standard, verbose agent responses
- **Adoption mode:** retrofit
- **Feature ID:** 0000005-framework-governance

---

## Product Layer
- **User stories confirmed:** 33
- **Acceptance criteria confirmed:** 25
- **Constraints:**
  - Hooks must exit 0 on unexpected errors; exit 2 on enforcement failure only
  - plan/.orchestrator-active is feature-scoped — keyed to feature-id, cleared at P7
  - Roo-Code: no hook API, sunset 02 May 2026 — out of scope
  - Copilot adapter must degrade gracefully when org policy disables hooks
- **Integrations:** gate-write.mjs, check-design.mjs, setup.ps1/setup.sh, planifest-codegen-agent, planifest-validate-agent, planifest-orchestrator, planifest-ship-agent

---

## Architecture Layer
- **Latency target:** gate-write sentinel check adds < 5ms per Write/Edit call
- **Availability:** n/a — framework tooling, not a service
- **Scalability:** n/a
- **Security:** no credentials; no user data; no auth layer
- **Data privacy:** n/a
- **Observability:** existing emit-phase-start/emit-phase-end telemetry hooks
- **API versioning:** n/a
- **Cost:** none

---

## Engineering Layer
- **Stack:** JavaScript ESM (.mjs) for hooks; Markdown for standards and skill files
- **Runtime:** Node.js (existing hook runtime)
- **Components:** 17 — see `plan/current/feature-brief.md` § Target Architecture
- **Data ownership:** see feature-brief.md § Data Ownership
- **Deployment:** setup.ps1/setup.sh copies planifest-framework/ to tool-specific directories
- **Infrastructure:** none

---

## Active Skills

None — no capability skills registered for this plan run.
