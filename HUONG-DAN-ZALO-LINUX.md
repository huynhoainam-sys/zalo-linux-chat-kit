# Zalo Linux — cài nhanh, ưu tiên tin nhắn và hình ảnh

Bộ cài dùng AppImage x86_64, cài theo user và không đụng database Windows.

## Cài đặt

Một dòng duy nhất:

```bash
(command -v curl >/dev/null && curl -fsSL https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/install-zalo-linux.sh || wget -qO- https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/install-zalo-linux.sh) | bash
```

Mặc định script chọn bản `chat` x86_64, không cài Wine/call/video. Script tự quét và cài dependency runtime/clipboard còn thiếu; việc tải ảnh cũ phụ thuộc dữ liệu Zalo còn lưu.

Hoặc tải script về để kiểm tra trước:

```bash
chmod +x install-zalo-linux.sh backup-zalo-linux.sh zalo-doctor.sh
./install-zalo-linux.sh
~/.local/bin/zalo-linux
```

 Script sẽ tự cài `curl`, `python3`, `xclip`, `wl-clipboard` và FUSE nếu máy có `sudo`. Nếu cần cài thủ công:

```bash
sudo apt update
sudo apt install -y curl python3 xclip wl-clipboard libfuse2
```

Ubuntu 24.04 có thể dùng `libfuse2t64` thay cho `libfuse2`.

## Đồng bộ tin nhắn cũ và kiểm tra ảnh

1. Đăng nhập bằng QR.
2. Trên điện thoại mở Cài đặt Zalo, tìm `Đồng bộ tin nhắn` hoặc `Đồng bộ tin nhắn với máy tính`.
3. Chọn đồng bộ về máy tính và chờ hoàn tất.
4. Mở các cuộc trò chuyện quan trọng, cuộn về tin cũ, mở ảnh và thử tìm bằng từ khóa.

Không copy thủ công thư mục Zalo từ Windows; dữ liệu E2EE/khóa thiết bị có thể không tương thích.

## Backup trước khi update

```bash
./backup-zalo-linux.sh
```

## Kiểm tra lỗi

```bash
./zalo-doctor.sh
```

Doctor kiểm tra FUSE, curl, python3 và clipboard của phiên đồ họa đang dùng. Khi thiếu FUSE 2, launcher dùng chế độ giải nén AppImage và doctor chỉ ghi chú. Doctor không thể xác nhận ảnh cũ đã tải được.

Bản `chat` và `full` dùng cùng cơ chế tin nhắn/ảnh của AppImage upstream; chuyển sang `full` không tự khôi phục ảnh cũ. Nếu tin nhắn đã về nhưng ảnh cũ thiếu, xem [hướng dẫn kiểm tra ảnh cũ](TROUBLESHOOTING.md#ảnh-cũ-trong-tin-nhắn-không-về-linux). So sánh với **Zalo PC mới đăng nhập**, không dùng Zalo Web làm mốc. Ảnh chỉ còn trên điện thoại cũ cần được lưu lại từ điện thoại.

## Gỡ cài đặt an toàn

```bash
curl -fsSL https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/zalo-uninstall.sh | bash
```

Lệnh không xóa dữ liệu chat. Ubuntu/Mint x86_64 là mục tiêu chính; ARM64 không được cam kết.
