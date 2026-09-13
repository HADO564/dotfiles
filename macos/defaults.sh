#!/usr/bin/env bash
# macOS settings that stand in for Hyprland behaviour. Safe to re-run.
# Undo any line by flipping its value, or reset in System Settings > Keyboard > Shortcuts.

set -euo pipefail

CTRL=262144
OPT=524288

# hotkey <id> <enabled 0|1> <ascii char> <keycode> <modifiers>
hotkey() {
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$1" \
    "{ enabled = $2; value = { parameters = ($3, $4, $5); type = standard; }; }"
}

# ── Free Ctrl+Space for Neovim ─────────────────────────────────────────────────
# macOS binds Ctrl+Space / Ctrl+Opt+Space to input-source switching, which
# swallows LazyVim's completion trigger and treesitter selection.
hotkey 60 0 32 49 "$CTRL"
hotkey 61 0 32 49 "$((CTRL + OPT))"

# ── Ctrl+1..9 switches to Desktop N (Hyprland: Super+1..9) ─────────────────────
# Only desktops that exist can be targeted; add them in Mission Control.
keycodes=(18 19 20 21 23 22 26 28 25)
for i in 0 1 2 3 4 5 6 7 8; do
  hotkey "$((118 + i))" 1 "$((49 + i))" "${keycodes[$i]}" "$CTRL"
done

# Keep desktops in a fixed order so the numbers above stay meaningful.
defaults write com.apple.dock mru-spaces -bool false

# ── Screenshots land in ~/Pictures/Screenshots (grimblast saved to ~/Pictures) ─
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

# ── Apply ─────────────────────────────────────────────────────────────────────
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
killall Dock SystemUIServer 2>/dev/null || true
echo "macOS defaults applied."
