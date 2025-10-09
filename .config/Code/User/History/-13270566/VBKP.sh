#!/usr/bin/env bash
# wallpaper_now.sh - pick one random wallpaper and set it immediately via hyprctl hyprpaper
WALLPAPER_DIR="/home/avinas/Pictures/wallpapers"
shopt -s nullglob
files=("$WALLPAPER_DIR"/*)
if [ ${#files[@]} -eq 0 ]; then
  echo "[wallpaper_now] no wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
fi
path="${files[RANDOM % ${#files[@]}]}"
hyprctl hyprpaper preload "$path"
hyprctl hyprpaper wallpaper ",${path}"
