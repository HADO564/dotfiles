# ── History ────────────────────────────────────────────────────────────────────
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt autocd extendedglob nomatch notify

# ── Completion ─────────────────────────────────────────────────────────────────
zstyle :compinstall filename '/home/hadoki/.zshrc'
autoload -Uz compinit
compinit

# ── Keybindings ────────────────────────────────────────────────────────────────
bindkey -e

# ── Path ───────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Plugins ───────────────────────────────────────────────────────────────────
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Aliases ────────────────────────────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias v='nvim'
alias vi='nvim'
alias lg='lazygit'
alias y='yazi'
alias top='btop'

# ── Prompt (Starship) ──────────────────────────────────────────────────────────
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
