---
name: fixbug
description: Diagnose and fix ONE application bug — analyze the bug against code + spec (with source citations), ask the tester clarifying questions at a hard human gate, then fix the app code and add a regression test that reproduces the bug (red before, green after). Use via /testkit:fixbug <bug content | BUG-ID>. The one testkit command that edits the app under test.
license: MIT
---

# Fixbug — chẩn đoán & sửa 1 bug ứng dụng

Mục tiêu: từ mô tả 1 bug → **định vị nguyên nhân gốc** trong code + tài liệu, **hỏi tester** những gì
còn mơ hồ, **sửa code app** đúng root cause, và **luôn** để lại 1 regression test tái hiện bug để nó
không tái phát.

> **Đây là command DUY NHẤT của testkit chạm vào code sản phẩm** (mở rộng có chủ đích sang dev-side).
> An toàn nằm ở **human gate bắt buộc**: không sửa 1 dòng code nào trước khi tester trả lời câu hỏi và
> duyệt hướng sửa.

## Luật cứng (không thương lượng)

1. **Gate trước khi sửa.** Bước 2 phải DỪNG lại, đặt câu hỏi + trình hướng sửa, và chờ user trả lời +
   OK. Tuyệt đối không edit code app trước đó.
2. **KHÔNG green-washing.** Sửa **APP** cho test xanh — KHÔNG bao giờ làm yếu/xoá assertion hay hạ
   Expected để khớp app sai. Regression test phải **thật sự** tái hiện bug: đỏ trước fix, xanh sau fix.
3. **KHÔNG bịa.** Mọi nhận định về hành vi đúng/sai đều kèm reference (`[SRS §x]`, `[file:line]`,
   `[bugs.md → BUG-ID]`). Không định vị được nguyên nhân → nói thẳng và hỏi, đừng đoán bừa.
4. **Sửa root cause, không vá triệu chứng.** Diff nhỏ nhất, theo convention trong `CLAUDE.md`.
5. **Lỗi ở tài liệu, không phải code → không sửa code.** Nếu spec lỗi thời/mâu thuẫn khiến "bug" thực ra
   là kỳ vọng sai, ghi `open-questions.md` và để tester/BA phân xử — đừng sửa app cho khớp một spec sai.
6. **Ngôn ngữ:** giao tiếp + artifact theo `lang` (`.testkit-lang` / `TESTKIT_LANG`, mặc định `vi`).
   Code, định danh (`BUG-LOGIN-03`, `REQ-012`, tag `@regression`), từ khoá framework giữ tiếng Anh.

## Bước 0 — Đầu vào & nhận dạng
- Arg = **nội dung bug** (mô tả tự do) HOẶC **`BUG-ID`** đã có trong `bugs.md`. Không có arg → hỏi lại
  nội dung bug, đừng tự chọn bug.
- Đọc `${TESTKIT_ROOT:-e2e-tests/docs}/.testkit-target` và `profiles/<target>.md` (nguồn yêu cầu, nguồn
  selector, runner, cách thực thi). Đọc `.testkit-lang`.
- Nếu arg là BUG-ID → load nguyên entry trong `bugs.md` (repro, expected vs actual, TC/REQ). Nếu là mô
  tả tự do → suy ra `bug-id` dạng `BUG-<MODULE>-nn` (module lấy từ màn hình/tính năng liên quan).

## Bước 1 — Định vị & khoanh vùng nguyên nhân (KHÔNG sửa gì)
Áp dụng tinh thần systematic-debugging: hiểu trước khi sửa.
- Chốt **expected vs actual**: bug nói app làm sai gì so với điều gì.
- **Nguồn yêu cầu (spec):** tìm REQ/mục tài liệu định nghĩa hành vi đúng — trích `[SRS §4.2]`. Với target
  `web-from-docs`/dual-input, tài liệu là chuẩn; với `web-playwright`/`desktop`, đọc code là chính,
  tài liệu (nếu có) để cross-check.
- **Nguồn hiện thực (code):** tìm ĐÚNG chỗ phát sinh hành vi sai (`file:line`). Chỉ đọc vùng liên đới,
  không quét cả repo. `web-blackbox` không có code → dựng repro qua Playwright MCP trên Staging.
- **Cross-check 3 chiều** code ↔ spec ↔ bug, rồi phân định:
  | Phân định | Nghĩa | Hành động |
  |---|---|---|
  | **App bug thật** | code lệch spec / lệch hành vi hợp lý | sửa được → tiếp Bước 2 |
  | **Spec/doc lỗi** | "bug" do kỳ vọng/tài liệu sai, code đúng | KHÔNG sửa code → `open-questions.md` + hỏi |
  | **Không tái hiện được** | thiếu dữ kiện (env/data/bước) | hỏi ở Bước 2, chưa kết luận |
  | **Test/env issue** | thực ra là selector/timing/môi trường | route như Phase 5 (`bugs.md`/`env-issues.md`), không phải việc của fixbug |
- Viết **root-cause hypothesis** kèm bằng chứng có reference. Không đủ dữ kiện → ghi rõ cái còn thiếu.

## Bước 2 — Đặt câu hỏi cho tester (HUMAN GATE — bắt buộc, dừng ở đây)
Trước khi chạm code, trình bày gọn cho user và **chờ trả lời**:
1. **Câu hỏi** cho mọi chỗ mơ hồ: hành vi kỳ vọng chính xác là gì? REQ nào là chuẩn nếu code≠tài liệu?
   tái hiện trên env/data nào? phạm vi ảnh hưởng nào chấp nhận được?
2. **Nhận định** root cause (kèm reference) — đây là app bug hay spec issue.
3. **Hướng sửa đề xuất** + **file sẽ đổi** + **blast radius/rủi ro** (còn gì dùng chung đoạn code đó).
4. Nếu là spec issue → nêu rõ "sẽ KHÔNG sửa code, đề xuất cập nhật tài liệu", chờ BA/tester quyết.

DỪNG. Không tiếp Bước 3 tới khi user trả lời câu hỏi và duyệt hướng sửa.

## Bước 3 — Sửa code app (chỉ sau khi được duyệt)
- Sửa **nguyên nhân gốc**, diff tối thiểu, khớp style/convention trong `CLAUDE.md` và code xung quanh.
- Không ôm đồm refactor ngoài phạm vi bug. Đụng nhiều nơi → nêu lý do.
- Nếu Bước 2 kết luận là spec issue → **không sửa code**; hoàn tất ở việc ghi `open-questions.md` +
  đề xuất chỉnh tài liệu, rồi sang Bước 6 (bỏ qua regression test cho code).

## Bước 4 — Regression test (LUÔN — đóng vòng lặp bug)
Sinh test tái hiện bug theo convention của `generate-script` + `profiles/<target>.md`:
- Test **phải đỏ trước fix, xanh sau fix** — nêu rõ điều này trong mô tả/summary; nếu không thể làm nó
  đỏ trên code cũ thì nó chưa tái hiện đúng bug, xem lại root cause.
- **web**: thêm vào `tests/e2e/` (hoặc file module tương ứng), tag `@regression` + `@bug-<id>`, comment
  truy vết `// BUG-LOGIN-03 / REQ-012`. Selector bền vững (`getByRole/Label/TestId`).
- **desktop-pyside6**: `@pytest.mark.regression`, đăng ký marker trong `pytest.ini`, comment `# BUG-...`;
  selector qua `objectName`; modal → `monkeypatch`.
- Gắn truy vết vào `rtm.md`: BUG-id ↔ REQ ↔ test (đánh dấu `[automated]`).
- (Khuyến nghị) dispatch subagent `test-integrity` trên diff test để chắc không có green-washing
  (assertion bị làm yếu, expected sửa cho khớp actual).

## Bước 5 — Xác minh (evidence trước khi tuyên bố)
- Chạy đúng regression test + test liên quan:
  - web: `TEST_ENV=staging npx playwright test --grep @bug-<id>` (rồi mở rộng module liên quan).
  - desktop: `QT_QPA_PLATFORM=offscreen pytest -q -m regression -k <module>`.
- Xác nhận: regression test **đỏ→xanh**, và **không làm vỡ** test khác. Còn đỏ → CHƯA xong, quay lại
  Bước 3/1, tuyệt đối không tuyên bố đã fix.
- Báo cáo output thật (số pass/fail), không tô hồng.

## Bước 6 — Ghi nhận
- `${TESTKIT_ROOT}/bug-fix-<id>.md`:
  ```
  # Bug fix: BUG-LOGIN-03 — <tiêu đề> — <ngày>
  ## Nội dung bug
  ## Nguyên nhân gốc      (kèm reference: [SRS §x], [file:line])
  ## Thay đổi              (file đã sửa + tóm tắt; hoặc "spec issue — không sửa code")
  ## Regression test       (đường dẫn + tag; đỏ trước / xanh sau)
  ## Xác minh              (lệnh + kết quả pass/fail)
  > Review: PENDING
  ```
- Cập nhật `bugs.md`: entry của bug → trạng thái **Fixed** + link tới `bug-fix-<id>.md` (+ commit nếu có).
- Nhắc bước sau: tester duyệt `bug-fix-<id>.md`; muốn chốt trên CI → `/testkit:run` rồi `/testkit:ci`.

## Đầu ra
Code app đã sửa (hoặc `open-questions.md` nếu là spec issue) + 1 regression test tag `@bug-<id>` gắn
`rtm.md` + `bug-fix-<id>.md` (`> Review: PENDING`) + `bugs.md` entry chuyển Fixed.
