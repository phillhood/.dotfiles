# Custom conda init configuration
# Make sure to not run `conda init` or remove the generated block from shell config

# Lazyload conda init for faster shell
conda_lazy_load() {
  # Capture caller command and shift args
  local cmd="$1"
  shift

  local conda_paths=(
    "/opt/miniconda3/bin/conda"
    # Might need to add more paths for different install methods...
  )
  # Unset the lazy loader for the given command so that future calls use the real command.
  unset -f "$cmd"
  # Run conda init hook and then run the command with original arguments
  for conda_path in "${conda_paths[@]}"; do
    if [ -f "$conda_path" ]; then
      eval "$($conda_path shell.zsh hook)"
      "$cmd" "$@"
      return
    fi
  done
  echo "No conda installation found... (check ~/.config/conda/conda_init.WSL.zsh)"
}

# Wrapper for lazy loading conda
conda() { conda_lazy_load conda "$@"; }

# Wrapper for lazy loading python
python() { conda_lazy_load python "$@"; }

# Conda aliases
alias cact='conda activate'
alias cdeact='conda deactivate'
alias cls='conda list'
alias cels='conda env list'
alias ccen='conda create --name'
alias conup='conda update'
alias conin='conda install'