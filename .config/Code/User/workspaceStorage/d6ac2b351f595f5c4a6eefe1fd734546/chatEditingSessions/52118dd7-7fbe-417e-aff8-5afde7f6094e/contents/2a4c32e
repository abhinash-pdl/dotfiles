#!/usr/bin/env bash
# wrapper to start wf-recorder with a timestamped filename
OUTDIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTDIR"
FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S).mkv"
# Try a conservative invocation that avoids GPU/format runtime changes which
# can cause ffmpeg sink errors on some setups. Use software encoding (libx264)
# and disable dmabuf to force CPU path. These options should be portable.
exec wf-recorder --no-dmabuf -f "$FILE" -c libx264 -p preset=ultrafast -p crf=20
