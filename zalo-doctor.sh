#!/usr/bin/env bash
set -Eeuo pipefail
warn=0
pass(){ printf '[ OK ] %s\n' "$*"; }
fail(){ printf '[WARN] %s\n' "$*"; warn=$((warn+1)); }
[[ "$(uname -m)" == "x86_64" ]] && pass "Kiến trúc x86_64" || fail "Không phải x86_64"
pass "$(ldd --version | head -1)"
ldconfig -p 2>/dev/null | grep -q 'libfuse.so.2' && pass "FUSE 2" || fail "Thiếu FUSE 2"
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zalo-linux"
[[ -x "$APP_DIR/Zalo-x86_64.AppImage" ]] && pass "AppImage executable" || fail "Thiếu AppImage hoặc chưa có quyền chạy"
[[ ! -e "$APP_DIR/Zalo-x86_64.AppImage.part" ]] && pass "Không có file tải dở" || fail "Có file tải dở; chạy repair"
command -v curl >/dev/null && pass "curl" || fail "Thiếu curl"
command -v python3 >/dev/null && pass "python3" || fail "Thiếu python3"
command -v xclip >/dev/null && pass "X11 clipboard: xclip" || fail "Thiếu xclip; dán ảnh Ctrl+V trên X11 có thể lỗi"
command -v wl-paste >/dev/null && pass "Wayland clipboard: wl-clipboard" || fail "Thiếu wl-clipboard; dán ảnh Ctrl+V trên Wayland có thể lỗi"
for d in "${XDG_CONFIG_HOME:-$HOME/.config}/ZaloApp" "${XDG_DATA_HOME:-$HOME/.local/share}/ZaloData" "${XDG_DATA_HOME:-$HOME/.local/share}/Zalo"; do
  if [[ -d "$d" ]]; then pass "Dữ liệu local: $d ($(du -sh "$d" | awk '{print $1}'))"; fi
done
FREE="$(df -Pk "$HOME" | awk 'NR==2 {print $4}')"
(( FREE > 1048576 )) && pass "Trống > 1 GiB" || fail "Nên có ít nhất 1 GiB trống"
pgrep -af 'Zalo|zalo' >/dev/null 2>&1 && pass "Zalo đang chạy" || echo '[NOTE] Zalo chưa chạy'
(( warn )) && { echo "Có $warn cảnh báo."; exit 1; }
echo "Môi trường phù hợp cho chat và đồng bộ ảnh/tin nhắn."
