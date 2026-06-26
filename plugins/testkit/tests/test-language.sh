#!/usr/bin/env bash
# Verify the en/vi language option is wired across the plugin.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$HERE/.."
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ok: $1"; }
chk() { if grep -q "$2" "$ROOT/$1" 2>/dev/null; then ok "$3"; else FAIL=$((FAIL+1)); echo "  FAIL: $3 ($1)"; fi; }

# Authoritative rule lives in using-testkit
chk "skills/using-testkit/SKILL.md" ".testkit-lang"   "using-testkit references .testkit-lang"
chk "skills/using-testkit/SKILL.md" "TESTKIT_LANG"     "using-testkit references TESTKIT_LANG"

# setup asks + writes the lang file
chk "skills/setup/SKILL.md"         ".testkit-lang"    "setup writes .testkit-lang"

# session-start surfaces lang
chk "hooks/session-start.sh"        ".testkit-lang"    "session-start reads .testkit-lang"
chk "hooks/session-start.sh"        "TESTKIT_LANG"     "session-start honors TESTKIT_LANG"

# Cursor rules carry the language rule
chk "templates/cursor-rules.testkit.mdc.template" ".testkit-lang" "cursor template references .testkit-lang"

# init command documents the prompt
chk "commands/init.md"              "language"         "init command documents language"

echo "---"; echo "PASS=$PASS FAIL=$FAIL"
[[ "$FAIL" -eq 0 ]]
