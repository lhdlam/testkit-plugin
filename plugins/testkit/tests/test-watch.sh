#!/usr/bin/env bash
# Verify the watch (headed/observe) mode is wired.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$HERE/.."
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ok: $1"; }
bad() { FAIL=$((FAIL+1)); echo "  FAIL: $1"; }
has() { [[ -f "$ROOT/$1" ]] && ok "$2" || bad "missing $1"; }
chk() { grep -q -- "$2" "$ROOT/$1" 2>/dev/null && ok "$3" || bad "$3 ($1)"; }

has "skills/watch/SKILL.md"   "watch skill exists"
has "commands/watch.md"       "watch command exists"

# web: headed + UI mode + slow-mo documented
chk "skills/watch/SKILL.md" "--headed"         "watch documents --headed"
chk "skills/watch/SKILL.md" "--ui"             "watch documents Playwright UI mode"
chk "skills/watch/SKILL.md" "UI_SLOWMO"        "watch documents desktop UI_SLOWMO"

# config template exposes SLOWMO via launchOptions
chk "templates/playwright.config.ts.template" "slowMo" "playwright config supports slowMo"
chk "templates/playwright.config.ts.template" "SLOWMO" "playwright config reads SLOWMO env"

echo "---"; echo "PASS=$PASS FAIL=$FAIL"
[[ "$FAIL" -eq 0 ]]
