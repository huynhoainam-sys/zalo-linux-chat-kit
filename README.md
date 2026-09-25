# Zalo Linux Chat Kit

Cài nhanh Zalo trên Ubuntu/Linux Mint, ưu tiên nhắn tin, lịch sử chat, hình ảnh và backup local.

## Cài một lần bằng một dòng

```bash
curl -fsSL https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/install-zalo-linux.sh | bash
```

Mặc định cài bản `Full` x86_64 để có trải nghiệm gần Windows nhất, gồm Wine bridge cho gọi thoại/video. Script tự quét và cài dependency còn thiếu: FUSE, đồ họa 32-bit, curl, Python 3, clipboard X11/Wayland, desktop integration và notification. Cần tài khoản có quyền `sudo` trên Ubuntu/Linux Mint.

Chỉ muốn bản chat nhẹ hơn:

```bash
ZALO_VARIANT=chat bash -c "$(curl -fsSL https://raw.githubusercontent.com/huynhoainam-sys/zalo-linux-chat-kit/main/install-zalo-linux.sh)"
```

Xem [HUONG-DAN-ZALO-LINUX.md](HUONG-DAN-ZALO-LINUX.md) để đồng bộ lịch sử và ảnh.
