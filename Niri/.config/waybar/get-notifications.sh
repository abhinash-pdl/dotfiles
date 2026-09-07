#!/bin/bash

# Simple notification indicator for waybar
# Shows icon when notifications exist

# Check if swaync is running
if ! pgrep -x "swaync" > /dev/null; then
    echo '{"text": "", "class": "empty"}'
    exit 0
fi

# Get DND state (0=notifications active, 1=dnd active)
DND=$(swaync-client -D 2>/dev/null)

if [ "$DND" == "true" ]; then
    echo '{"text": "󰂛", "class": "dnd"}'
else
    echo '{"text": "󰂚", "class": "notification"}'
fi
