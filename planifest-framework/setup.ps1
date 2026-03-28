<#
.SYNOPSIS
    Planifest Setup - Configures skills for your agentic coding tool.

.DESCRIPTION
    Copies Planifest skills into the directory structure each coding tool expects.
    Each tool's specific config lives in setup/<tool>.ps1.
    This script handles shared logic only.

.PARAMETER Tool
    The agentic tool to configure: claude-code, cursor, codex, antigravity, copilot, or all.

.EXAMPLE
    .\planifest-framework\setup.ps1 claude-code
    .\planifest-framework\setup.ps1 all
#>

param(
    [Parameter(Position = 0)]
    [string]$Tool
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$SkillsSrc = Join-Path $ScriptDir 'skills'
$WorkflowsSrc = Join-Path $ScriptDir 'workflows'
$SetupDir = Join-Path $ScriptDir 'setup'

$ValidTools = @('claude-code', 'cursor', 'codex', 'antigravity', 'copilot')

# --- Shared functions ---

function Copy-PlanifestSkills {
    param($TargetDir)

    Get-ChildItem -Path $SkillsSrc -Directory | ForEach-Object {
        $skillName = $_.Name
        $srcDir = $_.FullName
        $destDir = Join-Path $TargetDir $skillName
        
        $srcSkillMd = Join-Path $srcDir "SKILL.md"
        if (Test-Path $srcSkillMd) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            Copy-Item -Path $srcSkillMd -Destination $destDir -Force

            # Rewrite relative paths to match bundled directory structure
            $skillMdPath = Join-Path $destDir "SKILL.md"
            $skillContent = Get-Content -Path $skillMdPath -Raw
            $skillContent = $skillContent -replace '\.\./templates/', './assets/templates/'
            $skillContent = $skillContent -replace '\.\./standards/', './references/'
            $skillContent = $skillContent -replace '\.\./schemas/', './assets/schemas/'
            Set-Content -Path $skillMdPath -Value $skillContent -NoNewline -Encoding UTF8

            Write-Host "  + $skillName/SKILL.md"
            
            foreach ($optDir in @('scripts', 'assets', 'references')) {
                $srcOptDir = Join-Path $srcDir $optDir
                if (Test-Path $srcOptDir) {
                    Copy-Item -Path $srcOptDir -Destination $destDir -Recurse -Force
                }
            }

            # Bundle shared resources directly into the skill
            $templatesSrc = Join-Path $ScriptDir "templates"
            if (Test-Path $templatesSrc) {
                $destTemplates = Join-Path $destDir "assets\templates"
                New-Item -ItemType Directory -Path $destTemplates -Force | Out-Null
                Copy-Item -Path "$templatesSrc\*" -Destination $destTemplates -Recurse -Force
            }

            $schemasSrc = Join-Path $ScriptDir "schemas"
            if (Test-Path $schemasSrc) {
                $destSchemas = Join-Path $destDir "assets\schemas"
                New-Item -ItemType Directory -Path $destSchemas -Force | Out-Null
                Copy-Item -Path "$schemasSrc\*" -Destination $destSchemas -Recurse -Force
            }

            $standardsSrc = Join-Path $ScriptDir "standards"
            if (Test-Path $standardsSrc) {
                $destRefs = Join-Path $destDir "references"
                New-Item -ItemType Directory -Path $destRefs -Force | Out-Null
                Copy-Item -Path "$standardsSrc\*" -Destination $destRefs -Recurse -Force
            }
        }
    }
}

function Write-PlanifestBootFile {
    param($RelPath, $Content)

    $fullPath = Join-Path $ProjectRoot $RelPath
    $dir = Split-Path -Parent $fullPath
    New-Item -ItemType Directory -Path $dir -Force | Out-Null

    if (-not (Test-Path $fullPath)) {
        Set-Content -Path $fullPath -Value $Content -Encoding UTF8
        Write-Host "  + $RelPath (created)"
    }
    else {
        Write-Host "  - $RelPath (already exists, skipped)"
    }
}

function Copy-PlanifestWorkflow {
    param($WorkflowFile, $TargetDir)

    $name = [System.IO.Path]::GetFileNameWithoutExtension($WorkflowFile)
    $destFile = Join-Path $TargetDir "$name.md"

    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    Copy-Item -Path $WorkflowFile -Destination $destFile -Force
    Write-Host "  + workflows/$name.md"
}

function Invoke-PlanifestGuardrails {
    Write-Host ""
    Write-Host "  Activating Planifest Git Guardrails"

    # Point Git to the version-controlled hooks directory
    git config core.hooksPath planifest-framework/hooks
    Write-Host "  + git config core.hooksPath planifest-framework/hooks"

    # Note: chmod is not available on Windows; hooks are made executable by setup.sh on Unix.
    # On Windows, Git for Windows respects the executable bit stored in the repo,
    # so no additional step is required here.

    # Deploy the CI/CD pipeline workflow
    $githubWorkflows = Join-Path $ProjectRoot '.github\workflows'
    $workflowSrc = Join-Path $ScriptDir 'hooks\planifest.yml'
    if (Test-Path $workflowSrc) {
        New-Item -ItemType Directory -Path $githubWorkflows -Force | Out-Null
        $dest = Join-Path $githubWorkflows 'planifest.yml'
        if (-not (Test-Path $dest)) {
            Copy-Item -Path $workflowSrc -Destination $dest -Force
            Write-Host "  + .github/workflows/planifest.yml (created)"
        }
        else {
            Write-Host "  - .github/workflows/planifest.yml (already exists, skipped)"
        }
    }

    # Deploy .gitattributes to enforce LF endings on hook scripts.
    # Without this, Git for Windows re-adds CRLF on checkout, breaking the bash shebang.
    $gitattributesSrc = Join-Path $ScriptDir '.gitattributes'
    $gitattributesDest = Join-Path $ProjectRoot '.gitattributes'
    if (Test-Path $gitattributesSrc) {
        if (-not (Test-Path $gitattributesDest)) {
            Copy-Item -Path $gitattributesSrc -Destination $gitattributesDest -Force
            Write-Host "  + .gitattributes (created — enforces LF on hook scripts)"
        }
        else {
            Write-Host "  - .gitattributes (already exists, skipped)"
        }
    }

    Write-Host "  `u{2705} Git guardrails activated."
}

function Initialize-PlanifestRepo {
    Write-Host ""
    Write-Host "  Initializing Repository Structure"

    $gitignoreSrc = Join-Path $ScriptDir ".gitignore"
    $gitignoreDest = Join-Path $ProjectRoot ".gitignore"
    
    if (Test-Path $gitignoreSrc) {
        if (-not (Test-Path $gitignoreDest)) {
            Copy-Item -Path $gitignoreSrc -Destination $gitignoreDest
            Write-Host "  + .gitignore (copied)"
        }
        else {
            Write-Host "  - .gitignore (already exists at root, skipped)"
        }
    }
    else {
        Write-Host "  ! Warning: .gitignore not found in framework directory ($gitignoreSrc)"
    }

    $srcDir = Join-Path $ProjectRoot "src"
    if (-not (Test-Path $srcDir)) {
        New-Item -ItemType Directory -Path $srcDir -Force | Out-Null
        Write-Host "  + src/ (created)"
    }
    
    $srcReadme = Join-Path $srcDir "README.md"
    if (-not (Test-Path $srcReadme)) {
        Set-Content -Path $srcReadme -Value @'
# src/

Components live here. Each component is a subfolder with a `component.json` manifest.

See [planifest/spec/initiative-structure.md](../planifest/spec/initiative-structure.md) for the canonical layout.
'@ -Encoding UTF8
        Write-Host "  + src/README.md (created)"
    }

    $planDir = Join-Path $ProjectRoot "plan"
    if (-not (Test-Path $planDir)) {
        New-Item -ItemType Directory -Path $planDir -Force | Out-Null
        Write-Host "  + plan/ (created)"
    }
    
    $planReadme = Join-Path $planDir "README.md"
    if (-not (Test-Path $planReadme)) {
        Set-Content -Path $planReadme -Value @'
# plan/

Initiative specifications live here. Each initiative gets a subfolder.

See [plan/initiative-structure.md](initiative-structure.md) for the canonical layout.
'@ -Encoding UTF8
        Write-Host "  + plan/README.md (created)"
    }

    $planStructure = Join-Path $planDir "initiative-structure.md"
    if (-not (Test-Path $planStructure)) {
        Set-Content -Path $planStructure -Value @'
# Planifest â€” Repository Structure

> The canonical layout for a Planifest-managed repository. Three top-level folders, three concerns.

---

## The Three Folders

```
repo/
â”œâ”€â”€ planifest-framework/        â† The framework (skills, templates, schemas, standards)
â”‚                                 Drop this in. Don't modify it per-project.
â”‚
â”œâ”€â”€ plan/                       â† The specifications (organized by initiative)
â”‚                                 Plans, briefs, specs, ADRs, risk, scope, glossary.
â”‚                                 Everything that describes WHAT to build and WHY.
â”‚
â””â”€â”€ src/                        â† The code (organized by component)
                                  Implementation, tests, config, manifests.
                                  Everything that IS the built thing.
```

---

## `planifest-framework/` â€” The Framework

This folder is the Planifest framework itself. It is the same across every project. You do not modify it per-initiative â€” you update it when the framework evolves.

```
planifest/
â”œâ”€â”€ skills/           â† Agent instructions (orchestrator + phase skills)
â”œâ”€â”€ templates/        â† File format templates for every artifact
â”œâ”€â”€ schemas/          â† JSON Schema validation definitions
â”œâ”€â”€ standards/        â† Code quality standards
â””â”€â”€ spec/             â† This file â€” the canonical structure definition
```

---

## `plan/` â€” The Plan/Specifications

Organized by initiative. Each initiative gets a subfolder. This is where humans write briefs and agents write specs. No code lives here.

```
plan/
â””â”€â”€ {initiative-id}/
    â”œâ”€â”€ initiative-brief.md          â† Human input (start here)
    â”œâ”€â”€ planifest.md                 â† Validated plan (orchestrator output)
    â”œâ”€â”€ pipeline-run.md              â† Audit trail (per run)
    â”œâ”€â”€ pipeline-run-phase-2.md      â† Phase 2 audit (if phased)
    â”‚
    â”œâ”€â”€ design-spec.md               â† Functional & non-functional requirements
    â”œâ”€â”€ design-spec-phase-2.md       â† Phase 2 spec (if phased)
    â”œâ”€â”€ openapi-spec.yaml            â† API contract
    â”œâ”€â”€ scope.md                     â† In / Out / Deferred
    â”œâ”€â”€ risk-register.md             â† Risk items with likelihood & impact
    â”œâ”€â”€ domain-glossary.md           â† Ubiquitous language
    â”œâ”€â”€ security-report.md           â† Security review findings
    â”œâ”€â”€ quirks.md                    â† Quirks and workarounds
    â”œâ”€â”€ recommendations.md           â† Improvement suggestions
    â”‚
    â””â”€â”€ adr/
        â”œâ”€â”€ ADR-001-{title}.md       â† Architecture decision records
        â”œâ”€â”€ ADR-002-{title}.md
        â””â”€â”€ ...
```

### Path Rules â€” plan/

1. **Initiative ID** follows the format `{0000000}-{kebab-case-name}` — a 7-digit zero-padded number prefix for chronological ordering, followed by a human-chosen kebab-case name.
2. **No nesting** â€” specs, ADRs, and supporting docs are flat within the initiative folder. One level of subfolders only (adr/).
3. **No code** â€” nothing executable lives in `plan/`. If it runs, it belongs in `src/`.
4. **Phased initiatives** append the phase number: `design-spec-phase-2.md`, `pipeline-run-phase-2.md`. The `planifest.md` is updated per phase, not duplicated.
5. **ADRs** are numbered sequentially. Never renumber. Superseded ADRs stay with `status: superseded`.

---

## `src/` â€” The Code

Organized by component. Each component is a subfolder at the top level of `src/`. The component manifest lives with the code, not with the plan.

```
src/
â””â”€â”€ {component-id}/
    â”œâ”€â”€ component.json               â† Component manifest (from template)
    â”œâ”€â”€ package.json                  â† (or equivalent for the stack)
    â”‚
    â”œâ”€â”€ src/                          â† Implementation (structure varies by stack)
    â”‚   â””â”€â”€ ...
    â”‚
    â”œâ”€â”€ tests/                        â† Tests
    â”‚   â””â”€â”€ ...
    â”‚
    â””â”€â”€ docs/
        â”œâ”€â”€ data-contract.md          â† Schema ownership & invariants
        â””â”€â”€ migrations/
            â””â”€â”€ proposed-{desc}.md    â† Migration proposals
```

### Path Rules â€” src/

1. **Component ID** is kebab-case, matches the `id` in `component.json`.
2. **component.json is mandatory** â€” every component has one. Read it before any work; update it after every build.
3. **Component-specific docs** live with the component at `src/{component-id}/docs/`. These describe the component's data contract, migrations, and technical specifics.
4. **Initiative-level docs** live in `plan/`. The component's `component.json` references the initiative via the `initiative` field.
5. **Existing components** that predate Planifest are retrofitted by adding a `component.json` at their root.

---

## How the Three Folders Connect

```
plan/current/planifest.md
    â””â”€â”€ lists component IDs â†’ src/{component-id}/component.json
                                    â””â”€â”€ references initiative â†’ plan/

plan/current/design-spec.md
    â””â”€â”€ functional requirements â†’ implemented in â†’ src/{component-id}/src/

plan/current/adr/ADR-001-*.md
    â””â”€â”€ decisions â†’ followed by â†’ src/{component-id}/src/

plan/current/openapi-spec.yaml
    â””â”€â”€ API contract â†’ implemented in â†’ src/{component-id}/src/
```

The relationship is bidirectional:
- `planifest.md` lists all component IDs
- Each `component.json` references its initiative ID
- The plan describes WHAT; the code IS the WHAT

---

## Retrofit â€” Adding Planifest to an Existing Repo

If the repo already has code:

1. Drop `planifest/` into the repo root
2. Create `plan/` for the first initiative
3. Move existing components under `src/` (or leave them if they're already there)
4. Add a `component.json` to each existing component
5. The orchestrator's retrofit mode will read the codebase and infer the existing architecture

---

*Templates for each file are in [planifest/templates/](../templates/). Skills reference these paths.*
'@ -Encoding UTF8
        Write-Host "  + plan/initiative-structure.md (created)"
    }
}

function Invoke-PlanifestSetup {
    param($ToolName)

    $toolConfigPath = Join-Path $SetupDir "$ToolName.ps1"
    if (-not (Test-Path $toolConfigPath)) {
        Write-Host "Error: no config file at setup/$ToolName.ps1"
        exit 1
    }

    # Load tool-specific config
    $toolConfig = & $toolConfigPath

    $skillsDir = Join-Path $ProjectRoot $toolConfig.SkillsDir

    Write-Host ""
    Write-Host "  Setting up $ToolName"
    Write-Host "  Skills directory: $($toolConfig.SkillsDir)/"

    # Copy skills (now automatically bundles supporting files)
    Copy-PlanifestSkills -TargetDir $skillsDir

    # Copy workflows (if tool defines a workflow dir)
    if ($toolConfig.WorkflowsDir -and (Test-Path $WorkflowsSrc)) {
        $workflowsDir = Join-Path $ProjectRoot $toolConfig.WorkflowsDir
        Get-ChildItem -Path $WorkflowsSrc -Filter '*.md' | ForEach-Object {
            Copy-PlanifestWorkflow -WorkflowFile $_.FullName -TargetDir $workflowsDir
        }
    }

    # Create boot file (if tool defines one)
    if ($toolConfig.BootFile) {
        Write-PlanifestBootFile -RelPath $toolConfig.BootFile -Content $toolConfig.BootContent
    }

    Write-Host "  Done."
}

# --- Main ---

if (-not $Tool) {
    Write-Host ""
    Write-Host "Planifest Setup"
    Write-Host ""
    Write-Host "Usage: .\planifest-framework\setup.ps1 [tool]"
    Write-Host ""
    Write-Host "Tools:"
    foreach ($t in $ValidTools) {
        Write-Host "  $t"
    }
    Write-Host "  all"
    Write-Host ""
    Write-Host "Run from the repository root."
    Write-Host "Each tool's config: planifest-framework\setup\[tool].ps1"
    exit 0
}

Write-Host "Planifest Setup"
Write-Host ("=" * 40)

Initialize-PlanifestRepo
Invoke-PlanifestGuardrails

$ToolLower = $Tool.ToLower()

if ($ToolLower -eq 'all') {
    foreach ($t in $ValidTools) {
        Invoke-PlanifestSetup -ToolName $t
    }
}
elseif ($ValidTools -contains $ToolLower) {
    Invoke-PlanifestSetup -ToolName $ToolLower
}
else {
    Write-Host "Unknown tool: $Tool"
    Write-Host "Valid tools: $($ValidTools -join ', '), all"
    exit 1
}

Write-Host ""
Write-Host "Setup complete."
Write-Host "  Source of truth: planifest-framework/"
Write-Host "  Re-run after updating framework files."
