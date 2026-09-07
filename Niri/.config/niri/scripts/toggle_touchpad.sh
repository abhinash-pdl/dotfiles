#!/usr/bin/env bash
# toggle_touchpad.sh
config_file="$HOME/.config/niri/modules/general.kdl"

if awk '/touchpad {/{f=1} f&&/^\s*off\s*$/{print;exit} /^\s*}/{if(f)exit;f=0}' "$config_file" | grep -q off; then
    # off exists inside touchpad block -> remove it (enable)
    awk '/touchpad {/{f=1} f&&/^\s*off\s*$/{next} /^\s*}/{if(f)f=0} {print}' "$config_file" > "$config_file.tmp" && mv "$config_file.tmp" "$config_file"
    swayosd-client --custom-message "Touchpad Enabled" --custom-icon "input-touchpad-on-symbolic"
else
    # off missing -> insert it right after "touchpad {"
    awk '{print} /touchpad {/{print "        off"}' "$config_file" > "$config_file.tmp" && mv "$config_file.tmp" "$config_file"
    swayosd-client --custom-message "Touchpad Disabled" --custom-icon "input-touchpad-off-symbolic"
fi
