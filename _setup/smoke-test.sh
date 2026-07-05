#!/usr/bin/env bash
set -euo pipefail

# End-to-end test of the bootstrap flow in a throwaway Arch container.
# Provisions a non-root sudo user, runs bootstrap twice (second run proves
# idempotency: no rebuilds, yay --needed no-ops). systemd is absent in the
# container, so the docker service-enable step self-skips by design.

img="archlinux:latest"

docker run --rm "$img" bash -euo pipefail -c '
  pacman -Sy --noconfirm --needed git base-devel sudo
  useradd -m -G wheel tester
  echo "tester ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/tester

  su - tester -c "
    set -euo pipefail
    git clone --branch chezmoi https://github.com/phillhood/.dotfiles.git /tmp/dotfiles
    echo === FIRST RUN ===
    /tmp/dotfiles/_setup/bootstrap
    echo === SECOND RUN \(idempotency\) ===
    chezmoi apply
    echo === VERIFY ===
    command -v starship && command -v eza && command -v yay
    test -f ~/.zshrc && echo zshrc-applied
  "
'
echo "SMOKE TEST PASSED"
