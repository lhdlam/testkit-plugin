---
name: watch
description: Run tests in VISIBLE (headed) mode so a human can watch the UI being driven — for demos and reviewing case coverage. Web → Playwright headed / UI mode / slow-mo; desktop → pytest-qt on-screen + UI_SLOWMO. Not for CI (CI stays headless).
license: MIT
---

# Watch mode — chạy test cho người xem (headed)

Mục tiêu: chạy test ở chế độ **hiển thị thật** để con người nhìn UI thao tác — dùng để demo và soát xem
các case có cover đúng hành vi không. Đây KHÔNG phải chế độ CI (CI luôn headless — xem `setup-ci`).

> Đọc target từ `${TESTKIT_ROOT}/.testkit-target` (probe `e2e-tests/docs` rồi `docs`). Cần máy có màn hình.

## web-* (Playwright)

**Cách tốt nhất để soát case — Playwright UI mode** (time-travel, chọn test, xem từng bước, watch on save):
```bash
cd e2e-tests && TEST_ENV=staging npx playwright test --ui
```

**Chạy headed (mở trình duyệt thật), 1 luồng, chậm để mắt kịp nhìn:**
```bash
TEST_ENV=staging SLOWMO=500 npx playwright test --headed --workers=1 --grep @smoke
# 1 test cụ thể:
TEST_ENV=staging SLOWMO=800 npx playwright test --headed tests/e2e/login.spec.ts -g "valid"
```
> `SLOWMO` được đọc trong `playwright.config.ts` (`launchOptions.slowMo`). Mặc định 0 (không ảnh hưởng CI/headless).

**Bước từng dòng để soi (Inspector):**
```bash
TEST_ENV=staging npx playwright test --debug -g "valid"   # hoặc PWDEBUG=1
```

**Xem lại sau khi chạy (trace time-travel):**
```bash
TEST_ENV=staging npx playwright test --trace on && npx playwright show-trace
```

Khuyến nghị khi demo: `--workers=1` (chạy tuần tự, dễ theo dõi) + `SLOWMO` + chỉ 1 nhóm `--grep`.

## desktop-pyside6 (pytest-qt)

**Hiển thị app thật (KHÔNG offscreen/xvfb):**
```bash
pytest -s -v tests/test_login.py::test_login_success
```
**Slow-mo** (Screen Object dùng `UI_SLOWMO` qua `qtbot.wait` — xem template `LoginScreen.py`):
```bash
UI_SLOWMO=500 pytest -s tests/test_login.py        # mỗi thao tác dừng 500ms
```
**Tạm dừng để quan sát / tương tác tay:** chèn `qtbot.stop()` trong test — cửa sổ giữ nguyên tới khi đóng.
Lưu ý: chạy 1 test hoặc 1 nhóm nhỏ (`-m smoke`), đừng chạy cả suite; nhớ `window.show()`.

## Soát coverage trong lúc xem
Vừa xem vừa đối chiếu `test-cases.md`/`rtm.md`: case nào chưa có, hành vi nào chưa khớp Expected →
ghi lại; bug thật → `bugs.md` (KHÔNG sửa test cho xanh). Có thể dispatch agent `coverage-auditor`
để liệt kê gap sau buổi xem.

> CI vẫn LUÔN headless — watch mode chỉ để debug/demo trên máy có màn hình.
