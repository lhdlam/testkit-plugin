# testkit — AI test-automation toolkit

> Một plugin, một namespace `/testkit:*` — agent **viết & bảo trì** test, Playwright/pytest **chạy** test.
> Dành cho **tester**. Chạy trên **Claude Code** (gate cưỡng chế) và **Cursor** (gate advisory).

## Triết lý

1. **Agent viết test, framework chạy test.** Không để AI thao tác trực tiếp mỗi lần chạy → tránh chậm, đắt, flaky.
2. **Mỗi pha có 1 artifact + 1 điểm review của con người** trước khi sang pha sau. Tester là người gác cổng.
3. **Truy vết được:** mỗi test ↔ test case ↔ yêu cầu ↔ tài liệu.
4. **Không green-washing:** nghi app có bug thì ghi `bugs.md`, KHÔNG sửa test cho xanh.
5. **Selector bền vững:** web `getByRole/Label/TestId`; desktop `objectName`.
6. **Bắt đầu nhỏ:** làm trọn 1 module (vd login) rồi nhân rộng.

## Kiến trúc: 1 pipeline + target profile cắm vào

6 pha giống nhau cho mọi nền tảng; khác biệt gói trong `profiles/<target>.md`:

```
Phase 1        Phase 2         Phase 3            Phase 4         Phase 5        Phase 6
analyze   →   generate-   →   map-and-       →   generate-   →   run-and-   →   setup-ci
(hiểu)        cases (+RTM)    scenario           script          heal
  ↓             ↓               ↓                  ↓               ↓             ↓
feature-map   test-cases      ui-map/scenarios   spec/test_*     bugs.md       workflow
  [review]      [review]        [review]           [review]        [review]       —
```

| Target | Test gì | Selector | Runner | Thực thi |
|---|---|---|---|---|
| `web-playwright` | đọc code | code/live | Playwright/TS | URL Staging |
| `web-from-docs` | tài liệu + RTM | DOM live (MCP) | Playwright/TS | URL Staging |
| `web-blackbox` | explore live | DOM live (MCP) | Playwright/TS | URL Staging |
| `desktop-pyside6` | đọc code | `objectName` | pytest-qt | in-process |

## Cài đặt

### Claude Code
```
/plugin add marketplace github:lhdlam/testkit-plugin
/plugin install testkit@lhdlam
```

### Cursor
testkit sinh `.cursor/rules/` từ cùng template với `CLAUDE.md`. Lưu ý: Cursor không có
PreToolUse hook cưỡng chế → **các gate là advisory** (agent tự giác). Slash `/testkit:X`
được xử qua rule bridge (đọc `commands/X.md`).

## Quy trình điển hình

```
/testkit:init        → setup dự án test + CLAUDE.md + config (chọn target)
        ↓
/testkit:analyze     → Phase 1: feature-map.md   🚦 review
        ↓
/testkit:cases       → Phase 2: test-cases.md (+ rtm.md)   🚦 review
        ↓
/testkit:scenarios   → Phase 3: ui-map.md + scenarios.md   🚦 review
        ↓
/testkit:script      → Phase 4: POM/Screen Object + spec/test_*   🚦 review
        ↓
/testkit:run         → Phase 5: chạy + phân loại fail + self-heal
        ↓
/testkit:ci          → Phase 6: workflow CI
```

**Tăng trưởng (incremental):** `/testkit:new-feature` — khi project đã có bộ test, chỉ sinh test cho 1
feature mới (scope qua git diff hoặc mô tả), không quét lại cả repo, không đụng test cũ.

> Hướng dẫn từng bước chi tiết cho tester: xem [USAGE.md](USAGE.md).

## Trạng thái & gate

Artifact sống trong `${TESTKIT_ROOT:-e2e-tests/docs}/`. Mỗi artifact có dòng cuối
`> Review: PENDING|APPROVED`. Trên Claude Code, `pre-tool-gate.sh` chặn pha sau tới khi
pha trước `APPROVED`. Trên Cursor là advisory.

## Trạng thái phát triển (roadmap)

| Mốc | Nội dung | Trạng thái |
|---|---|---|
| **M1** | Target `web-playwright` end-to-end (6 pha + gate + templates + test) | ✅ Xong |
| **M2** | Target `desktop-pyside6` (pytest-qt, monkeypatch modal, headless) | ✅ Xong |
| **M3** | Target `web-from-docs` + `web-blackbox` (RTM, ui-map qua MCP) | ✅ Xong |
| **M4** | Cursor bridge (mirror `.cursor/rules/` từ template ở bước init) | ✅ Xong |
| **M5** | Subagents: `coverage-auditor`, `failure-classifier`, `selector-stability`, `test-integrity` | ✅ Xong |
| **M6** | `/testkit:new-feature` (incremental qua git diff / mô tả) | ✅ Xong |
| M6+ | Coverage dashboard (HTML từ rtm + kết quả chạy) | ⬜ Kế hoạch |

> Cả 4 target + 4 subagent + incremental mode đã hiện thực đầy đủ. Còn lại trên lộ trình:
> coverage dashboard (HTML). Pipeline cốt lõi đã hoàn chỉnh và dùng được.

## License

MIT.
