#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${ZALO_REPO:-VN-Linux-Family/zalo-for-linux}"
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zalo-linux"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
APPIMAGE="$APP_DIR/Zalo-x86_64.AppImage"
API="https://api.github.com/repos/$REPO/releases/latest"
die(){ echo "[ZALO-ERROR] $*" >&2; exit 1; }
info(){ echo "[ZALO] $*"; }
[[ "$(uname -m)" == "x86_64" ]] || die "Bản này dành cho Intel/AMD x86_64"
if ! command -v apt-get >/dev/null || ! command -v sudo >/dev/null; then
  command -v curl >/dev/null || die "Thiếu curl; cài curl thủ công"
  command -v python3 >/dev/null || die "Thiếu python3; cài python3 thủ công"
else
  need=()
  command -v curl >/dev/null || need+=(curl)
  command -v python3 >/dev/null || need+=(python3)
  command -v xclip >/dev/null || need+=(xclip)
  command -v wl-paste >/dev/null || need+=(wl-clipboard)
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
readarray -t META < <(python3 - "$tmp" <<'PY'
import json,sys
d=json.load(open(sys.argv[1],encoding='utf-8'))
a=[x for x in d.get('assets',[]) if x['name'].endswith('x86_64.AppImage') and 'Full' not in x['name']]
if not a: raise SystemExit('Không tìm thấy AppImage x86_64 thường')
x=a[0]; print(d.get('tag_name','unknown')); print(x['name']); print(x['browser_download_url']); print(x.get('digest',''))
PY
)
TAG="${META[0]}"; NAME="${META[1]}"; URL="${META[2]}"; DIGEST="${META[3]}"
info "Release $TAG — $NAME"
curl --fail --location --progress-bar "$URL" -o "$APPIMAGE.part"
mv "$APPIMAGE.part" "$APPIMAGE"; chmod 0755 "$APPIMAGE"
if [[ "$DIGEST" == sha256:* ]]; then
  [[ "${DIGEST#sha256:}" == "$(sha256sum "$APPIMAGE" | awk '{print $1}')" ]] || die "Checksum không khớp"
  info "Checksum SHA-256: OK"
else info "Release không cung cấp digest API; bỏ qua checksum"; fi
cat > "$BIN_DIR/zalo-linux" <<EOF
#!/usr/bin/env bash
exec "$APPIMAGE" "\$@"
EOF
chmod 0755 "$BIN_DIR/zalo-linux"
cat > "$DESKTOP_DIR/zalo-linux.desktop" <<EOF
[Desktop Entry]
Name=Zalo Linux
Comment=Zalo messaging client for Linux
Exec=$BIN_DIR/zalo-linux %U
Icon=applications-internet
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupWMClass=zalo
EOF
command -v update-desktop-database >/dev/null && update-desktop-database "$DESKTOP_DIR" || true
info "Đã cài $APPIMAGE"
info "Chạy: $BIN_DIR/zalo-linux"
