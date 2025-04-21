## Homebrew apps path
if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

## ~/.local/bin path
export PATH="$HOME/.local/bin:$PATH"

## Zinit 
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

## Zsh plugins 
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

## Snippits
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::colorize
zinit snippet OMZP::docker
zinit snippet OMZP::doctl
# zinit snippet OMZP::emoji
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found
zinit snippet $HOME/.config/zsh-plugins/conda.plugin.zsh

# Load completions
autoload -U compinit && compinit

# zinit cdreplay -q

# Keybindings 
# vim mode
# bindkey -v
# double tap Tab for autosuggest
bindkey '\t\t' autosuggest-accept
# history search
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

## Prompt
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/omp.yaml)"
fi

## History
HISTSIZE=5000
HISTILFE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

## Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

## Aliases
alias ls='ls --color'
alias la='ls -A --color'
alias c='clear'
alias ~='cd ~'
alias ..='cd ..'
alias vim=nvim
alias loadenv="setopt allexport ; . ./.env ; unsetopt allexport"

# Load personal shell utils 
for file in $HOME/.config/utils/*; do
  [ -r "$file" ] && source "$file"
done

# Speed up fzf
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --walker-skip=Library,Applications,.git,node_modules"

## OS-specific configs
case $(uname) in
  # macOS configs
  Darwin)
    conda_init_os="Darwin"
    # Docker CLI
    fpath=(/Users/phill/.docker/completions $fpath)
  ;;
  # Linux configs
  Linux)
    # WSL configs
    if [[ $(systemd-detect-virt) = wsl ]]; then
      conda_init_os="WSL"
      # Ignore stupid Windows permissions (all users write access...) for directory colors
      LS_COLORS=$LS_COLORS:'ow=1;34:' ; export LS_COLORS
      # fzf path
      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    else
      conda_init_os="Linux"
    fi
  ;;
esac

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

## Tools (TODO: move to .config/...)
# Conda Init 

source "$HOME/.config/conda/conda_init.$conda_init_os.zsh"
# Go
export GOPATH=$HOME/go
# SOPS age
export SOPS_AGE_KEY_FILE=$HOME/.age/dev.txt
# Github Copilot CLI Alias
# eval "$(gh copilot alias -- zsh)"

autoload -Uz compinit
compinit
# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
