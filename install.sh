#!/usr/bin/env bash
# Installs this Hyprland + Quickshell setup.
#
#   ./install.sh            symlink configs into ~/.config (backs up anything there)
#   ./install.sh --packages install packages first, then symlink
#   ./install.sh --dry-run  show what would happen, change nothing
#
# Configs are symlinked, not copied, so edits you make afterwards live in this
# repo and show up in `git status`.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
DO_PACKAGES=0

for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=1 ;;
    --packages) DO_PACKAGES=1 ;;
    -h|--help)  sed -n '2,10p' "$0"; exit 0 ;;
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
  if ! command -v yay >/dev/null 2>&1; then
    warn "yay not found. Several packages live in the AUR; install yay first:"
    warn "  sudo pacman -S --needed git base-devel"
    warn "  git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    exit 1
  fi
  say "Installing packages from packages/desktop-core.txt"
  run bash -c "grep -vE '^\s*#|^\s*$' '$REPO/packages/desktop-core.txt' \
                 | sed 's/#.*//' | tr -d ' ' | yay -S --needed --noconfirm -"
fi

# ---------------------------------------------------------------------------
# 2. Rewrite the author's home path
# Most files use ~ or relative paths, but a few formats (qt5ct/qt6ct) only
# accept absolute paths. Patch them to whoever is installing.
# ---------------------------------------------------------------------------
if [ "$HOME" != "/home/hadoki" ]; then
  say "Rewriting /home/hadoki -> $HOME in the checked-out configs"
  while IFS= read -r f; do
    echo "   $f"
    run sed -i "s|/home/hadoki|$HOME|g" "$f"
  done < <(grep -rl "/home/hadoki" "$REPO/config" "$REPO/home" 2>/dev/null || true)
fi

# ---------------------------------------------------------------------------
# 3. Symlink ~/.config entries
# ---------------------------------------------------------------------------
say "Linking configs into ~/.config (backups -> $BACKUP)"
run mkdir -p "$HOME/.config"

for src in "$REPO"/config/*; do
  name="$(basename "$src")"
  dest="$HOME/.config/$name"

  if [ -L "$dest" ]; then
    run rm -f "$dest"
  elif [ -e "$dest" ]; then
    run mkdir -p "$BACKUP"
    say "  backing up existing $name"
    run mv "$dest" "$BACKUP/$name"
  fi

  echo "  -> $name"
  run ln -s "$src" "$dest"
done

# ---------------------------------------------------------------------------
# 4. Symlink home dotfiles
# ---------------------------------------------------------------------------
say "Linking home dotfiles"
for src in "$REPO"/home/.*; do
  name="$(basename "$src")"
  [ "$name" = "." ] && continue
  [ "$name" = ".." ] && continue
  dest="$HOME/$name"

  if [ -L "$dest" ]; then
    run rm -f "$dest"
  elif [ -e "$dest" ]; then
    run mkdir -p "$BACKUP"
    say "  backing up existing $name"
    run mv "$dest" "$BACKUP/$name"
  fi

  echo "  -> $name"
  run ln -s "$src" "$dest"
done

# ---------------------------------------------------------------------------
# 5. Files that must exist but are not tracked
# ---------------------------------------------------------------------------
say "Seeding untracked local files"

env_example="$REPO/config/hypr/scripts/quickshell/calendar/.env.example"
env_real="$REPO/config/hypr/scripts/quickshell/calendar/.env"
if [ -f "$env_example" ] && [ ! -f "$env_real" ]; then
  echo "  .env (weather API key — fill this in for the calendar widget)"
  run cp "$env_example" "$env_real"
fi

monitors="$REPO/config/hypr/monitors.conf"
if [ ! -f "$monitors" ]; then
  echo "  monitors.conf (edit for your displays, or run nwg-displays)"
  run bash -c "printf 'monitor=,preferred,auto,1\n' > '$monitors'"
fi

# ---------------------------------------------------------------------------
# 6. Generate the colour scheme
# ---------------------------------------------------------------------------
say "Generating colours from the current wallpaper"
if command -v wal >/dev/null 2>&1; then
  if [ "$DRY_RUN" = 1 ]; then
    echo "   would: wal_apply.sh"
  else
    bash "$HOME/.config/hypr/scripts/wal_apply.sh" || \
      warn "wal_apply.sh failed — run it manually with an image path once you have a wallpaper"
  fi
else
  warn "python-pywal not installed; skipping. Colours appear after the first run of wal_apply.sh"
fi

echo
say "Done."
cat <<'EOF'

Next steps:
  1. Log out and back in, so QT_QPA_PLATFORMTHEME from hyprland.conf takes effect.
  2. Set your displays:   nwg-displays     (writes config/hypr/monitors.conf)
  3. Pick a wallpaper:    the bar's wallpaper picker, or
                          ~/.config/hypr/scripts/wal_apply.sh /path/to/image
  4. Weather widget:      put an OpenWeather key in
                          ~/.config/hypr/scripts/quickshell/calendar/.env

Keybindings are documented in ~/.config/hypr/keybindings.md
EOF
