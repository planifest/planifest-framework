# Scope — 0000006-build-assessment-phase

## In Scope
- `plan/current/build-log.md` working file created and maintained by orchestrator
- `planifest-framework/templates/build-log.template.md`
- `planifest-build-assessment-agent` skill (P8)
- P8 wiring in orchestrator and ship agent
- Model tier decision table in orchestrator skill
- Parallelism directives in orchestrator and 6 phase skills
- Test suite `test-0000006-build-assessment.sh`
- `run-tests.sh` update

## Out of Scope
- Automated cost tracking or billing integration
- Runtime enforcement of model tier selection (honour-system via skill instructions)
- Changes to setup.sh / setup.ps1
- Aggregated reporting across multiple pipeline runs
- Changes to hooks (gate-write, check-design, context-pressure)
- New MCP tools or telemetry events for build log

## Deferred
- Automated build log population via hooks (currently: orchestrator updates manually per phase)
  - Blocked until: hook API supports structured data emission per phase
- Cross-run build analytics dashboard
  - Blocked until: aggregation infrastructure exists
