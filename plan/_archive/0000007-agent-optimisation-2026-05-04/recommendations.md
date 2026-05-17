---
title: "Recommendations - 0000007-agent-optimisation"
date: "04 May 2026"
---
# Recommendations — 0000007-agent-optimisation

## 1. Harden setup manifest path validation

`setup.sh` and `setup.ps1` cleanup loops should add a prefix guard before `rm -rf` / `Remove-Item`:

**setup.sh:**
```bash
if [[ "$dir_path" == "$skills_dir"/* ]]; then
  rm -rf "$dir_path"
fi
```

**setup.ps1:**
```powershell
if ($_.StartsWith($skillsDir)) { Remove-Item -Path $_ -Recurse -Force }
```

This eliminates the theoretical path-traversal risk identified in the security report at near-zero cost.

## 2. Consider adding `bundle_standards` to sub-agent skills

`planifest-test-writer`, `planifest-implementer`, and `planifest-refactor` have no `bundle_standards` frontmatter. These are invoked inside the TDD loop and may benefit from access to `formatting-standards.md` for consistent output formatting. Low priority — only add if these skills need to produce prose output.

## 3. Extend language-quirks-en-gb.md for additional exceptions

As the framework grows, new American/British conflicts will emerge. The `language-quirks-en-gb.md` file is structured for easy extension. Consider a periodic review pass using `planifest-optimise-agent` to surface any newly stale terminology.

## 4. Multi-locale readiness

`language-quirks-en-gb.md` uses ISO locale frontmatter (`locale: "en-GB"`). If the framework is ever extended for other locales (e.g. `en-US`, `pt-BR`), this pattern scales naturally. The `planifest-optimise-agent` could be parameterised by locale as a future enhancement.
