# Target profile: web-playwright

> Web app, **có quyền đọc source code** (read-only), test chạy trỏ vào **URL Staging/UAT** đã deploy.
> Runner: **Playwright + TypeScript**. Đây là target mặc định khi project có `playwright.config.ts`.

## 5 trục adapter (pipeline đọc các giá trị này)

| Trục | Giá trị |
|---|---|
| **source_of_requirements** | `code` — agent đọc repo (read-only, KHÔNG build/run) để hiểu route, validation, state |
| **source_of_selectors** | `code+live` — suy từ code, xác thực bằng Playwright MCP mở Staging thật |
| **runner** | `playwright` (TypeScript) |
| **execution** | `staging_url` — `baseURL` từ `.env`, mọi `goto()` dùng đường dẫn TƯƠNG ĐỐI |
| **mcp** | Playwright MCP (tùy chọn nhưng khuyến nghị để verify selector) |

## Layout dự án

```
e2e-tests/
├── docs/            # artifacts pipeline: feature-map, test-cases, rtm, ui-map, scenarios, bugs, env-issues
├── tests/
│   ├── pages/       # Page Object Model — 1 class / màn hình
│   ├── fixtures/    # test data + .auth/ (storageState)
│   └── e2e/         # *.spec.ts
├── .env.staging / .env.uat / .env.example
├── playwright.config.ts
└── CLAUDE.md
```

## Quy ước bắt buộc (đưa vào CLAUDE.md)

- Mọi `goto()` dùng đường dẫn TƯƠNG ĐỐI (`page.goto('/login')`); `baseURL` từ `.env`. KHÔNG hardcode URL.
- KHÔNG hardcode email/mật khẩu → đọc `process.env` / fixtures.
- Page Object Model; selector ưu tiên `getByRole` > `getByLabel` > `getByTestId`. CẤM XPath/CSS brittle.
- Mỗi test độc lập, không phụ thuộc thứ tự.
- Môi trường dùng chung (Staging/UAT): test **tự tạo & tự dọn** dữ liệu (email/SĐT có timestamp ngẫu nhiên),
  KHÔNG xoá/sửa dữ liệu người khác, tránh thao tác phá hoại.
- Tên test: `should [hành vi] when [điều kiện]`. Mỗi assertion có ý nghĩa nghiệp vụ.
- Nghi app có bug → ghi `docs/bugs.md`, KHÔNG sửa test cho xanh.

## Phase 1 — analyze (đọc code)

Đọc repo read-only (KHÔNG build/run). Sinh `docs/feature-map.md`: route/màn hình + mục đích;
form/nút/input + validation rule; user flow chính; luồng lỗi & edge case; điểm phân quyền/bảo mật.

> Nếu KHÔNG có repo → đây không phải target này. Dùng `web-blackbox` (explore Staging) hoặc `web-from-docs`.

## Phase 3 — map-and-scenario

Dùng Playwright MCP mở `{STAGING_URL}`, đăng nhập bằng `.env.staging`, đi qua từng test case để
xác thực selector thật → `docs/ui-map.md`. Test case không khớp UI → `docs/untestable.md`.
Gom thành `docs/scenarios.md` (Smoke/Regression/Edge), mỗi bước map TC-ID.

## Phase 4 — generate-script

1. Page Object trong `tests/pages/` — locator `getByRole/getByLabel`, method hành động, `goto()` tương đối.
2. `tests/auth.setup.ts` — đăng nhập 1 lần, lưu `storageState` vào `tests/fixtures/.auth/user.json`;
   config tái dùng cho mọi project trừ test kiểm tra chính luồng đăng nhập.
3. `tests/e2e/*.spec.ts` — mỗi checkpoint = 1 `expect()`, tag `@smoke/@regression/@edge`,
   comment truy vết `// TC-LOGIN-01`.
4. Chạy thử 1 luồng smoke trỏ Staging để xác nhận selector khớp, KHÔNG tạo dữ liệu rác.

## Phase 5 — run-and-heal (taxonomy phân loại fail)

`TEST_ENV=staging npx playwright test`. Mỗi test fail, đọc trace, phân loại:
`[Bug ứng dụng | Selector sai | Timing/flaky | Test data | Môi trường]`
- **Môi trường** (Staging 5xx/trang trắng/redirect lạ/data drift) → ghi `docs/env-issues.md`, KHÔNG sửa test.
- **Bug ứng dụng** → ghi `docs/bugs.md`, KHÔNG sửa test.
- **Selector/Timing** → sửa test, ưu tiên web-first assertion (auto-wait), KHÔNG `waitForTimeout` cứng.
- **Data drift** → tăng độ độc lập dữ liệu (tự sinh dữ liệu riêng), không tăng timeout.
Cho phép `retries: 2` vì Staging chập chờn hơn local.

## Phase 6 — setup-ci

Workflow GitHub Actions trỏ Staging/UAT: `BASE_URL`/credential từ Secrets;
trigger nightly + thủ công + sau deploy; `@smoke` mỗi deploy, full regression nightly.

## Lệnh chạy

```bash
TEST_ENV=staging npx playwright test                 # full
TEST_ENV=staging npx playwright test --grep @smoke   # chỉ smoke
npx playwright show-trace                             # đọc trace khi fail
```
