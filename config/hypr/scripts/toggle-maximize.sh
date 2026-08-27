#!/bin/bash
WINDOW=$(hyprctl activewindow -j)
FULLSCREEN=$(echo "$WINDOW" | jq '.fullscreen')
CLASS=$(echo "$WINDOW" | jq -r '.class')

echo "$(date): class=$CLASS fullscreen=$FULLSCREEN" >> /tmp/toggle-maximize.log

if [ "$FULLSCREEN" = "0" ]; then
    hyprctl dispatch fullscreen 1 set
else
    hyprctl dispatch fullscreen 1 unset
fi

echo "$(date): after dispatch, fullscreen=$(hyprctl activewindow -j | jq '.fullscreen')" >> /tmp/toggle-maximize.log
