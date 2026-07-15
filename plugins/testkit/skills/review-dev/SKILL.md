---
name: review-dev
description: Review the developer's delivered output against the approved test cases — walk each TC on the real product (live UI via Playwright MCP, or code+run for desktop), give a per-TC verdict (Pass | Fail | Blocked | Untestable), and produce dev-review.md; mismatches go to bugs.md. Use via /testkit:review-dev after the dev delivers a feature.
license: MIT
---

# Review-dev — nghiệm thu output của dev theo test case

Mục tiêu: khi dev bàn giao tính năng, **đối chiếu sản phẩm thật với từng test case đã duyệt** và trả về
verdict cho từng case — báo cáo nghiệm thu khách quan thay vì "nhìn qua thấy ổn".

> **Ngôn ngữ:** báo cáo + giao tiếp theo `lang`. Khác `run-and-heal` (chạy script automation đã có),
> review-dev đi qua **test case** trực tiếp trên sản phẩm — dùng được cả khi CHƯA automate case nào.

## Đầu vào
- Phạm vi: feature/module hoặc danh sách TC-ID (vd `/testkit:review-dev login` hay `TC-LOGIN-*`).
  Không chỉ định → hỏi lại, đừng review cả hệ thống một lượt.
- `test-cases.md` đã `> Review: APPROVED` (case chưa duyệt thì chưa có chuẩn để nghiệm thu).
- Sản phẩm đã deploy (web: URL Staging/UAT) hoặc code branch dev bàn giao (desktop).

## Các bước

1. **Lấy danh sách TC trong phạm vi** từ `test-cases.md` (+ `rtm.md` để biết REQ nguồn).

2. **Đi qua từng TC trên sản phẩm thật:**
   - **web-***: Playwright MCP mở Staging, thực hiện đúng Steps của TC, so kết quả với Expected Result.
     KHÔNG tạo dữ liệu rác/thao tác phá hoại; dữ liệu thử dùng timestamp, dọn sau khi xong.
   - **desktop-pyside6**: đọc code bàn giao đối chiếu hành vi; case quan trọng → viết quick check
     pytest-qt tạm hoặc chạy test đã có (`pytest -k <module>`).
   - TC đã automate (đánh dấu `[automated]` trong rtm) → có thể chạy script thay vì thao tác lại.

3. **Verdict từng TC:**
   | Verdict | Nghĩa |
   |---|---|
   | ✅ Pass | hành vi khớp Expected Result |
   | ❌ Fail | lệch Expected → ghi chi tiết + **bugs.md** (repro, expected vs actual, TC/REQ) |
   | ⛔ Blocked | không đi tới được bước test (phụ thuộc lỗi khác/thiếu môi trường/data) |
   | ⚠ Untestable | UI/flow thực tế khác test case (chưa deploy, UI đổi, tài liệu lệch) → cần cập nhật case hoặc hỏi lại |

4. **Sinh báo cáo `dev-review-<scope>.md`** trong artifacts root:
   ```
   # Dev review: <scope> — <ngày>
   | TC | Tiêu đề | Verdict | Ghi chú / Bug ref |
   |----|---------|---------|-------------------|
   Tổng: N case — X Pass / Y Fail / Z Blocked / W Untestable
   > Review: PENDING
   ```
   Fail/Untestable phải có ghi chú đủ để dev tái hiện. Kết luận trung thực — **KHÔNG hạ Expected
   Result cho khớp sản phẩm** (đó là quyết định của tester/BA, ghi nhận trong bugs.md).

5. **Nhắc bước sau:** tester duyệt báo cáo; Fail → dev sửa → chạy lại review-dev đúng các TC đó;
   Pass đủ → có thể `/testkit:tc <TC-ID...>` để automate các case chưa có script.

## Đầu ra
`dev-review-<scope>.md` (verdict từng TC) + `bugs.md` entries cho mọi Fail + đề xuất cập nhật case cho Untestable.
