# testkit — Hướng dẫn sử dụng (cho tester)

Tài liệu này hướng dẫn dùng testkit để **AI agent tự viết bộ test automation** cho một web app,
theo đường đi qua 6 pha. Bạn (tester) là **người gác cổng**: ở mỗi pha bạn review artifact rồi mới
cho agent đi tiếp. Agent viết test, **Playwright chạy test**.

> Phiên bản hiện tại hiện thực đầy đủ 2 target: **web-playwright** (web app, test trỏ URL Staging/UAT)
> và **desktop-pyside6** (app PySide6, test in-process bằng pytest-qt). Hướng dẫn bên dưới đi theo
> ví dụ web; với desktop, các pha y hệt nhưng artifacts nằm ở `docs/`, runner là `pytest`, "selector"
> là `objectName` — chi tiết trong `profiles/desktop-pyside6.md`. Target khác (from-docs, blackbox) trên lộ trình.

---

## 0. Trước khi bắt đầu cần có

- **Claude Code** (hoặc Cursor) cài plugin testkit.
- **Node.js 18+** (`node --version`).
- **URL môi trường deploy**: `STAGING_URL` (và `UAT_URL` nếu có). testkit KHÔNG dựng app ở local.
- **Tài khoản test riêng** cho automation trên Staging (tách khỏi tài khoản người thật).
- (Khuyến nghị) **Playwright MCP** để agent mở Staging xác thực selector.

### Cài plugin

**Claude Code**
```
/plugin add marketplace github:lhdlam/testkit-plugin
/plugin install testkit@lhdlam
```

**Cursor** — testkit sinh `.cursor/rules/` ở bước init. Lưu ý: trên Cursor **gate là advisory**
(không bị chặn cứng), bạn cần tự kiểm "đã review chưa" trước khi sang pha sau.

---

## 1. Mô hình tinh thần: 6 pha, mỗi pha 1 cổng review

```
/testkit:init      Phase 0  Setup: scaffold + CLAUDE.md + config          (không cần review)
      │
/testkit:analyze   Phase 1  Hiểu app → feature-map.md                     🚦 bạn review
      │
/testkit:cases     Phase 2  Sinh test case + rtm.md                       🚦 bạn review
      │
/testkit:scenarios Phase 3  Map selector thật + kịch bản E2E              🚦 bạn review
      │
/testkit:script    Phase 4  Sinh Page Object + *.spec.ts + auth           🚦 bạn đọc assertion
      │
/testkit:run       Phase 5  Chạy + phân loại fail + self-heal             (lặp tới khi xanh)
      │
/testkit:ci        Phase 6  Sinh workflow CI                              (xong)
```

**Cơ chế cổng:** mỗi artifact trong `e2e-tests/docs/` kết thúc bằng một dòng:
```
> Review: PENDING
```
Sau khi bạn đọc và đồng ý, **đổi tay** thành:
```
> Review: APPROVED
```
Trên Claude Code, nếu pha trước còn `PENDING` thì hook sẽ **chặn** pha sau và nhắc bạn. Đây chính là
chỗ bạn kiểm soát chất lượng — đừng duyệt cho có.

---

## 2. Đi qua pipeline (ví dụ: module Login)

### Phase 0 — `/testkit:init`
Agent hỏi/đoán target (chọn **web-playwright**), scaffold `e2e-tests/`, cài Playwright + dotenv,
sinh `CLAUDE.md` (quy ước viết test), `playwright.config.ts`, và `.cursor/rules/` nếu dùng Cursor.

Sau đó **bạn điền** thông tin môi trường:
```bash
# e2e-tests/.env.staging  (KHÔNG commit — đã nằm trong .gitignore)
BASE_URL=https://staging.example.com
TEST_USER_EMAIL=automation@example.com
TEST_USER_PASSWORD=••••••
```

### Phase 1 — `/testkit:analyze`
Agent đọc source **read-only** (không build/run), sinh `e2e-tests/docs/feature-map.md`:
route/màn hình, form & validation, user flow, edge case, điểm phân quyền.

🚦 **Bạn review:** bổ sung luật nghiệp vụ ngầm mà code không thể hiện. Xong đổi
`> Review: PENDING` → `> Review: APPROVED`.

### Phase 2 — `/testkit:cases`
Agent sinh `test-cases.md` (Positive/Negative/Boundary/Permission) + `rtm.md` (ma trận truy vết).

🚦 **Bạn review 2 chiều:**
- *Chống bịa:* test case có bám feature-map không (mục "Đề xuất ngoài phạm vi" để riêng).
- *Chống sót:* mở `rtm.md` xem yêu cầu nào **chưa có test case**, bổ sung.

Đổi sang `APPROVED`.

### Phase 3 — `/testkit:scenarios`
Agent mở Staging qua Playwright MCP để **xác thực selector thật** → `ui-map.md`; test case không khớp
UI → `untestable.md`. Gom thành `scenarios.md` (Smoke/Regression/Edge).

🚦 **Bạn review:** kịch bản đúng hành trình thật chưa; xử lý mục "Tài liệu lệch sản phẩm" (nếu có).
Đổi sang `APPROVED`.

### Phase 4 — `/testkit:script`
Agent sinh `tests/pages/*.ts` (Page Object), `tests/auth.setup.ts` (đăng nhập 1 lần, lưu phiên),
`tests/e2e/*.spec.ts` (mỗi checkpoint = 1 `expect`, gắn tag `@smoke`, comment `// TC-LOGIN-01`),
rồi chạy thử 1 luồng smoke để xác nhận selector khớp.

🚦 **Bạn đọc lại assertion** xem có đúng nghiệp vụ không.

### Phase 5 — `/testkit:run`
```bash
cd e2e-tests && TEST_ENV=staging npx playwright test
```
Với mỗi test fail, agent **phân loại trước khi sửa**:

| Nhóm | Agent làm gì |
|---|---|
| Bug ứng dụng | **Không sửa test** → ghi `docs/bugs.md` cho bạn xác nhận |
| Môi trường (Staging down/mạng/data drift) | Không sửa test → `docs/env-issues.md` |
| Selector sai / Timing | Sửa test (web-first assertion, không sleep cứng) |
| Test data | Tăng độc lập: tự sinh dữ liệu riêng (timestamp), tự dọn |

Lặp `/testkit:run` tới khi xanh ổn định.

### Phase 6 — `/testkit:ci`
Agent sinh `.github/workflows/e2e-tests.yml` trỏ Staging: smoke mỗi deploy, full regression nightly.
Bạn đặt Secrets trên CI: `STAGING_BASE_URL`, `TEST_USER_EMAIL`, `TEST_USER_PASSWORD`.

---

## 3. Hai luật vàng (đừng phá)

1. **KHÔNG green-washing.** Test đỏ vì app sai → đó là test làm đúng việc. Đừng để agent "sửa test cho
   xanh". Quy ước này nằm sẵn trong `CLAUDE.md`; nếu thấy agent định làm yếu assertion, dừng lại.
2. **Dữ liệu tự sinh, tự dọn.** Staging dùng chung → mỗi test tạo dữ liệu riêng (email có timestamp),
   không đụng dữ liệu người khác. Flaky do data drift chữa bằng cách này, KHÔNG bằng tăng timeout.

---

## 4. Lệnh chạy nhanh

```bash
cd e2e-tests
TEST_ENV=staging npx playwright test                 # full
TEST_ENV=staging npx playwright test --grep @smoke   # chỉ smoke (critical path)
TEST_ENV=uat      npx playwright test                 # đổi môi trường chỉ bằng 1 biến
npx playwright show-report                            # xem báo cáo HTML
npx playwright show-trace                             # mổ xẻ 1 test fail
```

---

## 5. Bắt đầu nhỏ

Làm **trọn module login** (analyze → … → run xanh) trước khi nhân rộng. Vừa kiểm chứng quy trình,
vừa cho agent một "mẫu" để bắt chước cho các module sau — chất lượng đồng đều hơn nhiều.

---

## 6. Sự cố thường gặp

| Triệu chứng | Nguyên nhân & xử lý |
|---|---|
| `/testkit:cases` bị chặn | `feature-map.md` còn `> Review: PENDING` → review & đổi `APPROVED` |
| Agent đoán selector lung tung | Chưa cài Playwright MCP → cài để agent xác thực selector trên Staging thật |
| Test xanh local, đỏ CI | Thiếu Secrets trên CI, hoặc thiếu `npx playwright install --with-deps` |
| Đăng nhập lại mỗi test, chậm | `auth.setup.ts` chưa chạy / config chưa trỏ `storageState` — xem `playwright.config.ts` |
| Test phá dữ liệu người khác trên Staging | Vi phạm luật "tự sinh/tự dọn" — ép agent tạo dữ liệu riêng, tránh test xoá hàng loạt |

---

## 7. Phát triển plugin (dành cho maintainer)

```bash
bash tests/run-all.sh        # chạy toàn bộ test của plugin
bash tests/test-gate.sh      # chỉ test review gate
```
Thêm target mới = thêm 1 file `profiles/<target>.md` + (nếu cần) template tương ứng; pipeline 6 pha
giữ nguyên. Xem README mục Roadmap.
