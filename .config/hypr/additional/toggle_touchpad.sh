#!/usr/bin/env bash
# toggle_touchpad.sh - toggle touchpad on/off via Hyprland's Lua device API, with swayosd feedback

state_file="$HOME/.cache/touchpad_state"
touchpad=$(hyprctl devices -j | jq -r '.mice[] | select(.name | test("touchpad"; "i")).name')

icon_enabled="input-touchpad-on-symbolic"
icon_disabled="input-touchpad-off-symbolic"

if [[ -z "$touchpad" ]]; then
    swayosd-client --custom-message "No touchpad found" --custom-icon "dialog-error-symbolic"
    exit 1
fi

mkdir -p "$(dirname "$state_file")"

if [[ -f "$state_file" && "$(cat "$state_file")" == "disabled" ]]; then
    hyprctl eval "hl.device({ name = \"$touchpad\", enabled = true })" >/dev/null
    echo "enabled" > "$state_file"
    swayosd-client --custom-message "Touchpad Enabled" --custom-icon "$icon_enabled"
else
    hyprctl eval "hl.device({ name = \"$touchpad\", enabled = false })" >/dev/null
    echo "disabled" > "$state_file"
    swayosd-client --custom-message "Touchpad Disabled" --custom-icon "$icon_disabled"
fi
