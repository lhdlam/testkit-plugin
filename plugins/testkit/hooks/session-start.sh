#!/usr/bin/env bash
# session-start.sh — detect the testkit target and surface a one-line hint.
# Advisory only; never fails the session.
set -uo pipefail

# Probe known artifact roots (web: e2e-tests/docs, desktop: docs) + override.
for ROOT in "${TESTKIT_ROOT:-}" "e2e-tests/docs" "docs"; do
    [[ -n "$ROOT" && -f "$ROOT/.testkit-target" ]] || continue
    target="$(tr -d '[:space:]' < "$ROOT/.testkit-target" 2>/dev/null || echo '')"
    lang="${TESTKIT_LANG:-}"
    [[ -z "$lang" && -f "$ROOT/.testkit-lang" ]] && lang="$(tr -d '[:space:]' < "$ROOT/.testkit-lang" 2>/dev/null || echo '')"
    [[ -z "$lang" ]] && lang="vi"
    [[ -n "$target" ]] && echo "[testkit] target = $target | lang = $lang (artifacts in $ROOT/). Run /testkit:analyze → cases → scenarios → script → run → ci."
    exit 0
done

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
