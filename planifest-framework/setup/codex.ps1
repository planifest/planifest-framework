# OpenAI Codex - tool configuration
# https://openai.com/codex

@{
    SkillsDir   = '.agents\skills'
    BootFile    = 'AGENTS.md'
    BootContent = @(
        '# Planifest'
        ''
        'This project uses the Planifest framework for agentic development.'
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
