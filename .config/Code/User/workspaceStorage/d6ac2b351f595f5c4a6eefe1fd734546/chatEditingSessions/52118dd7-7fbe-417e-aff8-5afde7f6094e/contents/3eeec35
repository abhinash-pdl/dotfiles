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

# helper: ensure hyprpaper is running (creates socket)
ensure_hyprpaper() {
  if ! hyprctl hyprpaper listloaded >/dev/null 2>&1; then
    hyprpaper &
    # wait for socket up to 2s
    for i in {1..20}; do
      sleep 0.1
      if hyprctl hyprpaper listloaded >/dev/null 2>&1; then
        return 0
      fi
    done
    return 1
  fi
}

if ! ensure_hyprpaper; then
  echo "[wallpaper_now] hyprpaper didn't start or socket not available" >&2
  exit 2
fi

hyprctl hyprpaper preload "$path"
hyprctl hyprpaper wallpaper ",${path}"
