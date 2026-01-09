## Homebrew apps path
if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

## Path updates
export PATH="/usr/bin:$HOME/.local/bin:$PATH"

## Zinit 
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
mkdir -p "${XDG_CACHE_HOME:-${HOME}/.cache}/zinit/completions"
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
  # Prevent OSC 11 background color query from leaking in tmux
  export POSH_TERMINAL_BACKGROUND=dark
  if [ -n "$FBTERM" ]; then
    eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/omp.fbterm.yaml)"
  else
    eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/omp.yaml)"
  fi
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
os=$(uname -s)
case $os in

  # macOS configs
  Darwin)
    # Docker CLI
    fpath=(/Users/phill/.docker/completions $fpath)
    export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
  ;;

  # Linux configs
  Linux)
    # Distro-specific configs
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      distro=$ID
    elif type lsb_release >/dev/null 2>&1; then
      distro=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/lsb-release ]; then
      . /etc/lsb-release
      distro=$DISTRIB_ID
    elif [ -f /etc/debian_version ]; then
      distro="debian"
    else
      distro="unknown"
    fi
    distro_file="$HOME/.config/utils/distro/$distro"
    [ -r "$distro_file" ] && source "$distro_file"

    # WSL configs
    if [[ $(systemd-detect-virt) = wsl ]]; then
      # Ignore stupid Windows permissions (all users write access...) for directory colours
      LS_COLORS=$LS_COLORS:'ow=1;34:' ; export LS_COLORS
      # fzf path
      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    fi
    export PYTHONPATH="/usr/lib/python3/dist-packages:$PYTHONPATH"
  ;;
  
esac

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Conda init lazy loader
source "$HOME/.config/conda/conda_init.$os.zsh"
# Go
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$PATH:/usr/local/go/bin
# SOPS age
export SOPS_AGE_KEY_FILE=$HOME/.age/dev.txt

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

autoload -Uz compinit
compinit

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
