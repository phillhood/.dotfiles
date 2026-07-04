#!/usr/bin/env bash
set -euo pipefail

if [ -d /run/systemd/system ]; then
  echo "==> Enabling docker.service"
  sudo systemctl enable --now docker.service
else
  echo "==> systemd not running; skipping docker.service enable"
fi

if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
  echo "==> Adding $USER to docker group (re-login required to take effect)"
  sudo usermod -aG docker "$USER"
fi
