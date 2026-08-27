#!/usr/bin/env python3
"""
Auto-show hyprbars buttons when cursor hovers near the top of a window.
Bar stays hidden (height=0) until cursor enters the trigger zone.
"""
import subprocess
import json
import time

BAR_SHOW_HEIGHT = 26
TRIGGER_ZONE = 30   # pixels from window top edge to trigger show
POLL_INTERVAL = 0.08  # seconds
HIDE_DELAY_TICKS = 5  # ticks before hiding (~400ms)

current_height = -1
hide_counter = 0


def hyprctl_json(args):
    result = subprocess.run(
        ["hyprctl"] + args + ["-j"],
        capture_output=True, text=True
    )
    if result.returncode != 0 or not result.stdout.strip():
        return None
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return None


def set_bar_height(height):
    global current_height
    if height != current_height:
        subprocess.run(
            ["hyprctl", "keyword", "plugin:hyprbars:bar_height", str(height)],
            capture_output=True
        )
        current_height = height


def main():
    global hide_counter

    # Start hidden
    set_bar_height(0)

    while True:
        time.sleep(POLL_INTERVAL)
        try:
            cursor = hyprctl_json(["cursorpos"])
            window = hyprctl_json(["activewindow"])

            if not cursor or not window:
                continue

            cy = cursor["y"]
            wy = window["at"][1]
            diff = cy - wy

            in_zone = 0 <= diff <= TRIGGER_ZONE

            if in_zone:
                hide_counter = 0
                set_bar_height(BAR_SHOW_HEIGHT)
            else:
                hide_counter += 1
                if hide_counter >= HIDE_DELAY_TICKS:
                    set_bar_height(0)

        except Exception:
            pass


if __name__ == "__main__":
    main()
