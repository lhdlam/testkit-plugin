---
name: question
description: Q&A over the project's documents, code, and generated test artifacts — every answer cites its sources (document + section, file:line, TC/REQ id). Use via /testkit:question or whenever the tester asks "tài liệu nói gì về X?", "REQ nào cover X?", "TC này lấy từ đâu?".
license: MIT
---

# Question — hỏi đáp có trích dẫn nguồn

Mục tiêu: trả lời câu hỏi của tester về **tài liệu dự án / code / test artifacts**, và **mọi câu trả lời
phải kèm reference** tới đúng chỗ nội dung được đề cập. Không nguồn = không khẳng định.

> **Ngôn ngữ:** trả lời theo `lang` (`.testkit-lang`/`TESTKIT_LANG`, mặc định `vi`).

## Nguồn tra cứu (theo thứ tự ưu tiên)

1. **Tài liệu dự án** — `input/docs/` (from-docs) hoặc thư mục tài liệu user chỉ định (pdf/docx/md/slide).
2. **Artifacts đã sinh** — `feature-map.md`, `test-cases.md`, `rtm.md`, `scenarios.md`, `ui-map.md`,
   `bugs.md`, `open-questions.md` (probe `${TESTKIT_ROOT}` → `e2e-tests/docs` → `docs`).
3. **Source code** — nếu project có repo (web-playwright / desktop-pyside6), read-only.
4. **Test code** — `tests/` (spec/POM/Screen Object).

## Quy tắc trả lời

1. **Grep/Read trước, trả lời sau.** Tìm đúng đoạn liên quan trong nguồn rồi mới viết câu trả lời.
2. **Mỗi ý khẳng định kèm reference**, định dạng:
   - Tài liệu: `[SRS.docx §4.2]`, `[user-story-login.md → "AC3"]`
   - Artifact: `[test-cases.md → Login / đăng nhập thất bại khi sai mật khẩu]`, `[rtm.md → Chính sách mật khẩu]`
   - Code: `[app/main_window.py:87]`, `[tests/e2e/login.spec.ts:24]`
3. **Không có trong nguồn → nói thẳng** "tài liệu không đề cập" và (nếu hữu ích) gợi ý ghi vào
   `open-questions.md`. KHÔNG suy diễn thành khẳng định.
4. **Mâu thuẫn giữa các nguồn** (tài liệu A ≠ tài liệu B, hoặc tài liệu ≠ code) → nêu cả hai phía kèm
   reference từng bên, đề xuất đưa vào `open-questions.md` để con người phân xử.
5. Câu hỏi dạng truy vết ("case nào cover chính sách mật khẩu?", "case này lấy từ yêu cầu nào?") → dùng `rtm.md`
   làm bảng tra chính.

## Ví dụ

**Hỏi:** "Mật khẩu yêu cầu tối thiểu bao nhiêu ký tự?"
**Trả lời:** Tối thiểu 8 ký tự, có ít nhất 1 số và 1 ký tự đặc biệt `[SRS.docx §3.4 "Password policy"]`.
Validation này đã được cover bởi `[test-cases.md → Register / mật khẩu dưới 8 ký tự bị từ chối]`. Lưu ý: code hiện chỉ check độ dài
≥8, chưa check ký tự đặc biệt `[app/validators.ts:31]` — lệch với tài liệu, nên đưa vào `open-questions.md`.
