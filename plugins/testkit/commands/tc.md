---
name: "testkit:tc"
description: Generate a runnable test script for specific test-case ID(s) (e.g. /testkit:tc TC-LOGIN-02) straight from test-cases.md — lighter path than the full scenarios phase. Gated by test-cases.md APPROVED.
category: Testing
tags: [testkit, tc, case-script]
---

Invoke the `case-script` skill using the Skill tool, passing the TC-ID(s) the user provided
(e.g. `TC-LOGIN-02`, several IDs, or a group pattern like `TC-LOGIN-*`).

The skill extracts those cases from `test-cases.md` (must be `> Review: APPROVED`), resolves real
selectors (ui-map.md, or live discovery via Playwright MCP / objectName from code), reuses existing
Page/Screen Objects, appends one traceable test per TC (`// TC-LOGIN-02 ← REQ-003`, P1 → `@smoke`),
runs just those tests, and marks the TC as `[automated]` in `rtm.md`.

Assertions always match the documented Expected Result — if the product behaves differently, it logs
`bugs.md` instead of bending the assertion.
