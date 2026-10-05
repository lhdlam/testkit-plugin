#!/usr/bin/env bash
# Verify the clean-handover rules: generated code carries no comments, and the agent
# never invents identifier codes (TC-xx / REQ-xx / BUG-xx / OQ-xx).
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$HERE/.."
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ok: $1"; }
bad() { FAIL=$((FAIL+1)); echo "  FAIL: $1"; }
chk() { grep -q -- "$2" "$ROOT/$1" 2>/dev/null && ok "$3" || bad "$3 ($1)"; }

# Core principle is stated in both the entry skill and the README
chk "skills/using-testkit/SKILL.md" "Code sạch để bàn giao khách" "using-testkit states the clean-code rule"
chk "README.md" "Code sạch để bàn giao khách" "README states the clean-code rule"

# Every target's CLAUDE.md template bakes the rule into the user's project
for t in web-playwright web-from-docs web-blackbox desktop-pyside6; do
    chk "templates/CLAUDE.md.$t.template" "KHÔNG viết comment trong code" "$t template forbids comments"
    chk "templates/CLAUDE.md.$t.template" "KHÔNG tự đặt mã định danh" "$t template forbids invented ids"
done
chk "templates/cursor-rules.testkit.mdc.template" "KHÔNG viết comment trong code" "cursor rules forbid comments"

# Code-producing skills carry the rule
chk "skills/generate-script/SKILL.md" "Luật code sạch" "generate-script has the clean-code section"
chk "skills/case-script/SKILL.md" "KHÔNG comment trong code" "case-script forbids comments"
chk "skills/fixbug/SKILL.md" "Code sạch (bàn giao khách)" "fixbug forbids comments"
chk "skills/new-feature/SKILL.md" "KHÔNG comment" "new-feature forbids comments"

# Test case identity is Module + title, and the test name carries it
chk "skills/generate-cases/SKILL.md" "Module + Tiêu đề" "generate-cases identifies cases by module+title"
chk "skills/generate-script/SKILL.md" "Tên test CHÍNH LÀ tiêu đề test case" "generate-script names tests after the case"

# Shipped code templates must contain no comment lines at all
for f in templates/LoginPage.ts.template templates/auth.setup.ts.template; do
    grep -qE '^\s*//' "$ROOT/$f" && bad "$f still has // comments" || ok "$(basename "$f") is comment-free"
done
for f in templates/LoginScreen.py.template templates/conftest.py.template; do
    grep -qE '^\s*#' "$ROOT/$f" && bad "$f still has # comments" || ok "$(basename "$f") is comment-free"
done

# No invented identifier codes anywhere in the plugin's docs/templates
if grep -rqE "TC-[A-Z0-9]{2}|REQ-[0-9]{2}|BUG-[A-Z0-9]{2}|OQ-[0-9]" \
     --include="*.md" --include="*.template" "$ROOT"; then
    bad "invented identifier codes still present"
    grep -rnE "TC-[A-Z0-9]{2}|REQ-[0-9]{2}|BUG-[A-Z0-9]{2}|OQ-[0-9]" \
      --include="*.md" --include="*.template" "$ROOT" | head -5
else
    ok "no invented identifier codes (TC-/REQ-/BUG-/OQ-)"
fi

# Vietnamese comments in code are banned outright, everywhere the rule must appear
chk "skills/using-testkit/SKILL.md" "NGHIÊM CẤM comment tiếng Việt" "using-testkit bans Vietnamese comments"
chk "README.md" "NGHIÊM CẤM comment tiếng Việt" "README bans Vietnamese comments"
for t in web-playwright web-from-docs web-blackbox desktop-pyside6; do
    chk "templates/CLAUDE.md.$t.template" "NGHIÊM CẤM comment tiếng Việt" "$t template bans Vietnamese comments"
    chk "templates/CLAUDE.md.$t.template" "Dọn rác khi gặp" "$t template has cleanup-on-sight"
done
chk "templates/cursor-rules.testkit.mdc.template" "NGHIÊM CẤM comment tiếng Việt" "cursor rules ban Vietnamese comments"
chk "templates/cursor-rules.testkit.mdc.template" "Dọn rác khi gặp" "cursor rules have cleanup-on-sight"

# Cleanup-on-sight must reach every skill that writes code
chk "skills/using-testkit/SKILL.md" "cleanup-on-sight" "using-testkit states cleanup-on-sight"
chk "skills/generate-script/SKILL.md" "Dọn rác khi gặp" "generate-script has cleanup-on-sight"
chk "skills/fixbug/SKILL.md" "cleanup-on-sight" "fixbug has cleanup-on-sight"
chk "skills/case-script/SKILL.md" "XOÁ ngay" "case-script deletes legacy markers on sight"
chk "skills/new-feature/SKILL.md" "Dọn rác khi gặp" "new-feature has cleanup-on-sight"

# Cleanup is unbounded by design — delete on sight, wherever it is found
chk "skills/using-testkit/SKILL.md" "không giới hạn phạm vi" "cleanup is unbounded (delete on sight)"
chk "skills/fixbug/SKILL.md" "BẤT KỲ đâu" "fixbug cleans up anywhere it finds markers"
chk "README.md" "BẤT KỲ đâu" "README states cleanup is unbounded"

# No date / customer stamps in generated artifact headers
if grep -rqE "<ngày>|— <ngày" --include="*.md" "$ROOT"; then
    bad "artifact templates still stamp a date"
else
    ok "artifact headers carry no date stamp"
fi

echo "---"; echo "PASS=$PASS FAIL=$FAIL"
[[ "$FAIL" -eq 0 ]]
