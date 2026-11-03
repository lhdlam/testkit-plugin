---
name: "testkit:plan"
description: Phase 0.5 — analyze an incoming task, assess its blast radius, cross-check it against the spec and raise any deviation, then produce plan-<slug>.md for the tester to approve before any pipeline phase runs.
category: Testing
tags: [testkit, plan, impact, spec, scope]
---

Invoke the `plan-task` skill using the Skill tool, passing everything the user typed after the command —
a free-text task description, or a git branch/tag that already carries the change.

The skill reads only (it writes no tests and touches no application code), and produces a plan the
tester signs off on first:

1. **Scopes the task** — via `git diff` against a branch/tag when the target has code, otherwise by
   locating the screens/flows/documents the description points at. It asks rather than guessing.
2. **Analyses the task** against three sources, each claim carrying a real citation (`SRS §4.2`,
   `app/auth.ts:31`): what the task wants, what the docs say, what the system does today.
3. **Assesses the blast radius** across six buckets — screens/flows, existing test cases, existing
   automated tests, docs/requirements, data & permissions, and shared code — rating each
   High / Medium / Low, or "cần xác minh" when the evidence is thin.
4. **Cross-checks task ↔ docs ↔ implementation** and raises every mismatch into `open-questions.md`
   instead of deciding it alone.
5. **Writes `plan-<slug>.md`** ending in `> Review: PENDING`, then stops.

Requires an initialized testkit project (`.testkit-target`). No argument → ask for the task.

Once the plan is APPROVED the tester continues with `/testkit:new-feature` (new feature),
`/testkit:cases` (more cases on an existing module) or `/testkit:fixbug` (a bug). On Claude Code the
gate hook refuses `new-feature` while any `plan-*.md` is still PENDING.
