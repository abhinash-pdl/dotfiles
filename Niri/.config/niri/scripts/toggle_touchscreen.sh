#!/usr/bin/env bash
# toggle_touchscreen.sh
config_file="$HOME/.config/niri/modules/general.kdl"

if awk '/touch {/{f=1} f&&/^\s*off\s*$/{print;exit} /^\s*}/{if(f)exit;f=0}' "$config_file" | grep -q off; then
    awk '/touch {/{f=1} f&&/^\s*off\s*$/{next} /^\s*}/{if(f)f=0} {print}' "$config_file" > "$config_file.tmp" && mv "$config_file.tmp" "$config_file"
    swayosd-client --custom-message "Touchscreen Enabled" --custom-icon "input-touchscreen-symbolic"
else
    awk '{print} /touch {/{print "        off"}' "$config_file" > "$config_file.tmp" && mv "$config_file.tmp" "$config_file"
    swayosd-client --custom-message "Touchscreen Disabled" --custom-icon "action-unavailable-symbolic"
fi
