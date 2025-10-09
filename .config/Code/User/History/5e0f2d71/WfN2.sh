#!/usr/bin/env bash
# Wrapper to run clipboard_history.sh from Hyprland keybinds
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
"${HOME}/.config/hypr/additional/clipboard_history.sh"
