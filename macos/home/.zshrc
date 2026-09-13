# ── History ────────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt autocd extendedglob nomatch notify

# ── Path / env ─────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export EDITOR=nvim
export VISUAL=nvim

# ── Completion ─────────────────────────────────────────────────────────────────
# Extra completion definitions from Homebrew (must be on fpath before compinit)
fpath=("$HOMEBREW_PREFIX/share/zsh-completions" "$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select                          # Tab again → arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'  # case-insensitive, partial
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # colour files/dirs in the menu
zstyle ':completion:*' special-dirs true                    # complete ./ and ../
zstyle ':completion:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*' group-name ''
zmodload zsh/complist
bindkey -M menuselect '^[[Z' reverse-menu-complete         # Shift+Tab goes back

# ── Keybindings ────────────────────────────────────────────────────────────────
bindkey -e
# Home/End — WezTerm sends these for Cmd+←/→ (the 1~/4~ forms come through tmux)
bindkey '^[[H'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line

# ── Aliases ────────────────────────────────────────────────────────────────────
alias ls="eza --icons --git -a"
alias ld="eza --tree --level=2 --icons --git"
alias ll="eza -lah --icons --git"
alias ..='cd ..'
alias ...='cd ../..'
alias v='nvim'
alias vi='nvim'
alias cheat='nvim -R ~/dotfiles/macos/CHEATSHEET.md'

# ── Tools ──────────────────────────────────────────────────────────────────────
source <(fzf --zsh)
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# ── Plugins (syntax-highlighting must stay last) ───────────────────────────────
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
