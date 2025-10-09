#!/usr/bin/env bash
# Launch nm-connection-editor in a waybar-friendly detached manner.
# This script ensures the editor runs in the user's graphical session.

setsid nm-connection-editor >/dev/null 2>&1 & disown
