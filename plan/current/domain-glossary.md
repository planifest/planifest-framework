# Domain Glossary — 0000010-framework-quality-improvements

**Date:** 12 May 2026

---

| Term | Definition |
|------|------------|
| `allowedTools` | A JSON array in `.claude/settings.json` listing tool names that Claude Code may invoke without per-use user confirmation. Written by `setup.sh`/`setup.ps1` during project initialisation. |
| Agent dispatch | The act of invoking the Agent tool to spawn a separate Claude Code sub-agent session with a self-contained prompt. Distinct from parallel native tool calls within the orchestrator's own context. |
| Native tool call | A tool invocation (Write, Read, Bash, ctx_execute, etc.) made directly within the active agent's context. Multiple native tool calls may be dispatched in a single message for parallelism. |
| Parallel batch | A set of independent tool calls dispatched in a single agent message. All calls in a batch execute concurrently. |
| Subagent | A Claude Code Agent instance spawned by the orchestrator or a phase agent to perform a decomposed task. Receives a self-contained prompt; has no access to the parent's conversation history. |
| Skill directory | A directory under `planifest-framework/external-skills/` or `planifest-framework/skills/` containing a `SKILL.md` file (and optionally `attribution.txt`). The directory name is the canonical identifier for the skill. |
| Name normalisation | The process of converting a skill's `name` frontmatter field to kebab-case and renaming its directory to match. Ensures skills are discoverable by name. |
| Kebab-case | Lowercase, words separated by hyphens, non-alphanumeric characters (except hyphens) stripped. Example: `"AWS Expert"` → `"aws-expert"`. |
| Input validation AC | An acceptance criterion that specifies how untrusted input (filesystem content, hook stdin, environment variables) must be sanitised before use in output visible to the model or user. |
| Filesystem-content requirement | Any requirement in which the implementation reads content from a file, environment variable, or external source and interpolates it into model context, hook banners, log output, or displayed text. Requires an `## Input Validation` section in its requirement file. |
| High-signal repo | An upstream skill repository selected for full extraction due to manageable size and demonstrated quality (manually sampled in feature 0000009). The four high-signal repos in scope: `sw-agent-skills`, `wondelai-skills`, `garden-skills`, `marketingskills`. |
| Attribution snapshot | The `attribution.txt` file recording the upstream source, URL, star count, skill name, and licence for an externally sourced skill. Written at extraction time; not updated after. |
