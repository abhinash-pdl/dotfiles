#!/usr/bin/env bash
# screenshot_copy.sh - take full-screen screenshot and copy to clipboard (no save)
TMP=$(mktemp --suffix=.png)
if grim "$TMP"; then
	wl-copy --type image/png < "$TMP"
	notify-send "Screenshot copied" "Copied screenshot to clipboard"
else
	notify-send "Screenshot failed" "Could not take screenshot"
fi
rm -f "$TMP"
