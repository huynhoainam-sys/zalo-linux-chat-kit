# Zalo Linux — cài nhanh, ưu tiên tin nhắn và hình ảnh

Bộ cài dùng AppImage x86_64, cài theo user và không đụng database Windows.

## Cài đặt

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

## Đồng bộ tin nhắn cũ và ảnh

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

Doctor phải báo đủ FUSE, curl, python3, xclip và wl-clipboard trước khi kiểm tra dán ảnh.

Bản thường ưu tiên chat, ảnh, file và tìm kiếm. Bản `Full` chỉ nên dùng khi cần gọi thoại/video vì lớn hơn và có thêm Wine. Lịch sử nhiều năm chỉ khôi phục được nếu Zalo còn dữ liệu/backup cho phép đồng bộ.
