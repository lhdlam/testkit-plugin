---
name: run-and-heal
description: Phase 5 — run the test suite, classify every failure (Bug | Selector | Timing | Data | Env | Doc-drift), self-heal only genuine test issues, and route real bugs to bugs.md. Use via /testkit:run.
license: MIT
---

# Phase 5 — Run, verify & self-heal

Mục tiêu: test **xanh ổn định, không flaky** — và KHÔNG che giấu bug thật.

> **Ngôn ngữ:** `bugs.md`/`env-issues.md` + báo cáo viết theo `lang` (`.testkit-lang`/`TESTKIT_LANG`, mặc định `vi`).

## Lệnh chạy (theo target)
- web-*: `TEST_ENV=staging npx playwright test --reporter=list` (đọc trace: `npx playwright show-trace`).
- desktop: `QT_QPA_PLATFORM=offscreen pytest -q` (Linux không offscreen: `xvfb-run --auto-servernum pytest -q`).

## Vòng lặp phân loại fail (BẮT BUỘC phân loại trước khi sửa)

Với mỗi test fail, đọc trace/log rồi phân loại:

| Nhóm | Dấu hiệu | Hành động |
|---|---|---|
| **Bug ứng dụng** | sản phẩm chạy sai nghiệp vụ | **KHÔNG sửa test** → ghi `docs/bugs.md` |
| **Doc-drift** (from-docs) | sản phẩm khác tài liệu | KHÔNG sửa test → `bugs.md` (bug HOẶC tài liệu lỗi thời) |
| **Môi trường** | Staging 5xx/trang trắng/redirect lạ/data drift | KHÔNG sửa test → `docs/env-issues.md` |
| **Selector sai** | locator không khớp UI | sửa test, selector bền vững (getByRole/objectName) |
| **Timing/flaky** | chờ chưa đủ | web-first assertion / `qtbot.waitUntil` — KHÔNG `sleep`/`waitForTimeout` cứng |
| **Test data** | đụng dữ liệu chung | tăng độc lập: tự sinh dữ liệu riêng (timestamp), tự dọn |
| **(desktop) modal chặn** | test treo ở dialog | `monkeypatch` giá trị trả về |
| **(desktop) chỉ fail headless** | render phụ thuộc màn hình | sửa để chạy `offscreen`/xvfb |

> Hai luật cứng: (1) **KHÔNG sửa test cho xanh khi nghi app có bug.**
> (2) **Flaky do data drift** chữa bằng dữ liệu độc lập, KHÔNG bằng tăng timeout.

## Tùy chọn — dùng subagent (khi có)
- `failure-classifier`: phân loại hàng loạt fail và route sang `bugs.md`/`env-issues.md`.
- `test-integrity`: quét diff test xem có assertion bị làm yếu / expected bị sửa cho khớp actual.

## Kết thúc
Tóm tắt: tổng pass/fail/skip; từng fix theo nhóm; danh sách mục đã ghi `bugs.md`/`env-issues.md`.
Test xanh ổn định → `/testkit:ci`.
