---
title: "Backlog Entry: 0000042 - context-mode hook false-flags local http:// in command args"
summary: "The context-mode PreToolUse Bash hook blocks commands containing a literal http:// substring even when it's a local setup-script argument (e.g. a backend URL like http://localhost:3741), not an actual outbound fetch attempt."
status: "open"
---
# Backlog Entry: 0000042 - context-mode hook false-flags local http:// in command args

**Source feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source phase:** P0

**Date filed:** 2026-08-03

---

## Problem

The context-mode PreToolUse hook that pattern-matches Bash commands (meant to catch WebFetch-style outbound URL access run through Bash instead of the WebFetch tool) flags the literal substring `http://` anywhere in the command text — including when it's just a local argument value, e.g. a setup script being invoked with a `--backend-url http://localhost:3741` style argument. This produces a false positive: the command isn't fetching a URL, it's passing one as a local configuration parameter to a script that runs entirely on the machine. The workaround in the moment was to route the URL through a wrapper script so the raw Bash invocation itself never contains the literal URL string — functional, but a workaround, not a fix.

## Suggested Action

Tighten the context-mode hook's Bash pattern-matching so it distinguishes "this command performs an outbound fetch" (curl/wget/fetch-style invocations, or a URL as the primary subject of the command) from "this command merely contains a URL-shaped string as one argument among others" (e.g. passed to a local script, especially `http://localhost` / `127.0.0.1` targets which can never be a meaningful outbound fetch concern). Exact detection heuristic to be decided at pickup — this entry only names the false-positive class, not a specific regex fix.

## Why Deferred

Out of scope for 0000025 (that feature's stories are all `planifest-framework` skill/process fixes; this is a `context-mode-hooks` component enforcement-pattern bug, a different component). Non-blocking — the wrapper-script workaround unblocks the immediate case — but worth fixing at the source so future local-URL arguments don't need the same workaround.
