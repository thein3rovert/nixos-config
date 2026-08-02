---
id: HML-005
title: Fix opencode.json parse error on marcus configuration
status: To Do
assignee: []
created_date: '2026-08-01 21:31'
labels:
  - bug
  - nix
  - opencode
dependencies: []
priority: medium
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Marcus build failed with JSON parse error at line 160 in opencode.json (invalid literal near http://100.105.217.77:5173/api/mcp). Currently disabled opencode module on marcus as workaround. Need to fix the JSON syntax and re-enable.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 opencode.json parses valid JSON
- [ ] #2 opencode module re-enabled on marcus configuration
- [ ] #3 Marcus build passes with opencode enabled
<!-- AC:END -->
