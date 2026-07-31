---
title: "Backlog Entry: 0000011 - Add local timestamp to human design confirmation records"
summary: "Include date, local time, and timezone separated by '//' in human confirmation design records to disambiguate multiple version iterations on the same day."
status: "open"
---
# Backlog Entry: 0000011 - Add local timestamp to human design confirmation records

**Source feature:** [Feature-ID-or-Name]
**Source phase:** [Phase, e.g., P3 / P7]
**Date filed:** 2026-07-31

---

## Problem

Design record confirmations currently only note whether the human confirmed the design, which is insufficient when multiple versions are generated in a single day. A date alone is too vague to determine which specific version iteration was approved. Additionally, the confirmation output lacks a standard delimiter between the confirmation status and timestamp.

## Suggested Action

Update the design record confirmation format to include a local timestamp (noting timezone) separated from the confirmation status by a double slash (`//`).

**Format:**
```text
[Confirmation
Human confirmed this design before proceeding: yes // Date and Time confirmed: 31 Jul 2026 @ 11:57 AM BST]