#!/bin/bash
# Reapply pywal-generated border colors from the last wallpaper selection

colors="$HOME/.cache/wal/colors.json"
[[ -f "$colors" ]] || exit 0

color1=$(python3 -c "import json; c=json.load(open('$colors')); print(c['colors']['color1'][1:])" 2>/dev/null)
color2=$(python3 -c "import json; c=json.load(open('$colors')); print(c['colors']['color4'][1:])" 2>/dev/null)

[[ -n "$color1" && -n "$color2" ]] || exit 0

# Write a sourced config so colors persist across hyprctl reloads
cat > "$HOME/.config/hypr/wal-colors.conf" <<EOF
general {
    col.active_border = rgba(${color1}ee) rgba(${color2}ee) 45deg
    col.inactive_border = rgba(${color1}33)
}
EOF

# Also apply immediately via hyprctl if inside a running Hyprland session
if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    until [[ -S "/run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock" ]]; do
        sleep 0.5
    done
    hyprctl keyword general:col.active_border "rgba(${color1}ee) rgba(${color2}ee) 45deg"
    hyprctl keyword general:col.inactive_border "rgba(${color1}33)"
fi
