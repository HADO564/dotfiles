#!/bin/bash
# Show a rofi picker of minimized windows and restore the selected one

CLIENTS=$(hyprctl clients -j | jq -r '
  .[] | select(.workspace.name == "special:minimized") |
  "\(.address)\t\(.class)\t\(.title)"
')

if [ -z "$CLIENTS" ]; then
    notify-send "No minimized windows"
    exit 0
fi

# Build display list: "ClassName — Window Title"
DISPLAY=$(echo "$CLIENTS" | awk -F'\t' '{print $2 " — " $3}')

SELECTED=$(echo "$DISPLAY" | rofi -dmenu -p "Restore:" -i)
[ -z "$SELECTED" ] && exit 0

# Find the address of the selected entry
ADDR=$(echo "$CLIENTS" | awk -F'\t' -v sel="$SELECTED" '($2 " — " $3) == sel {print $1}')
[ -z "$ADDR" ] && exit 1

CURRENT_WS=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')

hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$ADDR"
hyprctl dispatch focuswindow "address:$ADDR"
