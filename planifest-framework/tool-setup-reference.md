# Agentic Tool Setup Reference

> How each supported coding tool discovers skills, and what the setup script creates for each.

---

## Scripts

Two setup scripts are provided — use whichever matches your OS:

| OS | Script | Interpreter |
|----|--------|-------------|
| macOS / Linux | `setup.sh` | Bash (pre-installed) |
| Windows | `setup.ps1` | PowerShell (pre-installed) |

**Zero dependencies.** Both scripts use only built-in OS capabilities — no Node.js, Python, or anything else required.

---

## What the Script Does

For each tool, the script:

1. **Creates the tool's skill directory** (e.g., `.claude/skills/`)
2. **Copies each skill** as `{skill-name}/SKILL.md` with the required YAML frontmatter (`name` + `description`)
3. **Copies supporting files** (templates, standards, schemas) into the skill directory as `_planifest-*` folders
4. **Copies workflows** (initiative-pipeline, change-pipeline, retrofit) into the tool's workflow directory
5. **Creates a boot file** (e.g., `CLAUDE.md`) if one doesn't already exist

---

## Tool Reference

### Claude Code (Anthropic)

| Item | Detail |
|------|--------|
| **Skill discovery** | `.claude/skills/{name}/SKILL.md` |
| **Workflow discovery** | `.claude/commands/{name}.md` (becomes `/name` slash command) |
| **Boot file** | `CLAUDE.md` (project root) |
| **Personal skills** | `~/.claude/skills/` |
| **Frontmatter** | `name` + `description` required |
| **Progressive disclosure** | Yes — reads frontmatter first, loads body on demand |
| **Setup command** | `./planifest-framework/setup.sh claude-code` or `.\planifest-framework\setup.ps1 claude-code` |

**Creates:**
```
.claude/
├── skills/
│   ├── orchestrator/SKILL.md
│   ├── ... (all 8 skills)
│   ├── _planifest-templates/
│   ├── _planifest-standards/
│   └── _planifest-schemas/
└── commands/
    ├── initiative-pipeline.md
    ├── change-pipeline.md
    └── retrofit.md
CLAUDE.md
```

---

### Cursor

| Item | Detail |
|------|--------|
| **Skill discovery** | `.cursor/skills/{name}/SKILL.md` |
| **Workflow discovery** | Embedded in `.cursor/rules/*.mdc` (no dedicated workflow dir) |
| **Rules** | `.cursor/rules/*.mdc` |
| **Compat paths** | Also scans `.claude/skills/`, `.codex/skills/` |
| **Personal skills** | `~/.cursor/skills/` |
| **Frontmatter** | `name` + `description` required |
| **Progressive disclosure** | Yes |
| **Setup command** | `./planifest-framework/setup.sh cursor` or `.\planifest-framework\setup.ps1 cursor` |

**Creates:**
```
.cursor/
├── skills/
│   ├── orchestrator/SKILL.md
│   ├── ... (all 8 skills)
│   ├── _planifest-templates/
│   ├── _planifest-standards/
│   └── _planifest-schemas/
└── rules/
    └── planifest.mdc
```

---

### Codex (OpenAI)

| Item | Detail |
|------|--------|
| **Skill discovery** | `.agents/skills/{name}/SKILL.md` (walks up to repo root) |
| **Workflow discovery** | `.agents/workflows/{name}.md` |
| **Boot file** | `AGENTS.md` (project root) |
| **Compat paths** | Also scans `.claude/skills/`, `.github/skills/` |
| **Personal skills** | `~/.codex/skills/` or `$CODEX_HOME/skills/` |
| **Frontmatter** | `name` + `description` required |
| **Progressive disclosure** | Yes |
| **Setup command** | `./planifest-framework/setup.sh codex` or `.\planifest-framework\setup.ps1 codex` |

**Creates:**
```
.agents/
├── skills/
│   ├── orchestrator/SKILL.md
│   ├── ... (all 8 skills)
│   ├── _planifest-templates/
│   ├── _planifest-standards/
│   └── _planifest-schemas/
└── workflows/
    ├── initiative-pipeline.md
    ├── change-pipeline.md
    └── retrofit.md
AGENTS.md
```

---

### Antigravity (Google)

| Item | Detail |
|------|--------|
| **Skill discovery** | `.gemini/skills/{name}/SKILL.md` or `.agent/skills/{name}/SKILL.md` |
| **Workflow discovery** | `.agent/workflows/{name}.md` (becomes `/name` slash command) |
| **Boot file** | None needed — uses skill discovery directly |
| **Personal skills** | `~/.gemini/antigravity/skills/` |
| **Frontmatter** | `name` + `description` required |
| **Progressive disclosure** | Yes |
| **Link command** | `gemini skills link ./planifest-framework/skills/<name>` |
| **Setup command** | `./planifest-framework/setup.sh antigravity` or `.\planifest-framework\setup.ps1 antigravity` |

**Creates:**
```
.gemini/
└── skills/
    ├── orchestrator/SKILL.md
    ├── ... (all 8 skills)
    ├── _planifest-templates/
    ├── _planifest-standards/
    └── _planifest-schemas/
.agent/
└── workflows/
    ├── initiative-pipeline.md
    ├── change-pipeline.md
    └── retrofit.md
```

---

### GitHub Copilot

| Item | Detail |
|------|--------|
| **Skill discovery** | `.github/skills/{name}/SKILL.md` |
| **Boot file** | `.github/copilot-instructions.md` |
| **Personal skills** | `~/.copilot/skills/` |
| **Frontmatter** | `name` + `description` + optional `license` |
| **Progressive disclosure** | Yes |
| **Setup command** | `./planifest-framework/setup.sh copilot` or `.\planifest-framework\setup.ps1 copilot` |

**Creates:**
```
.github/
├── skills/
│   ├── orchestrator/SKILL.md
│   ├── ... (all 8 skills)
│   ├── _planifest-templates/
│   ├── _planifest-standards/
│   └── _planifest-schemas/
└── copilot-instructions.md
```

---

## Common Patterns Across All Tools

All five tools share these conventions:
- Skills are folders containing a `SKILL.md` file
- `SKILL.md` must have YAML frontmatter with `name` and `description`
- Tools use **progressive disclosure** — they read frontmatter first, then load the full body on demand
- Personal/global skills in `~/.<tool>/skills/` override project skills
- No tool supports custom scan paths — only their hardcoded directories

---

## After Setup

1. **Commit the generated files** to version control if your team uses the same tool
2. **Re-run the script** after updating any skills, templates, or standards in `planifest-framework/`
3. **Add to `.gitignore`** if you don't want tool-specific files committed:
   ```
   .claude/
   .cursor/
   .agents/
   .gemini/
   .github/skills/
   ```

---

*Source of truth: `planifest-framework/` — the generated files are copies.*
