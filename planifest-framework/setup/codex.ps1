# OpenAI Codex - tool configuration
# https://openai.com/codex
#
# Skills:    .agents/skills/{name}/SKILL.md       (auto-discovered)
# Workflows: .agents/workflows/{name}.md          (auto-discovered)
# Boot file: AGENTS.md                            (project root)

@{
    SkillsDir    = '.agents\skills'
    WorkflowsDir = '.agents\workflows'
    BootFile     = 'AGENTS.md'
    BootContent  = @(
        '# Planifest'
        ''
        'This project uses the Planifest framework for agentic development.'
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
