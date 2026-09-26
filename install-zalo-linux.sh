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
curl --fail --location --silent --show-error "$API" -o "$tmp"
readarray -t META < <(python3 - "$tmp" "$VARIANT" <<'PY'
import json,sys
d=json.load(open(sys.argv[1],encoding='utf-8'))
a=[x for x in d.get('assets',[]) if x['name'].endswith('x86_64.AppImage') and (('Full' in x['name']) if sys.argv[2]=='full' else ('Full' not in x['name']))]
if not a: raise SystemExit('Không tìm thấy AppImage x86_64 thường')
x=a[0]; print(d.get('tag_name','unknown')); print(x['name']); print(x['browser_download_url']); print(x.get('digest',''))
PY
)
TAG="${META[0]}"; NAME="${META[1]}"; URL="${META[2]}"; DIGEST="${META[3]}"
info "Release $TAG — $NAME"
curl --fail --location --progress-bar "$URL" -o "$APPIMAGE.part"
if [[ "$DIGEST" == sha256:* ]]; then
  [[ "${DIGEST#sha256:}" == "$(sha256sum "$APPIMAGE.part" | awk '{print $1}')" ]] || { rm -f "$APPIMAGE.part"; die "Checksum không khớp; giữ nguyên bản đang cài"; }
  info "Checksum SHA-256: OK"
else info "Release không cung cấp digest API; bỏ qua checksum"; fi
if [[ -f "$APPIMAGE" ]]; then mv -f "$APPIMAGE" "$APPIMAGE.previous"; fi
mv "$APPIMAGE.part" "$APPIMAGE"; chmod 0755 "$APPIMAGE"
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
