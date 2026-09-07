#!/bin/bash
# ~/.local/bin/whatsapp-control (niri version)
#
# Niri differences from Hyprland that shape this script:
#   - No hex window "address" — windows have plain integer "id".
#   - No .class — app_id is the equivalent field (used here as "WhatsApp Desktop";
#     check `niri msg -j windows` on your system and adjust if the real app_id differs,
#     e.g. it may just be "WhatsApp").
#   - No special/scratchpad *overlay* workspace. The closest equivalent is a plain
#     named workspace (defined in your niri config, e.g. `workspace "special"`),
#     which you switch to like any other workspace rather than toggling an overlay.
#   - No native "minimize" dispatcher — niri is a scrollable-tiling WM and has no
#     minimize concept. The "minimize" action below falls back to moving the window
#     to a dedicated "minimized" workspace as the closest analogue.

ACTION=${1:-toggle}  # Default to toggle if no parameter

# Get current (focused) workspace - .id for comparisons against window.workspace_id,
# .idx for use as a move-window-to-workspace target (that action takes index or name,
# NOT the internal .id).
CURRENT_WS=$(niri msg -j workspaces | jq -r '.[] | select(.is_focused==true) | .id')
CURRENT_WS_IDX=$(niri msg -j workspaces | jq -r '.[] | select(.is_focused==true) | .idx')

# Get active window app_id and id
ACTIVE_APP_ID=$(niri msg -j focused-window | jq -r '.app_id' 2>/dev/null)
ACTIVE_ID=$(niri msg -j focused-window | jq -r '.id' 2>/dev/null)

case $ACTION in
    "hide")
        # Super+Q behavior: Hide WhatsApp, kill everything else
        if [ "$ACTIVE_APP_ID" = "WhatsApp Desktop" ]; then
            echo "Hiding active WhatsApp window to special workspace"
            niri msg action move-window-to-workspace --window-id "$ACTIVE_ID" --focus false "special"
        else
            echo "Killing active window"
            niri msg action close-window
        fi
        ;;
    "minimize")
        # Super+M behavior: Hide WhatsApp, minimize everything else
        if [ "$ACTIVE_APP_ID" = "WhatsApp Desktop" ]; then
            echo "Hiding active WhatsApp window to special workspace"
            niri msg action move-window-to-workspace --window-id "$ACTIVE_ID" --focus false "special"
        else
            # No native minimize in niri; closest analogue is parking it on a
            # dedicated "minimized" workspace.
            echo "Minimizing active window"
            niri msg action move-window-to-workspace --window-id "$ACTIVE_ID" --focus false "minimized"
        fi
        ;;
    "toggle")
        # Fast path: if WhatsApp is the *focused* window right now, just hide it.
        # (Don't rely on workspace-id matching alone - that misses cases where
        # WhatsApp is focused but the workspace lookup below races/misreads.)
        if [ "$ACTIVE_APP_ID" = "WhatsApp Desktop" ]; then
            echo "Hiding focused WhatsApp window to special workspace"
            niri msg action move-window-to-workspace --window-id "$ACTIVE_ID" --focus false "special"
            exit 0
        fi

        # Toggle behavior for WhatsApp only
        WHATSAPP_INFO=$(niri msg -j windows | jq -r '.[] | select(.app_id == "WhatsApp Desktop") | "\(.id) \(.workspace_id)"' | head -1)
        if [ -n "$WHATSAPP_INFO" ]; then
            WINDOW_ID=$(echo "$WHATSAPP_INFO" | awk '{print $1}')
            WINDOW_WS=$(echo "$WHATSAPP_INFO" | awk '{print $2}')

            if [ "$WINDOW_WS" = "$CURRENT_WS" ]; then
                # WhatsApp is already sitting on the workspace you're on - hide it.
                # --focus false keeps you on your current workspace instead of
                # following the window (niri follows by default when the moved
                # window is the focused one).
                echo "Hiding WhatsApp to special workspace"
                niri msg action move-window-to-workspace --window-id "$WINDOW_ID" --focus false "special"
            else
                # WhatsApp is elsewhere (including the special workspace) - pull it
                # onto your current workspace and focus it, whatever workspace you're on.
                echo "Bringing WhatsApp to current workspace ($CURRENT_WS_IDX) and focusing it"
                niri msg action move-window-to-workspace --window-id "$WINDOW_ID" "$CURRENT_WS_IDX"
                sleep 0.2
                niri msg action focus-window --id "$WINDOW_ID"
            fi
        else
            # WhatsApp is not running - launch it on current workspace
            echo "Launching new WhatsApp instance"
            "/opt/WhatsApp Desktop/whatsapp-linux-desktop"
        fi
        ;;
esac
