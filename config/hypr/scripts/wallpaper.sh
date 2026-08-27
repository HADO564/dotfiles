#!/bin/bash

# Set your Wallpaper Engine workshop wallpaper ID here.
# The ID is the number in the workshop URL:
#   https://steamcommunity.com/sharedfiles/filedetails/?id=XXXXXXXXXX
#                                                              ^^^^^^^^^^
WALLPAPER_ID="3588262443"

WORKSHOP_DIR="$HOME/.steam/steam/steamapps/workshop/content/431960"

if [[ -z "$WALLPAPER_ID" ]]; then
    echo "No wallpaper ID set. Edit ~/.config/hypr/scripts/wallpaper.sh and set WALLPAPER_ID."
    exit 1
fi

if [[ ! -d "$WORKSHOP_DIR/$WALLPAPER_ID" ]]; then
    echo "Wallpaper $WALLPAPER_ID not found in $WORKSHOP_DIR"
    exit 1
fi

# Wait for the Wayland compositor socket to be ready
WAYLAND_SOCKET="/run/user/$(id -u)/wayland-1"
until [ -S "$WAYLAND_SOCKET" ]; do
    sleep 0.5
done

pkill -f linux-wallpaperengine 2>/dev/null
sleep 0.5

# Update colors from this wallpaper's preview image
PREVIEW=$(find "$WORKSHOP_DIR/$WALLPAPER_ID" -maxdepth 1 -name "preview.*" \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) \
    | head -1)
if [[ -n "$PREVIEW" ]]; then
    bash "$(dirname "$0")/wal_apply.sh" "$PREVIEW" &
fi

exec linux-wallpaperengine --screen-root HDMI-A-1 --bg "$WALLPAPER_ID" --silent
