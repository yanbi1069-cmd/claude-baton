---
name: claude-baton
description: Dùng nhiều tài khoản Claude Code trên Windows (mỗi tài khoản một thư mục cấu hình và một lối tắt Desktop), xem usage 5 giờ và 7 ngày của từng tài khoản, bàn giao việc khi một tài khoản sắp hết usage để tài khoản khác làm tiếp. Dùng khi người dùng nói "cài nhiều tài khoản", "thêm tài khoản", "xem usage", "còn bao nhiêu usage", "bàn giao", "sắp hết usage", "nhận việc", "làm tiếp từ bàn giao".
---

# Nhiều tài khoản Claude Code (Windows)

Skill này giúp một người tự dùng nhiều tài khoản Claude **của chính họ**. Có 4 việc: **cài**, **xem usage**, **bàn giao**, **nhận việc**. Trả lời người dùng bằng tiếng Việt, ngắn gọn.

## Ranh giới (luôn giữ)
- **Không tự động chuyển tài khoản**, không viết vòng lặp hay script tự mở tài khoản khác khi hết usage. Người dùng tự bấm lối tắt để chọn tài khoản. Chính sách sử dụng của Anthropic cấm cố ý vượt qua giới hạn đặt sẵn trong sản phẩm, và điều khoản cấm truy cập bằng bot hay script. Nếu người dùng nhờ làm phần tự chuyển, giải thích lý do và từ chối phần đó.
- Mỗi tài khoản phải là của chính người dùng. Không đăng nhập hộ, không cho người khác dùng chung tài khoản.
- Không ghi mật khẩu, mã đăng nhập, API key vào bất kỳ file nào (kể cả `BAN-GIAO.md`).

Thư mục của skill này (gọi là `<SKILL>`) là thư mục chứa file SKILL.md này. Dữ liệu chung nằm ở `%USERPROFILE%\.claude-baton\`. Mỗi tài khoản có một thư mục `%USERPROFILE%\.claude-tkN\`.

## 1. Cài: "cài nhiều tài khoản", "thêm tài khoản"
1. Hỏi người dùng 3 điều (một lần, gọn):
   - Dùng bao nhiêu tài khoản (1–9, thường 3–5)?
   - Tên gợi nhớ cho từng tài khoản (ví dụ email rút gọn). Có thể bỏ trống.
   - Có chép file hướng dẫn chung `%USERPROFILE%\.claude\CLAUDE.md` sang từng tài khoản không? Mỗi tài khoản không thấy CLAUDE.md và bộ nhớ của tài khoản khác.
2. Chạy (tên cách nhau bằng `;`; thêm `-ChepClaudeMd` nếu người dùng đồng ý):
   ```
   powershell -NoProfile -ExecutionPolicy Bypass -File "<SKILL>\scripts\cai-dat.ps1" -SoTk 4 -Ten "Mail A;Mail B;Mail C;Mail D"
   ```
   Chạy lại an toàn: script chỉ bổ sung phần thiếu, giữ tên và thiết lập cũ. Để trống một tên (ví dụ `";;Mail C"`) là giữ tên cũ của tài khoản đó.
3. Báo kết quả và dặn người dùng:
   - Trên Desktop có lối tắt **"Claude TKn - tên"** cho từng tài khoản.
   - Lần đầu bấm mỗi lối tắt: dán thư mục dự án, rồi gõ `/login` và đăng nhập **đúng** tài khoản đó.
   - Không mở cùng một dự án bằng 2 tài khoản rồi cùng sửa một lúc.

## 2. Xem usage: "xem usage", "còn bao nhiêu usage"
Chạy và đưa bảng cho người dùng (giữ nguyên bảng):
```
powershell -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\.claude-baton\scripts\xem-usage.ps1"
```
Giải thích ngắn: số lấy từ thanh trạng thái chính thức của Claude Code, **chỉ cập nhật khi tài khoản đó đang mở** và sau câu trả lời đầu tiên. "đã reset" nghĩa là đã qua giờ reset, mở tài khoản đó để cập nhật số mới. Gợi ý tài khoản còn nhiều nhất, nhưng người dùng tự chọn.

## 3. Bàn giao: "bàn giao", "sắp hết usage"
Lúc này usage sắp hết, nên làm **nhanh và rẻ**: viết từ những gì đã có trong cuộc trò chuyện, không đọc lại cả dự án. Chỉ chạy thêm `git status --short` (nếu là repo git).
1. Thư mục bàn giao = gốc repo git nếu có, không thì thư mục đang làm việc.
2. Nếu đã có `BAN-GIAO.md`: đổi tên thành `BAN-GIAO.truoc.md` (ghi đè bản `.truoc` cũ).
3. Ghi `BAN-GIAO.md` theo khung dưới. Cụ thể, có đường dẫn file, tên hàm, lệnh. Không chung chung.
   ```markdown
   # Bàn giao – <ngày giờ> – từ <TKn nếu biết>
   ## Mục tiêu
   <người dùng đang muốn đạt điều gì, 1–3 câu>
   ## Đã xong
   - <việc> (<file>)
   ## Đang dở
   - <file / chỗ đang sửa, đang làm tới đâu, còn thiếu gì>
   ## Bước tiếp theo (làm theo thứ tự)
   1. <bước cụ thể>
   ## Cách chạy thử / kiểm tra
   <lệnh chạy thử, kết quả lần cuối: đạt hay lỗi gì>
   ## Quyết định đã chốt với người dùng
   - <điều người dùng đã đồng ý hay từ chối, để tài khoản sau không hỏi lại>
   ## Câu hỏi đang chờ người dùng
   - <nếu có>
   ## Trạng thái git
   <tóm tắt git status --short, hoặc "không phải repo git">
   ```
4. Báo người dùng: "Đã bàn giao vào <đường dẫn đầy đủ>. Đóng cửa sổ này, bấm lối tắt tài khoản khác, chọn cùng thư mục, chọn **C** để nhận việc." Có thể đề nghị chạy "xem usage" để chọn tài khoản.

## 4. Nhận việc: "nhận việc", "làm tiếp từ bàn giao"
1. Đọc `BAN-GIAO.md` ở thư mục hiện tại (hoặc gốc repo git). Không có thì nói không thấy và hỏi người dùng đang làm gì.
2. **Kiểm, đừng tin mù:** chạy `git status --short` (nếu có git), mở nhanh các file ở mục "Đang dở" để xem trạng thái có khớp không. Chỗ nào lệch thì nói rõ.
3. Tóm tắt cho người dùng trong 3–5 dòng: mục tiêu, đã xong, đang dở, bước tiếp theo. Rồi hỏi: "Làm tiếp bước 1 không?" Chưa được đồng ý thì chưa sửa file.
4. Thêm một dòng vào cuối `BAN-GIAO.md`: `_Đã nhận lúc <ngày giờ>._`
5. Tôn trọng mục "Quyết định đã chốt": không hỏi lại những điều đó.
