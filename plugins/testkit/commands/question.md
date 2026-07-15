---
name: "testkit:question"
description: Q&A over project documents, code, and test artifacts — every answer cites its sources (document + section, file:line, TC/REQ id). No source, no claim.
category: Testing
tags: [testkit, question, docs, reference]
---

Invoke the `question` skill using the Skill tool, passing the user's question as the argument.

The skill searches (in order) project documents (`input/docs/` or a user-specified folder), generated
artifacts (feature-map/test-cases/rtm/scenarios/ui-map/bugs), source code, and test code — then answers
in the configured language with an explicit reference for every claim (e.g. `[SRS.docx §4.2]`,
`[test-cases.md → TC-LOGIN-02]`, `[app/validators.ts:31]`).

If the sources don't cover the question, it says so and suggests logging it in `open-questions.md` —
it never turns speculation into a statement. Contradictions between sources are surfaced with both
references for a human to resolve.
