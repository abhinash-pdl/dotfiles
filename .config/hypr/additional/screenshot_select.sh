#!/usr/bin/env bash
# screenshot_select.sh - take selection screenshot using slurp, save and copy to clipboard
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
SEL=$(slurp)
if [ -z "$SEL" ]; then
  notify-send "Screenshot cancelled" "Selection aborted"
  exit 0
fi
FILE="$DIR/$(date +%Y%m%d_%H%M%S).png"
if grim -g "$SEL" "$FILE"; then
  wl-copy --type image/png < "$FILE"
  notify-send "Selection saved" "$FILE"
else
  notify-send "Screenshot failed" "Could not take selection"
fi

