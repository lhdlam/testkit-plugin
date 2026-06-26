#!/usr/bin/env bash
# Smoke test for pre-tool-gate.sh: blocks when artifact missing/PENDING, allows when APPROVED.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATE="$HERE/../hooks/pre-tool-gate.sh"
PASS=0; FAIL=0
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
export TESTKIT_ROOT="docs"
mkdir -p docs
echo "web-playwright" > docs/.testkit-target

run() { printf '{"tool_name":"Skill","tool_input":{"skill":"%s"}}' "$1" | bash "$GATE" 2>/dev/null; echo $?; }
check() { if [[ "$2" == "$3" ]]; then PASS=$((PASS+1)); echo "  ok: $1"; else FAIL=$((FAIL+1)); echo "  FAIL: $1 (got $2 want $3)"; fi; }

# 1. generate-script with no scenarios.md → blocked (exit 1)
check "block script when scenarios missing" "$(run testkit:generate-script)" 1

# 2. scenarios PENDING → blocked
printf '# scenarios\n> Review: PENDING\n' > docs/scenarios.md
check "block script when scenarios PENDING" "$(run generate-script)" 1

# 3. scenarios APPROVED → allowed (exit 0)
printf '# scenarios\n> Review: APPROVED\n' > docs/scenarios.md
check "allow script when scenarios APPROVED" "$(run generate-script)" 0

# 4. non-gated skill always allowed
check "allow non-gated skill" "$(run run-and-heal)" 0

# 5. no .testkit-target → fail-open (allow)
rm docs/.testkit-target
check "fail-open without .testkit-target" "$(run generate-script)" 0

# 6. desktop layout: artifacts in docs/ (no TESTKIT_ROOT) → gate probes docs/
unset TESTKIT_ROOT
rm -rf "$tmp"/*; mkdir -p docs
echo "desktop-pyside6" > docs/.testkit-target
printf '# scenarios\n> Review: PENDING\n' > docs/scenarios.md
check "desktop: probe docs/ + block PENDING" "$(run generate-script)" 1
printf '# scenarios\n> Review: APPROVED\n' > docs/scenarios.md
check "desktop: probe docs/ + allow APPROVED" "$(run generate-script)" 0

echo "---"; echo "PASS=$PASS FAIL=$FAIL"
[[ "$FAIL" -eq 0 ]]
