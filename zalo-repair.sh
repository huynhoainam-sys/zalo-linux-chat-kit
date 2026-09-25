#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zalo-linux"
APPIMAGE="$APP_DIR/Zalo-x86_64.AppImage"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
echo "[ZALO-REPAIR] Không xóa database chat; chỉ sửa runtime/launcher/dependency."

if command -v apt-get >/dev/null && command -v sudo >/dev/null; then
  need=()
  command -v curl >/dev/null || need+=(curl)
  command -v python3 >/dev/null || need+=(python3)
  command -v xclip >/dev/null || need+=(xclip)
  command -v wl-paste >/dev/null || need+=(wl-clipboard)
  command -v update-desktop-database >/dev/null || need+=(desktop-file-utils)
  command -v notify-send >/dev/null || need+=(libnotify-bin)
  if ! ldconfig -p 2>/dev/null | grep -q 'libfuse.so.2'; then
    apt-cache show libfuse2t64 >/dev/null 2>&1 && need+=(libfuse2t64) || need+=(libfuse2)
  fi
  if (( ${#need[@]} )); then sudo apt-get update && sudo apt-get install -y "${need[@]}"; fi
fi

[[ -f "$APPIMAGE" ]] || { echo "Chưa có AppImage; chạy lại install-zalo-linux.sh" >&2; exit 1; }
chmod 0755 "$APPIMAGE"
rm -f "$APPIMAGE.part"
mkdir -p "$BIN_DIR"
cat > "$BIN_DIR/zalo-linux" <<EOF
#!/usr/bin/env bash
if ! ldconfig -p 2>/dev/null | grep -q 'libfuse.so.2'; then export APPIMAGE_EXTRACT_AND_RUN=1; fi
exec "$APPIMAGE" "\$@"
EOF
chmod 0755 "$BIN_DIR/zalo-linux"
if ! ldconfig -p 2>/dev/null | grep -q 'libfuse.so.2'; then export APPIMAGE_EXTRACT_AND_RUN=1; fi
"$APPIMAGE" --appimage-version >/dev/null 2>&1 || echo "[WARN] AppImage không trả version; thử rollback nếu app không mở."
echo "Đã sửa launcher/runtime. Dữ liệu chat không bị xóa."
