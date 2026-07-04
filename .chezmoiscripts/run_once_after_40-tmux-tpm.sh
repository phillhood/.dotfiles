#!/usr/bin/env bash
set -euo pipefail

tpm_dir="$HOME/.tmux/plugins/tpm"
if [ ! -d "$tpm_dir" ]; then
  echo "==> Cloning tpm to $tpm_dir"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
fi
