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
