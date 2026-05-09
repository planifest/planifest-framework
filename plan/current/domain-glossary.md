---
title: "Domain Glossary - 0000009-framework-rail-tightening"
version: "0.1.0"
---
# Domain Glossary — 0000009-framework-rail-tightening

| Term | Definition |
|------|-----------|
| **always-permitted path** | A file path or prefix that gate-write.mjs passes unconditionally, regardless of whether `plan/current/design.md` exists. Currently: `plan/`, `docs/`, and specific filenames (`claude.md`, `.feature-id`, `.skips`, etc.). |
| **attribution.txt** | A file placed alongside each external skill's `SKILL.md` containing: license type, copyright holder, source URL, and any attribution text required by the original license. |
| **auto-trigger** | The behaviour where the orchestrator skill is invoked automatically at session start without the human explicitly requesting it, via a `UserPromptSubmit` hook or a CLAUDE.md instruction fallback. |
| **capability skill** | A skill that encodes craft knowledge for a specific technology or domain (e.g. React, Fastify), as distinct from a Planifest phase skill which encodes pipeline discipline. |
| **external skill** | An open-source skill sourced from outside the Planifest framework, curated into `planifest-framework/external-skills/` with a verified permissive license and attribution record. |
| **gate-write** | The PreToolUse hook (`gate-write.mjs`) that enforces write compliance — blocking writes to non-permitted paths unless a confirmed design exists and the target path is in scope. |
| **norm()** | The path normalisation function in gate-write.mjs: `normalize(p).replace(/\\/g, "/").toLowerCase()`. Converts Windows backslash paths to forward-slash for consistent prefix matching. |
| **pause.md** | A file written to `plan/current/pause.md` on explicit human command, capturing the current phase, active task, last completed artefact, and in-progress state to enable exact-point resume. |
| **permissive license** | A software license that allows use, modification, and redistribution with minimal restrictions. Accepted: MIT, Apache 2.0, ISC, BSD-2-Clause, BSD-3-Clause. Excluded: GPL, AGPL, unknown. |
| **relTarget** | The repo-relative path computed by gate-write.mjs from the absolute `rawTarget` and `cwd`. Used for prefix matching against always-permitted paths and component paths. |
| **sentinel** | `plan/.orchestrator-active` — a file written at P0 start and deleted at P7 end that signals an active pipeline run, permitting writes to `plan/current/`. |
| **skill map** | A table in `plan/current/design.md` (section `## Skill Map`) mapping each functional requirement to the Planifest skill best suited to implement or verify it. Produced at P0 end, re-evaluated at each phase gate. |
| **skill-to-requirement mapping** | See *skill map*. |
| **Tier 1 adapter** | A shell or Node.js adapter script that translates a non-Claude Code tool's hook envelope (Cursor, Windsurf, Cline, roo-code) to the Planifest common envelope, enabling gate-write enforcement on those tools. |
| **UserPromptSubmit hook** | A Claude Code hook event fired when the user submits a prompt. Used by Planifest to auto-trigger the orchestrator on session start. |
| **Windows path bug** | The bug in gate-write.mjs where mixed `\`/`/` separators on Windows cause `absTarget.startsWith(cwdWithSep)` to return false, leaving `relTarget` as the full absolute path and breaking the always-permitted prefix check. |
