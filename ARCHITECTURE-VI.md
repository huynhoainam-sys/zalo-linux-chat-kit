# Kiến trúc Zalo Linux

Đây là port cộng đồng, không phải client Linux chính thức của VNG.

```text
AppImage
  └─ Electron shell Linux
      ├─ mã JavaScript/React của Zalo desktop macOS
      ├─ SQLite native Linux
      ├─ db-cross-v4 Linux native
      │   └─ giải mã/khôi phục backup và đồng bộ E2EE
      ├─ zimage/zjxl/mp4thumb
      │   └─ xử lý ảnh, thumbnail và định dạng media
      └─ zcall-bridge + Wine (chỉ bản Full x86_64)
          └─ gọi thoại/video qua binary Windows của Zalo
```

## Vì sao không dùng Zalo Windows qua Wine làm mặc định?

Zalo PC là Electron nhưng có nhiều native module phụ thuộc Windows/macOS. Chạy nguyên bản Windows qua Wine thường gặp lỗi font, GPU, QR, đồng bộ và cuộc gọi. Port Linux giữ phần renderer/mạng của client macOS, thay các module quan trọng bằng bản Linux; riêng `zcall` dùng Wine bridge.

## Đồng bộ tin nhắn và hình ảnh

- Tin nhắn E2EE cần `db-cross-v4` Linux native.
- Database local dùng SQLite và các worker riêng của Zalo.
- Ảnh clipboard cần `xclip` trên X11 hoặc `wl-clipboard` trên Wayland.
- Bản Full thêm Wine và thư viện đồ họa i386 để hỗ trợ cuộc gọi.

## Giới hạn không thể hứa như Windows

- Không có bảo đảm chính thức từ VNG.
- Zalo đổi phiên bản/protocol có thể làm port lỗi.
- Lịch sử chỉ khôi phục được phần còn có trong backup hoặc được Zalo cho phép đồng bộ.
- ARM64 không có đường gọi đầy đủ như x86_64.
