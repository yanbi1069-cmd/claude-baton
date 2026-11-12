# claude-baton

**Pass the baton between your own Claude Code accounts on Windows.** One desktop shortcut per account, a per-account usage table (5-hour and 7-day limits, from Claude Code's official status line data), and a handoff file so the next account picks up exactly where the last one stopped. Switching is always manual: claude-baton never rotates accounts automatically.

---

## Tiếng Việt

Bộ skill này giúp bạn dùng 2–9 tài khoản Claude **của chính bạn**:
- Mỗi tài khoản có một lối tắt riêng trên Desktop.
- Xem được usage của từng tài khoản.
- Khi một tài khoản sắp hết usage, bạn bàn giao để tài khoản khác làm tiếp đúng chỗ, giống trao gậy trong chạy tiếp sức.

> **claude-baton không tự chuyển tài khoản khi hết usage.** Bạn tự bấm chọn tài khoản. Chính sách sử dụng của Anthropic cấm cố ý vượt qua giới hạn của sản phẩm, và cấm truy cập bằng bot hay script. Tự động xoay vòng tài khoản có thể khiến các tài khoản bị khóa. Nếu cần dùng nhiều hơn, hãy cân nhắc gói Max hoặc API trả theo lượng dùng.

### Cần có
- Windows 10 hoặc 11, đã cài [Claude Code](https://code.claude.com). Gõ `claude --version` trong PowerShell phải thấy số phiên bản.
- Các tài khoản Claude gói Pro trở lên. Số usage chỉ có với gói Pro, Max, Ultra.

### Cài skill (chọn 1 cách)
**Cách 1, nhờ Claude cài:** mở Claude Code rồi dán câu này:
```
Cài skill từ https://github.com/yanbi1069-cmd/claude-baton vào thư mục %USERPROFILE%\.claude\skills\claude-baton
```

**Cách 2, tự cài bằng git:** mở PowerShell và chạy:
```powershell
git clone https://github.com/yanbi1069-cmd/claude-baton "$env:USERPROFILE\.claude\skills\claude-baton"
```

**Cách 3, tải ZIP:** bấm **Code → Download ZIP**, giải nén, đổi tên thư mục `claude-baton-main` thành `claude-baton`, rồi chép vào `C:\Users\<tên bạn>\.claude\skills\`.

Dù dùng cách nào, kết quả phải có file `C:\Users\<tên bạn>\.claude\skills\claude-baton\SKILL.md`.

### Dùng trong 4 bước
1. **Tạo tài khoản:** mở Claude Code, gõ **`cài nhiều tài khoản`**. Claude hỏi số tài khoản và tên gợi nhớ, rồi tạo lối tắt **"Claude TK1 - …"**, **"Claude TK2 - …"** trên Desktop.
2. **Đăng nhập từng tài khoản (chỉ một lần):** bấm lối tắt TK1, dán đường dẫn thư mục dự án, gõ `/login` và đăng nhập đúng tài khoản 1. Làm tương tự với TK2, TK3… Từ lần sau, bấm lối tắt là vào thẳng.
3. **Khi làm việc:** thanh dưới cùng hiện kiểu `TK1 · 5h 24% (reset 14:30) · 7d 41%`. Khi thấy **"⚠ sắp hết, gõ: bàn giao"**, gõ **`bàn giao`**. Claude ghi việc đang dở vào file `BAN-GIAO.md` trong thư mục dự án.
4. **Đổi tài khoản:** đóng cửa sổ, bấm lối tắt của tài khoản khác. Đầu cửa sổ có bảng usage gợi ý tài khoản còn nhiều. Chọn **cùng thư mục**, rồi trả lời **C** khi được hỏi "Nhận việc?". Claude đọc bản bàn giao, kiểm lại file, tóm tắt, rồi hỏi bạn có làm tiếp không.

Lúc nào cũng có thể gõ **`xem usage`** để xem bảng usage của mọi tài khoản.

### Lưu ý
- Số usage chỉ cập nhật khi tài khoản đó **đang mở**, và sau câu trả lời đầu tiên. Tài khoản lâu không mở sẽ hiện số cũ hoặc chữ "đã reset".
- Mỗi tài khoản không thấy lịch sử chat và bộ nhớ của tài khoản khác. Vì vậy nhớ **bàn giao trước khi đổi tài khoản**.
- Đừng mở cùng một dự án bằng 2 tài khoản rồi cùng sửa một lúc.
- Muốn thêm hoặc đổi tên tài khoản: gõ lại `cài nhiều tài khoản`. Thiết lập cũ được giữ nguyên.
- Muốn gỡ bỏ: xóa các lối tắt "Claude TK…" trên Desktop, các thư mục `C:\Users\<tên bạn>\.claude-tk1`, `.claude-tk2`… và thư mục `C:\Users\<tên bạn>\.claude-baton`.

### Bên trong có gì
| File | Việc |
|---|---|
| `SKILL.md` | Hướng dẫn cho Claude: cài, xem usage, bàn giao, nhận việc |
| `scripts/cai-dat.ps1` | Tạo thư mục cấu hình cho từng tài khoản (`CLAUDE_CONFIG_DIR`), thanh trạng thái, lối tắt Desktop |
| `scripts/mo.cmd`, `scripts/mo.ps1` | Mở Claude Code bằng một tài khoản tại thư mục dự án |
| `scripts/statusline.ps1` | Hiện usage trên thanh trạng thái và ghi lại cho bảng |
| `scripts/xem-usage.ps1` | In bảng usage của mọi tài khoản |

Chỉ dùng PowerShell có sẵn trong Windows, không cần cài thêm gì.
