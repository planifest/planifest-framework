# Cursor - tool configuration
# https://docs.cursor.com

@{
    SkillsDir   = '.cursor\skills'
    BootFile    = '.cursor\rules\planifest.mdc'
    BootContent = @(
        '---'
        'description: Planifest framework for agentic development'
        'globs: ["**/*"]'
        '---'
        ''
        'This project uses the Planifest framework. Load the orchestrator skill for any initiative or change.'
        ''
        'Key paths:'
        '  planifest-framework/README.md    - framework overview and getting started'
        '  plan/                            - initiative specifications'
        '  src/                             - component code'
        '  planifest-framework/templates/   - artifact templates'
        '  planifest-framework/standards/   - code quality standards'
    ) -join "`n"
}
