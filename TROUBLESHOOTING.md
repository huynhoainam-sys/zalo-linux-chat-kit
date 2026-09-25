# Quy tắc xử lý lỗi

## Zalo không mở / báo FUSE

```bash
curl -fsSL https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/zalo-repair.sh | bash
```

Launcher tự bật `APPIMAGE_EXTRACT_AND_RUN=1` khi máy thiếu FUSE. Không xóa `~/.config/ZaloApp` hoặc `~/.local/share/ZaloData`.

## Không dán được ảnh

Chạy repair để cài `xclip` và `wl-clipboard`, sau đó đăng xuất/đăng nhập lại desktop nếu clipboard portal chưa hoạt động.

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
