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
manager), take them over once with:

```sh
make adopt            # stow --adopt: replaces real files with symlinks
git status            # should be clean; any diff is live drift to review
```
