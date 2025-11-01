#!/usr/bin/env bash

# Check if wofi is running
if pgrep -x "wofi" > /dev/null; then
    # If running, kill it
    pkill -x "wofi"
else
    # If not running, start wofi in drun mode
    wofi --show drun &
fi

