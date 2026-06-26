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

**desktop-pyside6:**
```bash
python -m venv .venv && source .venv/bin/activate
pip install pytest pytest-qt
```
Tạo `pytest.ini` (`qt_api = pyside6`), thư mục `tests/{screens,fixtures}`, `docs/`.

## Bước 3 — Sinh quy ước

1. Đọc template `${TESTKIT_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT}}/templates/CLAUDE.md.<target>.template`,
   điền theo project, ghi ra `CLAUDE.md` ở gốc dự án test.
2. **Cursor**: mirror cùng nội dung sang `.cursor/rules/testkit.mdc` (frontmatter `alwaysApply: true`)
   + `.cursor/rules/testkit-slash.mdc` (bridge: "user gõ /testkit:X → đọc commands/X.md").
3. Copy `playwright.config.ts` / `pytest.ini` từ templates nếu chưa có.

## Bước 4 — Ghi target & khởi tạo state

```bash
mkdir -p "${TESTKIT_ROOT:-e2e-tests/docs}"
printf '%s\n' "<target>" > "${TESTKIT_ROOT:-e2e-tests/docs}/.testkit-target"
```

## Đầu ra
Dự án sẵn sàng + `CLAUDE.md` + (Cursor) `.cursor/rules/` + config runner + `.testkit-target`.
Báo user các thông tin còn thiếu cần cung cấp: URL Staging/UAT, tài khoản test, (from-docs) thư mục tài liệu.

→ Bước tiếp: `/testkit:analyze`.
