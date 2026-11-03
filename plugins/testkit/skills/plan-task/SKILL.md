---
name: plan-task
description: Phase 0.5 — analyze ONE incoming task (feature request, change request, bug batch), assess its blast radius across screens/test cases/existing tests/docs, cross-check it against the spec and raise any deviation, then produce plan-<slug>.md for the tester to approve BEFORE any pipeline phase runs. Use via /testkit:plan <mô tả task | nhánh/tag git>.
license: MIT
---

# Phase 0.5 — Phân tích task & lập kế hoạch

Mục tiêu: trước khi động vào bất kỳ pha nào, **hiểu task → đo ảnh hưởng → đối chiếu spec → trình kế
hoạch cho tester duyệt**. Đây là cổng chặn sớm nhất: bắt sai phạm vi, lệch spec và rủi ro lan rộng
*trước khi* tốn công sinh test case/script.

> **Pha này KHÔNG sinh test, KHÔNG sửa code.** Chỉ đọc, đo, hỏi và viết ra `plan-<slug>.md`.
> **Ngôn ngữ:** toàn bộ plan + giao tiếp theo `lang` (`.testkit-lang` / `TESTKIT_LANG`, mặc định `vi`).

## Luật cứng

1. **KHÔNG bịa.** Mọi khẳng định về yêu cầu/hiện thực phải kèm **trích dẫn nguồn thật**
   (`SRS §4.2`, `app/auth.ts:31`, `test-cases.md → Login / <tiêu đề>`). Không định vị được → ghi vào
   mục "Câu hỏi cần trả lời", đừng đoán.
2. **KHÔNG tự đặt mã định danh** (TC-xx, REQ-xx, BUG-xx, OQ-xx). Gọi test case bằng **Module + Tiêu đề**,
   gọi yêu cầu bằng **tiêu đề mô tả + nguồn thật**.
3. **Lệch spec thì RAISE, không tự quyết.** Task mâu thuẫn tài liệu, hoặc tài liệu mâu thuẫn code →
   ghi `open-questions.md` + nêu trong plan, để tester/BA phân xử.
4. **Đo ảnh hưởng trung thực.** Không hạ mức rủi ro cho kế hoạch đẹp. Không chắc → ghi "cần xác minh".
5. **Dừng ở plan.** Viết xong `> Review: PENDING` là DỪNG. Không tự chạy sang pha sau.

## Bước 0 — Đầu vào & định phạm vi

Arg là **mô tả task** (tự do) HOẶC **nhánh/tag git** đã có code. Không có arg → hỏi lại, đừng tự chọn task.
- Đọc `${TESTKIT_ROOT:-e2e-tests/docs}/.testkit-target` và `profiles/<target>.md`.
- Đặt `slug` kebab ngắn từ tiêu đề task (vd `them-export-csv`) — dùng cho tên file plan.
- **Cách A — git diff** (target có code): `git diff --name-only <nhánh-chính>...<nhánh>`. Chắc chắn nhất.
- **Cách B — mô tả**: từ mô tả định vị màn hình/luồng/tài liệu liên quan. Không định vị được → HỎI.

## Bước 1 — Phân tích task (đọc tối thiểu, không quét cả repo)

Trả lời được 3 câu, mỗi câu kèm nguồn:
- **Task yêu cầu gì?** (hành vi mong muốn, điều kiện, ràng buộc)
- **Tài liệu nói gì về vùng này?** (trích `SRS §x`; không có tài liệu → ghi rõ "không có nguồn tài liệu")
- **Hiện tại hệ thống đang làm gì?** (trích `file:line`, hoặc `feature-map.md`, hoặc UI thật qua MCP)

## Bước 2 — Đánh giá ảnh hưởng (blast radius)

Đây là phần lõi của pha này. Lập bảng, **mỗi dòng kèm nguồn**:

```
| Hạng mục | Cái gì bị ảnh hưởng | Mức | Vì sao / Nguồn |
```
Quét đủ **6 hạng mục**, hạng mục nào không bị ảnh hưởng thì ghi "không" (đừng bỏ trống):

| Hạng mục | Soát cái gì |
|---|---|
| **Màn hình / luồng** | màn hình, route, dialog, bước trong luồng bị thay đổi |
| **Test case hiện có** | case trong `test-cases.md` phải sửa Expected / bị vô hiệu (gọi bằng Module + Tiêu đề) |
| **Test tự động hiện có** | file + tên test nhiều khả năng đỏ sau thay đổi (đối chiếu `rtm.md`) |
| **Tài liệu / yêu cầu** | mục tài liệu cần cập nhật theo task |
| **Dữ liệu & phân quyền** | schema/dữ liệu dùng chung, vai trò, phiên, quyền truy cập |
| **Vùng dùng chung** | hàm/component/API dùng chung nơi khác — nơi dễ vỡ ngoài ý muốn |

Mức: **Cao** (chắc chắn vỡ / chạm luồng critical) · **Trung bình** (phải sửa theo) · **Thấp** (liên quan gián tiếp).
Không đủ dữ kiện để xếp mức → ghi **"cần xác minh"** kèm cách xác minh.

## Bước 3 — So khớp spec & raise khi lệch

Đối chiếu **3 chiều: task ↔ tài liệu ↔ hiện thực**. Mỗi lệch là một dòng, kèm reference cả hai phía:

| Loại lệch | Nghĩa | Xử lý |
|---|---|---|
| **Task ≠ Tài liệu** | task yêu cầu khác điều tài liệu quy định | RAISE — `open-questions.md`, chờ BA/tester |
| **Tài liệu ≠ Hiện thực** | tài liệu và code đang vênh sẵn từ trước | RAISE — `open-questions.md` (bug tiềm ẩn HOẶC tài liệu lỗi thời) |
| **Task thiếu định nghĩa** | tài liệu không nói gì về vùng này | RAISE — nêu ở "Câu hỏi cần trả lời", KHÔNG tự suy diễn |

Có lệch → **không được coi là đã chốt phạm vi**; plan phải ghi rõ "chờ phân xử" ở mục tương ứng.

## Bước 4 — Sinh `plan-<slug>.md`

Trong artifacts root:

```
# Plan: <tiêu đề task>

## Mục tiêu
## Nguồn                  (trích dẫn thật cho từng ý: SRS §x, file:line, yêu cầu của user)
## Phạm vi
### Trong phạm vi
### NGOÀI phạm vi         (ghi rõ để tránh phình việc)
## Đánh giá ảnh hưởng     (bảng 6 hạng mục ở Bước 2)
## Lệch spec phát hiện được   (bảng ở Bước 3; không có → ghi "không phát hiện lệch")
## Rủi ro & cách giảm thiểu
## Các bước đề xuất       (thứ tự chạy pha nào, chạm gì, kiểm chứng ra sao)
## Câu hỏi cần tester trả lời
> Review: PENDING
```

KHÔNG thêm dấu ngày, tên khách, số hợp đồng hay ghi chú quyết định của khách vào plan.

## Bước 5 — Dừng & bàn giao

Tóm tắt cho tester: phạm vi, **các mục ảnh hưởng mức Cao**, số lệch spec đã raise, câu hỏi đang chờ.
Nhắc: duyệt plan (`PENDING` → `APPROVED`) rồi mới chạy pha sau.

Sau khi plan APPROVED, bước kế theo loại task:
- Tính năng mới → `/testkit:new-feature`
- Bổ sung case lẻ cho module sẵn có → `/testkit:cases` rồi `/testkit:tc`
- Sửa bug → `/testkit:fixbug`

## Gate
Trên Claude Code, `hooks/pre-tool-gate.sh` **chặn `new-feature` khi còn `plan-*.md` ở trạng thái PENDING**
— plan đã lập thì phải được duyệt trước khi sinh artifact. Chưa lập plan nào thì không chặn (tương thích
ngược). Trên Cursor gate là advisory: tự kiểm dòng `> Review:` trước khi đi tiếp.

## Đầu ra
`plan-<slug>.md` (`> Review: PENDING`) + `open-questions.md` cập nhật nếu phát hiện lệch spec.
