---
name: "testkit:new-feature"
description: Incremental mode — generate/update tests for ONE new feature only, scoped by git diff (feat-xxxx branch/tag) or a description, without rescanning the whole project.
category: Testing
tags: [testkit, incremental, new-feature]
---

Invoke the `new-feature` skill using the Skill tool. Pass through the feature name and/or description.

The skill scopes work to a single feature (Cách A: git diff of a `feat-xxxx` branch/tag; Cách B: a
description it locates in code/docs/UI), writes feature-scoped artifacts (`*-feat-xxxx.md`) and a tagged
test file (`@feat-xxxx` / `@pytest.mark.feat_xxxx`), and never deletes existing tests — behavior changes
are proposed for the tester to confirm.

Requires an initialized testkit project (`.testkit-target`). Run only the feature's tests:
`--grep @feat-xxxx` (web) or `-m feat_xxxx` (desktop).
