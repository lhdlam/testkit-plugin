---
name: generate-script
description: Phase 4 — turn scenarios into runnable test code (Playwright POM / pytest-qt Screen Object) with auth state, traceability comments, and tags. Use via /testkit:script. Gated — requires scenarios.md APPROVED.
license: MIT
---

# Phase 4 — Generate script

Mục tiêu: biến kịch bản thành **code chạy được**, ổn định, truy vết được. Tuân thủ `CLAUDE.md` + `profiles/<target>.md`.

## Pre-flight gate
`${TESTKIT_ROOT:-e2e-tests/docs}/scenarios.md` phải `> Review: APPROVED`. Chưa → DỪNG, nhắc duyệt Phase 3.
(Đây là gate được hook cưỡng chế mạnh nhất: chặn sinh code khi chưa duyệt kịch bản.)

## web-* (Playwright)
1. **Page Object** trong `tests/pages/` — locator `getByRole/getByLabel/getByTestId` (selector từ `ui-map.md`,
   KHÔNG đoán); method hành động; mọi `goto()` đường dẫn TƯƠNG ĐỐI.
2. **auth.setup.ts** — đăng nhập 1 lần, lưu `storageState` → `tests/fixtures/.auth/user.json`;
   config tái dùng cho mọi project trừ test kiểm tra chính luồng đăng nhập.
3. **`*.spec.ts`** trong `tests/e2e/` — mỗi checkpoint = 1 `expect()`; tên test theo quy ước;
   tag `@smoke/@regression/@edge`; comment truy vết `// TC-LOGIN-01 ← REQ-003`.
4. Chạy thử 1 luồng smoke trỏ Staging xác nhận selector khớp; KHÔNG tạo dữ liệu rác.

## desktop-pyside6 (pytest-qt)
1. **Screen Object** trong `tests/screens/` — tìm widget bằng `window.findChild(QType, "objectName")`,
   KHÔNG dò theo chỉ số/thứ tự con; method thao tác.
2. **conftest.py** — fixture tạo MainWindow mới mỗi test (`qtbot.addWidget` để tự dọn);
   cô lập trạng thái: `tmp_path` cho file, patch `QSettings`, mock DB/network.
3. **`test_*.py`** — mỗi checkpoint = 1 `assert`; chờ bằng `qtbot.waitUntil/waitSignal`,
   **TUYỆT ĐỐI không `time.sleep`**; **modal** (QMessageBox/QFileDialog) → `monkeypatch` giá trị trả về;
   marker `@pytest.mark.smoke/regression/edge`; comment `# TC-LOGIN-01`.
4. Chạy thử `QT_QPA_PLATFORM=offscreen pytest -q` xác nhận.

## Quy tắc chống green-washing
Assertion phải khớp **Expected Result** trong test-cases. Nếu UI/hành vi thật khác Expected → KHÔNG
sửa assertion cho khớp sản phẩm; ghi `docs/bugs.md` và dừng để tester phân định.

## Kết thúc
Báo cáo file đã tạo + kết quả chạy thử. Thêm `> Review: PENDING` vào `scenarios.md`? Không — pha này
review trên code: nhắc tester đọc lại assertion có đúng nghiệp vụ. → Bước tiếp: `/testkit:run`.
