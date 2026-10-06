---
name: using-testkit
description: Use when starting any conversation in a test-automation project, OR when the user types a `/testkit:<name>` slash-command pattern (e.g. `/testkit:init`, `/testkit:analyze`, `/testkit:run`) — establishes the pipeline, target-profile discovery, the review gate, and the slash-command bridge for platforms without native slash discovery (Cursor).
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using testkit

testkit là toolkit để **AI agent viết & bảo trì test automation**, còn framework (Playwright /
pytest-qt) **chạy** test. Bạn (agent) đi qua một pipeline 6 pha, mỗi pha sinh 1 artifact và
**dừng cho con người review** trước khi sang pha sau.

## Nguyên tắc tối thượng (không thương lượng)

1. **Agent viết test, framework chạy test.** Không thao tác UI thủ công thay cho việc viết test.
2. **Tôn trọng review gate.** KHÔNG nhảy sang pha sau khi artifact pha trước chưa `> Review: APPROVED`.
3. **KHÔNG green-washing.** Nghi app có bug → ghi `bugs.md`, tuyệt đối không sửa test/assertion cho xanh.
4. **KHÔNG bịa.** Không bịa yêu cầu (bám code/tài liệu/UI thật), không đoán selector.
5. **User instructions > skill.** CLAUDE.md / yêu cầu trực tiếp của user luôn thắng.
6. **Code sạch để bàn giao khách.** Code sinh ra (test, fix, scaffold) **KHÔNG chứa comment** — không
   comment truy vết, không comment giải thích, không dấu ngày/tên khách. **KHÔNG tự đặt mã định danh**
   (TC-xx, REQ-xx, BUG-xx, OQ-xx): test case nhận diện bằng **Module + tiêu đề mô tả**, và **tên test
   chính là tiêu đề đó**. Truy vết sống trong `rtm.md` (ánh xạ qua file + tên test), KHÔNG nhúng vào code.
   Vẫn **trích dẫn nguồn thật** (`SRS §4.2`, `app/auth.ts:31`) trong **tài liệu** — đó là tham chiếu có
   thật, không phải mã tự bịa.
7. **NGHIÊM CẤM comment tiếng Việt trong code.** Không có ngoại lệ. Phát hiện ở đâu → **XOÁ ngay**.
   (Tài liệu/artifact vẫn viết tiếng Việt theo `lang` — lệnh cấm này chỉ áp cho CODE.)
8. **Dọn rác khi gặp (cleanup-on-sight).** Trong lúc làm tính năng mới hoặc sửa bug, nếu gặp trong code:
   - mã định danh tự đặt (`TC-xx`, `REQ-xx`, `BUG-xx`, `OQ-xx`) → **XOÁ ngay**, không giữ, không đổi sang mã khác;
   - **comment tiếng Việt** → **XOÁ ngay**;
   - comment truy vết/giải thích thừa, ghi chú ngày, tên khách → **XOÁ ngay**;
   - **chỉ thị tắt lint/type-check** — `# noqa`, `# type: ignore`, `# pylint: disable`, `# fmt: off`,
     `// eslint-disable*`, `// @ts-ignore`, `// @ts-nocheck`, `// @ts-expect-error`, `// prettier-ignore`
     → **XOÁ ngay**, rồi **SỬA nguyên nhân thật**. TUYỆT ĐỐI không gắn lại để làm xanh lint; không sửa
     được thì nêu lên cho người quyết — che lỗi bằng suppression chính là green-washing (vi phạm luật #3).
   **Gặp ở ĐÂU thì xoá ở ĐÓ — không giới hạn phạm vi, không hỏi lại, không để "dọn sau".** Thấy trong
   file đang mở, file vô tình đọc qua, hay bất kỳ chỗ nào khác trong repo → xoá luôn ngay lần sửa đó.

> **Ngoại lệ duy nhất của luật #1:** `/testkit:fixbug` được phép **sửa code app** (dev-side) — nhưng chỉ
> sau một **human gate bắt buộc** (hỏi tester + duyệt hướng) và vẫn cấm green-washing (sửa app, không
> làm yếu test). Mọi command khác giữ nguyên: agent viết test, framework chạy test.

## Ngôn ngữ (en/vi)

testkit hỗ trợ 2 ngôn ngữ cho **tài liệu sinh ra** và **giao tiếp hỏi-đáp**. Thứ tự ưu tiên khi xác định `lang`:

1. Yêu cầu trực tiếp của user trong câu hỏi ("trả lời bằng tiếng Anh") — cao nhất.
2. Biến môi trường `TESTKIT_LANG` (`en` | `vi`).
3. File `${TESTKIT_ROOT}/.testkit-lang` (do `/testkit:init` ghi; probe `e2e-tests/docs` rồi `docs`).
4. Mặc định: `vi`.

**Phạm vi áp dụng `lang`:**
- **MỌI artifact** (feature-map, test-cases, rtm, scenarios, ui-map, bugs, env-issues, open-questions...) viết bằng `lang`.
- **MỌI câu trả lời/giải thích/câu hỏi** của agent với user viết bằng `lang`.
- Tiêu đề cột bảng, mô tả test case, Expected Result, nhãn phân loại lỗi → theo `lang`.

**KHÔNG dịch (luôn giữ nguyên):** code, tên biến/hàm/class, từ khoá framework (`getByRole`, `qtbot`, `expect`),
tên file, lệnh shell, tag framework (`@smoke`). Tên test theo convention trong CLAUDE.md.

Đổi ngôn ngữ bất kỳ lúc nào: sửa `.testkit-lang` (1 dòng `en` hoặc `vi`) hoặc `export TESTKIT_LANG=en`.

## Pipeline & skill tương ứng

| Pha | Skill | Artifact | Command |
|---|---|---|---|
| 0 Setup | `setup` | config + CLAUDE.md | `/testkit:init` |
| 1 Hiểu | `analyze-target` | `feature-map.md` | `/testkit:analyze` |
| 2 Test case | `generate-cases` | `test-cases.md` (+ `rtm.md`) | `/testkit:cases` |
| 3 Kịch bản | `map-and-scenario` | `ui-map.md` + `scenarios.md` | `/testkit:scenarios` |
| 4 Script | `generate-script` | POM/Screen Object + spec/test_* | `/testkit:script` |
| 5 Chạy/heal | `run-and-heal` | test xanh + `bugs.md`/`env-issues.md` | `/testkit:run` |
| 6 CI | `setup-ci` | workflow CI | `/testkit:ci` |
| ↻ Incremental | `new-feature` | artifact + test cho 1 feature (`*-feat-xxxx`) | `/testkit:new-feature` |
| ⚙ Helper | (script) | cài Playwright MCP (web: discover/verify selector) | `/testkit:mcp` |
| 👁 Watch | `watch` | chạy test hiển thị (headed) cho người xem/demo/soát case | `/testkit:watch` |
| ❓ Q&A | `question` | hỏi đáp tài liệu/code/artifact — mọi câu trả lời kèm reference | `/testkit:question` |
| 🎯 TC-script | `case-script` | sinh script cho test case cụ thể (gate: test-cases APPROVED) | `/testkit:tc <module \| tiêu đề>` |
| ✅ Nghiệm thu | `review-dev` | review output dev theo test case → verdict từng TC + dev-review.md | `/testkit:review-dev <scope>` |
| 🐞 Fix bug | `fixbug` | chẩn đoán → hỏi tester (gate) → **sửa code app** + regression test → bug-fix-<slug>.md | `/testkit:fixbug <mô tả bug>` |

## Target profile

Mỗi project có MỘT target. Đọc `profiles/<target>.md` trước khi chạy pha — nó định nghĩa
nguồn yêu cầu, nguồn selector, runner, cách thực thi, layout. Target hiện có:
`web-playwright`, `web-from-docs`, `web-blackbox`, `desktop-pyside6`.

**Auto-detect** (hook `session-start.sh` gợi ý, hoặc tự suy):
- có `playwright.config.ts` + repo code → `web-playwright`
- có `pyproject`/`PySide6` + `pytest.ini` → `desktop-pyside6`
- chỉ có `docs/` tài liệu, không có code → `web-from-docs`
- không code, không tài liệu, chỉ có URL → `web-blackbox`

Target được ghi vào `${TESTKIT_ROOT:-e2e-tests/docs}/.testkit-target` lúc `setup`.

## Review gate

Mỗi artifact kết thúc bằng dòng `> Review: PENDING`. Sau khi con người duyệt, đổi thành
`> Review: APPROVED`. Trên **Claude Code**, `hooks/pre-tool-gate.sh` chặn skill pha sau tới khi
pha trước APPROVED. Trên **Cursor**, gate là **advisory** — bạn phải tự kiểm tra dòng `> Review:`
trước khi chạy pha tiếp theo và nhắc user duyệt nếu còn PENDING.

## Slash command bridge (`/testkit:<name>`)

- **Claude Code**: slash auto-discover từ `commands/`. Platform tự gọi.
- **Cursor / nền không có native slash**: khi user gõ `/testkit:<name>`:
  1. Đọc `${TESTKIT_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT}}/commands/<name>.md`
  2. Làm theo nội dung (đa số chỉ wrap một skill cùng tên)
  3. Không có file → fallback invoke skill cùng tên

> Đừng đoán `/testkit:<name>` nghĩa là gì — đọc command file vì nó chứa pre-flight check & argument parsing.
