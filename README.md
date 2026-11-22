# Zalo Linux Chat Kit

Cài Zalo cộng đồng trên Ubuntu/Linux Mint, ưu tiên tin nhắn, lịch sử chat, hình ảnh và sao lưu local.

> Trên Ubuntu 24.04 GNOME/Wayland, nên cài đồng bộ tiếng Việt + Flameshot + Zalo qua [Universal Linux Office Kit](https://github.com/huynhoainam-sys/universal-linux-office-kit) với `--repair-desktop`. Bộ cài này vẫn có thể chạy độc lập.

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

**Khi GitHub API báo 403:** installer tự thử bản upstream cố định đã xác minh (`26.10.11`, SHA-256 cho Chat/Full). Đây là fallback, không bảo đảm mới nhất. Nếu GitHub Releases cũng bị chặn, cần kiểm tra proxy/tường lửa hoặc đổi mạng. Script sẽ không thay AppImage đang chạy nếu tải lỗi hoặc checksum sai.

Nếu GitHub API truy cập được nhưng release hiện tại không có biến thể `full`, script báo lỗi rõ ràng thay vì tự hạ xuống một phiên bản cũ. Bản `chat` là lựa chọn khuyến nghị; upstream release `26.11.10` có bản Chat x86_64 nhưng không có gói `Full`. Bản Full cũ có thể phải cài thư viện i386 và tốn thêm dung lượng.

Khi cập nhật, installer kiểm tra SHA-256 nếu upstream cung cấp, kiểm tra định dạng ELF, giữ bản AppImage trước tại `Zalo-x86_64.AppImage.previous` và tự sao lưu dữ liệu chat nếu còn đủ dung lượng. Nếu proxy FPT chặn GitHub Releases nhưng đã có Zalo, bộ cài giữ nguyên bản cũ. Không tự đổi proxy, không xóa dữ liệu chat và không bỏ qua checksum.

Trên GNOME Wayland, launcher mặc định khởi chạy Zalo bằng chế độ tương thích XWayland với biến môi trường IBus chỉ áp dụng cho ứng dụng. Nếu gõ tiếng Việt chưa ổn định, thử:

```bash
ZALO_OZONE_PLATFORM=auto "$HOME/.local/bin/zalo-linux"
```

Đây là chế độ Electron Wayland mặc định mới; chế độ `x11` có thể khôi phục bằng `ZALO_OZONE_PLATFORM=x11`. Cần đăng xuất/đăng nhập sau khi đổi bộ gõ ở Office Kit rồi thử gõ trong hộp chat Zalo.

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
