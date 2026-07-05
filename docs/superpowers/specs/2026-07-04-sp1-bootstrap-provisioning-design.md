# SP1 — Fresh-machine bootstrap & dependency provisioning

**Date:** 2026-07-04
**Status:** Approved design, ready for implementation plan
**Branch:** `chezmoi`

## Context

The `chezmoi` branch migrated the dotfiles from stow to chezmoi, but `_setup/` is still the
pre-chezmoi bootstrap: it installs stow/nvm/oh-my-posh, ends with `stow .`, and its 22 per-tool
dependency scripts don't match the tools the current `.zshrc`/configs actually use. This sub-project
rewrites provisioning so a bare Arch machine can be taken to the current working setup with one
command, chezmoi-native.

This is **SP1** of a three-part decomposition of `TODO.md`:

- **SP1 (this spec)** — bootstrap & dependency provisioning.
- **SP2 (later)** — config tracking & templating (nvim, Hyprland rice, ghostty, tmux-powerline,
  VS Code keybindings). Desktop packages will slot into SP1's package data as a templated group.
- **SP3 (later)** — cleanups (envman removal, code-tunnel systemd, optional global `.claudeignore`).

## Goal

`chezmoi init --apply` provisions a fresh Arch machine: installs the correct toolchain via
pacman/AUR and lays down all tracked dotfiles, idempotently and re-runnably.

## Locked decisions

| Decision | Choice |
| --- | --- |
| Target distro | **Arch only** (this machine reports `/etc/os-release` `ID=arch`). Drop the old ubuntu/debian/darwin branches. |
| Package source | **pacman/AUR-first**, with `yay` as the unified installer (wraps pacman for official repos, builds AUR). `paru` is absent; `yay` is present. |
| Package groups | `core`, `cli`, `secrets`, `docker` install by default; `k8s` is **opt-in**. Desktop packages deferred to SP2. |
| Provisioning model | **chezmoi-native** (Approach C): package data + `run_*` scripts run during `chezmoi apply`; a thin `_setup/bootstrap` is the bare-machine entrypoint. |
| Execution model | **Run as normal user** (yay/makepkg refuse root); individual steps escalate with `sudo`. Flips the old root/`$SUDO_USER` model. |
| Toolchains | Install a **default Rust stable + Node LTS** (not just the version managers). |
| Easter eggs | **Keep** `_setup/_kek/`; `_setup/bootstrap` echoes one at the very end. |

## Architecture & flow

### Entrypoint 1 — `_setup/bootstrap` (bare machine)

Minimal POSIX/bash script, the single human-facing entrypoint. Responsibilities:

1. **Guard:** refuse to run as root (yay/makepkg must build as a normal user; steps call `sudo`
   internally).
2. `sudo pacman -Sy --needed --noconfirm git chezmoi` (both in official `extra`).
3. `chezmoi init --apply --branch chezmoi git@github.com:phillhood/.dotfiles.git`
   (no `exec`, so control returns).
4. Echo one `_setup/_kek/*` easter egg from the chezmoi source path as the final line.

### Entrypoint 2 — `chezmoi apply` (does the real work)

chezmoi orders scripts by `before`/`after` and numeric prefix, interleaved with file application:

```
run_onchange_before_10-install-packages.sh.tmpl   ensure base-devel + yay, then yay -S --needed all groups
  … chezmoi applies all dot_* config files …
run_once_after_20-set-default-shell.sh            chsh to zsh if the login shell isn't already zsh
run_onchange_after_30-docker.sh                   systemctl enable --now docker; usermod -aG docker $USER
run_once_after_40-tmux-tpm.sh                     clone tpm if missing
run_once_after_50-rust-node.sh                    rustup default stable; fnm install --lts + set default
```

`run_onchange_` scripts are chezmoi templates whose content-hash changes when the data they inline
changes — so editing the package list makes the next `chezmoi apply` install exactly the new
packages, and a no-op otherwise. `run_once_` steps run once per machine.

## Package data model

`.chezmoidata/packages.yaml` — single source of truth (yay installs official + AUR transparently,
so no per-tool repo classification is needed):

```yaml
packages:
  core:    [zsh]                       # git, base-devel, yay, chezmoi are handled as build prereqs
  cli:     [starship, atuin, fnm, eza, bat, ripgrep, fzf, zoxide,
            direnv, jq, uv, rustup, go, tmux, neovim, fastfetch]
  secrets: [sops, age]
  docker:  [docker, docker-compose, docker-buildx]
  k8s:     [kubectl, kubectx, k9s, helm, kubeseal, argocd]   # opt-in only
```

Exact package names (e.g. `helm` vs `helm-bin`, `fnm` official vs AUR) are resolved at
implementation time by checking availability; yay handles both sources, so the group lists are the
only thing that changes.

### k8s opt-in

`.chezmoi.toml.tmpl` uses `promptBoolOnce` during `chezmoi init` to ask "install k8s tools?" once and
stores the answer as `data.installK8s`. The install-packages template includes the `k8s` group only
when true. Non-interactive on subsequent applies.

## Scripts

### `.chezmoiscripts/run_onchange_before_10-install-packages.sh.tmpl`

1. `sudo pacman -S --needed --noconfirm base-devel git` (yay build prerequisites).
2. Ensure `yay`: if absent, clone `yay-bin` from AUR and `makepkg -si`.
3. Flatten the group lists from the inlined data (`{{ .packages.core }}`, `cli`, `secrets`, `docker`,
   plus `k8s` under `{{ if .installK8s }}`) and run `yay -S --needed --noconfirm <all>`.

### Exception scripts (steps that are more than "install a package")

- **`run_once_after_20-set-default-shell.sh`** — `chsh -s "$(command -v zsh)"` if the login shell
  isn't already zsh.
- **`run_onchange_after_30-docker.sh`** — `sudo systemctl enable --now docker.service`;
  `sudo usermod -aG docker "$USER"` (both guarded/idempotent).
- **`run_once_after_40-tmux-tpm.sh`** — clone tpm if missing. **Clone path is pinned to whatever the
  tracked `dot_tmux.conf` references** (the old dep used `~/.config/tmux/plugins/tpm` but
  `dot_tmux.conf` maps to `~/.tmux.conf`; reconcile at implementation, don't guess).
- **`run_once_after_50-rust-node.sh`** — `rustup default stable`; `fnm install --lts` and set it as
  the default.

### Not needed as scripts

zinit self-clones in `.zshrc`; starship/atuin/zoxide/direnv/fzf/uv are activated by `.zshrc` evals.

## Repo changes

**Removed:** `_setup/_dependencies/` (all 22 per-tool scripts); old `_setup/setup`.

**Added:**
```
_setup/bootstrap
.chezmoidata/packages.yaml
.chezmoi.toml.tmpl
.chezmoiscripts/run_onchange_before_10-install-packages.sh.tmpl
.chezmoiscripts/run_once_after_20-set-default-shell.sh
.chezmoiscripts/run_onchange_after_30-docker.sh
.chezmoiscripts/run_once_after_40-tmux-tpm.sh
.chezmoiscripts/run_once_after_50-rust-node.sh
```

**Kept:** `_setup/_kek/` (easter eggs, now invoked from `_setup/bootstrap`); `_utils/` untouched.

**Docs:** update `README.md` bootstrap one-liner; check off the *Bootstrap scripts* section in
`TODO.md`.

**`.chezmoiignore`:** no change. `.chezmoidata`, `.chezmoiscripts`, and `.chezmoi.toml.tmpl` are
chezmoi's own special paths (active, correctly not ignored); `_setup/` stays repo-only as today.

## Error handling & idempotency

- Every script uses `set -euo pipefail` and fails fast — a failed package aborts with a clear chezmoi
  error rather than the old ✓/✗ marker-guessing.
- Idempotent by construction: `yay -S --needed` skips installed packages; `run_once_` runs once per
  machine; docker group/enable and tpm-clone are guarded. `chezmoi apply` is safe to re-run.
- The old `$MARKER_DIR` marker system is removed; chezmoi's own script state replaces it.

## Testing / verification

No clean machine on hand, so verification is layered:

1. `shellcheck` every new script.
2. `chezmoi execute-template` on the `.tmpl` files to confirm they render against the package data.
3. `chezmoi apply --dry-run --verbose` and `chezmoi status` to confirm script ordering and no
   surprises.
4. **Primary end-to-end check:** run the full `_setup/bootstrap` flow in a throwaway
   `docker run archlinux` container — exercises pacman, the yay build, package install, and the
   chezmoi handoff on a clean Arch userland. A second run in the same container proves idempotency
   (no-ops).

## Out of scope (SP1)

- The age private key at `~/.age/dev.txt` — SP1 installs the `sops`/`age` binaries only; the key is
  provisioned out-of-band and never enters the repo.
- Desktop packages (hyprland/waybar/ghostty/etc.) and their configs — SP2.
- Non-Arch distro support — removed now, re-addable later if a non-Arch machine appears.
