---
title: "Recommendations - 0000021-framework-context-bloat-audit"
summary: "Suggested improvements for future iterations, produced by the docs-agent at P6."
status: "active"
version: "0.1.0"
---
# Recommendations - 0000021-framework-context-bloat-audit

**Feature:** 0000021-framework-context-bloat-audit

---

1. **Run backlog `0000020` (orchestrator router + `references/` decomposition) next, informed by this feature's concrete ceiling data.** In-file trimming alone got `planifest-orchestrator/SKILL.md` from 1,195 to 943 lines (21.1%) across two full `claude-opus-5` audit rounds — genuinely exhausted, verified by two independent gap-closing agents diffing against the audit's own itemized findings. The file is still 943 lines (31% of the trimmed skills corpus). Structural decomposition is the only remaining lever, and this feature leaves the audit methodology, the regression pack, and the exact list of what's load-bearing already in place to make that attempt safer than it would have been before.

2. **Extend `promote-to-regression.sh` with an automated test, not just a manual fix.** The path-adjustment bug this feature found and fixed (`tests/regression/` sitting one directory level deeper than `tests/`, breaking every `$SCRIPT_DIR`-relative path in a promoted test) was pre-existing and undetected because only one test had ever been promoted before this feature. The fix is now in place and the newly-promoted `test-regression-pack.sh` covers the mechanism generally, but consider a dedicated test that promotes a synthetic dummy test file with a known `$SCRIPT_DIR/helpers/...` and `$SCRIPT_DIR/..` reference and asserts both resolve correctly post-promotion — this would have caught the original bug at the time it was introduced rather than years later.

3. **Consider formalizing this feature's "second audit round when the first falls short of an aggregate target" pattern.** It worked well here (found genuinely new redundancy rather than re-flagging), but it was ad hoc. If future context-reduction passes recur, a documented loop convention (bounded rounds, honest-shortfall reporting, human escalation on persistent gaps) would save re-deriving the approach each time — this may be a natural fit for `planifest-loop-runner`'s existing loop-mechanics convention.

4. **Backlog `0000024` (skill-scope principle ADR) and `0000021`'s backlog entry (minimal artifact set) remain good candidates for a follow-up pass**, per the human's own reasoning at P0 — both are easier to write well once the general redundancy in the corpus they'd be evaluating is already gone, which is now the case.

5. **The `CLAUDE.md` gitignore discovery is worth a moment's attention, not urgent action.** This repo's `CLAUDE.md` is intentionally untracked (part of the "Agent tool config" gitignore block alongside `.claude/`), which is reasonable for a framework dogfooding itself — but it means fixes made to it (this feature included two small ones) never propagate via git and must be re-applied by hand on every fresh checkout. Not a defect to fix now, just a characteristic worth the next person knowing about explicitly rather than discovering mid-feature as this one did.
