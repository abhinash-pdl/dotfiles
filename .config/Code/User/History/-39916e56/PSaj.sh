#!/usr/bin/env bash
# wrapper to start wf-recorder with a timestamped filename
OUTDIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTDIR"
FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S).mkv"
# Start wf-recorder without forcing ffmpeg pix_fmts; let wf-recorder choose defaults
exec wf-recorder -f "$FILE"
