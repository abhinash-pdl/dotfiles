#!/usr/bin/env bash
# screenshot_select.sh - take selection screenshot using slurp, save and copy to clipboard
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
SEL=$(slurp)
if [ -z "$SEL" ]; then
  notify-send "Screenshot cancelled"
  exit 0
fi
FILE="$DIR/$(date +%Y%m%d_%H%M%S).png"
grim -g "$SEL" "$FILE" && wl-copy < "$FILE"
notify-send "Selection saved" "$FILE"

