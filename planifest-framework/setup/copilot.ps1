# GitHub Copilot - tool configuration
# https://docs.github.com/en/copilot

@{
    SkillsDir   = '.github\skills'
    BootFile    = '.github\copilot-instructions.md'
    BootContent = @(
        '# Planifest'
        ''
        'This project uses the Planifest framework.'
        'Load the orchestrator skill for any initiative or change.'
        ''
        'Key paths:'
        '  planifest-framework/README.md    - framework overview and getting started'
        '  plan/                            - initiative specifications'
        '  src/                             - component code'
        '  planifest-framework/templates/   - artifact templates'
        '  planifest-framework/standards/   - code quality standards'
    ) -join "`n"
}
