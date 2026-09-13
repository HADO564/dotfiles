#!/usr/bin/env bash
# Sets this repo up on macOS. Only the terminal dev environment is linked
# (zsh, WezTerm, starship, tmux, Neovim); the Hyprland/Quickshell side is skipped.
#
#   macos/install.sh             symlink configs (backs up anything already there)
#   macos/install.sh --packages  brew bundle first, then symlink
#   macos/install.sh --defaults  also apply macos/defaults.sh (shortcuts, Spaces, screenshots)
#   macos/install.sh --dry-run   show what would happen, change nothing

set -euo pipefail

MACOS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$MACOS")"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
DO_PACKAGES=0
DO_DEFAULTS=0

for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=1 ;;
    --packages) DO_PACKAGES=1 ;;
    --defaults) DO_DEFAULTS=1 ;;
    -h|--help)  sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

say()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
run()  { if [ "$DRY_RUN" = 1 ]; then echo "   would: $*"; else "$@"; fi; }

# ---------------------------------------------------------------------------
# 1. Packages
# ---------------------------------------------------------------------------
if [ "$DO_PACKAGES" = 1 ]; then
  if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew not found. Install it from https://brew.sh first."
    exit 1
  fi
  say "Installing packages from macos/Brewfile"
  run brew bundle --file "$MACOS/Brewfile"
fi

# ---------------------------------------------------------------------------
# 2. Symlinks  (repo source : destination)
# Shared configs come from config/, Mac-only ones from macos/.
# Files are linked individually where the target dir holds other things
# (e.g. ~/.config/wezterm keeps its background image).
# ---------------------------------------------------------------------------
LINKS=(
  "$REPO/config/nvim:$HOME/.config/nvim"
  "$REPO/config/tmux:$HOME/.config/tmux"
  "$REPO/bin/tmux-sessionizer:$HOME/.local/bin/tmux-sessionizer"
  "$MACOS/config/wezterm/wezterm.lua:$HOME/.config/wezterm/wezterm.lua"
  "$MACOS/config/starship/starship.toml:$HOME/.config/starship/starship.toml"
  "$MACOS/home/.zshrc:$HOME/.zshrc"
  "$MACOS/home/.zprofile:$HOME/.zprofile"
)

say "Linking configs (backups -> $BACKUP)"
for pair in "${LINKS[@]}"; do
  src="${pair%%:*}"
  dest="${pair#*:}"
  rel="${dest#"$HOME"/}"

  if [ -L "$dest" ]; then
    run rm -f "$dest"
  elif [ -e "$dest" ]; then
    run mkdir -p "$BACKUP/$(dirname "$rel")"
    say "  backing up existing ~/$rel"
    run mv "$dest" "$BACKUP/$rel"
  fi

  echo "  -> ~/$rel"
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
done

# ---------------------------------------------------------------------------
# 3. macOS settings
# ---------------------------------------------------------------------------
if [ "$DO_DEFAULTS" = 1 ]; then
  say "Applying macos/defaults.sh"
  run bash "$MACOS/defaults.sh"
fi

echo
say "Done."
cat <<'EOF'

Next steps:
  1. Open a new WezTerm window (or run: exec zsh).
  2. Run nvim once; LazyVim installs its plugins on first launch.
  3. Git over HTTPS uses your gh login:  gh auth login && gh auth setup-git

Shortcuts (Hyprland -> macOS): macos/CHEATSHEET.md
EOF
