#!/usr/bin/env bash
# wallpaper_change.sh - manually change wallpaper (for keybind)

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

shopt -s nullglob
files=("$WALLPAPER_DIR"/*)
if [ ${#files[@]} -eq 0 ]; then
  echo "[wallpaper_change] no wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
fi

# pick a random wallpaper
path="${files[RANDOM % ${#files[@]}]}"

# ensure swww daemon is running
if ! pgrep -x swww-daemon >/dev/null; then
  swww-daemon &
  sleep 0.5
fi

# set wallpaper with swww (doesn't use Hyprland IPC, no Waybar interference)
swww img "$path" \
  --transition-type wipe \
  --transition-duration 1.5 \
  --transition-fps 60 \
  --transition-angle 30 &

# set pywal colors for terminal/apps (waybar colors-waybar.css is read-only to prevent reloads)
# -n = skip setting wallpaper, -e = skip reloading external programs
(wal -i "$path" -n -e >/dev/null 2>&1 &)

# optional: print selected wallpaper
echo "[wallpaper_change] selected: $path"
