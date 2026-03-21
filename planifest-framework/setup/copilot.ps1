# GitHub Copilot - tool configuration
# https://docs.github.com/en/copilot
#
# Skills:    .github/skills/{name}/SKILL.md       (auto-discovered)
# Workflows: .github/workflows/{name}.md          (natural language workflows)
# Boot file: .github/copilot-instructions.md

@{
    SkillsDir    = '.github\skills'
    WorkflowsDir = '.github\workflows'
    BootFile     = '.github\copilot-instructions.md'
    BootContent  = @(
        '# Planifest'
        ''
        'This project uses the Planifest framework.'
        'Load the orchestrator skill for any initiative or change.'
        ''
        '## Workflows'
        ''
        '- initiative-pipeline: Full spec-to-ship pipeline for new initiatives'
        '- change-pipeline: Modify an existing initiative'
        '- retrofit: Onboard an existing codebase'
        ''
        'Key paths:'
        '  planifest-framework/README.md    - framework overview and getting started'
        '  plan/                            - current initiative specifications
  plan/changelog/                  - change audit logs
  docs/                            - living repository documentation'
        '  src/                             - component code'
        '  planifest-framework/templates/   - artifact templates'
        '  planifest-framework/standards/   - code quality standards'
    ) -join "`n"
}
