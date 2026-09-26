# Quy tắc xử lý lỗi

## Zalo không mở / báo FUSE

```bash
curl -fsSL https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/zalo-repair.sh | bash
```

Launcher tự bật `APPIMAGE_EXTRACT_AND_RUN=1` khi máy thiếu FUSE. Không xóa `~/.config/ZaloApp` hoặc `~/.local/share/ZaloData`.

## Bấm icon nhưng Zalo không mở (SUID sandbox)

Chạy `~/.local/bin/zalo-linux` trong Terminal. Nếu thấy `The SUID sandbox helper binary was found, but is not configured correctly`, cài lại hoặc chạy repair để cập nhật launcher. Launcher dùng `--no-sandbox` mặc định cho cả bản Chat và Full. Đặt `ZALO_SANDBOX=1` để thử chế độ sandbox trên máy có hỗ trợ. Khi phải tắt sandbox, Electron giảm bảo vệ của ứng dụng Zalo; chỉ chạy AppImage từ nguồn tin cậy. Repair cũng khôi phục icon và desktop entry. Nếu trước đây tạo icon thủ công `Zalo Linux (AppImage)`, có thể bỏ ghim và xóa lối tắt cũ sau khi xác nhận icon `Zalo Linux` mới mở được.

## Không dán được ảnh

Chạy repair để cài `xclip` và `wl-clipboard`, sau đó đăng xuất/đăng nhập lại desktop nếu clipboard portal chưa hoạt động.

## Ảnh cũ trong tin nhắn không về Linux

Nếu ảnh mới vẫn hiển thị nhưng ảnh cũ chỉ xem được trên điện thoại, đừng xóa cache/database Zalo hoặc cài lại trước khi sao lưu. Chạy `curl -fsSL https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/backup-zalo-linux.sh | bash` để giữ dữ liệu Linux hiện tại. Đồng bộ tin nhắn không bảo đảm khôi phục mọi tệp ảnh cũ.

1. Chọn một ảnh cũ cụ thể, mở lại cùng cuộc trò chuyện trên điện thoại và trên Zalo Web hoặc Zalo PC được hỗ trợ. Nếu thiết bị khác cũng thiếu ảnh, installer/repair Linux không thể tạo lại tệp đó. Hãy lưu ảnh từ điện thoại về máy hoặc lưu vào My Documents rồi chuyển sang máy tính.
2. Nếu Zalo Web/PC xem được ảnh đó nhưng bản Linux không xem được, ghi lại thời điểm tin nhắn, bản AppImage và lỗi khi chạy `~/.local/bin/zalo-linux` từ Terminal (ẩn nội dung riêng tư). Đây là lỗi cần khoanh vùng trong AppImage upstream; đổi sang bản Full hay cài `xclip` không tự sửa phần tải ảnh cũ.
3. Trên điện thoại, kiểm tra **Cá nhân → Cài đặt → Sao lưu và khôi phục** và tài khoản Google Drive liên kết. Theo [Zalo Help](https://help.zalo.me/huong-dan/chuyen-muc/quan-ly-tai-khoan-zalo/sao-luu-va-khoi-phuc/chi-tiet-ve-cac-du-lieu-duoc-zalo-sao-luu/), sao lưu ảnh chỉ kiểm tra ảnh gửi trong 120 ngày gần nhất tại thời điểm sao lưu; ảnh trong cộng đồng hoặc nhóm hơn 100 người không được sao lưu theo cách này. Ảnh đã lưu trước đó vẫn phụ thuộc bản sao lưu thực tế.

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
