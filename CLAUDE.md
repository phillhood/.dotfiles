# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles managed with [chezmoi](https://chezmoi.io), targeting Arch Linux (Hyprland/Wayland).
This is the `chezmoi` branch — an in-progress migration of the old [stow](https://www.gnu.org/software/stow/)-based
`main` branch. Outstanding migration items live in [`TODO.md`](./TODO.md).

## The one thing to understand: source-name mapping

This repo **is** the chezmoi source directory (`~/.local/share/chezmoi`). chezmoi translates
source filenames into `$HOME` targets — the repo does not mirror `$HOME` literally. You edit the
`dot_*` source files here; running `chezmoi apply` renders them into place. **Never edit the deployed
`~/.zshrc` etc. directly** — it gets overwritten on the next apply.

Naming attributes encoded in source filenames:

| Source name                         | Target / effect                          |
| ----------------------------------- | ---------------------------------------- |
| `dot_zshrc`                         | `~/.zshrc` (`dot_` → `.`)                |
| `dot_config/k9s/config.yaml`        | `~/.config/k9s/config.yaml`              |
| `executable_uv-python.sh`           | target file gets the executable bit      |
| `private_htoprc`                    | target file gets mode `0600`             |
| `_setup/`, `_utils/` (`_` prefix)   | ignored by chezmoi — repo-only, not deployed |

`.chezmoiignore` is the other half: it lists paths that stay in the repo as reference/tooling
(`README.md`, `TODO.md`, `_setup`, `_utils`) plus defensive guards so `~/.claude` secrets and
runtime state can never be swept into version control.

## Commands

There is no build/test/lint — the "commands" are the chezmoi lifecycle:

```sh
chezmoi diff                 # preview what apply would change (run this before applying)
chezmoi apply                # render source → $HOME
chezmoi edit ~/.zshrc        # edit the source of a target, then apply
chezmoi add ~/.config/foo    # start tracking a live file (imports it as a dot_* source)
chezmoi re-add               # pull edits made directly to already-tracked targets back into source
chezmoi cd                   # jump into this repo to commit/push
```

When you change a `dot_*` file in this repo, deploy it with `chezmoi apply` and confirm with
`chezmoi diff` (should be clean). A source edit is not "done" until applied.

## Layout

- **`dot_zshrc`** — the shell entrypoint: zinit plugins, starship prompt, atuin history, fnm (node),
  uv (python), zoxide/fzf. At the bottom it sources every file in `~/.config/utils/*`, then sources a
  distro-specific file `~/.config/utils/distro/<os-release $ID>` (e.g. `arch`).
- **`dot_config/utils/`** — plain shell files of functions/aliases sourced by `.zshrc`
  (`general`, `docker`, `k8s`, and `distro/arch`). Add a new helper by dropping a file here; it is
  auto-sourced on next shell start. `distro/<id>` files hold per-distro config.
- **`dot_claude/`** — tracks hand-maintained pieces of `~/.claude`: `settings.json`, the
  `uv-python.sh` hook, and `plugins/known_marketplaces.json`. The statusline
  (`~/.claude/ccline/ccline`) is a separately-installed binary that `settings.json` only references
  (not tracked here). Treat the `.chezmoiignore` `~/.claude` guard block as load-bearing — never
  track credentials/history/caches.
- **`_setup/`** — **stale, stow-era bootstrap** (see below). Not wired into the chezmoi workflow.
- **`_utils/terminals/`** — terminal colour-scheme conversion tooling (Material Monokai across
  kitty/iTerm2/fbterm/nvim/Windows Terminal via `convert_colours.py`).

## `_setup/` bootstrap architecture

`_setup/setup` is a fresh-machine provisioner from the pre-chezmoi era. It detects the distro from
`/etc/os-release`, then iterates `_dependencies/<N_phase>/` directories in `sort -V` order; each file
in a phase is an install script run as `zsh <file> $DISTRO`. A script signals success by
`touch`-ing `$MARKER_DIR/<its-name>`, which the runner checks to print ✓/✗.

**It has not been migrated:** it still ends with `stow .` and installs nvm/oh-my-posh rather than the
current chezmoi/starship/fnm stack. Do not treat it as the working bootstrap path — updating it is an
open TODO item.

## State note

This branch has no commits yet — everything is currently untracked. The default branch for PRs is `main`.
