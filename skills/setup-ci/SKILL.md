---
name: setup-ci
description: Phase 6 — generate a CI workflow (GitHub Actions) that runs the suite headless / against Staging, reading secrets from the CI store. Use via /testkit:ci.
license: MIT
---

# Phase 6 — Setup CI/CD

Mục tiêu: test tự chạy mỗi lần có code mới / theo lịch, máy tester chỉ viết & review.

## web-* (Playwright trỏ Staging/UAT)
Workflow `.github/workflows/e2e-tests.yml`:
- Trigger: nightly (cron) + thủ công (`workflow_dispatch`) + sau deploy.
- `BASE_URL` + credential từ **Secrets** (KHÔNG commit `.env.*`).
- `npx playwright install --with-deps chromium`.
- `@smoke` chạy nhanh mỗi deploy; full regression nightly.
- Upload `playwright-report/` làm artifact.
- `retries: 2` (config) vì Staging chập chờn.

## desktop-pyside6 (headless)
Workflow `.github/workflows/desktop-tests.yml`:
- Trigger: pull_request + push nhánh chính.
- Linux: cài `xvfb libxkbcommon-x11-0 libegl1`; chạy `xvfb-run --auto-servernum pytest -q`
  với `QT_QPA_PLATFORM=offscreen`. Windows/macOS runner có desktop → `pytest` thẳng.
- Cài deps từ `requirements-dev.txt`. Fail pipeline nếu có test đỏ.

## Lấy template
Đọc `${TESTKIT_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT}}/templates/ci-<target>.yml.template`, điền theo project, ghi vào `.github/workflows/`.

## Kết thúc
Báo user: cấu hình Secrets nào cần đặt (BASE_URL, TEST_USER_*), lịch chạy đề xuất. Pipeline hoàn tất.
