#!/usr/bin/env bash
# Completeness test: every implemented target has a profile + CLAUDE.md template,
# and its CI template (resolved by runner family) exists.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$HERE/.."
PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); echo "  ok: $1"; }
bad()  { FAIL=$((FAIL+1)); echo "  FAIL: $1"; }
has()  { [[ -f "$ROOT/$1" ]] && ok "$1" || bad "missing $1"; }

# Implemented targets (keep in sync with README roadmap "Xong").
TARGETS="web-playwright web-from-docs web-blackbox desktop-pyside6"

for t in $TARGETS; do
  has "profiles/$t.md"
  has "templates/CLAUDE.md.$t.template"
done

# CI template family resolution
has "templates/ci-web.yml.template"            # web-playwright / web-from-docs / web-blackbox
has "templates/ci-desktop-pyside6.yml.template" # desktop-pyside6

# Each profile must declare its 5 adapter axes (sanity).
for t in $TARGETS; do
  for axis in source_of_requirements source_of_selectors runner execution mcp; do
    grep -q "$axis" "$ROOT/profiles/$t.md" && ok "$t declares $axis" || bad "$t missing axis $axis"
  done
done

echo "---"; echo "PASS=$PASS FAIL=$FAIL"
[[ "$FAIL" -eq 0 ]]
