#!/usr/bin/env bash
# Verify the Playwright MCP quick-installer script + command.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$HERE/.."
SCRIPT="$ROOT/scripts/install-playwright-mcp.sh"
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ok: $1"; }
bad() { FAIL=$((FAIL+1)); echo "  FAIL: $1"; }

[[ -f "$SCRIPT" ]] && ok "script exists" || bad "script missing"
bash -n "$SCRIPT" 2>/dev/null && ok "script syntax valid" || bad "script syntax error"
[[ -x "$SCRIPT" ]] && ok "script executable" || bad "script not executable"
[[ -f "$ROOT/commands/mcp.md" ]] && ok "command mcp.md exists" || bad "command mcp.md missing"

# --cursor writes valid JSON with playwright server
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
( cd "$tmp" && bash "$SCRIPT" --cursor --version 0.0.99 >/dev/null 2>&1 )
if [[ -f "$tmp/.cursor/mcp.json" ]]; then
  node -e "let j=JSON.parse(require('fs').readFileSync('$tmp/.cursor/mcp.json'));process.exit(j.mcpServers&&j.mcpServers.playwright?0:1)" \
    && ok "--cursor writes valid .cursor/mcp.json with playwright" || bad "cursor json missing playwright"
else
  bad "--cursor did not create .cursor/mcp.json"
fi

echo "---"; echo "PASS=$PASS FAIL=$FAIL"
[[ "$FAIL" -eq 0 ]]
