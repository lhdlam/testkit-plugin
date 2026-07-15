---
name: case-script
description: Generate a runnable test script for SPECIFIC test-case ID(s) (e.g. TC-LOGIN-02) straight from test-cases.md — lighter path than the full scenarios phase. Use via /testkit:tc <TC-ID...>. Gated — requires test-cases.md APPROVED.
license: MIT
---

# Case-script — sinh script cho từng TC-ID

Mục tiêu: tester **chỉ định TC-ID** (một hoặc nhiều) → sinh script chạy được cho đúng các case đó.
Đường tắt so với pipeline đầy đủ (không cần dựng `scenarios.md` trước) — dùng khi cần automate nhanh
một case cụ thể, hoặc bổ sung case lẻ sau khi suite chính đã có.

> **Ngôn ngữ:** giao tiếp + comment mô tả theo `lang`; code/định danh giữ tiếng Anh.

## Pre-flight gate
`test-cases.md` phải `> Review: APPROVED` (case chưa được người duyệt thì không automate).
Claude Code: hook chặn; Cursor: tự kiểm.

## Các bước

1. **Parse TC-ID** từ argument (vd `TC-LOGIN-02 TC-LOGIN-03` hoặc `TC-LOGIN-*` cho cả nhóm).
   Đọc `test-cases.md`, trích đúng các dòng: Steps, Expected Result, Precondition, Priority, REQ nguồn.
   TC-ID không tồn tại → báo user, liệt kê ID gần giống (không đoán).

2. **Resolve selector cho từng bước:**
   - Có `ui-map.md` và TC nằm trong đó → dùng selector đã xác thực.
   - Chưa có → web: dùng Playwright MCP mở Staging đi qua các bước để lấy selector thật (KHÔNG đoán);
     desktop: lấy `objectName` từ `feature-map.md`/code. Ghi bổ sung vào `ui-map.md` cho lần sau.

3. **Sinh/cập nhật code:**
   - Page/Screen Object: tái dùng class hiện có; chỉ thêm locator/method còn thiếu (đừng tạo trùng).
   - Test: thêm vào file spec/test theo module của TC (vd `TC-LOGIN-*` → `login.spec.ts` / `test_login.py`);
     chưa có file → tạo mới theo template.
   - Mỗi TC = 1 test, comment truy vết `// TC-LOGIN-02 ← REQ-003`, tag theo Priority
     (P1 → `@smoke`, còn lại `@regression`) + tag `@tc` để chạy nhóm sinh lẻ.
   - Assertion khớp **đúng Expected Result trong test-cases.md** — hành vi thật khác Expected →
     KHÔNG bẻ assertion theo sản phẩm, ghi `bugs.md` (luật chống green-washing).

4. **Chạy thử đúng các test vừa sinh:**
   - web: `TEST_ENV=staging npx playwright test -g "TC-LOGIN-02"`
   - desktop: `QT_QPA_PLATFORM=offscreen pytest -q -k "TC_LOGIN_02 or login_02"` (theo tên test đã đặt)
   Fail → phân loại theo taxonomy Phase 5 (không sửa test oan).

5. **Cập nhật truy vết:** đánh dấu TC đã automate trong `rtm.md` (cột "Test case phủ" → thêm ghi chú
   `[automated]`), để tester thấy tiến độ automate theo case.

## Đầu ra
Code test cho đúng TC yêu cầu + `ui-map.md` bổ sung (nếu khám phá thêm) + `rtm.md` cập nhật + kết quả chạy thử.
