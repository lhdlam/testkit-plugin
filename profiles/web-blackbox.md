# Target profile: web-blackbox

> Web app, **KHÔNG có source code, KHÔNG có (hoặc rất ít) tài liệu**. Agent học ứng dụng bằng cách
> **khám phá UI thật trên Staging** qua Playwright MCP, kết hợp mô tả của tester. Runner: **Playwright + TS**,
> test trỏ URL Staging/UAT.

## 5 trục adapter

| Trục | Giá trị |
|---|---|
| **source_of_requirements** | `live_exploration` — agent duyệt Staging, đọc DOM, ghi nhận form/nút/luồng; tester bổ sung domain |
| **source_of_selectors** | `live` — selector lấy trực tiếp từ DOM thật qua **Playwright MCP** |
| **runner** | `playwright` (TypeScript) |
| **execution** | `staging_url` — `baseURL` từ `.env`, `goto()` đường dẫn tương đối |
| **mcp** | **Playwright MCP bắt buộc** (vừa là nguồn hiểu app vừa là nguồn selector) |

## Đặc thù & rủi ro
- Không có "nguồn sự thật" về yêu cầu → **kiến thức domain của tester là tối quan trọng** ở mỗi review.
- Dễ sót luồng ẩn (không có link điều hướng rõ) → tester liệt kê các luồng cần kiểm để agent không bỏ.
- Vẫn giữ truy vết `test → test case`; RTM ở đây map theo **tính năng quan sát được**, không theo REQ tài liệu.

## Layout dự án

```
e2e-tests/
├── docs/                # artifacts: feature-map, test-cases, rtm, ui-map, untestable, scenarios, bugs, env-issues
├── tests/{pages,fixtures,e2e}/
├── .env.staging / .env.uat / .env.example
├── .mcp.json            # Playwright MCP (commit)
├── playwright.config.ts
└── CLAUDE.md
```

## Quy ước bắt buộc (đưa vào CLAUDE.md)
- KHÔNG có code/tài liệu → mọi hiểu biết & selector lấy từ khám phá Staging thật qua Playwright MCP.
- Khi khám phá: **chỉ KHÁM PHÁ, KHÔNG tạo dữ liệu rác / thao tác phá hoại** trên Staging.
- Test trỏ DEPLOY: `goto()` tương đối, `baseURL` từ `.env`, KHÔNG hardcode URL/credential.
- POM; selector `getByRole > getByLabel > getByTestId`. Test độc lập, tự tạo/tự dọn dữ liệu (timestamp).
- Nghi app có bug → ghi `docs/bugs.md`, KHÔNG sửa test cho xanh. Lỗi môi trường → `docs/env-issues.md`.

## Phase 1 — analyze (khám phá Staging)
Playwright MCP mở `{STAGING_URL}`, đăng nhập tài khoản test `.env.staging` nếu cần. Duyệt các màn hình chính,
đọc DOM từng trang → `feature-map.md`: màn hình/route phát hiện + mục đích; form/nút/input + validation quan sát
(khi nhập sai); user flow đi qua được; trạng thái lỗi/edge quan sát được.
> Chỉ khám phá, không tạo dữ liệu rác. KHÔNG viết test ở pha này.

## Phase 2 — generate-cases
Từ `feature-map.md` (đã review + bổ sung domain), sinh test case nhiều loại + `rtm.md` (map theo tính năng quan sát).
Tester rà độ phủ — đây là chỗ domain của tester bù vào chỗ agent thiếu.

## Phase 3 — map-and-scenario
Playwright MCP đi lại từng test case trên UI thật → `ui-map.md` (selector bền vững). Case không khớp → `untestable.md`
`[Tính năng chưa deploy/không tồn tại | UI khác mong đợi]`. Gom `scenarios.md` (Smoke/Regression/Edge).

## Phase 4–6
Như `web-playwright`: POM (selector từ `ui-map.md`), `auth.setup.ts`, `*.spec.ts` truy vết `// TC-xxx`;
run-and-heal phân loại `[Bug | Selector | Timing | Data | Môi trường]`; CI trỏ Staging (smoke/deploy, regression/nightly).

## Khi nào dùng target này
Chọn `web-blackbox` khi **không có repo và không có tài liệu đáng tin**. Nếu có tài liệu → ưu tiên `web-from-docs`
(có RTM truy vết). Nếu có code → `web-playwright`.
