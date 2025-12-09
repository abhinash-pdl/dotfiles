#!/usr/bin/env bash
# wallpaper_random.sh - auto-cycles random wallpapers with pywal colors
# Designed to run in background (exec-once in hyprland.conf)

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
INTERVAL=${1:-600} # seconds, default 600 (10 minutes)
LOCKFILE="/tmp/wallpaper_random.lock"

# Prevent multiple instances
exec 200>"$LOCKFILE"
if ! flock -n 200; then
  echo "[wallpaper_random] Another instance is already running"
  exit 1
fi

shopt -s nullglob
files=("$WALLPAPER_DIR"/*)
if [ ${#files[@]} -eq 0 ]; then
  echo "[wallpaper_random] no wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
fi

# Cleanup on exit
trap "rm -f '$LOCKFILE'" EXIT

random_wallpaper() {
  local idx=$((RANDOM % ${#files[@]}))
  echo "${files[$idx]}"
}

set_wallpaper() {
  local path="$1"
  
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
  
  echo "[wallpaper_random] selected: $path"
}

# Run once initially
set_wallpaper "$(random_wallpaper)"

# Loop forever, changing wallpaper every INTERVAL seconds
while true; do
  sleep "$INTERVAL"
  set_wallpaper "$(random_wallpaper)"
done
