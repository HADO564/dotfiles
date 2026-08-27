# Dev Environment Cheatsheet
# tmux + Neovim + CLI Tools

---

## tmux  (Prefix = Ctrl+a)

### Sessions
| Binding | Action |
|---|---|
| `Prefix f` | Fuzzy project finder → session |
| `Prefix s` | List & switch sessions |
| `Prefix d` | Detach |
| `Prefix $` | Rename session |

### Windows
| Binding | Action |
|---|---|
| `Prefix c` | New window (keeps cwd) |
| `Prefix ,` | Rename window |
| `Prefix Tab` | Toggle last window |
| `Prefix 1–9` | Jump to window |
| `Prefix n / p` | Next / previous window |
| `Prefix < / >` | Move window left / right |
| `Prefix &` | Kill window |

### Panes
| Binding | Action |
|---|---|
| `Prefix \|` | Split right |
| `Prefix -` | Split down |
| `Prefix h/j/k/l` | Navigate panes |
| `Prefix H/J/K/L` | Resize pane |
| `Prefix z` | Zoom / unzoom pane |
| `Prefix x` | Kill pane |
| `Prefix q` | Show pane numbers |

### Copy Mode
| Binding | Action |
|---|---|
| `Prefix [` | Enter copy mode |
| `v` | Start selection |
| `Ctrl+v` | Rectangle selection |
| `y` | Yank to clipboard (wl-copy) |
| `q` | Exit copy mode |

### Misc
| Binding | Action |
|---|---|
| `Prefix r` | Reload tmux config |

---

## Neovim  (Leader = Space)

### Launch
| Command | Action |
|---|---|
| `nvim .` | Open file tree in current directory |
| `nvim <file>` | Open specific file |

### Creating Files
| Command / Binding | Action |
|---|---|
| `:e path/to/file` | Open a buffer at that path (`:w` writes it to disk) |
| `:w path/to/file` | Save current buffer as a new file |
| `:enew` | New empty unnamed buffer (`:w <name>` to name it) |
| `:!mkdir -p dir` | Create missing parent dirs before `:w` |
| `<leader>fn` | New empty buffer (LazyVim "New File") |
| `<leader>e` then `a` | New file in explorer (end with `/` to make a directory) |
| `<leader>e` then `r` / `d` | Rename / delete in explorer |

### File Navigation
| Binding | Action |
|---|---|
| `<leader>ff` | Find files (root dir) |
| `<leader>fF` | Find files (cwd) |
| `<leader>fg` | Find **git-tracked** files |
| `<leader>fb` / `<leader>,` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>fp` | Projects |
| `<leader>e` | File explorer (toggle) |

### Search / Grep
| Binding | Action |
|---|---|
| `<leader>/` | Live grep (root dir) |
| `<leader>sg` | Live grep (root dir) |
| `<leader>sG` | Live grep (cwd) |
| `<leader>sw` | Grep word under cursor |
| `<leader>sb` | Search lines in buffer |
| `<leader>sd` | Diagnostics |
| `<leader>sk` | Search keymaps |
| `<leader>sR` | Resume last search |

### Explorer (snacks sidebar, on the left)
| Binding | Action |
|---|---|
| `Ctrl+h` | **File → explorer** (focus the sidebar) |
| `Ctrl+l` | **Explorer → file** (focus editor, explorer stays open) |
| `l` / `Enter` | Open file under cursor and jump to it |
| `h` | Collapse directory |
| `<leader>e` | Toggle explorer open / closed (closes it if open) |
| `Ctrl+j` / `Ctrl+k` | Move down / up the list |
| `a` / `r` / `d` | Add / rename / delete |
| `<BS>` | Go up one directory |
| `.` | Re-root explorer at directory under cursor |
| `H` / `I` | Toggle hidden / ignored files |
| `y` / `p` | Yank / paste path |

> `Ctrl+h/l` are just window moves — with extra splits open they step one
> window at a time, not straight to the explorer.

### Harpoon (Project Bookmarks)
| Binding | Action |
|---|---|
| `<leader>ha` | Add current file |
| `<leader>hh` | Open harpoon menu |
| `<leader>h1–4` | Jump to bookmark 1–4 |
| `<leader>hp` | Previous bookmark |
| `<leader>hn` | Next bookmark |

### Git — LazyVim built-in (snacks pickers)
| Binding | Action |
|---|---|
| `<leader>gg` | LazyGit (root dir) |
| `<leader>gG` | LazyGit (cwd) |
| `<leader>gs` | Git status |
| `<leader>gb` | Git blame line |
| `<leader>gl` | Git log |
| `<leader>gL` | Git log (cwd) |
| `<leader>gf` | Current file history |
| `<leader>gd` | Git diff picker (hunks) |
| `<leader>gS` | Git stash |
| `<leader>gB` | Open in GitHub (browse) |
| `<leader>gY` | Copy GitHub link |
| `<leader>gi` / `<leader>gI` | GitHub issues (open / all) |
| `<leader>gp` / `<leader>gP` | GitHub PRs (open / all) |

### Git Hunks (gitsigns — only inside tracked files)
| Binding | Action |
|---|---|
| `]h` / `[h` | Next / previous hunk |
| `<leader>ghp` | Preview hunk inline |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghb` | Blame line (full) |
| `<leader>ghd` | Diff this file |

### Git — Extended
| Binding | Action |
|---|---|
| `<leader>gn` | Neogit |
| `<leader>gD` | Diffview (side-by-side diff) |
| `<leader>gH` | File history (Diffview) |
| `<leader>gx` | Close Diffview |

### GitHub (Octo)
| Binding | Action |
|---|---|
| `<leader>Go` | Octo dashboard |
| `<leader>Gi` | List issues |
| `<leader>Gp` | List pull requests |
| `<leader>Gc` | Create pull request |
| `<leader>Gr` | Start PR review |

### LSP
| Binding | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover docs |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format file |
| `[d / ]d` | Prev / next diagnostic |
| `<leader>cd` | Line diagnostic |

### Buffers & Splits
| Binding | Action |
|---|---|
| `<leader>bd` | Delete buffer |
| `<leader>bb` | Switch to **alternate** buffer |
| `<leader>bo` | Delete other buffers |
| `Ctrl+h/j/k/l` | Navigate splits |
| `<leader>-` | Split window **below** |
| `<leader>\|` | Split window **right** |

---

## System

| Binding | Action |
|---|---|
| `Super + I` | btop (CPU / RAM / processes) |

## CLI Tools

### GitHub (`gh`)
```
gh auth login            # Authenticate
gh repo list             # List repos
gh issue list            # List issues
gh pr list               # List PRs
gh pr create             # Create PR
gh pr checkout <num>     # Checkout PR branch
gh pr view --web         # Open PR in browser
```

### Linear
```
linear issue list        # List issues
linear issue create      # Create issue
linear issue view <id>   # View issue
```

### Docker
```
docker ps                # Running containers
docker ps -a             # All containers
docker images            # List images
docker compose up -d     # Start stack (background)
docker compose down      # Stop stack
docker logs -f <name>    # Follow logs
docker exec -it <name> sh   # Shell into container
docker system prune      # Clean up unused resources
```

### Wallpapers (CLI)
```
swww img ~/Pictures/wall.jpg    # Static wallpaper
swww img ~/Pictures/wall.gif    # Animated wallpaper
waypaper                        # GUI picker (or Super+W)
```

---

> Press `q` to close.
