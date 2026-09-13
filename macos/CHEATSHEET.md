# macOS Cheatsheet
# Hyprland habits → built-in macOS, plus what changed in the terminal

Open from a terminal with `cheat`.
tmux and Neovim bindings are identical to Arch — see `config/hypr/dev-cheatsheet.md`.

---

## Apps & launcher

| Arch (Hyprland)          | macOS                                                   |
| ------------------------ | ------------------------------------------------------- |
| `Alt + Space` launcher   | `Cmd + Space` Spotlight (Raycast: `Opt + Space`)        |
| `Super + V` clipboard    | `Cmd + Space`, then `Cmd + 4` (Spotlight clipboard)     |
| `Super + Q` terminal     | Spotlight → "WezTerm"                                   |
| `Super + E` file manager | Finder — `Cmd + Shift + H` home, `Cmd + Shift + .` hidden files |
| `Super + Shift + C` color picker | Digital Color Meter (Spotlight)                 |
| `Super + I` btop         | Activity Monitor, or `top`                              |

## Windows

| Arch (Hyprland)          | macOS                                                   |
| ------------------------ | ------------------------------------------------------- |
| `Super + X` close        | `Cmd + W` close window · `Cmd + Q` quit app             |
| `Super + M` minimize     | `Cmd + M` · `Cmd + H` hide whole app                    |
| Focus next window        | `Cmd + Tab` apps · ``Cmd + ` `` windows of same app     |
| Tile left / right        | `Globe + Ctrl + ← / →`                                  |
| Maximize (fill)          | `Globe + Ctrl + F` · back: `Globe + Ctrl + R`           |
| Center                   | `Globe + Ctrl + C`                                      |
| Fullscreen               | `Globe + F`                                             |

## Workspaces (Desktops)

| Arch (Hyprland)              | macOS                                               |
| ---------------------------- | --------------------------------------------------- |
| `Super + 1–9` switch         | `Ctrl + 1–9` (set by `macos/defaults.sh`)           |
| Next / previous              | `Ctrl + ← / →` · three-finger swipe                 |
| `Super + Shift + 1–9` move window | Hold the window's title bar, press `Ctrl + N`  |
| Overview                     | `Ctrl + ↑` Mission Control (add desktops with `+`)  |
| `Super + S` scratchpad       | No direct match — `Cmd + H` hides, `Cmd + Tab` back |

## Screenshots  (saved to ~/Pictures/Screenshots)

| Arch (grimblast)            | macOS                          |
| --------------------------- | ------------------------------ |
| `Print` area → clipboard    | `Cmd + Ctrl + Shift + 4`       |
| `Shift + Print` screen → clipboard | `Cmd + Ctrl + Shift + 3` |
| `Super + Print` area → file | `Cmd + Shift + 4`              |
| Screen → file               | `Cmd + Shift + 3`              |
| Window → file               | `Cmd + Shift + 4`, then `Space`|
| Recording / options         | `Cmd + Shift + 5`              |

## System

| Arch                        | macOS                                     |
| --------------------------- | ----------------------------------------- |
| `Super + L` lock            | `Ctrl + Cmd + Q`                          |
| `Super + Shift + Alt + M` exit | `Cmd + Shift + Q` log out              |
| gammastep                   | Night Shift (Settings → Displays)         |
| hypridle                    | Settings → Lock Screen                    |
| Media / brightness keys     | Work natively                             |
| `wl-copy` / `wl-paste`      | `pbcopy` / `pbpaste`                      |

---

## Terminal (WezTerm)

| Key                 | Does                                          |
| ------------------- | --------------------------------------------- |
| `Cmd + ← / →`       | Start / end of line                           |
| `Opt + ← / →`       | Word back / forward                           |
| `Cmd + Backspace`   | Delete line                                   |
| `Opt + Backspace`   | Delete word                                   |
| `Cmd + Click`       | Open link                                     |
| `Cmd + + / -`       | Font size                                     |

## Shell (zsh)

| Key                  | Does                                         |
| -------------------- | -------------------------------------------- |
| `Tab`                | Complete (dirs only for `cd`, `mkdir`, …)     |
| `Tab Tab`            | Arrow-key menu · `Shift + Tab` goes back     |
| `→`                  | Accept grey history suggestion               |
| `Ctrl + R`           | Fuzzy history (fzf)                          |
| `Ctrl + T`           | Fuzzy insert file path (fzf)                 |
| `Alt + C`            | Fuzzy cd (fzf)                               |
| `z <dir>`            | zoxide jump                                  |

## Differences from Arch

- **tmux:** `Prefix` is still `Ctrl + a`; copy-mode `y` goes to `pbcopy`.
  tmux-resurrect (`Prefix Ctrl+s / Ctrl+r`) only loads if installed at
  `~/.local/share/tmux/plugins/tmux-resurrect`.
- **Prefix f** (sessionizer) searches `~/projects`, `~/dotfiles`, `~/Documents`.
  Override with `export TMUX_SESSIONIZER_PATHS="~/work ~/code"`.
- **Neovim:** `<leader>gg` needs lazygit (`brew install lazygit`);
  Neogit (`<leader>gn`) works without it.
- **Ctrl + Space** no longer switches keyboard input, so it reaches Neovim.
