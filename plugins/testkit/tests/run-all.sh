#!/usr/bin/env bash
# run-all.sh — run every testkit plugin test.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fail=0
for t in "$HERE"/test-*.sh; do
  echo "▶ $(basename "$t")"
  bash "$t" || fail=1
  echo
done
[[ "$fail" -eq 0 ]] && echo "ALL TESTS PASSED" || { echo "SOME TESTS FAILED"; exit 1; }
