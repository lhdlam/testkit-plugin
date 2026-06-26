---
name: generate-cases
description: Phase 2 — turn feature-map.md into structured test cases (positive/negative/boundary/permission) plus a requirements traceability matrix (rtm.md). Use via /testkit:cases. Gated — requires feature-map.md APPROVED.
license: MIT
---

# Phase 2 — Generate test cases

Mục tiêu: biến `feature-map.md` thành test case có cấu trúc, phủ đủ loại + **ma trận truy vết (RTM)**.

## Pre-flight gate
Kiểm tra `${TESTKIT_ROOT:-e2e-tests/docs}/feature-map.md` có dòng `> Review: APPROVED`.
Nếu chưa → DỪNG, nhắc user duyệt Phase 1 trước. (Claude Code: hook cũng chặn; Cursor: bạn tự kiểm.)

## Sinh `test-cases.md`
Bảng mỗi test case:
```
| ID | REQ nguồn | Module | Tiêu đề | Loại | Precondition | Steps | Expected Result | Priority |
```
- Loại: `Positive | Negative | Boundary | Permission | Error-handling` (desktop thêm `State`: enabled/disabled, điều hướng, modal).
- Phủ: happy path mọi luồng chính; negative (sai định dạng, bỏ trống bắt buộc, vượt giới hạn);
  boundary (min/max, ký tự đặc biệt); permission (truy cập trái phép, hết phiên).
- Priority theo rủi ro nghiệp vụ: P1 critical → P3 low.
- **Chống bịa**: mỗi test case phải bắt nguồn từ một mục trong feature-map. Ý tưởng ngoài tài liệu/code
  → để riêng mục cuối "Đề xuất ngoài phạm vi" cho tester duyệt.

## Sinh `rtm.md` (ma trận truy vết)
```
| REQ/Mục | Mô tả ngắn | Nguồn | Test case phủ | Trạng thái phủ |
```
Đánh dấu rõ mục nào **CHƯA có test case** (gap) để tester thấy độ phủ khách quan.

> RTM là công cụ chống-sót then chốt — đừng bỏ qua.

## Tùy chọn — kiểm độ phủ bằng subagent
Sau khi sinh `rtm.md`, có thể dispatch agent `coverage-auditor` (Agent tool) để đo độ phủ khách quan:
nó liệt kê yêu cầu **0 test case** (High), case chỉ happy-path (Medium), và case **bịa** (cite REQ không có
trong feature-map). Đính kèm tóm tắt vào cuối `rtm.md` cho tester.

## Kết thúc
Thêm `> Review: PENDING` cuối `test-cases.md`. Nhắc user kiểm 2 chiều: chống bịa (bám nguồn) +
chống sót (đọc `rtm.md`), bổ sung case nghiệp vụ đặc thù, rồi đổi thành `> Review: APPROVED`.

→ Bước tiếp: `/testkit:scenarios`.
