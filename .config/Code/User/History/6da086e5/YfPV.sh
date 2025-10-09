#!/usr/bin/env bash
# screenshot_copy.sh - take full-screen screenshot and copy to clipboard (no save)
TMP=$(mktemp --suffix=.png)
grim "$TMP" && wl-copy < "$TMP"
notify-send "Screenshot copied to clipboard"
rm -f "$TMP"
