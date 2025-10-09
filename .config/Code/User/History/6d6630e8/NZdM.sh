#!/usr/bin/env bash
# ffmpeg-pipewire-record.sh
# Records the desktop via PipeWire/ffmpeg into ~/Videos/Screencasts

OUTDIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTDIR"
FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S)-ffrec.mkv"

# Check whether ffmpeg was built with PipeWire (demuxer) support.
# Use the demuxers list which is reliable for input format support.
if ffmpeg -hide_banner -demuxers 2>/dev/null | grep -qi pipewire; then
  exec ffmpeg -y -f pipewire -i default \
    -c:v libx264 -preset ultrafast -crf 20 -pix_fmt yuv420p "$FILE"
else
  # Notify the user and fail gracefully. This prevents rapid restart loops
  # in systemd and gives a clear action: install ffmpeg with PipeWire support.
  echo "ffmpeg does not have PipeWire input support; aborting." >&2
  # Notify via desktop notifications if available; ignore errors.
  notify-send "Screen recorder" \
    "ffmpeg lacks PipeWire support. Install ffmpeg with pipewire (libpipewire) or use wf-recorder." || true
  # Exit with non-zero so the calling toggle can fall back to other methods.
  exit 2
fi
