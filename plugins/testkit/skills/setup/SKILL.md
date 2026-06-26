---
name: setup
description: Phase 0 — scaffold a test-automation project, pick the target profile, and write CLAUDE.md / .cursor rules + runner config. Use at the start of a testkit pipeline or via /testkit:init.
license: MIT
---

# Phase 0 — Setup

Mục tiêu: chuẩn bị dự án test, **chốt target**, sinh quy ước (CLAUDE.md + Cursor rules) và config runner.

## Bước 1 — Xác định target

Hỏi user (AskUserQuestion) nếu chưa rõ; hoặc auto-detect:
- `playwright.config.ts` + có repo code → **web-playwright**
- có `docs/` tài liệu, không có code → **web-from-docs**
- chỉ có URL Staging, không code/không tài liệu → **web-blackbox**
- `PySide6` + `pytest.ini`/`pyproject` → **desktop-pyside6**

**Đọc `${TESTKIT_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT}}/profiles/<target>.md`** — nó quyết định toàn bộ các pha sau.

## Bước 1b — Chọn ngôn ngữ (en/vi)

Hỏi user (AskUserQuestion) ngôn ngữ cho **tài liệu sinh ra + giao tiếp hỏi-đáp**:
- `vi` — Tiếng Việt (mặc định)
- `en` — English

Ghi nhớ lựa chọn này; nó được dùng ở Bước 3 (CLAUDE.md) và Bước 4 (.testkit-lang), và mọi pha sau tuân theo
(xem `using-testkit` → "Ngôn ngữ"). Nếu user không quan tâm → mặc định `vi`.

## Bước 2 — Scaffold theo layout của profile

**web-* targets:**
```bash
mkdir -p e2e-tests && cd e2e-tests
npm init playwright@latest        # chọn TypeScript, thư mục tests, thêm GitHub Actions
npm i -D dotenv
```
Tạo `e2e-tests/docs/`, `.env.staging`/`.env.uat`/`.env.example`, `.gitignore` (bỏ `.env.*`, `node_modules`, `playwright-report`, `tests/fixtures/.auth/`).
Cài Playwright MCP (then chốt cho black-box/from-docs):
```bash
claude mcp add playwright npx @playwright/mcp@latest --scope project   # tạo .mcp.json (commit)
```
**web-from-docs**: tạo thêm `e2e-tests/input/docs/` và nhắc user bỏ TẤT CẢ tài liệu dự án (pdf/docx/md/slide) vào đó.

**desktop-pyside6:**
```bash
python -m venv .venv && source .venv/bin/activate
pip install pytest pytest-qt
```
Tạo `pytest.ini` (`qt_api = pyside6`), thư mục `tests/{screens,fixtures}`, `docs/`.

## Bước 3 — Sinh quy ước

1. Đọc template `${TESTKIT_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT}}/templates/CLAUDE.md.<target>.template`,
   điền theo project, ghi ra `CLAUDE.md` ở gốc dự án test.
   - **Theo `lang` đã chọn:** nếu `lang=en`, dịch nội dung template sang tiếng Anh khi ghi CLAUDE.md (template gốc là tiếng Việt); nếu `vi`, giữ nguyên.
   - Thêm vào đầu CLAUDE.md một dòng directive: `- Ngôn ngữ tài liệu & giao tiếp: <lang> (đổi trong .testkit-lang).`
     (en: `- Output & chat language: <lang> (change in .testkit-lang).`) — để mọi phiên Claude tự áp dụng vì CLAUDE.md luôn được đọc.
2. **Cursor**: copy template `${TESTKIT_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT}}/templates/cursor-rules.testkit.mdc.template`
   → `.cursor/rules/testkit.mdc` (frontmatter `alwaysApply: true`). File này gộp cả quy ước + slash bridge
   (user gõ `/testkit:X` → đọc `commands/X.md`) + nhắc gate là **advisory** trên Cursor. Đồng bộ phần "Quy ước"
   với `CLAUDE.md` của target (cùng nguồn — đừng để lệch).
3. Copy `playwright.config.ts` / `pytest.ini` từ templates nếu chưa có.

## Bước 4 — Ghi target & khởi tạo state

Artifacts root theo target: **web-*** → `e2e-tests/docs`; **desktop-pyside6** → `docs` (test chung repo app).
Override bằng `TESTKIT_ROOT`. Hook tự dò cả hai vị trí.

```bash
ROOT="${TESTKIT_ROOT:-e2e-tests/docs}"   # desktop-pyside6: ROOT=docs
mkdir -p "$ROOT"
printf '%s\n' "<target>" > "$ROOT/.testkit-target"
printf '%s\n' "<lang>"   > "$ROOT/.testkit-lang"     # en | vi (mặc định vi)
```

## Đầu ra
Dự án sẵn sàng + `CLAUDE.md` (kèm directive ngôn ngữ) + (Cursor) `.cursor/rules/` + config runner +
`.testkit-target` + `.testkit-lang`.
Báo user (bằng `lang` đã chọn) các thông tin còn thiếu: URL Staging/UAT, tài khoản test, (from-docs) thư mục tài liệu.

→ Bước tiếp: `/testkit:analyze`.
