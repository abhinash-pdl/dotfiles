#!/usr/bin/env bash
# wrapper to start wf-recorder with a timestamped filename
OUTDIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTDIR"
FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S).mkv"
exec wf-recorder -f "$FILE"
