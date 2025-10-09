#!/usr/bin/env bash
# obs-record-menu.sh
# Present a small menu to choose how to start OBS: Normal (start recording), Safe (minimal plugins), or Open UI only.

set -euo pipefail

MENU_CMD=""
CHOICE=""

if command -v wofi >/dev/null 2>&1; then
  MENU_CMD="wofi --dmenu --prompt 'OBS mode:'"
elif command -v rofi >/dev/null 2>&1; then
  MENU_CMD="rofi -dmenu -p 'OBS mode:'"
elif command -v dmenu >/dev/null 2>&1; then
  MENU_CMD="dmenu -p 'OBS mode:'"
fi

OPTIONS=$'Normal\nSafe\nOpen UI\nCancel'

if [ -n "$MENU_CMD" ]; then
  CHOICE=$(printf "%s" "$OPTIONS" | eval "$MENU_CMD") || true
else
  # tty fallback
  echo "Choose OBS mode:" >&2
  echo "$OPTIONS" >&2
  read -r CHOICE
fi

case "$CHOICE" in
  Normal)
    # start recording normally via wrapper
    ~/.config/hypr/additional/obs-toggle.sh
    ;;
  Safe)
    # Start OBS with plugins disabled (by pointing OBS_PLUGIN_PATH to an empty dir)
    # This runs the same toggle wrapper; the env will be propagated to the child process.
    mkdir -p "$XDG_RUNTIME_DIR/obs-empty-plugins" 2>/dev/null || true
    OBS_PLUGIN_PATH="$XDG_RUNTIME_DIR/obs-empty-plugins" env OBS_PLUGIN_PATH="$OBS_PLUGIN_PATH" ~/.config/hypr/additional/obs-toggle.sh
    ;;
  "Open UI")
    # Start OBS without auto-recording (open UI)
    nohup obs > /tmp/obs-ui.log 2>&1 &
    notify-send "OBS" "OBS started (UI mode)" || true
    ;;
  *)
    # Cancel or empty choice
    exit 0
    ;;
esac
