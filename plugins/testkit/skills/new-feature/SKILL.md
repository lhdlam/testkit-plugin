---
name: new-feature
description: Incremental mode — generate/update tests for ONE new feature only (scoped by git diff or a description), without rescanning the whole project. Use via /testkit:new-feature when an existing testkit project gains a feature.
license: MIT
---

# Incremental — test one feature only

Mục tiêu: với 1 tính năng mới, **chỉ** sinh/cập nhật feature-map + test case + kịch bản + script **cho
riêng tính năng đó**. Nhanh, rẻ, không đụng test cũ, không quét lại toàn bộ.

> Dùng khi project đã init testkit (`.testkit-target` tồn tại) và đã có bộ test gốc. Nếu chưa init →
> chạy `/testkit:init` rồi pipeline đầy đủ trước.

## Bước 0 — Đầu vào & đặt tên
Lấy tên ngắn gọn `feat-xxxx` (kebab). Xác định **cách định phạm vi**:
- **Cách A — git diff** (target có code: web-playwright, desktop-pyside6): có tag/nhánh `feat-xxxx`.
- **Cách B — mô tả**: user dán mô tả tính năng (làm gì, màn hình nào, input/nút/kết quả, validate, luồng).

Đọc `profiles/<target>.md` (target từ `.testkit-target`).

## Bước 1 — Định phạm vi (đọc tối thiểu, KHÔNG quét cả repo)
- **Cách A**: `git diff --name-only <nhánh-chính>...feat-xxxx` (hoặc `git show --stat <tag>`).
  Chỉ đọc các file đó + màn hình/widget liên quan trực tiếp.
- **Cách B (code targets)**: từ mô tả suy ra màn hình/file liên quan, tìm ĐÚNG file đó (theo tên màn hình,
  nhãn nút, route/QStackedWidget) và CHỈ đọc phần đó. Không định vị được → ghi
  `docs/open-questions-feat-xxxx.md` và HỎI lại, KHÔNG đoán bừa.
- **web-from-docs**: phạm vi = tài liệu mới/đổi cho tính năng → trích REQ liên quan.
- **web-blackbox**: phạm vi = luồng mô tả → Playwright MCP explore RIÊNG luồng đó trên Staging.

## Bước 2 — Artifact RIÊNG cho tính năng (không trộn vào file tổng)
- `docs/feature-map-feat-xxxx.md` — màn hình/widget/REQ liên quan tính năng.
  (desktop: widget mới thiếu objectName → `docs/missing-object-names.md`)
- `docs/test-cases-feat-xxxx.md` — case bám phạm vi (positive/negative/boundary/state/permission),
  ID `TC-FEATXXXX-nn`. KHÔNG bịa hành vi ngoài phạm vi; ý ngoài → mục "Đề xuất".
- `docs/scenarios-feat-xxxx.md` — kịch bản E2E của tính năng.
Mỗi artifact kết thúc `> Review: PENDING` (review advisory ở mode này — TỰ nhắc tester duyệt).

## Bước 3 — Script RIÊNG cho tính năng
- Page/Screen Object mới (nếu có màn hình mới) trong `tests/pages/` (web) / `tests/screens/` (desktop).
- File test riêng: `tests/e2e/feat-xxxx.spec.ts` (web) hoặc `tests/test_feat_xxxx.py` (desktop).
  - web: tag `@feat-xxxx` (+ `@smoke/@regression`); comment `// TC-FEATXXXX-01`.
  - desktop: `@pytest.mark.feat_xxxx`; đăng ký marker trong `pytest.ini`; comment `# TC-FEATXXXX-01`.
- Tuân thủ `CLAUDE.md` + `profiles/<target>.md` (selector, auth state, monkeypatch modal, cô lập trạng thái).

## Bước 4 — Tính năng đổi hành vi cũ?
Nếu tính năng làm đổi hành vi cũ → **liệt kê test hiện có bị ảnh hưởng + đề xuất cập nhật**, KHÔNG tự xoá;
chờ tester xác nhận. (Có thể dispatch agent `test-integrity` trên diff để chắc không green-wash.)

## Bước 5 — Chạy RIÊNG nhóm tính năng
- web: `TEST_ENV=staging npx playwright test --grep @feat-xxxx`
- desktop: `QT_QPA_PLATFORM=offscreen pytest -q -m feat_xxxx`
Fail → áp dụng phân loại & self-heal của Phase 5 (agent `failure-classifier`).

## Khác biệt Cách A vs B
A định vị bằng git diff (chắc chắn, đúng file đã đổi). B định vị bằng suy luận từ mô tả (dễ sai phạm vi)
→ thêm ràng buộc **hỏi lại khi không định vị được** + **không bịa ngoài mô tả**. Có cả tag lẫn mô tả → ưu tiên A, dùng mô tả bổ sung ngữ cảnh.
