#!/bin/bash
if command -v glow &>/dev/null; then
    glow -p ~/.config/hypr/keybindings.md
else
    less ~/.config/hypr/keybindings.md
fi
