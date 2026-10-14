# Zalo Linux Chat Kit

Cài Zalo cộng đồng trên Ubuntu/Linux Mint, ưu tiên tin nhắn, lịch sử chat, hình ảnh và sao lưu local.

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

Mặc định script chọn bản `chat` x86_64 (không kèm Wine/call/video), tự kiểm tra và cài các dependency còn thiếu khi có quyền `sudo`. Nếu muốn bản Full, sau khi đã tải/cập nhật repo, chạy:

```bash
ZALO_VARIANT=full bash "$HOME/zalo-linux-chat-kit/install-zalo-linux.sh"
```

> Không sử dụng lệnh `curl ... | bash` trong trường hợp URL chưa tải thành công. Nếu `git clone` cũng lỗi, kiểm tra mạng/proxy hoặc thử mạng khác trước; installer vẫn cần truy cập `api.github.com` và GitHub Releases để tải AppImage. Không xóa dữ liệu chat khi xử lý lỗi cài.

## Hướng dẫn và sửa lỗi

- [Đồng bộ tin nhắn, hình ảnh và backup](HUONG-DAN-ZALO-LINUX.md)
- [Xử lý lỗi, FUSE và rollback an toàn](TROUBLESHOOTING.md)

Installer trích xuất icon từ AppImage, tạo launcher `Zalo Linux` và chạy Electron với `--no-sandbox` để tránh lỗi SUID trên một số bản Ubuntu. Cờ này làm giảm mức bảo vệ của ứng dụng; chỉ sử dụng AppImage từ nguồn tin cậy. Nếu hệ thống hỗ trợ sandbox, thử `ZALO_SANDBOX=1 "$HOME/.local/bin/zalo-linux"`.

**Sửa launcher/runtime (giữ nguyên dữ liệu chat):**

```bash
bash "$HOME/zalo-linux-chat-kit/zalo-repair.sh"
```

**Gỡ ứng dụng (không xóa database chat):**

```bash
bash "$HOME/zalo-linux-chat-kit/zalo-uninstall.sh"
```

Bộ cài này dành cho Ubuntu/Linux Mint x86_64; không bảo đảm hỗ trợ đầy đủ ARM64.
