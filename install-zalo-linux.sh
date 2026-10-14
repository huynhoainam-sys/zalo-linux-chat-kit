#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${ZALO_REPO:-VN-Linux-Family/zalo-for-linux}"
VARIANT="${ZALO_VARIANT:-chat}"
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zalo-linux"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
APPIMAGE="$APP_DIR/Zalo-x86_64.AppImage"
API="https://api.github.com/repos/$REPO/releases/latest"
die(){ echo "[ZALO-ERROR] $*" >&2; exit 1; }
info(){ echo "[ZALO] $*"; }
[[ "$(uname -m)" == "x86_64" ]] || die "Bản này dành cho Intel/AMD x86_64"
[[ "$VARIANT" == "full" || "$VARIANT" == "chat" ]] || die "ZALO_VARIANT chỉ nhận full hoặc chat"
if ! command -v apt-get >/dev/null || ! command -v sudo >/dev/null; then
  command -v curl >/dev/null || die "Thiếu curl; cài curl thủ công"
  command -v python3 >/dev/null || die "Thiếu python3; cài python3 thủ công"
else
  need=()
  command -v curl >/dev/null || need+=(curl)
  if [[ "$VARIANT" == "full" && -f /usr/bin/dpkg ]]; then
    sudo dpkg --add-architecture i386 >/dev/null 2>&1 || true
    need+=(libgl1 libgl1:i386 libegl1 libegl1:i386 libvulkan1 libvulkan1:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386)
  fi
  command -v python3 >/dev/null || need+=(python3)
  command -v xclip >/dev/null || need+=(xclip)
  command -v wl-paste >/dev/null || need+=(wl-clipboard)
  command -v update-desktop-database >/dev/null || need+=(desktop-file-utils)
  command -v notify-send >/dev/null || need+=(libnotify-bin)
  command -v curl >/dev/null || need+=(ca-certificates)
  if ! ldconfig -p 2>/dev/null | grep -q 'libfuse.so.2'; then
    if apt-cache show libfuse2t64 >/dev/null 2>&1; then need+=(libfuse2t64); else need+=(libfuse2); fi
  fi
  if (( ${#need[@]} )); then
    info "Cài dependency: ${need[*]}"
    sudo apt-get update
    sudo apt-get install -y "${need[@]}"
  fi
fi
mkdir -p "$APP_DIR" "$BIN_DIR" "$DESKTOP_DIR"
tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
# Thu thập metadata tự động. Nếu API bị HTTP 403 hoặc JSON lỗi, fallback sang
# một release chính thức đã xác minh tên file và SHA-256 (không xóa bản đang cài).
metadata=""
if curl --fail --location --silent --show-error --connect-timeout 20 "$API" -o "$tmp"; then
  metadata="$(python3 - "$tmp" "$VARIANT" <<'PY'
  import json,sys
  d=json.load(open(sys.argv[1],encoding='utf-8'))
  suffix='-Full-x86_64.AppImage' if sys.argv[2]=='full' else '-x86_64.AppImage'
  a=[x for x in d.get('assets',[]) if x.get('name','').endswith(suffix) and '+ZaDark-' in x['name'] and (sys.argv[2]=='full' or '-Full-' not in x['name'])]
  if not a: raise SystemExit('Không tìm thấy AppImage ZaDark x86_64 đúng biến thể')
  if len(a) != 1: raise SystemExit('Có nhiều AppImage ZaDark cùng biến thể; cần chọn thủ công')
  x=a[0]
  print(d.get('tag_name','unknown')); print(x['name']); print(x['browser_download_url']); print(x.get('digest') or '-')
  PY
  )" || metadata=""
else
  info "Không truy cập được GitHub Releases API; thử bản dự phòng đã xác minh."
fi
if [[ -n "$metadata" ]]; then
  readarray -t META <<< "$metadata"
  (( ${#META[@]} == 4 )) || die "Metadata release thiếu trường; giữ nguyên bản đang cài"
  TAG="${META[0]}"; NAME="${META[1]}"; URL="${META[2]}"; DIGEST="${META[3]}"
else
  [[ "$REPO" == "VN-Linux-Family/zalo-for-linux" ]] || die "Không có fallback đã xác minh cho ZALO_REPO=$REPO"
  TAG="26.10.11"
  if [[ "$VARIANT" == "full" ]]; then
    NAME="Zalo-26.10.11+ZaDark-26.2.1-e80931a-Full-x86_64.AppImage"
    URL="https://github.com/VN-Linux-Family/zalo-for-linux/releases/download/26.10.11/Zalo-26.10.11%2BZaDark-26.2.1-e80931a-Full-x86_64.AppImage"
    DIGEST="sha256:daaee9684daf60bec96eb097bd4fcb623980452d3805ccc949dddaf5da3ea77b"
  else
    NAME="Zalo-26.10.11+ZaDark-26.2.1-e80931a-x86_64.AppImage"
    URL="https://github.com/VN-Linux-Family/zalo-for-linux/releases/download/26.10.11/Zalo-26.10.11%2BZaDark-26.2.1-e80931a-x86_64.AppImage"
    DIGEST="sha256:7a58408a88a2a430c072e5ed34465b38dd1b3328cc83e97efeb90cfd9964c31a"
  fi
  info "Dùng release dự phòng cố định $TAG vì GitHub API không truy cập được."
fi
info "Release $TAG — $NAME"
if ! curl --fail --location --progress-bar --retry 2 --connect-timeout 20 "$URL" -o "$APPIMAGE.part"; then
  rm -f "$APPIMAGE.part"
  die "Không tải được AppImage từ GitHub Releases. Kiểm tra URL, proxy/tường lửa hoặc thử mạng khác; Zalo hiện tại vẫn được giữ."
fi
if [[ "$DIGEST" == sha256:* ]]; then
  [[ "${DIGEST#sha256:}" == "$(sha256sum "$APPIMAGE.part" | awk '{print $1}')" ]] || { rm -f "$APPIMAGE.part"; die "Checksum không khớp; giữ nguyên bản đang cài"; }
  info "Checksum SHA-256: OK"
else info "Release không cung cấp digest API; bỏ qua checksum"; fi
chmod 0755 "$APPIMAGE.part"
if [[ -f "$APPIMAGE" ]]; then
  ln -f -- "$APPIMAGE" "$APPIMAGE.previous.tmp"
  mv -f -- "$APPIMAGE.previous.tmp" "$APPIMAGE.previous"
fi
mv -f -- "$APPIMAGE.part" "$APPIMAGE"
cat > "$BIN_DIR/zalo-linux" <<'EOF'
#!/usr/bin/env bash
APPIMAGE="${XDG_DATA_HOME:-$HOME/.local/share}/zalo-linux/Zalo-x86_64.AppImage"
if ! ldconfig -p 2>/dev/null | grep -q 'libfuse.so.2'; then export APPIMAGE_EXTRACT_AND_RUN=1; fi
# AppImage mount is user-owned, so Electron's setuid helper cannot start on affected Ubuntu systems.
# ZALO_SANDBOX=1 restores the upstream launch mode when the host supports it.
if [[ "${ZALO_SANDBOX:-0}" == 1 ]]; then exec "$APPIMAGE" "$@"; fi
exec "$APPIMAGE" --no-sandbox "$@"
EOF
chmod 0755 "$BIN_DIR/zalo-linux"
ICON_PATH="$APP_DIR/zalo.png"
icon_tmp="$(mktemp -d)"
if (cd "$icon_tmp" && "$APPIMAGE" --appimage-extract 'app/pc-dist/favicon-512x512.png' >/dev/null 2>&1) && [[ -s "$icon_tmp/squashfs-root/app/pc-dist/favicon-512x512.png" ]]; then
  cp "$icon_tmp/squashfs-root/app/pc-dist/favicon-512x512.png" "$ICON_PATH"
else
  echo "[ZALO] Không trích xuất được icon; dùng icon hệ thống." >&2
fi
rm -r -- "$icon_tmp"
if [[ -s "$ICON_PATH" ]]; then DESKTOP_ICON="$ICON_PATH"; else DESKTOP_ICON=applications-internet; fi
cat > "$DESKTOP_DIR/zalo-linux.desktop" <<EOF
[Desktop Entry]
Name=Zalo Linux
Comment=Zalo messaging client for Linux
Exec=$BIN_DIR/zalo-linux %U
Icon=$DESKTOP_ICON
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupWMClass=zalo
EOF
command -v update-desktop-database >/dev/null && update-desktop-database "$DESKTOP_DIR" || true
info "Đã cài $APPIMAGE"
info "Chạy: $BIN_DIR/zalo-linux"
