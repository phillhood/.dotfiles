#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting Rust stable as the default toolchain"
rustup default stable

echo "==> Installing Node LTS via fnm"
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"
fnm install --lts
fnm default lts-latest
