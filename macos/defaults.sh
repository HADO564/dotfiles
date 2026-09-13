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

# ── Workspaces are handled by AeroSpace (macos/config/aerospace) ───────────────
# Turn off the native Ctrl+1..9 "Switch to Desktop N" shortcuts so they don't
# compete with AeroSpace's Alt+1..9.
keycodes=(18 19 20 21 23 22 26 28 25)
for i in 0 1 2 3 4 5 6 7 8; do
  hotkey "$((118 + i))" 0 "$((49 + i))" "${keycodes[$i]}" "$CTRL"
done

# Settings AeroSpace recommends: stable Space order, apps grouped in Mission
# Control, and one Space spanning all displays (needs a log out).
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock expose-group-apps -bool true
defaults write com.apple.spaces spans-displays -bool true

# ── Screenshots land in ~/Pictures/Screenshots (grimblast saved to ~/Pictures) ─
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

# ── Keyboard: fast repeat, no accent popup (log out to apply) ──────────────────
# Holding a key shows an accent picker instead of repeating — breaks hjkl in nvim.
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g KeyRepeat -int 2          # 30ms between repeats (UI fastest)
defaults write -g InitialKeyRepeat -int 15  # 225ms before repeat starts (UI shortest)

# ── Touch ID for sudo (asks for your password once) ────────────────────────────
# sudo_local survives macOS updates. Inside tmux this needs pam-reattach.
if ! grep -qs '^auth.*pam_tid.so' /etc/pam.d/sudo_local; then
  sed 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
fi

# ── Apply ─────────────────────────────────────────────────────────────────────
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
killall Dock SystemUIServer 2>/dev/null || true
echo "macOS defaults applied."
