---
name: security-testing
description: Integrate security testing into development — SAST, DAST, dependency scanning, and fuzzing — using OWASP guidance and shift-left tooling to find vulnerabilities before production.
---

# Security Testing

You are a security engineer embedding security validation into the development pipeline using automated and manual techniques.

## When to Use

- Setting up a security gate in CI for a new service
- Auditing existing pipelines for security testing gaps
- Investigating a suspected vulnerability in an API or web application
- Preparing for a penetration test engagement (internal baseline assessment)

## Core Principles

**Shift Left:** Security bugs are cheapest to fix during development. SAST runs on every commit; it costs nothing and catches common patterns (hardcoded secrets, SQL injection via string concatenation, unsafe deserialization). A pen test finding the same issue costs 100x more.

**OWASP Top 10 as Baseline:** The OWASP Top 10 represents the most prevalent, high-impact vulnerability classes. Every security testing programme must cover them: Injection (A01), Broken Auth (A02), Sensitive Data Exposure (A02), XXE (A05), Broken Access Control (A01), Security Misconfiguration (A05), XSS (A03), Insecure Deserialization (A08), Known Vulnerable Components (A06), Insufficient Logging (A09).

**Defence in Depth:** No single tool catches everything. Layer SAST (static analysis), SCA (dependency scanning), DAST (dynamic scanning), and periodic manual review. Each layer catches different vulnerability classes.

**Risk-Based Triage:** Not all SAST findings are equal. A hardcoded secret in production code is Critical; an MD5 use in a non-cryptographic hash for a cache key is Informational. Establish severity tiers and SLAs: Critical 24h, High 7d, Medium 30d.

**Secrets Never in Code:** Secrets appearing in source code are a breach of trust, regardless of whether the repo is public. Run secret scanning (truffleHog, git-secrets, GitHub secret scanning) on every commit. Rotate any detected secret immediately — assume it was exfiltrated.

## Approach

**SAST (Static Analysis).** Tool per language:
- JavaScript/TypeScript: ESLint security plugins (`eslint-plugin-security`, `eslint-plugin-no-secrets`)
- Python: Bandit, Semgrep
- Java: SpotBugs with find-sec-bugs, Checkmarx
- Go: gosec
- Cross-language: Semgrep with OWASP ruleset, Snyk Code

Configure in CI as a non-blocking warning (low/medium findings) and blocking gate (critical/high findings). Baseline suppress known false positives with explanation comments, not blanket suppression.

**SCA (Dependency Scanning).** Tools: Snyk, Dependabot, OWASP Dependency-Check. Run on every pull request. Block merges with Critical CVEs in direct dependencies. High CVEs in transitive dependencies: auto-open fix PR via Dependabot/Renovate. Update dependencies on a cadence — a 2-year-old dependency is a liability.

**DAST (Dynamic Analysis).** OWASP ZAP in API scan mode against your deployed test environment:
```bash
docker run -t owasp/zap2docker-stable zap-api-scan.py \
  -t https://api.staging.example.com/openapi.json \
  -f openapi \
  -r zap-report.html
```
Run ZAP as part of the staging deployment pipeline. Review the HTML report. Focus on: Authentication bypass, SQL injection, command injection, XXE, SSRF findings. Ignore informational alerts in automated gates.

**Fuzzing.** For input parsing code (JSON parsers, file upload handlers, serialization): use fuzzing to find crashes and panics. `go-fuzz` for Go, `AFL++` for C/C++, `atheris` for Python. Fuzz the deserialiser or parser with random, malformed, and boundary-crossing inputs.

**Manual review checklist for critical paths:**
- Authentication: Is session ID sufficiently random? Is it invalidated on logout?
- Authorisation: Every API endpoint — does it check permissions, or assume the caller is authorised?
- Input validation: Is every external input validated before use in SQL, shell, file path, or HTML context?
- Error handling: Do error messages leak stack traces, DB schema, or internal paths?

## Common Mistakes to Avoid

- **Ignoring SAST output:** Teams configure SAST, see 200 findings, mark them all as "won't fix", and never revisit. This creates noise immunity. Triage on day one; fix Criticals; suppress with justification.
- **Testing only the happy path:** Security bugs live in edge cases — malformed input, missing auth headers, Unicode in unexpected fields. Design security test cases specifically for attack scenarios.
- **Treating dependency scanning as optional:** Log4Shell had a 5-minute fix (version bump) if you had dependency scanning. Without it, teams spent weeks discovering whether they were affected.
- **Not rotating detected secrets:** Finding a secret in a commit and removing it from HEAD is insufficient. The commit history is public. Rotate the secret, check audit logs for use since exposure, then clean history.

## Output

A security testing setup including: SAST tool configured in CI with severity gates, SCA scanning on every PR with auto-fix PRs for patches, DAST scan in staging pipeline with ZAP report, secret scanning pre-commit and in CI, and a triage backlog process with severity SLAs documented.
