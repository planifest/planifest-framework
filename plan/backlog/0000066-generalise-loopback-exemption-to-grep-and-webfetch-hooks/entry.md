---
title: "Backlog Entry: 0000066 - Assess whether the loopback exemption generalises to block-grep and block-webfetch"
summary: "A discovered-but-out-of-scope item deferred for pickup at a future P0."
status: "open"
---
# Backlog Entry: 0000066 - Assess whether the loopback exemption generalises to block-grep and block-webfetch

**Source feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source phase:** P6
**Deferral source:** deliberate scope decision
**Date filed:** 2026-08-08

---

## Problem

Backlog `0000042` reported `block-bash.mjs` false-flagging a bare loopback `http://` URL appearing as an argument to an otherwise permitted command. The fix shipped in `0000026` (`7f28593`) as the `LOOPBACK_HOSTS` exemption, which parses the URL with the platform parser rather than substring matching, so `localhost.evil.com` and `localhost@evil.com` cannot bypass it, and leaves `curl` and `wget` blocked regardless of target.

Its two siblings, `planifest-framework/hooks/context-mode/block-grep.mjs` and `block-webfetch.mjs`, were never assessed for the same class of false positive. They may not share the pattern at all: `block-bash.mjs` needed the exemption because a URL can ride along as an argument to a command that is itself permitted, and neither sibling has an obvious analogue of that shape.

## Suggested Action

Check whether either hook actually exhibits a false-positive class before porting anything. If one does, reuse `block-bash.mjs`'s parser-based matching rather than writing a second implementation of host comparison.

## Why Deferred

See `0000028`'s `scope.md` Deferred section: the assessment was deferred pending characterisation of the false-positive class, and nothing in `0000028` was blocked by it since `0000042`'s own fix had already shipped. Also recorded in `0000028`'s `recommendations.md` Deferred Items table. Best picked up when a false positive is actually observed rather than speculatively.
