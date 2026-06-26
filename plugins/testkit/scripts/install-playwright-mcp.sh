#!/usr/bin/env bash
# install-playwright-mcp.sh — quick-install Playwright MCP for testkit web targets.
#
# Playwright MCP lets the agent open the live Staging/UAT site to discover & verify
# selectors. Required for web-from-docs / web-blackbox; recommended for web-playwright;
# NOT needed for desktop-pyside6 or merely to RUN tests.
#
# Usage:
#   bash install-playwright-mcp.sh [--version <ver>] [--scope project|user] [--cursor]
#
#   --version <ver>   pin @playwright/mcp version (default: latest; pin for team/CI)
#   --scope <s>       Claude Code scope: project (commit .mcp.json, default) | user
#   --cursor          also write/merge .cursor/mcp.json (for Cursor)
#
# Safe to re-run. Requires Node 18+ (Playwright MCP does not run on Node 16).
set -uo pipefail

VERSION="latest"
SCOPE="project"
DO_CURSOR=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) VERSION="${2:?}"; shift 2;;
    --scope)   SCOPE="${2:?}";   shift 2;;
    --cursor)  DO_CURSOR=1;       shift;;
    -h|--help) sed -n '2,16p' "$0"; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done
PKG="@playwright/mcp@${VERSION}"

# Node version check (advisory)
if command -v node >/dev/null 2>&1; then
  major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
  [[ "$major" -ge 18 ]] || echo "⚠ Node $major detected — Playwright MCP needs Node 18+."
else
  echo "⚠ Node not found — install Node 18+ first (nodejs.org)."
fi

# --- Claude Code ---
if command -v claude >/dev/null 2>&1; then
  echo "▶ Claude Code: registering Playwright MCP ($PKG, scope=$SCOPE)…"
  claude mcp add playwright npx "$PKG" --scope "$SCOPE" \
    || echo "  (add returned non-zero — may already exist; check 'claude mcp list')"
  if claude mcp list 2>/dev/null | grep -qi playwright; then
    echo "  ✓ playwright is registered (claude mcp list)"
  else
    echo "  ⚠ not shown in 'claude mcp list' — verify manually"
  fi
else
  echo "▶ 'claude' CLI not found — skipping Claude Code registration."
fi

# --- Cursor (.cursor/mcp.json) ---
if [[ "$DO_CURSOR" -eq 1 ]]; then
  echo "▶ Cursor: writing .cursor/mcp.json…"
  mkdir -p .cursor
  if command -v node >/dev/null 2>&1; then
    PKG="$PKG" node -e '
      const fs=require("fs"),p=".cursor/mcp.json";
      let j={}; try{j=JSON.parse(fs.readFileSync(p,"utf8"))}catch(_){}
      j.mcpServers=j.mcpServers||{};
      j.mcpServers.playwright={command:"npx",args:[process.env.PKG]};
      fs.writeFileSync(p,JSON.stringify(j,null,2)+"\n");
      console.log("  ✓ merged playwright into "+p);
    '
  else
    cat > .cursor/mcp.json <<EOF
{
  "mcpServers": {
    "playwright": { "command": "npx", "args": ["$PKG"] }
  }
}
EOF
    echo "  ✓ wrote .cursor/mcp.json (node not found — created fresh; merge manually if you had others)"
  fi
fi

echo "Done. Tip: pin a version for team/CI, e.g. --version 0.0.x (avoids flaky tool drift)."
