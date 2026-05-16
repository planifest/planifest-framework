---
title: "Requirement: REQ-005 - open-source-skill-library"
status: "active"
version: "0.1.0"
---
# Requirement: REQ-005 - open-source-skill-library

**Feature:** 0000009-framework-rail-tightening
**Source:** Feature brief AC — curated open-source skill library with permissive licence and attribution.txt
**Priority:** should-have

---

## Functional Requirements

- A directory `planifest-framework/external-skills/` is created to hold curated open-source skills
- Each skill occupies its own subdirectory: `planifest-framework/external-skills/{skill-name}/`
- Each skill directory contains:
  - `SKILL.md` — the skill content (unchanged from source, or minimally adapted for SKILL.md format)
  - `attribution.txt` — a licence snapshot captured at the time of inclusion, containing: capture date, licence type, copyright holder, source URL, any required attribution text, and the full verbatim licence text as it existed at capture date. The snapshot is retained as evidence even if the upstream repository later changes its licence.
- Only skills with permissive licences (MIT, Apache 2.0, ISC, BSD-2-Clause, BSD-3-Clause, or equivalent) are included; skills with GPL, AGPL, or unknown licences are excluded
- `setup.sh` and `setup.ps1` accept a new flag `--include-full-skill-library`; when set, all skills in `external-skills/` are copied to the tool's skill directory alongside the built-in skills
- Without the flag, external skills are not copied (opt-in)
- The library is populated during this pipeline run via web search for highly-regarded open-source Claude Code SKILL.md-format skills; a minimum of 3 skills must be included
- A `README.md` in `planifest-framework/external-skills/` lists all included skills with their source URLs and licence types

## Implementation Notes — Curation (11 May 2026, updated 12 May 2026)

**Final library size:** 200 skills — 192 from real upstream sources, 8 original work.

**Sources used:**

| Repository | Stars (captured) | Licence | Skills adopted |
|------------|-----------------|---------|---------------|
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | ~500 | MIT © 2026 Antigravity User | 55 |
| [garrytan/gstack](https://github.com/garrytan/gstack) | ~93k | MIT © 2026 Garry Tan | 22 |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 2.6k+ | MIT © 2025 Addy Osmani | 21 |
| [KentoShimizu/sw-agent-skills](https://github.com/KentoShimizu/sw-agent-skills) | ~200 | Apache-2.0 © 2026 Kento Shimizu | 21 |
| [danielmiessler/fabric](https://github.com/danielmiessler/fabric) | 41.6k+ | MIT | 16 |
| [obra/superpowers](https://github.com/obra/superpowers) | ~2k | MIT © 2025 Jesse Vincent | 11 |
| [wondelai/skills](https://github.com/wondelai/skills) | ~200 | MIT © 2025 Wondel.ai sp. z o.o. | 11 |
| [anthropics/skills](https://github.com/anthropics/skills) | ~132k | Apache-2.0 | 7 |
| [aj-geddes/useful-ai-prompts](https://github.com/aj-geddes/useful-ai-prompts) | ~800 | MIT © 2025 AJ Geddes | 7 |
| [zxkane/aws-skills](https://github.com/zxkane/aws-skills) | ~200 | MIT © 2025 Mengxin Zhu | 4 |
| [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) | ~300 | MIT © 2025 Corey Haines | 4 |
| [itsmostafa/aws-agent-skills](https://github.com/itsmostafa/aws-agent-skills) | ~100 | MIT (no named author in Licence) | 4 |
| [Mindrally/skills](https://github.com/Mindrally/skills) | ~300 | Apache-2.0 (no named copyright holder) | 3 |
| [vuejs-ai/skills](https://github.com/vuejs-ai/skills) | ~500 | MIT | 1 |
| [antonbabenko/terraform-skill](https://github.com/antonbabenko/terraform-skill) | ~500 | Apache-2.0 © 2026 Anton Babenko | 1 |
| [ccheney/robust-skills](https://github.com/ccheney/robust-skills) | ~100 | MIT | 1 |
| [mukul975/Privacy-Data-Protection-Skills](https://github.com/mukul975/Privacy-Data-Protection-Skills) | ~100 | Apache-2.0 | 1 |
| [dpconde/claude-android-skill](https://github.com/dpconde/claude-android-skill) | ~50 | MIT © 2025 David Perez | 1 |
| [Aspegio/nelson](https://github.com/Aspegio/nelson) | ~50 | MIT © 2025 Harry Munro | 1 |
| planifest-framework (original work) | — | MIT © 2026 Planifest Framework Contributors | 8 |

**Snapshot rationale:** Each `attribution.txt` captures the licence text as it existed at the time of inclusion (11 May 2026). This provides evidence of the licence terms even if the upstream repository changes its licence in future. Repos are cloned at `_temp/` (gitignored) during the pipeline run; `_temp/` is not committed.

**attribution.txt format (standard):**
```
# Attribution snapshot — captured YYYY-MM-DD
# Source: owner/repo
# Source URL: https://github.com/owner/repo
# Stars at capture: Nk+
# Skill: upstream-skill-name
# Skill URL: https://github.com/owner/repo/blob/main/.../SKILL.md
# Licence: MIT | Apache-2.0
# NOTICE: <content of NOTICE file, if present>   ← Apache-2.0 repos only

LICENSE (MIT | Apache-2.0):

[Full verbatim licence text as captured]
```

---

## Licence Compliance Analysis (11 May 2026, updated 12 May 2026)

### MIT licences (13 repositories, 148 skills)

**Obligation:** "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."

**How satisfied:**
- Each skill's `attribution.txt` carries the verbatim copyright line and the full MIT licence text, co-located with the `SKILL.md` file it covers.
- `SKILL.md` files are copied verbatim; no modifications are made, so no "modified file" notices are required.
- Two skills (`android-development`, `nelson`) use an earlier attribution format but contain all required fields.

**Result: compliant.**

---

### Apache-2.0 licences (6 repositories, 52 skills)

Apache 2.0 §4 imposes four obligations on distribution. Status for each:

| §4 clause | Obligation | Status |
|-----------|-----------|--------|
| (a) | Give recipients a copy of this Licence | ✅ Full Apache 2.0 text in every `attribution.txt` |
| (b) | Modified files must carry a prominent notice of change | ✅ No files modified — verbatim copies only |
| (c) | Retain copyright, patent, trademark, and attribution notices in Source form | ✅ SKILL.md copied verbatim; any internal notices retained. Copyright in `attribution.txt`. |
| (d) | If Work includes a NOTICE file, include a readable copy of that NOTICE | See below |

**NOTICE file audit:**

| Repository | NOTICE file? | Content | Action taken |
|------------|-------------|---------|--------------|
| `KentoShimizu/sw-agent-skills` | ✅ Yes | `Copyright 2026 Kento Shimizu` | Carried verbatim as `# NOTICE:` line in all 21 `attribution.txt` files for skills sourced from this repo |
| `anthropics/skills` | ❌ None | — | No action required |
| `antonbabenko/terraform-skill` | ❌ None | — | No action required |
| `mukul975/Privacy-Data-Protection-Skills` | ❌ None | — | No action required |
| `Mindrally/skills` | ❌ None | — | No action required |

**Additional finding — `terraform-skill`:** The SKILL.md body contains `**Copyright © 2026 Anton Babenko**`. This notice is retained verbatim because the file is copied without modification.

**Additional finding — `Mindrally/skills`:** The Apache-2.0 Licence file uses the boilerplate template form (`Copyright [yyyy] [name of copyright owner]`) with no actual holder named. Reproduced exactly as found.

**Result: compliant.**

---

### Skills without a named copyright holder

`itsmostafa/aws-agent-skills` has `Copyright (c) 2025` with no author name in its Licence file. The `attribution.txt` files for the 4 skills sourced from this repo reproduce the licence exactly as found. This is the upstream repo's own omission; we cannot fabricate a name.

`Mindrally/skills` has the Apache-2.0 boilerplate template as its Licence with no named holder. Same treatment — reproduced as found.

---

### Excluded licence types

No skills with GPL, AGPL, LGPL, or unknown licences were included. All 200 skills are MIT, Apache-2.0, or original work (MIT).

## Acceptance Criteria

- [ ] `planifest-framework/external-skills/` exists with at least 3 skill subdirectories
- [ ] Every skill subdirectory contains both `SKILL.md` and `attribution.txt`
- [ ] `attribution.txt` in each skill is a licence snapshot: capture date header, licence type, copyright holder, source URL, required attribution text, and full verbatim licence text as it existed at capture date
- [ ] No skill with a GPL, AGPL, or unknown licence is included
- [ ] `setup.sh --include-full-skill-library` copies all external skills to the tool's skill dir
- [ ] `setup.ps1 --include-full-skill-library` does the same (PS1 parity)
- [ ] Without the flag, external skills are not copied
- [ ] `planifest-framework/external-skills/README.md` exists and lists all skills with source URLs and licences
- [ ] Re-running setup with the flag is idempotent (no duplicate copies)

## Dependencies

- None
