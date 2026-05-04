#!/usr/bin/env node
/**
 * GitHub Copilot Agent Hooks adapter (Preview 2025).
 *
 * Wires gate-write and check-design enforcement into the Copilot
 * agent_hooks API. Degrades gracefully when hooks are disabled by
 * org policy — always exits 0 on non-enforcement failures (ADR-003).
 *
 * Hook registration: .github/hooks/ (see setup.ps1/setup.sh)
 * Copilot hook docs: https://docs.github.com/en/copilot/agent-hooks
 */

import { existsSync, readFileSync } from "node:fs";
import { join, normalize, resolve } from "node:path";

function readStdin() {
  return new Promise((res) => {
    let data = "";
    process.stdin.setEncoding("utf-8");
    process.stdin.on("data", (c) => { data += c; });
    process.stdin.on("end", () => res(data.replace(/^﻿/, "")));
    process.stdin.resume();
  });
}

function norm(p) {
  return normalize(p).replace(/\\/g, "/").toLowerCase();
}

const ALWAYS_PERMITTED_PREFIXES = ["plan/", "docs/"];
const ALWAYS_PERMITTED_FILES = [
  "claude.md", "agents.md", ".planifest-session", ".skips", ".feature-id",
];

function isAlwaysPermitted(relPath) {
  const n = norm(relPath);
  const base = n.split("/").pop() ?? "";
  if (ALWAYS_PERMITTED_FILES.includes(base)) return true;
  return ALWAYS_PERMITTED_PREFIXES.some((p) => n.startsWith(norm(p)));
}

try {
  const raw = await readStdin();

  // Degrade gracefully if input is not valid JSON (org policy may disable hooks)
  let input;
  try {
    input = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  const eventType = input?.event ?? input?.hook_event ?? "";
  const cwd = input?.workspace ?? input?.cwd ?? process.cwd();

  // --- UserPromptSubmit equivalent: check-design injection ---
  if (eventType === "prompt_submit" || eventType === "user_prompt_submit") {
    const featureBriefPath = join(cwd, "plan", "current", "feature-brief.md");
    const sentinelPath = join(cwd, "plan", ".orchestrator-active");

    if (!existsSync(featureBriefPath) && !existsSync(sentinelPath)) {
      const additionalContext =
        "[Planifest] STOP — No feature brief and no orchestrator sentinel detected. " +
        "Before writing any code or plan artefacts, load the planifest-orchestrator " +
        "skill and complete Phase 0 (Assess & Coach).";
      process.stdout.write(JSON.stringify({ additionalContext }));
      process.exit(0);
    }

    const designPath = join(cwd, "plan", "current", "design.md");
    if (existsSync(designPath)) {
      try {
        const content = readFileSync(designPath, "utf-8");
        const match = /^##\s+(Component Paths|Scope)\s*$/im.exec(content);
        if (match) {
          const afterStart = content.slice(match.index);
          const lines = afterStart.split("\n");
          const scopeLines = [lines[0]];
          for (let i = 1; i < lines.length; i++) {
            if (/^##\s/.test(lines[i]) && i > 1) break;
            scopeLines.push(lines[i]);
          }
          const scopeSection = scopeLines.join("\n").trim();
          if (scopeSection) {
            process.stdout.write(JSON.stringify({
              additionalContext:
                "[Planifest] Confirmed scope from plan/current/design.md:\n\n" + scopeSection,
            }));
          }
        }
      } catch { /* silent */ }
    }
    process.exit(0);
  }

  // --- PreToolUse equivalent: gate-write ---
  if (eventType === "pre_tool_use" || eventType === "tool_call") {
    const toolName = input?.tool ?? input?.tool_name ?? "";
    const isWriteTool = /write|edit|create_file|update_file/i.test(toolName);
    if (!isWriteTool) process.exit(0);

    const rawTarget = input?.tool_input?.path ?? input?.tool_input?.file_path
      ?? input?.parameters?.path ?? input?.parameters?.file_path ?? "";
    if (!rawTarget) process.exit(0);

    const absTarget = resolve(cwd, rawTarget);
    const cwdWithSep = cwd.endsWith("/") || cwd.endsWith("\\") ? cwd : cwd + "/";
    const relTarget = absTarget.startsWith(cwdWithSep)
      ? absTarget.slice(cwdWithSep.length)
      : rawTarget;

    // Sentinel check for plan/current/**
    const normRel = norm(relTarget);
    const isPlanCurrent = normRel.startsWith("plan/current/") || normRel === "plan/current";
    const isFeatureBrief = normRel.endsWith("feature-brief.md");
    if (isPlanCurrent && !isFeatureBrief) {
      const sentinelPath = join(cwd, "plan", ".orchestrator-active");
      if (!existsSync(sentinelPath)) {
        process.stdout.write(
          "[Planifest] No orchestrator sentinel at plan/.orchestrator-active. " +
          "Load the planifest-orchestrator skill and complete Phase 0.\n"
        );
        process.exit(2);
      }
    }

    if (isAlwaysPermitted(relTarget)) process.exit(0);

    const designPath = join(cwd, "plan", "current", "design.md");
    if (!existsSync(designPath)) {
      process.stdout.write(
        "[Planifest] No confirmed design at plan/current/design.md. " +
        "Complete Phase 0 first.\n"
      );
      process.exit(2);
    }

    process.exit(0);
  }

  // Unknown event type — pass through
  process.exit(0);
} catch {
  // Never block on unexpected errors (ADR-003)
  process.exit(0);
}
