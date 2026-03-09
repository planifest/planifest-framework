<#
.SYNOPSIS
    Planifest Setup - Configures skills for your agentic coding tool.

.DESCRIPTION
    Copies Planifest skills into the directory structure each coding tool expects,
    adds YAML frontmatter, copies supporting files, and creates boot files.

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

# --- Skill metadata ---

$Skills = @{
    'orchestrator'   = @{
        Name = 'planifest-orchestrator'
        Desc = 'Guides a human from an initial idea to a complete specification, then executes the Planifest pipeline to build it. Use this for new initiatives or full pipeline runs.'
    }
    'spec-agent'     = @{
        Name = 'planifest-spec-agent'
        Desc = 'Produces specification artifacts (design spec, OpenAPI spec, scope, risk register, domain glossary) for an initiative. Invoked by the orchestrator during Phase 1.'
    }
    'adr-agent'      = @{
        Name = 'planifest-adr-agent'
        Desc = 'Produces Architecture Decision Records for each significant decision in the specification. Invoked by the orchestrator during Phase 2.'
    }
    'codegen-agent'  = @{
        Name = 'planifest-codegen-agent'
        Desc = 'Generates the full implementation from the specification artifacts. Invoked during Phase 3.'
    }
    'validate-agent' = @{
        Name = 'planifest-validate-agent'
        Desc = 'Runs CI checks (lint, typecheck, test, build) and self-corrects up to 5 times. Invoked during Phase 4.'
    }
    'security-agent' = @{
        Name = 'planifest-security-agent'
        Desc = 'Performs a security review of the implementation, producing a security report. Invoked during Phase 5.'
    }
    'change-agent'   = @{
        Name = 'planifest-change-agent'
        Desc = 'Handles modifications to existing initiatives. Loads domain context, implements the minimum change, validates, and updates documentation.'
    }
    'docs-agent'     = @{
        Name = 'planifest-docs-agent'
        Desc = 'Produces per-component documentation, system-wide registry, dependency graph, and pipeline-run audit trail. Invoked during Phase 6.'
    }
}

# --- Tool definitions ---

$Tools = @{
    'claude-code' = @{ SkillsDir = '.claude\skills' }
    'cursor'      = @{ SkillsDir = '.cursor\skills' }
    'codex'       = @{ SkillsDir = '.agents\skills' }
    'antigravity' = @{ SkillsDir = '.gemini\skills' }
    'copilot'     = @{ SkillsDir = '.github\skills' }
}

# --- Boot file content ---

$BootFiles = @{
    'claude-code' = @{
        Path    = 'CLAUDE.md'
        Content = "# Planifest`n`nThis project uses the Planifest framework for agentic development.`n`nTo start a new initiative:`n  Load the orchestrator skill and execute the Initiative Pipeline.`n`nTo make a change:`n  Load the orchestrator skill and execute the Change Pipeline.`n`nKey paths:`n  planifest-framework/README.md    - framework overview and getting started`n  plan/                            - initiative specifications`n  src/                             - component code`n  planifest-framework/templates/   - artifact templates`n  planifest-framework/standards/   - code quality standards"
    }
    'cursor'      = @{
        Path    = '.cursor\rules\planifest.mdc'
        Content = "---`ndescription: Planifest framework for agentic development`nglobs: [""**/*""]`n---`n`nThis project uses the Planifest framework. Load the orchestrator skill for any initiative or change."
    }
    'codex'       = @{
        Path    = 'AGENTS.md'
        Content = "# Planifest`n`nThis project uses the Planifest framework for agentic development.`nLoad the orchestrator skill for any initiative or change."
    }
    'copilot'     = @{
        Path    = '.github\copilot-instructions.md'
        Content = "# Planifest`n`nThis project uses the Planifest framework.`nLoad the orchestrator skill for any initiative or change."
    }
}

# --- Functions ---

function Copy-Skill {
    param($SkillKey, $TargetDir)

    $srcFile = Join-Path $SkillsSrc "$SkillKey-SKILL.md"
    $destDir = Join-Path $TargetDir $SkillKey
    $destFile = Join-Path $destDir 'SKILL.md'

    New-Item -ItemType Directory -Path $destDir -Force | Out-Null

    $meta = $Skills[$SkillKey]
    $frontmatter = "---`nname: $($meta.Name)`ndescription: $($meta.Desc)`n---`n`n"

    $content = Get-Content $srcFile -Raw
    $output = $frontmatter + $content
    Set-Content -Path $destFile -Value $output -NoNewline -Encoding UTF8

    Write-Host "  + $SkillKey/SKILL.md"
}

function Copy-Support {
    param($TargetDir, $DirName)

    $src = Join-Path $ScriptDir $DirName
    $dest = Join-Path $TargetDir "_planifest-$DirName"

    if (Test-Path $src) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        Copy-Item -Path "$src\*" -Destination $dest -Recurse -Force
        Write-Host "  + _planifest-$DirName/"
    }
}

function Write-BootFile {
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

function Setup-Tool {
    param($ToolName)

    $toolConfig = $Tools[$ToolName]
    $skillsDir = Join-Path $ProjectRoot $toolConfig.SkillsDir

    Write-Host ""
    Write-Host "  Setting up $ToolName"
    Write-Host "  Skills directory: $($toolConfig.SkillsDir)/"

    # Copy skills
    foreach ($key in $Skills.Keys) {
        Copy-Skill -SkillKey $key -TargetDir $skillsDir
    }

    # Copy supporting files
    Copy-Support -TargetDir $skillsDir -DirName 'templates'
    Copy-Support -TargetDir $skillsDir -DirName 'standards'
    Copy-Support -TargetDir $skillsDir -DirName 'schemas'

    # Create boot file
    if ($BootFiles.ContainsKey($ToolName)) {
        $boot = $BootFiles[$ToolName]
        Write-BootFile -RelPath $boot.Path -Content $boot.Content
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
    Write-Host "  claude-code    .claude\skills\ + CLAUDE.md"
    Write-Host "  cursor         .cursor\skills\ + .cursor\rules\planifest.mdc"
    Write-Host "  codex          .agents\skills\ + AGENTS.md"
    Write-Host "  antigravity    .gemini\skills\"
    Write-Host "  copilot        .github\skills\ + copilot-instructions.md"
    Write-Host "  all            all of the above"
    Write-Host ""
    Write-Host "Run from the repository root."
    exit 0
}

Write-Host "Planifest Setup"
Write-Host ("=" * 40)

$ToolLower = $Tool.ToLower()

if ($ToolLower -eq 'all') {
    foreach ($t in $Tools.Keys) {
        Setup-Tool -ToolName $t
    }
}
elseif ($Tools.ContainsKey($ToolLower)) {
    Setup-Tool -ToolName $ToolLower
}
else {
    Write-Host "Unknown tool: $Tool"
    Write-Host "Valid tools: $($Tools.Keys -join ', '), all"
    exit 1
}

Write-Host ""
Write-Host "Setup complete."
Write-Host "  Source of truth: planifest-framework/"
Write-Host "  Re-run after updating framework files."
