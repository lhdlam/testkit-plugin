# Target profile: desktop-pyside6

> App desktop **Python + PySide6**, **đã có source code**. Test chạy **in-process** qua pytest-qt
> (KHÔNG trình duyệt, KHÔNG URL Staging — app được import & điều khiển ngay trong tiến trình test).
> Runner: **pytest + pytest-qt**. Đây là target mặc định khi có `pytest.ini` (qt_api=pyside6) / `PySide6`.

## 5 trục adapter (pipeline đọc các giá trị này)

| Trục | Giá trị |
|---|---|
| **source_of_requirements** | `code` — đọc repo read-only (KHÔNG chạy app) để hiểu cây widget, signal/slot, validate |
| **source_of_selectors** | `code` — "selector" = `objectName` của widget (`findChild(QType, "objectName")`), tương đương data-testid |
| **runner** | `pytest-qt` (fixture `qtbot`) |
| **execution** | `in_process` — test import cửa sổ app, điều khiển qua `qtbot`; headless qua `QT_QPA_PLATFORM=offscreen`/xvfb |
| **mcp** | KHÔNG cần (không có trình duyệt) |

## Layout dự án (test nằm CHUNG repo với app)

```
desktop-app/
├── app/                 # SOURCE — đọc ở Phase 1 (main_window.py, screens/, ...)
├── tests/
│   ├── conftest.py      # fixture dùng chung (tạo MainWindow, cô lập trạng thái)
│   ├── screens/         # Screen Object — 1 class / cửa sổ-dialog
│   ├── fixtures/        # dữ liệu test
│   └── test_*.py        # đầu ra Phase 4
├── docs/                # artifacts pipeline: feature-map, missing-object-names, test-cases, rtm, scenarios, bugs
├── pytest.ini           # qt_api = pyside6
├── requirements-dev.txt
└── CLAUDE.md
```

> **Artifacts ở `docs/`** (không phải `e2e-tests/docs/`). Setup ghi `.testkit-target` vào `docs/`;
> hook tự dò vị trí này. Nếu muốn override: `export TESTKIT_ROOT=docs`.

## Quy ước bắt buộc (đưa vào CLAUDE.md)

- Framework: pytest + pytest-qt; ép `qt_api = pyside6` trong `pytest.ini`.
- Tương tác qua `qtbot` (`mouseClick`, `keyClicks`, `addWidget`).
- **TUYỆT ĐỐI KHÔNG `time.sleep`** — chờ bằng `qtbot.waitSignal` / `qtbot.waitUntil`.
- Tìm widget bằng `objectName`: `window.findChild(QType, "objectName")`. Widget thiếu objectName → ghi
  `docs/missing-object-names.md` đề xuất bổ sung, **KHÔNG** dò theo chỉ số/thứ tự con (rất dễ gãy).
- Hộp thoại **MODAL** (QMessageBox, QFileDialog) chặn event loop → PHẢI `monkeypatch` thay vì mở thật (nếu không test treo).
- Cô lập trạng thái: `tmp_path` cho file, patch `QSettings`, mock DB/network. Mỗi test độc lập.
- Mỗi test tạo cửa sổ mới + `qtbot.addWidget` để tự dọn. Test phải chạy được **headless**.
- Nghi app có bug → ghi `docs/bugs.md`, KHÔNG sửa test cho xanh.

## Phase 1 — analyze (đọc code + audit objectName)

Đọc `app/` read-only (KHÔNG chạy app). `feature-map.md`: lớp UI (QMainWindow/QDialog/QWidget) + mục đích;
mỗi màn hình → widget tương tác + `objectName` + kiểu widget; map signal/slot (thao tác → hàm → hành vi);
quy tắc validate, điều hướng (QStackedWidget), trạng thái lỗi.
Phụ: **`missing-object-names.md`** — widget tương tác thiếu objectName + đề xuất tên (khoản đầu tư đáng giá nhất cho độ ổn định).

## Phase 3 — scenarios

Không "khám phá UI live" (đã có code). Selector = objectName từ feature-map. Gom test case thành kịch bản E2E;
**ghi rõ bước nào mở modal** (Phase 4 sẽ monkeypatch).

## Phase 4 — generate-script (pytest-qt)

1. **Screen Object** trong `tests/screens/` — `findChild(QType, "objectName")`, method thao tác (`login()`, `add_task()`).
2. **conftest.py** — fixture tạo MainWindow mới mỗi test (`qtbot.addWidget`); fixture `tmp_path`/patch `QSettings` cô lập trạng thái.
3. **`test_*.py`** — mỗi checkpoint = 1 `assert`; chờ bằng `qtbot.waitUntil/waitSignal` (KHÔNG sleep);
   modal → `monkeypatch` giá trị trả về; marker `@pytest.mark.smoke/regression/edge`; comment `# TC-LOGIN-01`.
4. Chạy thử `QT_QPA_PLATFORM=offscreen pytest -q` xác nhận.

## Phase 5 — run-and-heal (taxonomy phân loại fail)

`QT_QPA_PLATFORM=offscreen pytest -q` (Linux không offscreen: `xvfb-run --auto-servernum pytest -q`). Phân loại:
`[Bug ứng dụng | Không tìm thấy widget (objectName) | Timing (thiếu waitUntil) | Modal chặn | Rò rỉ trạng thái | Chỉ fail headless]`
- **Bug ứng dụng** → `docs/bugs.md`, KHÔNG sửa test.
- **objectName** → kiểm tra; app thiếu → `docs/missing-object-names.md`, KHÔNG dò theo chỉ số.
- **Timing** → `qtbot.waitUntil/waitSignal`, KHÔNG sleep. **Modal** → monkeypatch. **Rò rỉ** → `tmp_path`/patch.
> pytest-qt **tự bắt exception trong slot + qWarning/qCritical** rồi fail test — tận dụng để lộ bug ngầm.

## Phase 6 — setup-ci (headless)

GitHub Actions: trigger PR + push nhánh chính; Linux cài `xvfb libxkbcommon-x11-0 libegl1`;
chạy `xvfb-run --auto-servernum pytest -q` (`QT_QPA_PLATFORM=offscreen`). Windows/macOS runner có desktop → `pytest` thẳng.

## Lệnh chạy

```bash
QT_QPA_PLATFORM=offscreen pytest -q              # full headless
pytest -q -m smoke                               # chỉ smoke
pytest -s -v tests/test_login.py                 # quan sát UI (cần màn hình, debug/demo)
UI_SLOWMO=500 pytest -s tests/test_login.py      # slow-mo (nếu Screen Object hỗ trợ)
```

## Hai tầng test (khuyến nghị)
Tách logic nghiệp vụ khỏi UI → test logic bằng pytest thường (nhanh, bền); chỉ dùng pytest-qt cho hành vi UI & luồng người dùng.
