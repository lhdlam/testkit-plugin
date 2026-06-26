---
name: "testkit:mcp"
description: Quick-install Playwright MCP (so the agent can open the live site to discover/verify selectors). Needed for web-from-docs / web-blackbox, recommended for web-playwright, not for desktop.
category: Testing
tags: [testkit, mcp, playwright, setup]
---

Run the Playwright MCP quick-installer.

Playwright MCP is NOT required to *run* tests — only for the agent to open the live Staging/UAT site and
discover/verify selectors. Required for `web-from-docs` / `web-blackbox`, recommended for `web-playwright`,
not used for `desktop-pyside6`.

Run:

```bash
bash "${TESTKIT_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT}}/scripts/install-playwright-mcp.sh" --scope project
# Cursor too:        … --cursor
# Pin a version:     … --version 0.0.x
```

Then verify: `claude mcp list` (should show `playwright`). In a Claude Code session, test with
*"Use Playwright MCP to open https://example.com and tell me what's on the page."*

> Default registers project scope (`.mcp.json`, commit so the team shares it). Use `--scope user` for a
> personal all-projects setup. Requires Node 18+.
