#!/bin/bash
# Fix deprecated [colors] section in foot.ini to use [colors-dark]

if [ -f "$HOME/.cache/wal/colors-foot.ini" ]; then
    sed -i 's/^\[colors\]$/[colors-dark]/' "$HOME/.cache/wal/colors-foot.ini"
    echo "Fixed colors-foot.ini section"
fi
