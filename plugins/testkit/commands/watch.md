---
name: "testkit:watch"
description: Run tests in VISIBLE (headed) mode so a human can watch the UI being driven — for demos and reviewing case coverage. Web → Playwright headed/UI/slow-mo; desktop → pytest on-screen + UI_SLOWMO. CI stays headless.
category: Testing
tags: [testkit, watch, headed, demo, ui]
---

Invoke the `watch` skill using the Skill tool. Pass through any test path / grep / slow-mo the user wants.

Runs the suite VISIBLY so a human can watch the UI and review case coverage (not for CI). Quick refs:

- **web (Playwright):** `npx playwright test --ui` (best for exploring coverage), or
  `SLOWMO=500 npx playwright test --headed --workers=1 --grep @smoke`, or `--debug` to step through.
- **desktop (pytest-qt):** `pytest -s -v tests/test_x.py` (no offscreen), `UI_SLOWMO=500 pytest -s …`,
  `qtbot.stop()` to pause and inspect.

Requires a machine with a display. Reads the target from `.testkit-target`.
