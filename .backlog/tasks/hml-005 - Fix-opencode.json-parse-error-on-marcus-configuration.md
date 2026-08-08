---
id: HML-005
title: Fix opencode.json parse error on marcus configuration
status: Done
assignee: []
created_date: '2026-08-01 21:31'
updated_date: '2026-08-02 19:09'
labels:
  - bug
  - nix
  - opencode
dependencies: []
priority: medium
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Marcus build failed with JSON parse error at line 160 in opencode.json (invalid literal near http://100.105.217.77:5173/api/mcp). Currently disabled opencode module on marcus as workaround. Need to fix the JSON syntax and re-enable.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 opencode.json parses valid JSON
- [x] #2 opencode module re-enabled on marcus configuration
- [x] #3 Marcus build passes with opencode enabled
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
**Issue:** CI was failing with JSON parse error at line 160 in opencode.json - `builtins.fromJSON` cannot parse JSON comments (`//`).

**Root Cause:** Lines 160-168 contained commented-out todoist MCP config using `//` syntax, which is invalid JSON. The Nix module reads opencode.json from polis repo using `builtins.fromJSON (builtins.readFile "${inputs.polis}/opencode.json")` which requires strict JSON.

**Fix:** Removed the commented lines (160-168) from opencode.json in polis repo. JSON doesn't support comments natively - use `.jsonc` or `.nix` if comments are needed, or document separately.

**Verification:** CI build now passes successfully for marcus configuration with opencode module enabled.
<!-- SECTION:FINAL_SUMMARY:END -->
