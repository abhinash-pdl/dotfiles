#!/usr/bin/env bash

getdate() {
    date '+%Y-%m-%d_%H.%M.%S'
}
getaudiooutput() {
    pactl list sources | grep 'Name' | grep 'monitor' | cut -d ' ' -f2
}
getactivemonitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

xdgvideo="$(xdg-user-dir VIDEOS)"
if [[ $xdgvideo = "$HOME" ]]; then
  unset xdgvideo
fi
SAVE_DIR="${xdgvideo:-$HOME/Videos}"
mkdir -p "$SAVE_DIR"
cd "$SAVE_DIR" || exit

if pgrep wf-recorder > /dev/null; then
    LAST_FILE=$(ls -t "$SAVE_DIR"/recording_*.mp4 2>/dev/null | head -1)
    notify-send "Recording Stopped" "Saved to: ${LAST_FILE:-$SAVE_DIR}" -a 'Recorder' &
    pkill wf-recorder &
else
    FILENAME="recording_$(getdate).mp4"
    if [[ "$1" == "--fullscreen-sound" ]]; then
        notify-send "Starting recording" "$SAVE_DIR/$FILENAME" -a 'Recorder' & disown
        wf-recorder -o "$(getactivemonitor)" --pixel-format yuv420p -f "./$FILENAME" -t --audio="$(getaudiooutput)"
    elif [[ "$1" == "--fullscreen" ]]; then
        notify-send "Starting recording" "$SAVE_DIR/$FILENAME" -a 'Recorder' & disown
        wf-recorder -o "$(getactivemonitor)" --pixel-format yuv420p -f "./$FILENAME" -t
    else
        if ! region="$(slurp 2>&1)"; then
            notify-send "Recording cancelled" "Selection was cancelled" -a 'Recorder' & disown
            exit 1
        fi
        notify-send "Starting recording" "$SAVE_DIR/$FILENAME" -a 'Recorder' & disown
        if [[ "$1" == "--sound" ]]; then
            wf-recorder --pixel-format yuv420p -f "./$FILENAME" -t --geometry "$region" --audio="$(getaudiooutput)"
        else
            wf-recorder --pixel-format yuv420p -f "./$FILENAME" -t --geometry "$region"
        fi
    fi
fi
