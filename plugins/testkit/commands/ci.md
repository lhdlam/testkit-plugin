---
name: "testkit:ci"
description: Phase 6 — generate a CI workflow (GitHub Actions) that runs the suite headless / against Staging, reading secrets from the CI store.
category: Testing
tags: [testkit, ci]
---

Invoke the `setup-ci` skill using the Skill tool. Pass through any arguments.

Produces `.github/workflows/*.yml` from the target template: web → Playwright against Staging (smoke per
deploy, full nightly); desktop → pytest-qt headless via Xvfb/offscreen. Secrets stay in the CI store.
