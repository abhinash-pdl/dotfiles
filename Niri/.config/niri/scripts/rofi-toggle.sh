#!/usr/bin/env bash

# Check if wofi is running
if pgrep -x "rofi" > /dev/null; then
    # If running, kill it
    pkill -x "rofi"
else
    # If not running, start wofi in drun mode
    rofi -show drun &
fi

