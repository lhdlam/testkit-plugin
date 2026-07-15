#!/usr/bin/env bash
# Verify the tester tools: question (Q&A with references), case-script (/testkit:tc),
# review-dev (acceptance review), and the dual-input mode in analyze-target.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$HERE/.."
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ok: $1"; }
bad() { FAIL=$((FAIL+1)); echo "  FAIL: $1"; }
has() { [[ -f "$ROOT/$1" ]] && ok "$2" || bad "missing $1"; }
chk() { grep -q -- "$2" "$ROOT/$1" 2>/dev/null && ok "$3" || bad "$3 ($1)"; }

# question
has "skills/question/SKILL.md"    "question skill exists"
has "commands/question.md"        "question command exists"
chk "skills/question/SKILL.md" "reference" "question requires references"
chk "skills/question/SKILL.md" "open-questions.md" "question routes gaps to open-questions"

# case-script (/testkit:tc)
has "skills/case-script/SKILL.md" "case-script skill exists"
has "commands/tc.md"              "tc command exists"
chk "skills/case-script/SKILL.md" "APPROVED" "case-script documents its gate"
chk "skills/case-script/SKILL.md" "rtm.md" "case-script updates rtm (automated mark)"

# review-dev
has "skills/review-dev/SKILL.md"  "review-dev skill exists"
has "commands/review-dev.md"      "review-dev command exists"
chk "skills/review-dev/SKILL.md" "Blocked" "review-dev has verdict taxonomy"
chk "skills/review-dev/SKILL.md" "bugs.md" "review-dev routes fails to bugs.md"

# gate wiring
chk "hooks/pre-tool-gate.sh" "case-script" "gate covers case-script"
chk "hooks/pre-tool-gate.sh" "review-dev"  "gate covers review-dev"

# dual-input mode
chk "skills/analyze-target/SKILL.md" "Dual-input" "analyze supports dual-input (docs + code)"

echo "---"; echo "PASS=$PASS FAIL=$FAIL"
[[ "$FAIL" -eq 0 ]]
