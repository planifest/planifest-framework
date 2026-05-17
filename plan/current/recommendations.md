---
title: "Recommendations - 0000011-setup-parity-and-consistency"
status: "active"
---
# Recommendations - 0000011-setup-parity-and-consistency

Suggested improvements for future iterations. Not blockers — flagged for human attention.

---

## S-001 — cursor.mjs SCRIPT_NAME allowlist (Security)

**File:** `planifest-framework/hooks/adapters/cursor.mjs:25,66`

`process.argv[2]` is used to construct a file path with no validation against a known-good set of values. Add an explicit allowlist:

```js
const ALLOWED_SCRIPTS = new Set(["gate-write", "check-design", "emit-phase-start", "emit-phase-end"]);
if (!SCRIPT_NAME || !ALLOWED_SCRIPTS.has(SCRIPT_NAME)) process.exit(0);
```

Low severity — requires hook configuration write access to exploit — but defence-in-depth is straightforward here.

---

## T-001 — --backend-url flag should validate URL format (Telemetry)

**File:** `planifest-framework/setup.sh:~line 23`, `planifest-framework/setup.ps1`

The `--backend-url` flag accepts any string without format validation. A basic URL format check would prevent silent misconfiguration:

```bash
if [[ ! "$BACKEND_URL" =~ ^https?:// ]]; then
  echo "Error: --backend-url must start with http:// or https://"
  exit 1
fi
```

---

## D-001 — decisions-index.md was created from filename inference (Documentation)

**File:** `docs/decisions-index.md`

The decisions-index was bootstrapped in this pipeline run using ADR filenames to infer titles. Human review is recommended to verify that the one-line summaries accurately reflect the ADR decisions, particularly for ADRs from features 0000001 and 0000003 which predate current conventions.

---

## P-001 — PowerShell integration tests lack workspace isolation (Testing)

**File:** `planifest-framework/tests/test_setup.ps1`

The PowerShell tests use a temp workspace pattern but do not verify that the workspace is fully cleaned up on test failure. A `try/finally` pattern around the temp dir cleanup would prevent stale workspaces accumulating on CI:

```powershell
try {
    # test body
} finally {
    Remove-Item -Recurse -Force $ws -ErrorAction SilentlyContinue
}
```

---

## R-001 — Roo Code migration path should be a migration doc (Operational)

**File:** `planifest-framework/setup/roo-code.sh`, `roo-code.ps1`

The deprecation message tells users to switch to Cline, but there is no migration document in `planifest-framework/migrations/` documenting what state cleanup is needed (removing `.roo/` configs, reverting any Roo-specific hook files). A migration doc would make the transition explicit.
