# Windsurf - tool configuration
# https://docs.windsurf.com
#
# Skills:    .windsurf/skills/{name}/SKILL.md       (auto-discovered via memories/rules)
# Workflows: (none - Windsurf uses rules, not a separate workflow directory)
# Boot file: .windsurfrules                         (project root - always-on rules file)

@{
    SkillsDir        = '.windsurf\skills'
    WorkflowsDir     = ''
    BootFile         = '.windsurfrules'
    BootTemplate     = 'planifest-framework/templates/standard-boot.md'

    # Enforcement — Tier 1: native hooks adapter (REQ-009)
    Tier             = 1
    HookAdapterSrc   = 'hooks\adapters\windsurf.mjs'
    HookAdapterDest  = '.windsurf\hooks\adapters\windsurf.mjs'
    HooksInstallDir  = '.windsurf\hooks'
    SettingsFile     = '.windsurf\settings.json'
}
