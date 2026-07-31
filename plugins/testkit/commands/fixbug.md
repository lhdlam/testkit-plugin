---
name: "testkit:fixbug"
description: Diagnose and fix an application bug — analyze against code + spec (with citations), ask the tester clarifying questions, then fix the app code and add a regression test that reproduces the bug (red before, green after).
category: Testing
tags: [testkit, bug, fix, debug, regression]
---

Invoke the `fixbug` skill using the Skill tool. Pass through everything the user typed after the
command as the bug content — either free-text describing the bug, or a `BUG-ID` (e.g. `BUG-LOGIN-03`)
that already exists in `bugs.md`.

The skill runs a guarded debug workflow:

1. **Locate** the bug in code + spec and form a root-cause hypothesis — every claim carries a source
   reference (`[SRS §4.2]`, `[app/auth.ts:31]`, `[bugs.md → BUG-LOGIN-03]`); if it cannot be located,
   it says so instead of guessing.
2. **Asks the tester clarifying questions and presents the proposed fix + blast radius — then STOPS.**
   This is a hard human gate: no application code is edited before the user answers and approves.
3. **Fixes the root cause** in the application code (minimal, convention-matching diff) — unless the
   real fault is a stale/contradictory spec, in which case it edits no code and routes to
   `open-questions.md`.
4. **Always adds a regression test** that reproduces the bug (must be red before the fix, green after),
   tagged `@regression @bug-<id>`, traced in `rtm.md`.
5. **Verifies** by running the regression test + related tests and reports the real output — a bug is
   never declared fixed on a red run.
6. Writes `bug-fix-<id>.md` (`> Review: PENDING`) and updates the `bugs.md` entry to Fixed.

⚠️ `fixbug` is the one testkit command that modifies the application under test (dev-side). It never
green-washes: it fixes the **app** so the test passes, never weakens the test to match a broken app.
No argument → ask the user for the bug content. Works even before any automation exists.
