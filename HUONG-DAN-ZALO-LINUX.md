# Zalo Linux — cài nhanh, ưu tiên tin nhắn và hình ảnh

Bộ cài dùng AppImage x86_64, cài theo user và không đụng database Windows.

## Cài đặt trên Ubuntu/Linux Mint (khuyến nghị)

Cách này tải script bằng `git clone`, không phụ thuộc `raw.githubusercontent.com` — địa chỉ đang trả lỗi HTTP 403 trên một số mạng. Cần Ubuntu/Linux Mint **x86_64**, tài khoản có quyền `sudo` và kết nối tới GitHub để tải bản phát hành.

**Cài lần đầu:** sao chép toàn bộ khối lệnh vào Terminal.

```bash
sudo apt-get update && sudo apt-get install -y git
git clone --depth 1 https://github.com/huynhoainam-sys/zalo-linux-chat-kit.git "$HOME/zalo-linux-chat-kit"
bash -n "$HOME/zalo-linux-chat-kit/install-zalo-linux.sh" && bash "$HOME/zalo-linux-chat-kit/install-zalo-linux.sh"
```

**Nếu đã tải repository trước đây:** không chạy lại `git clone` vào thư mục cũ; cập nhật và cài lại:

```bash
git -C "$HOME/zalo-linux-chat-kit" pull --ff-only
bash -n "$HOME/zalo-linux-chat-kit/install-zalo-linux.sh" && bash "$HOME/zalo-linux-chat-kit/install-zalo-linux.sh"
```

**Mở Zalo:**

```bash
"$HOME/.local/bin/zalo-linux"
```

Nếu `curl: (22) ... 403` xuất hiện **sau khi clone thành công**, cập nhật bộ cài bằng `git pull` theo lệnh ở trên: installer sẽ thử bản upstream cố định `26.10.11` với kiểm tra SHA-256 khi GitHub API không phản hồi. Nếu GitHub Releases cũng bị chặn, cần đổi mạng hoặc liên hệ quản trị mạng; không xóa dữ liệu Zalo.

Mặc định script chọn bản `chat` x86_64 (không kèm Wine/call/video), tự kiểm tra và cài các dependency còn thiếu khi có quyền `sudo`. Nếu muốn bản Full, sau khi đã tải/cập nhật repo, chạy:

```bash
ZALO_VARIANT=full bash "$HOME/zalo-linux-chat-kit/install-zalo-linux.sh"
```

> Không sử dụng lệnh `curl ... | bash` trong trường hợp URL chưa tải thành công. Nếu `git clone` cũng lỗi, kiểm tra mạng/proxy hoặc thử mạng khác trước; installer vẫn cần truy cập `api.github.com` và GitHub Releases để tải AppImage. Không xóa dữ liệu chat khi xử lý lỗi cài.

Khi cần tự cài dependency, Ubuntu 24.04 thường sử dụng `libfuse2t64`; bộ cài sẽ tự chọn gói FUSE tương ứng nếu kho apt có.

## Đồng bộ tin nhắn cũ và kiểm tra ảnh

1. Đăng nhập bằng QR.
2. Trên điện thoại mở Cài đặt Zalo, tìm `Đồng bộ tin nhắn` hoặc `Đồng bộ tin nhắn với máy tính`.
3. Chọn đồng bộ về máy tính và chờ hoàn tất.
4. Mở các cuộc trò chuyện quan trọng, cuộn về tin cũ, mở ảnh và thử tìm bằng từ khóa.

Không copy thủ công thư mục Zalo từ Windows; dữ liệu E2EE/khóa thiết bị có thể không tương thích.

## Backup trước khi update

```bash
bash "$HOME/zalo-linux-chat-kit/backup-zalo-linux.sh"
```

## Kiểm tra lỗi

```bash
bash "$HOME/zalo-linux-chat-kit/zalo-doctor.sh"
```

Doctor kiểm tra FUSE, curl, python3 và clipboard của phiên đồ họa đang dùng. Khi thiếu FUSE 2, launcher dùng chế độ giải nén AppImage và doctor chỉ ghi chú. Doctor không thể xác nhận ảnh cũ đã tải được.

Bản `chat` và `full` dùng cùng cơ chế tin nhắn/ảnh của AppImage upstream; chuyển sang `full` không tự khôi phục ảnh cũ. Nếu tin nhắn đã về nhưng ảnh cũ thiếu, xem [hướng dẫn kiểm tra ảnh cũ](TROUBLESHOOTING.md#ảnh-cũ-trong-tin-nhắn-không-về-linux). So sánh với **Zalo PC mới đăng nhập**, không dùng Zalo Web làm mốc. Ảnh chỉ còn trên điện thoại cũ cần được lưu lại từ điện thoại.

## Gỡ cài đặt an toàn

```bash
bash "$HOME/zalo-linux-chat-kit/zalo-uninstall.sh"
```

Lệnh không xóa dữ liệu chat. Ubuntu/Mint x86_64 là mục tiêu chính; ARM64 không được cam kết.
