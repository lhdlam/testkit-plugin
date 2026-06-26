---
name: map-and-scenario
description: Phase 3 — validate selectors against the real UI (ui-map.md) and assemble test cases into end-to-end scenarios (scenarios.md). Use via /testkit:scenarios. Gated — requires test-cases.md APPROVED.
license: MIT
---

# Phase 3 — Map UI & build scenarios

Mục tiêu: xác thực **selector thật** + gom test case thành **kịch bản end-to-end**.

## Pre-flight gate
`${TESTKIT_ROOT:-e2e-tests/docs}/test-cases.md` phải `> Review: APPROVED`. Chưa → DỪNG, nhắc duyệt Phase 2.

## ui-map (tùy target)
- **web-blackbox / web-from-docs** (không có code): dùng Playwright MCP mở `{STAGING_URL}`, đăng nhập
  bằng `.env.staging`, đi qua từng test case trên UI THẬT → ghi `ui-map.md` (TC-ID → [bước → selector/route]).
  Test case không khớp UI → `untestable.md` phân loại: `[Tính năng chưa deploy | UI đã đổi | Tài liệu lệch sản phẩm]`.
- **web-playwright** (có code): suy selector từ code, **verify nhanh** 1-2 luồng qua Playwright MCP trên Staging.
- **desktop-pyside6**: selector = `objectName` đã có trong `feature-map.md`; bước nào mở **modal**
  (QMessageBox/QFileDialog) phải đánh dấu để Phase 4 monkeypatch.

## scenarios.md
Gom test case (bỏ untestable) thành kịch bản E2E. Mỗi kịch bản:
- Scenario ID + tên + nhóm (`Smoke` critical / `Regression` đầy đủ / `Edge`)
- Mô tả hành trình người dùng + test data cần (mô tả, chưa cần giá trị thật)
- Trình tự bước (đánh số), mỗi bước map **TC-ID** (và REQ nguồn nếu có)
- Checkpoint trung gian + trạng thái đầu/cuối
- (desktop) ghi rõ bước nào mở modal

## Kết thúc
`> Review: PENDING` cuối `scenarios.md`. Nhắc user kiểm kịch bản phản ánh đúng hành vi thật + thứ tự nghiệp vụ;
xử lý mục "Tài liệu lệch sản phẩm" trong `untestable.md` (báo team). Đổi thành `> Review: APPROVED`.

→ Bước tiếp: `/testkit:script`.
