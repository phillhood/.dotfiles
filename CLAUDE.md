# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for Arch Linux (Hyprland/Wayland), managed with [GNU Stow](https://www.gnu.org/software/stow/).
Migrated from an earlier chezmoi setup. The dotfiles repo does **only** symlink management; machine
provisioning (package installs, post-install steps) lives in a separate `bootstrap` repo.

## The model: stow packages

Each top-level directory (`zsh/`, `git/`, `tmux/`, …) is a **stow package** whose contents mirror the
layout under `$HOME`. `stow <package>` creates symlinks: `zsh/.zshrc` → `~/.zshrc`,
`starship/.config/starship.toml` → `~/.config/starship.toml`, and so on.

**Deployed files are symlinks back into this repo.** Edit `zsh/.zshrc` here and `~/.zshrc` reflects it
immediately — there is no apply/render step. They are the same inode; never expect the repo and the
target to diverge.

When you **add a new file** to a package, re-link with `make restow` (stow only links files that exist
at stow time).

## Commands

```sh
make install     # symlink all packages into $HOME (alias: make stow)
make unstow      # remove all symlinks
make restow      # re-link after adding/renaming files
make adopt       # one-time: take over pre-existing real files as symlinks
stow git tmux    # stow individual packages
stow -D k9s      # unstow one package
stow -n zsh      # dry-run
```

`make install` does not install software — package provisioning is the `bootstrap` repo's job.

## Layout

- **`zsh/`** — `.zshrc` (zinit, starship, atuin, fnm, uv, zoxide/fzf), `.hushlogin`, and
  `.config/utils/*` (shell function/alias files sourced by `.zshrc`: `general`, `docker`, `k8s`, and
  `distro/arch`). `.zshrc` sources every file in `~/.config/utils/*`, then a distro-specific
  `~/.config/utils/distro/<os-release $ID>`. Add a helper by dropping a file in `zsh/.config/utils/`
  and running `make restow`.
- **`git/`** — `.gitconfig` (with a per-directory `includeIf` → `.gitconfig-shy` for the hobby
  identity) and `.gitignore_global`. Multi-account SSH is handled by `core.sshCommand`, not host
  aliases.
- **`ssh/`** — only `.ssh/config`. Private keys are never tracked (this repo is public).
- **`claude/`** — the stable, hand-edited pieces of `~/.claude`: `CLAUDE.md` and
  `hooks/uv-python.sh` (rewrites python/pip → uv). `settings.json` and `plugins/known_marketplaces.json`
  are NOT stowed — Claude Code / the GSD framework rewrite them at runtime (which breaks the symlink
  and churns the repo). Credentials, caches, and other runtime state under `~/.claude` are never tracked.
- **`starship/`, `tmux/`, `bat/`, `htop/`, `k9s/`, `helm/`** — single-app config packages.
- **`tools/`** — terminal colour-scheme conversion tooling (Material Monokai across
  kitty/iTerm2/fbterm/nvim/Windows Terminal). Repo-only, not stowed.
- **`canonical/`** — reference copies of configs that are NOT stowed (e.g. `.claude/settings.json`,
  which a plugin rewrites live) but kept for `bootstrap` to apply on a fresh machine. Mirrors `$HOME`;
  absent from `PACKAGES`, so `make install` ignores it. See `canonical/README.md`.

## Provisioning

Package installs and post-install steps (set default shell, tmux tpm, rustup, fnm, docker) are **not**
in this repo. They live in `phillhood/bootstrap`, which installs packages then clones + `make install`s
these dotfiles. One-way dependency: bootstrap → dotfiles.
