#!/usr/bin/env bash
# wallpaper_random.sh - set random wallpaper with pywal colors on startup

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

shopt -s nullglob
files=("$WALLPAPER_DIR"/*)
if [ ${#files[@]} -eq 0 ]; then
  echo "[wallpaper_random] no wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
fi

# pick a random wallpaper
path="${files[RANDOM % ${#files[@]}]}"

# ensure hyprpaper is running
if ! hyprctl hyprpaper listloaded >/dev/null 2>&1; then
  hyprpaper &
  for i in {1..20}; do
    sleep 0.1
    if hyprctl hyprpaper listloaded >/dev/null 2>&1; then break; fi
  done
fi

# set wallpaper via hyprpaper
hyprctl hyprpaper preload "$path"
hyprctl hyprpaper wallpaper ",${path}"

# set pywal colors for terminal/apps
wal -i "$path"

# optional: print selected wallpaper
echo "[wallpaper_random] selected: $path"
