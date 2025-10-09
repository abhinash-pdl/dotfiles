#!/usr/bin/env bash
# wallpaper_random.sh
# Cycles wallpapers randomly from the wallpapers directory using hyprctl hyprpaper
# Designed to run in background (exec-once in hyprland.conf)

WALLPAPER_DIR="/home/avinas/Pictures/wallpapers"
INTERVAL=${1:-300} # seconds, default 300 (5 minutes)

shopt -s nullglob
files=("$WALLPAPER_DIR"/*)
if [ ${#files[@]} -eq 0 ]; then
  echo "[wallpaper_random] no wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
fi

random_wallpaper() {
  # pick random file
  local idx=$((RANDOM % ${#files[@]}))
  echo "${files[$idx]}"
}

set_wallpaper() {
  local path="$1"
  # preload then set (hyprpaper requires preload)
  hyprctl hyprpaper preload "$path"
  # set for all monitors
  hyprctl hyprpaper wallpaper ",${path}"
}

# Run once initially
set_wallpaper "$(random_wallpaper)"

while true; do
  sleep "$INTERVAL"
  set_wallpaper "$(random_wallpaper)"
done
