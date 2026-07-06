# dotfiles

Personal dotfiles for Arch Linux (Hyprland/Wayland), managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a **stow package** that mirrors the layout under `$HOME`.
`stow <package>` symlinks its contents into place. Editing a file here changes the live
config immediately — the deployed files are symlinks back into this repo.

## Layout

| Package    | Symlinks into                                             |
| ---------- | --------------------------------------------------------- |
| `zsh`      | `~/.zshrc`, `~/.hushlogin`, `~/.config/utils/*`           |
| `starship` | `~/.config/starship.toml`                                 |
| `git`      | `~/.gitconfig`, `~/.gitconfig-shy`, `~/.gitignore_global` |
| `tmux`     | `~/.tmux.conf`                                            |
| `ssh`      | `~/.ssh/config`                                           |
| `claude`   | `~/.claude/CLAUDE.md`, `~/.claude/hooks/uv-python.sh`      |
| `bat`      | `~/.config/bat/config`                                    |
| `htop`     | `~/.config/htop/htoprc`                                   |
| `k9s`      | `~/.config/k9s/*`                                         |
| `helm`     | `~/.config/helm/repositories.yaml`                        |
| `hypr`     | `~/.config/hypr/{hyprland.lua,themes,scripts}` (plugins/ + *.bak excluded) |
| `waybar`   | `~/.config/waybar/{config.jsonc,style.css,*.sh}` (backup/ + *.bak excluded) |
| `walker`   | `~/.config/walker/*`                                      |
| `ghostty`  | `~/.config/ghostty/*`                                     |
| `btop`     | `~/.config/btop/*`                                        |
| `cava`     | `~/.config/cava/*`                                        |
| `fastfetch`| `~/.config/fastfetch/*`                                   |

Repo-only (not stowed): `tools/` — terminal colour-scheme tooling, plus `tools/canonical/` (reference
configs a plugin rewrites live — e.g. `.claude/settings.json` — applied by `bootstrap`, not stow).

## Usage

Prerequisite: `stow` installed (`sudo pacman -S stow`).

```sh
git clone https://github.com/phillhood/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install          # symlink every package into $HOME
```

Common operations:

```sh
make stow             # symlink all packages (idempotent)
make unstow           # remove all symlinks
make restow           # re-link after adding/renaming files
stow git tmux         # stow individual packages
stow -D k9s           # unstow a single package
stow -n zsh           # dry-run (show what would happen)
```

`make install` only creates symlinks — it does **not** install software.

## Fresh machine

This repo assumes the required packages are already installed. To provision a bare
machine (install packages, then clone + stow these dotfiles), see
[`phillhood/bootstrap`](https://github.com/phillhood/bootstrap).

## Migrating an existing machine

If the target files already exist as real files (e.g. migrating off another dotfile
manager), take them over once with `make adopt`.

> [!CAUTION]
> `make adopt` is a **one-time migration** step. For any package file that already exists as a
> real file at the target, it moves that local file *into* the repo — overwriting the tracked
> copy — then symlinks it back. Run it from a clean tree and **review `git diff` afterward**:
> every adopted change shows up there. Commit what you want to keep, and discard local drift with
> `git restore .`. Re-running it later can silently clobber committed config with stale local files.

```sh
git status            # start from a clean tree
make adopt            # stow --adopt: pull existing real files into the repo, then symlink
git diff              # review every adopted change — this is your safety check
git restore .         # discard unwanted drift (or commit to keep it)
```
