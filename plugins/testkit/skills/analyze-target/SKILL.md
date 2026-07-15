---
name: analyze-target
description: Phase 1 — understand the system under test (read code / read docs / explore live UI per target) and produce feature-map.md. Use after setup or via /testkit:analyze. Does NOT write tests.
license: MIT
---

# Phase 1 — Analyze

Mục tiêu: hiểu ứng dụng (luồng, input/output, validation, phân quyền) → `feature-map.md`.
**KHÔNG viết test ở pha này.**

> **Ngôn ngữ:** viết artifact + trả lời theo `lang` (`.testkit-lang`/`TESTKIT_LANG`, mặc định `vi`) — xem `using-testkit`.

## Đọc profile trước
Đọc `profiles/<target>.md` (target lấy từ `${TESTKIT_ROOT:-e2e-tests/docs}/.testkit-target`).
Nguồn hiểu biết tùy target:
- **web-playwright / desktop-pyside6**: đọc source **read-only**, KHÔNG build/run app.
- **web-from-docs**: đọc toàn bộ `docs/` (mọi định dạng), trích yêu cầu REQ-xxx có nguồn.
- **web-blackbox**: dùng Playwright MCP mở `{STAGING_URL}` khám phá UI (chỉ khám phá, không tạo data rác).

## Dual-input (có CẢ tài liệu lẫn code) — khuyến nghị khi đủ 2 nguồn

Nếu project có cả **tài liệu** (`input/docs/` hoặc thư mục user chỉ) và **source code** (mọi target `*-code`):
1. **Tài liệu = nguồn sự thật về YÊU CẦU** (test gì): trích REQ-xxx gắn nguồn (tài liệu + mục) như from-docs.
2. **Code = nguồn sự thật về HIỆN THỰC** (validation rule chính xác, route, state, objectName).
3. **Cross-check hai chiều** — giá trị lớn nhất của dual-input:
   - Tài liệu nói X, code làm Y → ghi `open-questions.md` mục **"Tài liệu ≠ Code"** (kèm reference cả 2 phía).
     Đây có thể là bug tiềm ẩn hoặc tài liệu lỗi thời — con người phân xử TRƯỚC khi sinh test case.
   - Code có hành vi tài liệu không nhắc (validation ngầm, edge case) → liệt kê mục "Phát hiện từ code"
     trong feature-map để tester quyết có đưa vào phạm vi test không.
4. Trong `feature-map.md`, mỗi yêu cầu ghi rõ nguồn: `[doc]`, `[code]`, hoặc `[doc+code]` (khớp nhau).

## Sinh `feature-map.md`
Liệt kê:
1. Màn hình/route (web) hoặc cửa sổ/dialog (desktop) + mục đích từng cái
2. Thành phần tương tác (form/nút/input) + validation rule
   - desktop: kèm `objectName` + kiểu widget
   - web-from-docs: mỗi yêu cầu gắn nguồn (tài liệu + mục), mã `REQ-xxx`
3. User flow chính (đăng ký → xác thực → đăng nhập...)
4. Luồng lỗi & edge case
5. Điểm phân quyền / bảo mật / trạng thái bất thường

## Artifact phụ theo target
- **web-from-docs**: `open-questions.md` (mâu thuẫn/mơ hồ/khoảng trống — KHÔNG tự bịa, để con người xử).
- **desktop-pyside6**: `missing-object-names.md` (widget tương tác thiếu `objectName` + đề xuất tên).

## Kết thúc
Thêm dòng cuối `feature-map.md`:
```
> Review: PENDING
```
Nhắc user: review feature-map, bổ sung domain/business ngầm, giải `open-questions.md` (nếu có),
quyết bổ sung `objectName` (desktop), rồi đổi dòng cuối thành `> Review: APPROVED`.

→ Bước tiếp (sau APPROVED): `/testkit:cases`.
