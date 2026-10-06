---
name: generate-script
description: Phase 4 — turn scenarios into runnable test code (Playwright POM / pytest-qt Screen Object) with auth state and tags. Produces clean, comment-free, handover-ready code. Use via /testkit:script. Gated — requires scenarios.md APPROVED.
license: MIT
---

# Phase 4 — Generate script

Mục tiêu: biến kịch bản thành **code chạy được**, ổn định, **sạch để bàn giao khách**. Tuân thủ
`CLAUDE.md` + `profiles/<target>.md`.

## Luật code sạch (bắt buộc)
- **KHÔNG viết comment trong code sinh ra** — không comment truy vết, không comment giải thích,
  không ghi chú ngày/tên khách. Code tự diễn đạt qua tên biến/hàm/test rõ nghĩa.
- **KHÔNG tự đặt mã định danh** (TC-xx, REQ-xx, BUG-xx). **Tên test CHÍNH LÀ tiêu đề test case.**
- Truy vết test ↔ test case ↔ yêu cầu sống trong `rtm.md` (ánh xạ qua file + tên test), **không** trong code.
- **NGHIÊM CẤM comment tiếng Việt trong code** — không ngoại lệ.
- **KHÔNG dùng chỉ thị tắt lint/type-check** (`# noqa`, `# type: ignore`, `// @ts-ignore`,
  `// eslint-disable*`…) để làm xanh. Gặp cái có sẵn → **XOÁ** rồi **sửa nguyên nhân thật**.
- **Dọn rác khi gặp:** thấy mã định danh cũ (`TC-xx`/`REQ-xx`/`BUG-xx`/`OQ-xx`), comment tiếng Việt,
  comment thừa hay chỉ thị `noqa`/`ts-ignore`/`eslint-disable` ở **BẤT KỲ đâu** → **XOÁ ngay trong cùng
  lần sửa**, không hỏi lại, không giới hạn phạm vi.

## Pre-flight gate
`${TESTKIT_ROOT:-e2e-tests/docs}/scenarios.md` phải `> Review: APPROVED`. Chưa → DỪNG, nhắc duyệt Phase 3.
(Đây là gate được hook cưỡng chế mạnh nhất: chặn sinh code khi chưa duyệt kịch bản.)

## web-* (Playwright)
1. **Page Object** trong `tests/pages/` — locator `getByRole/getByLabel/getByTestId` (selector từ `ui-map.md`,
   KHÔNG đoán); method hành động; mọi `goto()` đường dẫn TƯƠNG ĐỐI.
2. **auth.setup.ts** — đăng nhập 1 lần, lưu `storageState` → `tests/fixtures/.auth/user.json`;
   config tái dùng cho mọi project trừ test kiểm tra chính luồng đăng nhập.
3. **`*.spec.ts`** trong `tests/e2e/` — mỗi checkpoint = 1 `expect()`; **tên test = tiêu đề test case**
   (vd `test('đăng nhập thất bại khi sai mật khẩu', ...)`); tag `@smoke/@regression/@edge`. Không comment.
4. Chạy thử 1 luồng smoke trỏ Staging xác nhận selector khớp; KHÔNG tạo dữ liệu rác.

## desktop-pyside6 (pytest-qt)
1. **Screen Object** trong `tests/screens/` — tìm widget bằng `window.findChild(QType, "objectName")`,
   KHÔNG dò theo chỉ số/thứ tự con; method thao tác.
2. **conftest.py** — fixture tạo MainWindow mới mỗi test (`qtbot.addWidget` để tự dọn);
   cô lập trạng thái: `tmp_path` cho file, patch `QSettings`, mock DB/network.
3. **`test_*.py`** — mỗi checkpoint = 1 `assert`; chờ bằng `qtbot.waitUntil/waitSignal`,
   **TUYỆT ĐỐI không `time.sleep`**; **modal** (QMessageBox/QFileDialog) → `monkeypatch` giá trị trả về;
   marker `@pytest.mark.smoke/regression/edge`; **tên hàm test = tiêu đề test case** dạng snake_case
   (vd `test_dang_nhap_that_bai_khi_sai_mat_khau`). Không comment.
4. Chạy thử `QT_QPA_PLATFORM=offscreen pytest -q` xác nhận.

## Quy tắc chống green-washing
Assertion phải khớp **Expected Result** trong test-cases. Nếu UI/hành vi thật khác Expected → KHÔNG
sửa assertion cho khớp sản phẩm; ghi `docs/bugs.md` và dừng để tester phân định.

## Tùy chọn — audit selector bằng subagent
Sau khi sinh Page/Screen Object, có thể dispatch agent `selector-stability` (Agent tool) để soát selector
brittle: web (XPath/CSS nth/absolute URL) hoặc desktop (findChild thiếu objectName / theo chỉ số). Sửa các
mục High trước khi chạy.

## Kết thúc
Báo cáo file đã tạo + kết quả chạy thử. Pha này review trên code: nhắc tester đọc lại assertion có đúng
nghiệp vụ. → Bước tiếp: `/testkit:run`.
