# dotfiles

Hyprland desktop built around a custom [Quickshell](https://quickshell.outfoxxed.me)
bar, with every colour in the system generated from the current wallpaper.

- **Compositor** — Hyprland
- **Shell / bar** — Quickshell (custom QML; not waybar)
- **Colours** — pywal, fanned out to Quickshell, Hyprland, Rofi, GTK, Qt, cava, swaync
- **Terminal** — kitty · **Launcher** — vicinae + rofi · **Files** — Thunar
- **Wallpaper** — awww (swww fork), optionally linux-wallpaperengine

## Install

```bash
git clone https://github.com/HADO564/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run     # see exactly what it would do
./install.sh --packages    # install packages, then link
```

`install.sh` symlinks `config/*` into `~/.config` and `home/.*` into `~`.
Anything already there is moved to `~/.config-backup-<timestamp>` first, so
the script is safe to run on a machine that is already set up.

Because it symlinks rather than copies, edits you make later land in this repo
and show up in `git status`.

### macOS

The Mac side reuses the terminal dev environment only — Neovim and tmux are
shared with Arch, everything desktop-related is replaced by built-in macOS
features (mapped in `macos/CHEATSHEET.md`).

```bash
macos/install.sh --dry-run               # see what it would do
macos/install.sh --packages --defaults   # brew bundle, link, apply macOS settings
```

## Layout

```
config/      -> ~/.config/*
home/        -> ~/.{zshrc,bashrc,profile,...}
bin/         shared scripts (tmux-sessionizer)
macos/
  Brewfile              the few packages macOS doesn't already cover
  install.sh            links config/{nvim,tmux} + macos/* into place
  defaults.sh           Ctrl+1..9 desktops, frees Ctrl+Space, screenshot folder
  CHEATSHEET.md         Hyprland shortcuts -> macOS equivalents
  config/, home/        Mac-only zsh, WezTerm, starship
packages/
  desktop-core.txt      curated: what this desktop actually needs
  pacman-official.txt   every explicitly installed repo package
  aur-packages.txt      every explicitly installed AUR package
install.sh
```

## How the theming works

One script drives everything: `config/hypr/scripts/wal_apply.sh`.

```
wallpaper image
   └─ pywal  ──>  ~/.cache/wal/colors.json
        └─ wal_apply.sh derives a Catppuccin-shaped palette
             ├─ /tmp/qs_colors.json ............ Quickshell (bar, popups, tray menu)
             ├─ ~/.config/hypr/colors.conf ..... window border colours
             ├─ ~/.config/rofi/theme.rasi ...... launcher
             ├─ ~/.config/gtk-[34].0/colors.css  GTK3 / GTK4 + libadwaita
             └─ ~/.config/qt[56]ct/ ............ Qt palette + stylesheet
```

Then `quickshell/wallpaper/matugen_reload.sh` nudges each running app to
re-read its colours.

Two rules keep this maintainable:

- **Generated files hold colours only.** `colors.css` and `pywal.qss` are
  regenerated on every wallpaper change and are gitignored.
- **Hand-written files hold shape.** `gtk.css` and the QML own the rounding,
  padding and hover states, and import the colours. They survive retheming.

### Context menus

Menus are the one thing every toolkit draws differently, so they are themed in
three separate places:

| Menu | Drawn by | Themed in |
|---|---|---|
| Tray icon right-click | Quickshell | `quickshell/tray/TrayMenu.qml` + `TrayMenuSection.qml` |
| Thunar, GTK apps | GTK3 / GTK4 | `config/gtk-3.0/gtk.css`, `config/gtk-4.0/gtk.css` |
| VLC and other Qt apps | Qt | `qt6ct` + generated `pywal.qss` |

The tray menu is a full QML reimplementation of the dbusmenu protocol rather
than Quickshell's built-in `QsMenuAnchor`, which renders an unstyled native Qt
widget menu that no stylesheet can reach.

## Notes

- **Log out and back in after installing.** `QT_QPA_PLATFORMTHEME=qt6ct` is set
  in `hyprland.conf` and only applies to newly started sessions.
- **Qt5 apps need `qt5ct`.** `QT_QPA_PLATFORMTHEME` takes a single value, so
  Qt6 apps read `qt6ct` and Qt5 apps (VLC, for one) need `qt5ct` installed and
  will otherwise stay unthemed. The `qt5ct` configs are generated either way.
- **Displays** are not tracked — `config/hypr/monitors.conf` is gitignored.
  Run `nwg-displays` to generate your own.
- **Weather widget** needs a free [OpenWeather](https://openweathermap.org/api)
  key in `config/hypr/scripts/quickshell/calendar/.env` (copy `.env.example`).
- **Fonts** are JetBrains Mono Nerd Font for text and Iosevka Nerd Font for
  icons. Menus will look wrong without both.

Keybindings: `config/hypr/keybindings.md`
