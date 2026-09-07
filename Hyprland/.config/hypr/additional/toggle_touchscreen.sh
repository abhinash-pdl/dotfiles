#!/usr/bin/env bash
# toggle_touchscreen.sh - toggle touchscreen on/off via Hyprland's Lua device API, with swayosd feedback

state_file="$HOME/.cache/touchscreen_state"
touchscreen=$(hyprctl devices -j | jq -r '.touch[] | select(.name | test("touch"; "i")).name')

icon_enabled="input-touchscreen-symbolic"
icon_disabled="action-unavailable-symbolic"   # swap to input-touchscreen-symbolic if this doesn't resolve

if [[ -z "$touchscreen" ]]; then
    swayosd-client --custom-message "No touchscreen found" --custom-icon "dialog-error-symbolic"
    exit 1
fi

mkdir -p "$(dirname "$state_file")"

if [[ -f "$state_file" && "$(cat "$state_file")" == "disabled" ]]; then
    hyprctl eval "hl.device({ name = \"$touchscreen\", enabled = true })" >/dev/null
    echo "enabled" > "$state_file"
    swayosd-client --custom-message "Touchscreen Enabled" --custom-icon "$icon_enabled"
else
    hyprctl eval "hl.device({ name = \"$touchscreen\", enabled = false })" >/dev/null
    echo "disabled" > "$state_file"
    swayosd-client --custom-message "Touchscreen Disabled" --custom-icon "$icon_disabled"
fi
