---
name: "testkit:review-dev"
description: Review the developer's delivered output against the approved test cases — per-TC verdict (Pass | Fail | Blocked | Untestable) into dev-review.md; every Fail gets a bugs.md entry. Works even before any automation exists.
category: Testing
tags: [testkit, review, acceptance, dev]
---

Invoke the `review-dev` skill using the Skill tool, passing the scope the user gave (a feature/module
name, or a test case title, e.g. `login`).

The skill walks each in-scope test case on the real product (web: live Staging via Playwright MCP;
desktop: delivered code + quick pytest-qt checks), assigns a per-TC verdict, and writes
`dev-review-<scope>.md` with a summary table. Fails are logged to `bugs.md` with repro details;
mismatched cases are flagged Untestable for the tester/BA to resolve — Expected Results are never
lowered to match the product.

Requires `test-cases.md` `> Review: APPROVED`. Ask for a scope if none was given.
