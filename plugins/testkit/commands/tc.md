---
name: "testkit:tc"
description: Generate a runnable test script for specific test case(s) named by module or title (e.g. /testkit:tc Login) straight from test-cases.md — lighter path than the full scenarios phase. Gated by test-cases.md APPROVED.
category: Testing
tags: [testkit, test-case, script]
---

Invoke the `case-script` skill using the Skill tool, passing the scope the user provided — a module
name (e.g. `Login`) or a test case title (e.g. `đăng nhập thất bại khi sai mật khẩu`).

The skill reads the matching cases from `test-cases.md` (Steps / Expected / Precondition / Priority /
Nguồn), resolves real selectors (`ui-map.md`, else Playwright MCP / `objectName` — never guessed),
reuses existing Page/Screen Objects, and appends one test per case. **The test name is the test case
title**; P1 → `@smoke`, others → `@regression`. Generated code carries **no comments and no invented
identifier codes** — traceability is recorded in `rtm.md` (`[automated]` + file + test name), not in
the code. It then runs just those tests and reports.

If the product's real behaviour contradicts the Expected Result, it logs `bugs.md` instead of bending
the assertion. Ambiguous or unmatched scope → it lists near matches and asks rather than guessing.
