# Quy tắc xử lý lỗi

Các lệnh bên dưới giả định đã tải repository vào `$HOME/zalo-linux-chat-kit` theo [hướng dẫn cài đặt](README.md#cài-đặt-trên-ubuntulinux-mint-khuyến-nghị). Không tải và thực thi script bằng `curl | bash` khi Raw GitHub bị HTTP 403.

## Lệnh cài báo HTTP 403

Nếu `curl` báo HTTP 403 khi truy cập `raw.githubusercontent.com`, dùng `git clone` trong [README](README.md) thay vì `curl | bash`.

Nếu `git clone` **thành công** nhưng chạy installer tiếp tục gặp `curl: (22) ... 403`, đó thường là bước gọi `https://api.github.com/repos/VN-Linux-Family/zalo-for-linux/releases/latest`. Cập nhật bản vá rồi chạy lại:

```bash
git -C "$HOME/zalo-linux-chat-kit" pull --ff-only
bash "$HOME/zalo-linux-chat-kit/install-zalo-linux.sh"
```

Bộ cài có fallback tới bản `26.10.11` Chat/Full từ GitHub Releases, kiểm tra SHA-256 trước khi thay AppImage. Nếu GitHub Releases cũng trả 403, không có lệnh cài nào vượt được giới hạn mạng này: thử kết nối khác hoặc yêu cầu quản trị mạng kiểm tra tường lửa/proxy. Chạy:

```bash
curl -sS -L -o /dev/null -w 'GitHub API: HTTP %{http_code}\\n' 'https://api.github.com/repos/VN-Linux-Family/zalo-for-linux/releases/latest'
curl -sS -L -o /dev/null -w 'GitHub release: HTTP %{http_code}\\n' 'https://github.com/VN-Linux-Family/zalo-for-linux/releases/tag/26.10.11'
```

Không xóa database chat hoặc tắt cơ chế bảo vệ hệ thống để xử lý HTTP 403.

## Zalo không mở / báo FUSE

```bash
bash "$HOME/zalo-linux-chat-kit/zalo-repair.sh"
```

Launcher tự bật `APPIMAGE_EXTRACT_AND_RUN=1` khi máy thiếu FUSE. Không xóa `~/.config/ZaloApp` hoặc `~/.local/share/ZaloData`.

## Quét QR xong nhưng cứ “Đang đăng nhập…”

Vấn đề trùng hiện tượng tại [issue #13 của dự án Zalo Linux gốc](https://github.com/VN-Linux-Family/zalo-for-linux/issues/13). Người bảo trì từng xác định một số bản cũ thiếu Linux SQLite binding; lỗi được đánh dấu sửa từ `26.3.20`. Tuy vậy, màn hình xoay cũng có thể do phiên đăng nhập hỏng hoặc kết nối mạng: riêng ảnh chụp màn hình không đủ để kết luận nguyên nhân trên máy của bạn.

1. Trên điện thoại, kiểm tra đã **xác nhận đăng nhập** sau khi quét QR. Đóng Zalo trên Ubuntu và cập nhật repo cùng AppImage lên bản mới.
2. Nếu vẫn xoay, dùng `bash "$HOME/zalo-linux-chat-kit/zalo-login-recover.sh" --dry-run` để xem trước, sau đó đóng hết Zalo và chạy `bash "$HOME/zalo-linux-chat-kit/zalo-login-recover.sh"`. Script di chuyển nguyên thư mục `ZaloData` vào `~/.config/ZaloData.login-backup-...`, giữ lại dữ liệu và không ghi đè bản backup cũ. Khởi động Zalo rồi quét QR lại.
3. Nếu vẫn lỗi, thử chế độ hiển thị khác qua `ZALO_OZONE_PLATFORM=auto "$HOME/.local/bin/zalo-linux"` trên GNOME Wayland. Xem lỗi trong DevTools `Ctrl+Shift+I` → Console. Lỗi `node_sqlite3.node`, `GLIBC`, `ERR_PROXY_CONNECTION_FAILED` hoặc `net::ERR_*` giúp phân biệt thư viện với mạng; đừng kết luận tất cả đều do proxy FPT.
4. Trên mạng công ty có proxy, thử kết nối hotspot điện thoại **nếu được phép theo chính sách IT**. Proxy cho GitHub tải AppImage và máy chủ xác thực Zalo là hai đường mạng khác nhau. Không tắt bảo mật hoặc vượt cơ chế chặn của doanh nghiệp.

Muốn quay lại dữ liệu cũ: đóng Zalo, **di chuyển `~/.config/ZaloData` mới sang vị trí backup riêng** trước; sau đó dùng lệnh `--restore DUONG_DAN_BACKUP` mà script đã in. Script từ chối ghi đè dữ liệu mới.

**Chú ý:** Login sạch có thể yêu cầu đồng bộ lại, và dữ liệu chỉ có tại máy Linux cũ có thể không được tải lại từ máy chủ. Hãy kiểm tra backup trước khi chọn phục hồi. Khi gửi log, che toàn bộ QR, token, cookie, số điện thoại, nội dung chat và URL đăng nhập.

## Bấm icon nhưng Zalo không mở (SUID sandbox)

Chạy `~/.local/bin/zalo-linux` trong Terminal. Nếu thấy `The SUID sandbox helper binary was found, but is not configured correctly`, cài lại hoặc chạy repair để cập nhật launcher. Launcher dùng `--no-sandbox` mặc định cho cả bản Chat và Full. Đặt `ZALO_SANDBOX=1` để thử chế độ sandbox trên máy có hỗ trợ. Khi phải tắt sandbox, Electron giảm bảo vệ của ứng dụng Zalo; chỉ chạy AppImage từ nguồn tin cậy. Repair cũng khôi phục icon và desktop entry. Nếu trước đây tạo icon thủ công `Zalo Linux (AppImage)`, có thể bỏ ghim và xóa lối tắt cũ sau khi xác nhận icon `Zalo Linux` mới mở được.

## Không dán được ảnh

Chạy repair để cài `xclip` và `wl-clipboard`, sau đó đăng xuất/đăng nhập lại desktop nếu clipboard portal chưa hoạt động.

## ZaDark báo `Unexpected token '<'` khi dịch tin nhắn

Nút dịch thuộc **ZaDark** được đóng gói trong AppImage upstream. Thông báo này cho biết mã dịch đang đọc một phản hồi HTML như JSON. Ảnh lỗi chưa cho biết máy chủ đã trả mã HTTP nào, nên không thể kết luận chỉ từ ảnh rằng lỗi do mạng, giới hạn dịch hay máy chủ ZaDark.

1. Đóng Zalo rồi chạy lại script cài đặt để lấy bản AppImage mới nhất; installer giữ bản trước ở `Zalo-x86_64.AppImage.previous`. Chọn ngôn ngữ đích trong ZaDark Settings và thử lại với một câu ngắn, không chứa thông tin riêng tư.
2. Nếu vẫn lỗi, mở `Ctrl+Shift+I` → **Network**, bấm dịch một câu thử, lọc `Fetch/XHR`. Kiểm tra **Status** và **Response Headers → Content-Type** của yêu cầu dịch. Nếu phản hồi là `text/html`, ghi lại **tên miền**, mã HTTP và phiên bản ZaDark; không chia sẻ URL đầy đủ, nội dung tin nhắn, cookie, token hoặc response body.
3. Nếu cùng lỗi trên ZaDark bản mới nhất, xem đây là lỗi ở tính năng/API dịch của ZaDark; repair FUSE, clipboard, đổi `--no-sandbox` hoặc xóa dữ liệu Zalo không xử lý được phản hồi dịch sai định dạng. Trong lúc chờ upstream sửa, sao chép đoạn cần dịch sang công cụ dịch tin cậy. Đừng xóa cache/database Zalo để thử sửa lỗi này.

Bộ cài này không sửa mã ZaDark bên trong AppImage và không bảo đảm API dịch của ZaDark luôn hoạt động.



## Ảnh cũ trong tin nhắn không về Linux

Nếu ảnh mới vẫn hiển thị nhưng ảnh cũ chỉ xem được trên điện thoại, đừng xóa cache/database Zalo hoặc cài lại trước khi sao lưu. Chạy `bash "$HOME/zalo-linux-chat-kit/backup-zalo-linux.sh"` để giữ dữ liệu Linux hiện tại. Đồng bộ tin nhắn không bảo đảm khôi phục mọi tệp ảnh cũ.

1. Chọn một ảnh cũ cụ thể. So sánh cùng tin nhắn trên **ứng dụng Zalo PC Windows/Mac mới đăng nhập** và bản Linux; Zalo Web có thể hiển thị lịch sử ngắn hơn nên không dùng làm mốc. Không xóa dữ liệu PC hoặc điện thoại đang xem được ảnh để thử lại: ảnh có thể chỉ còn trong cache của thiết bị cũ.
2. Nếu PC mới đăng nhập tải được ảnh nhưng Linux không tải được, ghi lại thời điểm tin nhắn, tên AppImage và trạng thái ảnh khi mở (trắng, xoay mãi hay báo lỗi). Có thể mở DevTools bằng `Ctrl+Shift+I` để kiểm tra Console/Network. Ẩn cookie, token, URL ảnh riêng tư và nội dung cuộc trò chuyện trước khi chia sẻ log. Đây là lỗi cần khoanh vùng trong AppImage upstream; bản Full hay `xclip` không tự sửa phần tải ảnh cũ.
3. Nếu ảnh chỉ xem được trên điện thoại hoặc PC đã dùng lâu, hãy lưu ảnh từ điện thoại về máy hoặc My Documents để giữ lại. Đồng bộ tin nhắn không bảo đảm tải được file ảnh cũ từ cache thiết bị khác.
4. Trên điện thoại, kiểm tra **Cá nhân → Cài đặt → Sao lưu và khôi phục** và tài khoản Google Drive liên kết. Theo [Zalo Help](https://help.zalo.me/huong-dan/chuyen-muc/quan-ly-tai-khoan-zalo/sao-luu-va-khoi-phuc/chi-tiet-ve-cac-du-lieu-duoc-zalo-sao-luu/), sao lưu ảnh chỉ kiểm tra ảnh gửi trong 120 ngày gần nhất tại thời điểm sao lưu; ảnh trong cộng đồng hoặc nhóm hơn 100 người không được sao lưu theo cách này. Đây là giới hạn sao lưu trên điện thoại, không phải giới hạn đồng bộ Zalo PC.

Ảnh quan trọng còn mở được trên điện thoại: lưu về máy hoặc My Documents ngay. Không gửi database, QR đăng nhập, token hay URL ảnh riêng tư lên issue công khai.



## Bản cập nhật không chạy

Installer giữ bản trước tại:

```text
~/.local/share/zalo-linux/Zalo-x86_64.AppImage.previous
```

Rollback an toàn:

```bash
mv ~/.local/share/zalo-linux/Zalo-x86_64.AppImage ~/.local/share/zalo-linux/Zalo-x86_64.AppImage.failed
mv ~/.local/share/zalo-linux/Zalo-x86_64.AppImage.previous ~/.local/share/zalo-linux/Zalo-x86_64.AppImage
chmod +x ~/.local/share/zalo-linux/Zalo-x86_64.AppImage
```

## Mất tin nhắn cũ

Không xóa database. Chạy backup trước, đăng nhập lại bằng QR và kích hoạt đồng bộ từ điện thoại. Nếu chỉ bản Linux không thấy lịch sử, kiểm tra lại bằng Zalo Web/Windows trước khi phục hồi database.
