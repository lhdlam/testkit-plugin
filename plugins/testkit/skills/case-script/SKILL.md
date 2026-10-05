---
name: case-script
description: Generate a runnable test script for SPECIFIC test case(s) named by module/title (e.g. "Login / đăng nhập thất bại khi sai mật khẩu") straight from test-cases.md — lighter path than the full scenarios phase. Use via /testkit:tc <module | tiêu đề>. Gated — requires test-cases.md APPROVED.
license: MIT
---

# Case-script — sinh script cho từng test case được chỉ định

Mục tiêu: tester **chỉ định test case** (theo module hoặc tiêu đề) → sinh script chạy được cho đúng các
case đó. Đường tắt so với pipeline đầy đủ (không cần dựng `scenarios.md` trước) — dùng khi cần automate
nhanh một case cụ thể, hoặc bổ sung case lẻ sau khi suite chính đã có.

> **Ngôn ngữ:** giao tiếp theo `lang`; code/từ khoá framework giữ tiếng Anh.
> **Code sạch:** code sinh ra KHÔNG comment, KHÔNG mã định danh tự đặt.
> **NGHIÊM CẤM comment tiếng Việt trong code.** Thấy mã định danh cũ / comment tiếng Việt / comment thừa
> ở **BẤT KỲ đâu** → **XOÁ ngay** trong cùng lần sửa, không giới hạn phạm vi, không hỏi lại.

## Pre-flight gate
`test-cases.md` phải `> Review: APPROVED` (case chưa được người duyệt thì không automate).
Claude Code: hook chặn; Cursor: tự kiểm.

## Các bước

1. **Xác định test case từ argument.** Argument là **tên module** (vd `Login` → mọi case của module) hoặc
   **tiêu đề test case** (vd `đăng nhập thất bại khi sai mật khẩu`), khớp không phân biệt hoa/thường.
   Đọc `test-cases.md`, trích đúng các dòng: Steps, Expected Result, Precondition, Priority, Nguồn.
   Không khớp case nào → báo user, liệt kê tiêu đề gần giống (không đoán).
   Khớp nhiều case mơ hồ → liệt kê và hỏi lại, đừng tự chọn.

2. **Resolve selector cho từng bước:**
   - Có `ui-map.md` và case nằm trong đó → dùng selector đã xác thực.
   - Chưa có → web: dùng Playwright MCP mở Staging đi qua các bước để lấy selector thật (KHÔNG đoán);
     desktop: lấy `objectName` từ `feature-map.md`/code. Ghi bổ sung vào `ui-map.md` cho lần sau.

3. **Sinh/cập nhật code:**
   - Page/Screen Object: tái dùng class hiện có; chỉ thêm locator/method còn thiếu (đừng tạo trùng).
   - Test: thêm vào file spec/test theo module của case (vd module `Login` → `login.spec.ts` /
     `test_login.py`); chưa có file → tạo mới theo template.
   - **Mỗi case = 1 test, tên test CHÍNH LÀ tiêu đề test case** (web giữ nguyên câu mô tả; desktop
     snake_case hoá). Tag theo Priority (P1 → `@smoke`, còn lại `@regression`).
   - **KHÔNG comment trong code. KHÔNG mã định danh.**
   - Assertion khớp **đúng Expected Result trong test-cases.md** — hành vi thật khác Expected →
     KHÔNG bẻ assertion theo sản phẩm, ghi `bugs.md` (luật chống green-washing).

4. **Chạy thử đúng các test vừa sinh** (lọc theo tiêu đề):
   - web: `TEST_ENV=staging npx playwright test -g "đăng nhập thất bại khi sai mật khẩu"`
   - desktop: `QT_QPA_PLATFORM=offscreen pytest -q -k "dang_nhap_that_bai_khi_sai_mat_khau"`
   Fail → phân loại theo taxonomy Phase 5 (không sửa test oan).

5. **Cập nhật truy vết:** đánh dấu case đã automate trong `rtm.md` (cột "Test case phủ" → thêm ghi chú
   `[automated]` kèm file + tên test), để tester thấy tiến độ automate theo case.

## Đầu ra
Code test cho đúng case yêu cầu + `ui-map.md` bổ sung (nếu khám phá thêm) + `rtm.md` cập nhật + kết quả chạy thử.
