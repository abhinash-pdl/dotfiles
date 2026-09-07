#!/usr/bin/env bash
# screenshot_full.sh - take full-screen screenshot, save to ~/Pictures/Screenshots and notify
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y%m%d_%H%M%S).png"
if grim "$FILE"; then
	# copy image to clipboard with explicit mime type
	wl-copy --type image/png < "$FILE"
	notify-send "Screenshot saved" "$FILE"
else
	notify-send "Screenshot failed" "Could not take screenshot"
fi
