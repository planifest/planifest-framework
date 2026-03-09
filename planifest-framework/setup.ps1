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

# --- Skill metadata ---

$Skills = @{
    'orchestrator'   = @{ Name = 'planifest-orchestrator'; Desc = 'Guides a human from an initial idea to a complete specification, then executes the Planifest pipeline to build it. Use this for new initiatives or full pipeline runs.' }
    'spec-agent'     = @{ Name = 'planifest-spec-agent'; Desc = 'Produces specification artifacts (design spec, OpenAPI spec, scope, risk register, domain glossary) for an initiative. Invoked by the orchestrator during Phase 1.' }
    'adr-agent'      = @{ Name = 'planifest-adr-agent'; Desc = 'Produces Architecture Decision Records for each significant decision in the specification. Invoked by the orchestrator during Phase 2.' }
    'codegen-agent'  = @{ Name = 'planifest-codegen-agent'; Desc = 'Generates the full implementation from the specification artifacts. Invoked during Phase 3.' }
    'validate-agent' = @{ Name = 'planifest-validate-agent'; Desc = 'Runs CI checks (lint, typecheck, test, build) and self-corrects up to 5 times. Invoked during Phase 4.' }
    'security-agent' = @{ Name = 'planifest-security-agent'; Desc = 'Performs a security review of the implementation, producing a security report. Invoked during Phase 5.' }
    'change-agent'   = @{ Name = 'planifest-change-agent'; Desc = 'Handles modifications to existing initiatives. Loads domain context, implements the minimum change, validates, and updates documentation.' }
    'docs-agent'     = @{ Name = 'planifest-docs-agent'; Desc = 'Produces per-component documentation, system-wide registry, dependency graph, and pipeline-run audit trail. Invoked during Phase 6.' }
}

# --- Shared functions ---

function Copy-PlanifestSkill {
    param($SkillKey, $TargetDir)

    $srcFile = Join-Path $SkillsSrc "$SkillKey-SKILL.md"
    $meta = $Skills[$SkillKey]
    $destDir = Join-Path $TargetDir $meta.Name
    $destFile = Join-Path $destDir 'SKILL.md'

    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    $frontmatter = "---`nname: $($meta.Name)`ndescription: $($meta.Desc)`n---`n`n"
    $content = Get-Content $srcFile -Raw
    Set-Content -Path $destFile -Value ($frontmatter + $content) -NoNewline -Encoding UTF8

    Write-Host "  + $($meta.Name)/SKILL.md"
}

function Copy-PlanifestSupport {
    param($TargetDir, $DirName)

    $src = Join-Path $ScriptDir $DirName
    $dest = Join-Path $TargetDir "_planifest-$DirName"

    if (Test-Path $src) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        Copy-Item -Path "$src\*" -Destination $dest -Recurse -Force
        Write-Host "  + _planifest-$DirName/"
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

    # Copy skills
    foreach ($key in $Skills.Keys) {
        Copy-PlanifestSkill -SkillKey $key -TargetDir $skillsDir
    }

    # Copy supporting files
    Copy-PlanifestSupport -TargetDir $skillsDir -DirName 'templates'
    Copy-PlanifestSupport -TargetDir $skillsDir -DirName 'standards'
    Copy-PlanifestSupport -TargetDir $skillsDir -DirName 'schemas'

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
