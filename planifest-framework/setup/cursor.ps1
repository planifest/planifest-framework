# Cursor - tool configuration
# https://docs.cursor.com
#
# Skills:    .cursor/skills/{name}/SKILL.md       (auto-discovered)
# Workflows: embedded in .cursor/rules/*.mdc      (Cursor uses rules, not separate workflows)
# Boot file: .cursor/rules/planifest.mdc

@{
    SkillsDir    = '.cursor\skills'
    WorkflowsDir = ''
    BootFile     = '.cursor\rules\planifest.mdc'
    BootContent  = @(
        '---'
        'description: Planifest framework for agentic development'
        'globs: ["**/*"]'
        '---'
        ''
        'This project uses the Planifest framework. Load the orchestrator skill for any initiative or change.'
        ''
        '## Workflows'
        ''
        '- **Initiative Pipeline**: Load the orchestrator skill. Provide an initiative brief at plan/initiative-brief.md'
        '- **Change Pipeline**: Load the orchestrator skill. Provide initiative ID, component ID, and change request.'
        '- **Retrofit**: Load the orchestrator skill with retrofit adoption mode.'
        ''
        '## Key paths'
        ''
        '- planifest-framework/README.md    - framework overview and getting started'
        '- plan/                            - current initiative specifications
  plan/changelog/                  - change audit logs
  docs/                            - living repository documentation'
        '- src/                             - component code'
        '- planifest-framework/templates/   - artifact templates'
        '- planifest-framework/standards/   - code quality standards'
    ) -join "`n"
}
