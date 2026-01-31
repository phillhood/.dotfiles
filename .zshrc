## Homebrew apps path
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

## Path updates
export PATH="/usr/bin:$HOME/.local/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

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

# Load completions
autoload -U compinit && compinit

# Lazy load kubectl completion to speed up shell startup
kubectl() {
  if ! type __start_kubectl >/dev/null 2>&1; then
    source <(command kubectl completion zsh)
  fi
  command kubectl "$@"
}

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
HISTFILE=~/.zsh_history
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
alias loadenv-staging="setopt allexport ; . ./.env.staging ; unsetopt allexport"
function pip { uv pip "$1" --system "${@:2}"; }

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
[[ -o interactive ]] && eval "$(fzf --zsh)"
[[ -o interactive ]] && eval "$(zoxide init --cmd cd zsh)"

# Undefine zoxide cd function in non-interactive shells to avoid issues with scripts that use cd
if [[ ! -o interactive ]] && (( ${+functions[cd]} )); then
  unfunction cd
fi

# uv (python)
eval "$(uv generate-shell-completion zsh)"
# Go
# export GOPATH=$HOME/go
# export GOROOT=/usr/local/go
# export PATH=$PATH:/usr/local/go/bin
# SOPS age
export SOPS_AGE_KEY_FILE=$HOME/.age/dev.txt

# nvm lazy loader - only load when nvm/node/npm/npx is first used
export NVM_DIR="$HOME/.nvm"
_nvm_load() {
  unset -f nvm node npm npx _nvm_load
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm() { _nvm_load && nvm "$@"; }
node() { _nvm_load && node "$@"; }
npm() { _nvm_load && npm "$@"; }
npx() { _nvm_load && npx "$@"; }

autoload -Uz compinit
compinit

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
# export PATH="/opt/homebrew/bin:$PATH"
# export GOPATH=$HOME/go
# export PATH=$GOPATH/bin:$PATH
alias dos3='aws s3 --profile do'
alias kctrldev='kubectx do-nyc3-core-development && kubens ctrl-core-dev'
alias kctrlprod='kubectx do-nyc3-core-production && kubens ctrl-core'

alias k='kubectl'
alias kctx='kubectx'
alias kns='kubens'
