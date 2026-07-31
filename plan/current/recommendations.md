# Recommendations - 0000018-telemetry-emission-consistency

**Skill:** planifest-docs-agent
**Date:** 2026-07-31

> Constructive, specific suggestions for future iterations. Not blocking; not acted on in this release.

---

1. **Document that `--backend-url` must never carry embedded credentials.** The security review (P5) found that a human-supplied `--backend-url` containing userinfo (e.g. `https://user:token@host/emit`) could have its credential leak verbatim into `plan/.telemetry-failures/*.json` via an unredacted `error_message` field on a failed fetch. The directory is now gitignored (fixed this release), which closes the git-history exposure path, but the underlying "don't put secrets in this flag" expectation isn't documented anywhere a human configuring `setup.sh` would see it. Worth a one-line callout in `setup.sh --help` output or `telemetry-standards.md` next time either is touched (`planifest-framework/setup.sh:22`, `plan/current/security-report.md` finding 1).

2. **`.claude/` (the locally-generated skill/hook copy) has now gone stale twice in two consecutive releases** (0000017, 0000018) because `setup.sh` isn't re-run automatically after a framework skill change ships. Both times it was caught and fixed manually. This was explicitly kept out of scope for 0000018 (human-confirmed), but the recurrence rate (2/2 recent releases) suggests it's worth a real fix — e.g. a post-ship reminder, or `setup.sh --sync-only` invoked automatically at P9 — before a third occurrence goes unnoticed (`plan/current/design.md` Risks section, Process risk).

3. **req-005's original requirement doc had no dedicated test file at P1/P3 time** — the gap was only caught during P4's semantic-correctness check, and turned out to hide a real implementation gap too (the orchestrator only recorded the `Telemetry` build-log field on failure, never on the normal `emitted`/`confirmed-disabled` paths). Worth a spec-agent habit check: every Acceptance Criteria list should get an explicit "which test covers this" note at P1, rather than relying on P4 to catch a fully-missing suite (`plan/current/build-log.md` P4 Cycle 1 entry).

4. **req-004's original scope spec named `planifest-ship-agent` as one of the 8 affected phase skills; the real 8th skill was `planifest-change-agent`.** `ship-agent` had already deferred fully to `telemetry-standards.md` with no local gate line, so it never needed the fix. This was caught and corrected at P3/P4 time, but it's worth a general note: when a requirement enumerates a fixed list of files/skills "by name," verify the list against a grep for the actual pattern being fixed, not just institutional memory of which skills exist (`plan/current/requirements/req-004-phase-skill-telemetry-rewrite.md`).
