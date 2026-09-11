#!/bin/bash

ACTION=${1:-toggle} 

CURRENT_WS=$(niri msg -j workspaces | jq -r '.[] | select(.is_focused==true) | .id')
CURRENT_WS_IDX=$(niri msg -j workspaces | jq -r '.[] | select(.is_focused==true) | .idx')

ACTIVE_APP_ID=$(niri msg -j focused-window | jq -r '.app_id' 2>/dev/null)
ACTIVE_ID=$(niri msg -j focused-window | jq -r '.id' 2>/dev/null)

case $ACTION in
    "hide")
        if [ "$ACTIVE_APP_ID" = "WhatsApp Desktop" ]; then
            echo "Hiding active WhatsApp window to special workspace"
            niri msg action move-window-to-workspace --window-id "$ACTIVE_ID" --focus false "special"
        else
            echo "Killing active window"
            niri msg action close-window
        fi
        ;;
    "minimize")
        if [ "$ACTIVE_APP_ID" = "WhatsApp Desktop" ]; then
            echo "Hiding active WhatsApp window to special workspace"
            niri msg action move-window-to-workspace --window-id "$ACTIVE_ID" --focus false "special"
        else
         
            echo "Minimizing active window"
            niri msg action move-window-to-workspace --window-id "$ACTIVE_ID" --focus false "minimized"
        fi
        ;;
    "toggle")
        if [ "$ACTIVE_APP_ID" = "WhatsApp Desktop" ]; then
            echo "Hiding focused WhatsApp window to special workspace"
            niri msg action move-window-to-workspace --window-id "$ACTIVE_ID" --focus false "special"
            exit 0
        fi

        WHATSAPP_INFO=$(niri msg -j windows | jq -r '.[] | select(.app_id == "WhatsApp Desktop") | "\(.id) \(.workspace_id)"' | head -1)
        if [ -n "$WHATSAPP_INFO" ]; then
            WINDOW_ID=$(echo "$WHATSAPP_INFO" | awk '{print $1}')
            WINDOW_WS=$(echo "$WHATSAPP_INFO" | awk '{print $2}')

            if [ "$WINDOW_WS" = "$CURRENT_WS" ]; then
                echo "Hiding WhatsApp to special workspace"
                niri msg action move-window-to-workspace --window-id "$WINDOW_ID" --focus false "special"
            else
                echo "Bringing WhatsApp to current workspace ($CURRENT_WS_IDX) and focusing it"
                niri msg action move-window-to-workspace --window-id "$WINDOW_ID" "$CURRENT_WS_IDX"
                sleep 0.2
                niri msg action focus-window --id "$WINDOW_ID"
            fi
        else
            echo "Launching new WhatsApp instance"
            "whatsapp-linux-desktop"
        fi
        ;;
esac
