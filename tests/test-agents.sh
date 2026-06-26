#!/usr/bin/env bash
# Verify the M5 subagents exist with valid frontmatter (name + description + tools).
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$HERE/.."
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ok: $1"; }
bad() { FAIL=$((FAIL+1)); echo "  FAIL: $1"; }

AGENTS="coverage-auditor failure-classifier selector-stability test-integrity"

for a in $AGENTS; do
  f="$ROOT/agents/$a.md"
  if [[ ! -f "$f" ]]; then bad "missing agents/$a.md"; continue; fi
  # frontmatter must declare name matching file, plus description + tools
  grep -qE "^name: $a$" "$f"        && ok "$a: name"        || bad "$a: name mismatch"
  grep -qE "^description: " "$f"     && ok "$a: description" || bad "$a: no description"
  grep -qE "^tools: " "$f"           && ok "$a: tools"       || bad "$a: no tools"
done

echo "---"; echo "PASS=$PASS FAIL=$FAIL"
[[ "$FAIL" -eq 0 ]]
