#!/usr/bin/env bash
# screenshot_full.sh - take full-screen screenshot, save to ~/Pictures/Screenshots and notify
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y%m%d_%H%M%S).png"
grim "$FILE" && wl-copy < "$FILE"
notify-send "Screenshot saved" "$FILE"
