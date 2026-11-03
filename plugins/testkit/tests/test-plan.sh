#!/usr/bin/env bash
# Verify /testkit:plan — the Phase 0.5 planning gate: the skill/command exist, the plan
# covers scoping, the six impact buckets and the spec cross-check, and the conditional
# hook gate really blocks new-feature only while a plan is PENDING.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$HERE/.."
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ok: $1"; }
bad() { FAIL=$((FAIL+1)); echo "  FAIL: $1"; }
has() { [[ -f "$ROOT/$1" ]] && ok "$2" || bad "missing $1"; }
chk() { grep -q -- "$2" "$ROOT/$1" 2>/dev/null && ok "$3" || bad "$3 ($1)"; }

has "skills/plan-task/SKILL.md" "plan-task skill exists"
has "commands/plan.md"          "plan command exists"

# Read-only by contract: planning must not generate tests or touch app code
chk "skills/plan-task/SKILL.md" "KHÔNG sinh test, KHÔNG sửa code" "plan is read-only"

# Scoping: git diff or description, and it asks instead of guessing
chk "skills/plan-task/SKILL.md" "git diff" "plan scopes via git diff"
chk "skills/plan-task/SKILL.md" "KHÔNG bịa" "plan forbids fabrication"

# The six impact buckets must all be named
for bucket in "Màn hình / luồng" "Test case hiện có" "Test tự động hiện có" \
              "Tài liệu / yêu cầu" "Dữ liệu & phân quyền" "Vùng dùng chung"; do
    chk "skills/plan-task/SKILL.md" "$bucket" "impact bucket: $bucket"
done
chk "skills/plan-task/SKILL.md" "cần xác minh" "plan admits insufficient evidence"

# Spec cross-check raises rather than decides
chk "skills/plan-task/SKILL.md" "Task ≠ Tài liệu" "plan cross-checks task vs docs"
chk "skills/plan-task/SKILL.md" "Tài liệu ≠ Hiện thực" "plan cross-checks docs vs implementation"
chk "skills/plan-task/SKILL.md" "open-questions.md" "plan raises deviations to open-questions"

# Artifact + gate, and the clean-code rules apply here too
chk "skills/plan-task/SKILL.md" "Review: PENDING" "plan artifact carries the review gate"
chk "skills/plan-task/SKILL.md" "KHÔNG tự đặt mã định danh" "plan uses no invented ids"
chk "skills/using-testkit/SKILL.md" "plan-task" "using-testkit lists the planning phase"
chk "hooks/pre-tool-gate.sh" "@plan" "gate hook knows the conditional plan gate"

# --- Behavioural test of the conditional gate -------------------------------
HOOK="$ROOT/hooks/pre-tool-gate.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/e2e-tests/docs"
echo "web-playwright" > "$TMP/e2e-tests/docs/.testkit-target"
PAYLOAD='{"tool_name":"Skill","tool_input":{"skill":"testkit:new-feature"}}'
gate() { ( cd "$TMP" && printf '%s' "$PAYLOAD" | bash "$HOOK" >/dev/null 2>&1; echo $? ); }

[[ "$(gate)" == "0" ]] && ok "gate allows new-feature when no plan exists" \
                       || bad "gate must not block when no plan exists"

printf '# Plan: x\n> Review: PENDING\n' > "$TMP/e2e-tests/docs/plan-x.md"
[[ "$(gate)" == "1" ]] && ok "gate blocks new-feature while a plan is PENDING" \
                       || bad "gate must block a PENDING plan"

printf '# Plan: x\n> Review: APPROVED\n' > "$TMP/e2e-tests/docs/plan-x.md"
[[ "$(gate)" == "0" ]] && ok "gate allows new-feature once the plan is APPROVED" \
                       || bad "gate must allow an APPROVED plan"

printf '# Plan: y\n> Review: PENDING\n' > "$TMP/e2e-tests/docs/plan-y.md"
[[ "$(gate)" == "1" ]] && ok "gate blocks when any one of several plans is PENDING" \
                       || bad "gate must block if any plan is PENDING"

echo "---"; echo "PASS=$PASS FAIL=$FAIL"
[[ "$FAIL" -eq 0 ]]
