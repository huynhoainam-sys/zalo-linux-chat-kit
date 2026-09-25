#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zalo-linux"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
rm -f "$BIN_DIR/zalo-linux" "$DESKTOP_DIR/zalo-linux.desktop"
if [[ "${ZALO_REMOVE_APPIMAGE:-0}" == "1" ]]; then
  rm -f "$APP_DIR/Zalo-x86_64.AppImage" "$APP_DIR/Zalo-x86_64.AppImage.previous" "$APP_DIR/Zalo-x86_64.AppImage.failed"
fi
command -v update-desktop-database >/dev/null && update-desktop-database "$DESKTOP_DIR" || true
echo "Đã gỡ launcher. Dữ liệu chat giữ nguyên tại các thư mục Zalo local."
echo "Muốn xóa AppImage cũng dùng: ZALO_REMOVE_APPIMAGE=1 bash zalo-uninstall.sh"
