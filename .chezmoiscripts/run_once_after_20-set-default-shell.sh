#!/usr/bin/env bash
set -euo pipefail

zsh_path="$(command -v zsh)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"

if [ "$current_shell" != "$zsh_path" ]; then
  echo "==> Setting default shell to zsh ($zsh_path)"
  sudo chsh -s "$zsh_path" "$USER"
fi
