#!/usr/bin/env bash
# session-start.sh — detect the testkit target and surface a one-line hint.
# Advisory only; never fails the session.
set -uo pipefail

ROOT="${TESTKIT_ROOT:-e2e-tests/docs}"
TARGET_FILE="$ROOT/.testkit-target"

if [[ -f "$TARGET_FILE" ]]; then
    target="$(tr -d '[:space:]' < "$TARGET_FILE" 2>/dev/null || echo '')"
    [[ -n "$target" ]] && echo "[testkit] target = $target (artifacts in $ROOT/). Run /testkit:analyze → cases → scenarios → script → run → ci."
    exit 0
fi

# Not initialized yet — try to guess and hint.
guess=""
if [[ -f "playwright.config.ts" || -f "e2e-tests/playwright.config.ts" ]]; then
    guess="web-playwright"
elif [[ -f "pytest.ini" ]] && grep -qi "pyside6" pytest.ini 2>/dev/null; then
    guess="desktop-pyside6"
fi

if [[ -n "$guess" ]]; then
    echo "[testkit] not initialized. Looks like '$guess'. Run /testkit:init to set up the pipeline."
fi
exit 0
