# Target profile: web-from-docs

> Web app, **KHÔNG có source code**. Đầu vào là **toàn bộ tài liệu dự án** (SRS/BRD, user story, API docs,
> slide, wiki...). Agent **tự sinh test case** từ tài liệu, rồi đối chiếu UI thật trên Staging để lấy selector.
> Runner: **Playwright + TypeScript**, test trỏ URL Staging/UAT.

## 5 trục adapter

| Trục | Giá trị |
|---|---|
| **source_of_requirements** | `docs` — đọc `input/docs/` (mọi định dạng), trích yêu cầu `REQ-xxx` có nguồn (tài liệu + mục) |
| **source_of_selectors** | `live` — KHÔNG có code → selector lấy từ khám phá Staging thật qua **Playwright MCP** (then chốt) |
| **runner** | `playwright` (TypeScript) |
| **execution** | `staging_url` — `baseURL` từ `.env`, `goto()` đường dẫn tương đối |
| **mcp** | **Playwright MCP bắt buộc** (Phase 3 dựa hẳn vào nó để map selector) |

## Hai rủi ro đặc thù (vì agent diễn giải tài liệu)
1. **Bịa yêu cầu** không có trong tài liệu → ép mỗi test case truy vết về `REQ-xxx` + nguồn; ý ngoài tài liệu để mục riêng.
2. **Bỏ sót yêu cầu** → dùng **RTM** (`rtm.md`) đo độ phủ khách quan, đánh dấu REQ chưa phủ.
> Phủ **yêu cầu**, không phủ tài liệu. Đo bằng RTM, không đếm số trang.

## Layout dự án

```
e2e-tests/
├── input/docs/          # TẤT CẢ tài liệu dự án (pdf, docx, md, slide...) — bạn bỏ vào đây
├── docs/                # artifacts: feature-map, open-questions, test-cases, rtm, ui-map, untestable, scenarios, bugs, env-issues
├── tests/{pages,fixtures,e2e}/
├── .env.staging / .env.uat / .env.example
├── .mcp.json            # Playwright MCP (commit, cả team dùng)
├── playwright.config.ts
└── CLAUDE.md
```

## Quy ước bắt buộc (đưa vào CLAUDE.md) — trọng tâm chống bịa
- Nguồn yêu cầu: `input/docs/`. Sinh test case BÁM SÁT tài liệu, **KHÔNG bịa** yêu cầu không có trong tài liệu.
  Thiếu/mâu thuẫn → ghi `docs/open-questions.md`, KHÔNG tự suy diễn.
- Mỗi test case truy vết về nguồn (tài liệu + mục) trong `rtm.md`. Comment trong code: `// TC-005 ← REQ-012 ← SRS §4.2`.
- KHÔNG có source code → mọi selector lấy từ khám phá Staging thật qua Playwright MCP, KHÔNG đoán.
- Test trỏ DEPLOY: `goto()` tương đối, `baseURL` từ `.env`, KHÔNG hardcode URL/credential.
- POM; selector `getByRole > getByLabel > getByTestId`. Test độc lập, tự tạo/tự dọn dữ liệu.
- Sản phẩm chạy khác tài liệu → KHÔNG sửa test cho khớp sản phẩm, ghi `docs/bugs.md`.

## Phase 1 — analyze (đọc tài liệu)
Đọc hết `input/docs/`. `feature-map.md`: tính năng/module + mục đích; mỗi tính năng → **các yêu cầu kiểm thử**
gắn nguồn, mã `REQ-xxx`; user flow; business rule/validation/phân quyền nêu trong tài liệu.
Phụ: **`open-questions.md`** — mâu thuẫn giữa tài liệu, yêu cầu mơ hồ, khoảng trống. KHÔNG bịa, để con người xử.
> **Cổng quan trọng:** giải `open-questions.md` TRƯỚC khi sinh test case, nếu không test case sai hàng loạt.

## Phase 2 — generate-cases (RTM bắt buộc)
Mỗi `REQ-xxx` → test case nhiều loại, mỗi case gắn `REQ nguồn`. `rtm.md` đánh dấu REQ nào CHƯA phủ.
Case ngoài tài liệu → mục "Đề xuất ngoài tài liệu" cho tester duyệt.

## Phase 3 — map-and-scenario (đối chiếu UI thật)
Playwright MCP mở `{STAGING_URL}`, đăng nhập `.env.staging`, đi qua từng test case trên UI THẬT → `ui-map.md`
(TC-ID → selector/route bền vững). Case không khớp UI → `untestable.md`: `[Tính năng chưa deploy | UI đã đổi | Tài liệu lệch sản phẩm]`.
> Mục **"Tài liệu lệch sản phẩm"** rất giá trị: tài liệu lỗi thời HOẶC sản phẩm có bug → báo team.

## Phase 4–6
Như `web-playwright`: POM (selector từ `ui-map.md`), `auth.setup.ts` (storageState), `*.spec.ts` truy vết `// TC ← REQ ← tài liệu`;
run-and-heal thêm nhóm **Doc-drift** (sản phẩm khác tài liệu → `bugs.md`, KHÔNG sửa test); CI trỏ Staging.

## Truy vết ba tầng
`script → test case → yêu cầu (REQ) → tài liệu`. Tài liệu đổi → lần ngay test nào cần cập nhật.
