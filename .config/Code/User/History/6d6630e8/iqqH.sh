#!/usr/bin/env bash
# ffmpeg-pipewire-record.sh
# Records the desktop via pipewire/ffmpeg into ~/Videos/Screencasts
OUTDIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTDIR"
FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S)-ffrec.mkv"
# If ffmpeg supports pipewire input, use it; otherwise fail fast
if ffmpeg -hide_banner -sources 2>/dev/null | grep -qi pipewire; then
  exec ffmpeg -y -f pipewire -i default -c:v libx264 -preset ultrafast -crf 20 -pix_fmt yuv420p "$FILE"
else
  # Try the common pipewire device name
  exec ffmpeg -y -f pulse -i default -c:v libx264 -preset ultrafast -crf 20 -pix_fmt yuv420p "$FILE"
fi
