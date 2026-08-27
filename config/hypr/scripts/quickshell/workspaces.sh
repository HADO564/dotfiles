#!/usr/bin/env bash

# ============================================================================
# 1. ZOMBIE PREVENTION
# Kills any older instances of this script. When Quickshell reloads, 
# it can leave the old listener pipelines running in the background infinitely.
# ============================================================================
for pid in $(pgrep -f "quickshell/workspaces.sh"); do
    if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ]; then
        kill -9 "$pid" 2>/dev/null
    fi
done

# Cleanly kill immediate children (like socat) when the script exits normally
cleanup() {
    pkill -P $$ 2>/dev/null
}
trap cleanup EXIT SIGTERM SIGINT

# --- Special Cleanup for Network/Bluetooth ---
# The network toggle starts a background bluetooth scan that must be killed explicitly.
BT_PID_FILE="$HOME/.cache/bt_scan_pid"

if [ -f "$BT_PID_FILE" ]; then
    kill $(cat "$BT_PID_FILE") 2>/dev/null
    rm -f "$BT_PID_FILE"
fi

# Ensure bluetooth scan is explicitly turned off (timeout prevents deadlocks on fresh installs)
(timeout 2 bluetoothctl scan off > /dev/null 2>&1) &
# ---------------------------------------------

print_workspaces() {
    active=$(timeout 2 hyprctl activeworkspace -j 2>/dev/null | jq '.id')
    clients=$(timeout 2 hyprctl clients -j 2>/dev/null)

    if [ -z "$active" ] || [ -z "$clients" ]; then return; fi

    # Use clients as source of truth — workspaces -j can transiently drop entries
    max_ws=$(echo "$clients" | jq '[.[].workspace.id | select(. > 0)] | if length > 0 then max else 0 end')
    seq_end=$(( active > max_ws ? active : max_ws ))
    [ "$seq_end" -lt 1 ] && seq_end=1

    echo "$clients" | jq --unbuffered --argjson a "$active" --argjson end "$seq_end" -c '
        # Build map: ws_id -> { count, title }
        (group_by(.workspace.id) | map({
            key: (.[0].workspace.id | tostring),
            value: { count: length, title: (.[length-1].title // "Empty") }
        }) | from_entries) as $ws
        |
        [range(1; $end + 1)] | map(
            . as $i |
            (if $i == $a then "active"
             elif ($ws[$i|tostring] != null and $ws[$i|tostring].count > 0) then "occupied"
             else "empty" end) as $state |
            ($ws[$i|tostring].title // "Empty") as $win |
            { id: $i, state: $state, tooltip: $win }
        )
    ' > /tmp/qs_workspaces.tmp

    mv /tmp/qs_workspaces.tmp /tmp/qs_workspaces.json
}

# Print initial state
print_workspaces

# ============================================================================
# 2. THE EVENT DEBOUNCER
# Listen to Hyprland socket wrapped in an infinite loop
# ============================================================================
while true; do
    socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
        case "$line" in
            workspace*|focusedmon*|activewindow*|createwindow*|closewindow*|movewindow*|destroyworkspace*)
                
                # -> THE FIX <-
                # Hyprland emits HUNDREDS of events a second when you move/resize windows.
                # This reads and discards all subsequent events arriving within a 50ms window.
                # It bundles the storm into a single UI update, completely preventing CPU clogging!
                while read -t 0.05 -r extra_line; do
                    continue
                done

                print_workspaces
                ;;
        esac
    done
    sleep 1
done
