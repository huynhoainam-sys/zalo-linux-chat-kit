# Zalo Linux Chat Kit

Cài nhanh Zalo trên Ubuntu/Linux Mint, ưu tiên nhắn tin, lịch sử chat, hình ảnh và backup local.

## Cài một lần bằng một dòng

```bash
(command -v curl >/dev/null && curl -fsSL https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/install-zalo-linux.sh || wget -qO- https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/install-zalo-linux.sh) | bash
```

Mặc định cài bản `chat` x86_64, không cài Wine/call/video: nhẹ hơn và tập trung vào tin nhắn, lịch sử và hình ảnh. Script tự quét và cài dependency còn thiếu: FUSE, curl, Python 3, clipboard X11/Wayland, desktop integration và notification. Cần tài khoản có quyền `sudo` trên Ubuntu/Linux Mint.

Nếu sau này cần bản Full:

```bash
ZALO_VARIANT=full bash -c "$(curl -fsSL https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/install-zalo-linux.sh)"
```

Xem [HUONG-DAN-ZALO-LINUX.md](HUONG-DAN-ZALO-LINUX.md) để đồng bộ lịch sử và ảnh.

Installer trích xuất icon Zalo từ AppImage và tạo launcher trong menu ứng dụng. Icon `Zalo Linux` mở AppImage với `--no-sandbox` cho cả bản Chat và Full để tránh lỗi SUID sandbox trên Ubuntu. Cách này giảm bảo vệ riêng của ứng dụng; chỉ dùng AppImage từ nguồn tin cậy. Nếu máy hỗ trợ sandbox Electron và muốn bật lại, chạy `ZALO_SANDBOX=1 ~/.local/bin/zalo-linux`.

Nếu lỗi runtime, chạy [zalo-repair.sh](zalo-repair.sh). Xem [TROUBLESHOOTING.md](TROUBLESHOOTING.md) để rollback mà không xóa dữ liệu chat.

## Gỡ cài đặt

```bash
curl -fsSL https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/zalo-uninstall.sh | bash
```

Lệnh chỉ gỡ AppImage/launcher; database chat vẫn được giữ lại.

Hỗ trợ chính: Ubuntu/Mint x86_64. ARM64 không được chọn vì release upstream và native module không tương đương x86_64.
