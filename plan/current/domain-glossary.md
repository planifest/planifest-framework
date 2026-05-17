# Domain Glossary - 0000011-setup-parity-and-consistency

**Feature:** 0000011-setup-parity-and-consistency
**Version:** 0.1.0
**Status:** active

Terms used in the requirements and spec artifacts for this feature. All agents and humans use these terms consistently.

---

| Term | Definition |
|------|------------|
| **hook adapter** | A Node.js `.mjs` script in `planifest-framework/hooks/adapters/` that translates a tool's native hook envelope into Planifest enforcement logic. Each tool has one adapter. |
| **common envelope** | The normalised JSON structure that Planifest enforcement scripts (`gate-write.mjs`, `check-design.mjs`) expect on stdin. Adapter's job is to translate the tool's native envelope into this form. |
| **Tier 1** | Hooks enforcement tier where the tool has a native hook system and Planifest wires enforcement through it. The strongest enforcement tier. |
| **Tier 1b** | A Tier 1 variant where native hook support exists but has platform limitations (e.g. macOS/Linux only). Codex CLI is Tier 1b. |
| **Tier 2** | Hooks enforcement tier where enforcement is wired through a plugin or extension mechanism rather than native hooks. |
| **Tier 3** | Hooks enforcement tier where no native hook system exists. Enforcement relies on written instructions in the boot file (e.g. AGENTS.md, CLAUDE.md). |
| **gate-write** | The Planifest enforcement script (`hooks/enforcement/gate-write.mjs`) that blocks writes to `src/` when no confirmed design exists or the target path is outside the declared component scope. |
| **check-design** | The Planifest enforcement script (`hooks/enforcement/check-design.mjs`) that injects active component scope from `design.md` as additional context at the start of each prompt turn. |
| **fail-open** | Adapter behaviour where any unexpected internal error causes the adapter to exit 0 (allow) rather than exit 2 (block). Prevents hook bugs from blocking developer sessions. |
| **idempotent** | A setup script or migration is idempotent if running it multiple times produces the same result as running it once. No duplicate entries, no data loss on re-run. |
| **living documentation** | Documentation that is continuously updated to reflect current system state, as opposed to point-in-time artifacts. `docs/` contains living docs; `plan/` contains change artifacts. |
| **migration instruction doc** | A `.md` file in `planifest-framework/migrations/` that instructs the `planifest-migrator` skill on what changes to make in an existing repo. Picked up automatically by the orchestrator's resume detection. Moved to `_done/` when complete. |
| **archive directory** | The directory where completed pipeline artifacts are moved after a feature ships. Canonical name: `plan/_archive/` (underscore prefix sorts to top in directory listings). |
| **acceptance criterion (AC)** | A specific, testable condition that must be satisfied for a user story to be considered complete. Expressed as a checkbox in the `## Acceptance Criteria` section of a requirement doc. |
| **user story** | A requirement expressed from the perspective of the person who benefits: "As a {role}, I want {capability} so that {outcome}." One user story per requirement file. |
| **spec-agent** | The Planifest pipeline skill responsible for producing P1 artifacts: execution plan, requirements, scope, risk register, and domain glossary. |
| **rail tightening test** | `planifest-framework/tests/test-0000009-rail-tightening.sh` — a static grep-based assertion test that checks framework files contain required strings and functions. Used to prevent regression of structural invariants. |
| **`$ValidTools`** | The PowerShell array in `setup.ps1` that lists every recognised tool name. Passing an unrecognised tool name prints an error and exits. |
| **`Copy-ExternalSkills`** | The PowerShell function in `setup.ps1` (added by REQ-001) that copies `SKILL.md` and `attribution.txt` from `external-skills/*/` to the tool's skill directory when `--include-full-skill-library` is set. |
| **`.planifest-manifest`** | A line-delimited text file in the repo root tracking all directories installed by setup scripts. Used to clean up stale installations on re-run. |
| **`pre_user_prompt`** (Windsurf) | Windsurf Cascade hook event that fires before a user prompt is processed. Used by Planifest for check-design scope injection. |
| **`beforeSubmitPrompt`** (Cursor) | Cursor hook event that fires before the user prompt is submitted to the agent. Used by Planifest for check-design scope injection. |
| **`UserPromptSubmit`** (Codex) | Codex CLI hook event that fires when the user submits a prompt. Used by Planifest for check-design scope injection. |
| **`userPromptSubmitted`** (Copilot) | GitHub Copilot hook event that fires when the user submits a prompt. Used by Planifest for check-design context injection. |
