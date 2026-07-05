# ~/.zshrc — managed by stow (~/.dotfiles)

# ---- PATH ----
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ---- zinit (plugin manager) ----
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME/.git" ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Oh-My-Zsh snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::docker
zinit snippet OMZP::command-not-found
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx

# ---- Completions ----
autoload -Uz compinit && compinit
zinit cdreplay -q

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --icons --color=always $realpath'

# ---- History ----
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory hist_ignore_space \
       hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# ---- Keybindings ----
bindkey '\t\t' autosuggest-accept   # double-Tab accepts autosuggestion
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ---- Prompt ----
eval "$(starship init zsh)"

# ---- Tool integrations ----
eval "$(zoxide init zsh --cmd cd)"
eval "$(fzf --zsh)"
eval "$(atuin init zsh --disable-up-arrow)"
eval "$(direnv hook zsh)"

# fnm (node)
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd --shell zsh)"

# uv (python)
eval "$(uv generate-shell-completion zsh)"

# Speed up fzf walking
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --walker-skip=.git,node_modules,target"

# ---- Aliases ----
alias c='clear'
alias ~='cd ~'
alias ..='cd ..'
alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias tree='eza --tree --icons'
alias cat='bat --paging=never'
alias grep='rg'
alias vim='nvim'
alias py='uv run python'
alias pyr='uv run'
alias pip='uv pip'
alias loadenv="setopt allexport ; . ./.env ; unsetopt allexport"
alias loadenv-staging="setopt allexport ; . ./.env.staging ; unsetopt allexport"
# Kubernetes
alias k='kubectl'
alias kctx='kubectx'
alias kns='kubens'

# ---- Environment ----
export SOPS_AGE_KEY_FILE="$HOME/.age/dev.txt"

# ---- Personal shell utils (~/.config/utils/*) ----
for file in $HOME/.config/utils/*(.N); do
  [ -r "$file" ] && source "$file"
done

# ---- Distro-specific config (~/.config/utils/distro/<id>) ----
if [ -f /etc/os-release ]; then
  . /etc/os-release
  distro_file="$HOME/.config/utils/distro/$ID"
  [ -r "$distro_file" ] && source "$distro_file"
fi
