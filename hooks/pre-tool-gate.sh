#!/usr/bin/env bash
# pre-tool-gate.sh — multi-stage review gate for the testkit pipeline.
#
# Blocks a pipeline phase skill until the PRIOR phase artifact is marked
# "> Review: APPROVED". Claude Code passes a JSON payload on stdin:
#   { "tool_name": "Skill", "tool_input": { "skill": "testkit:generate-script", ... } }
#
# Hook contract: exit 0 → allow; exit non-0 → block (stderr shown to agent + user).
#
# Gate map (skill → required APPROVED artifact):
#   generate-cases    ← feature-map.md
#   map-and-scenario  ← test-cases.md
#   generate-script   ← scenarios.md   (strongest gate: no code before scenarios signed off)
#
# Fail-open: jq missing, empty/malformed stdin, skill not in the map, or no testkit
# project (no <root>/.testkit-target). Cursor has no enforced PreToolUse hook, so the
# skills self-check the same marker (advisory) — see using-testkit.

set -euo pipefail

command -v jq >/dev/null 2>&1 || exit 0

input="$(cat || true)"
[[ -n "$input" ]] || exit 0

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // ""' 2>/dev/null || echo '')"
[[ "$tool_name" == "Skill" ]] || exit 0

skill="$(printf '%s' "$input" | jq -r '.tool_input.skill // ""' 2>/dev/null || echo '')"
# strip optional "testkit:" prefix
skill="${skill#testkit:}"

required=""
case "$skill" in
    generate-cases)   required="feature-map.md" ;;
    map-and-scenario) required="test-cases.md" ;;
    generate-script)  required="scenarios.md" ;;
    *) exit 0 ;;
esac

ROOT="${TESTKIT_ROOT:-e2e-tests/docs}"

# Only enforce inside an initialized testkit project.
[[ -f "$ROOT/.testkit-target" ]] || exit 0

ARTIFACT="$ROOT/$required"

if [[ ! -f "$ARTIFACT" ]]; then
    cat >&2 <<EOF
✗ testkit gate: refusing "$skill" — prior artifact missing.

  Expected: $ARTIFACT

  Run the previous phase first, have a human review it, then add the line
  "> Review: APPROVED" at the end and re-run.
EOF
    exit 1
fi

if ! grep -qE '^[[:space:]]*>[[:space:]]*Review:[[:space:]]+APPROVED[[:space:]]*$' "$ARTIFACT"; then
    cat >&2 <<EOF
✗ testkit gate: refusing "$skill" — "$required" not approved.

  File: $ARTIFACT

  Open it, finish the human review, then change the trailing line
      > Review: PENDING
  to
      > Review: APPROVED
  and re-run the command.
EOF
    exit 1
fi

exit 0
