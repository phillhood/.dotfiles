# Dotfiles (chezmoi)

Personal dotfiles managed with [chezmoi](https://chezmoi.io). This is the `chezmoi`
branch — a migration of the old [stow](https://www.gnu.org/software/stow/)-based `main`
branch to chezmoi, targeting Arch Linux (Hyprland/Wayland).

## Layout

Source lives in `~/.local/share/chezmoi` (this repo). chezmoi maps source names to the
home directory: `dot_zshrc` → `~/.zshrc`, `dot_config/…` → `~/.config/…`.

| Source                     | Target                     | Notes                                   |
| -------------------------- | -------------------------- | --------------------------------------- |
| `dot_zshrc`                | `~/.zshrc`                 | zinit plugins + starship + atuin + fnm  |
| `dot_gitconfig`            | `~/.gitconfig`             |                                         |
| `dot_gitignore_global`     | `~/.gitignore_global`      | referenced by gitconfig `excludesfile`  |
| `dot_hushlogin`            | `~/.hushlogin`             |                                         |
| `dot_tmux.conf`            | `~/.tmux.conf`             | tpm + resurrect                         |
| `dot_config/starship.toml` | `~/.config/starship.toml`  | prompt (catppuccin mocha)               |
| `dot_config/utils/`        | `~/.config/utils/`         | shell helpers sourced by `.zshrc`       |
| `dot_config/k9s/`          | `~/.config/k9s/`           | k8s (tools installed separately)        |
| `dot_config/helm/`         | `~/.config/helm/`          | helm repos                              |
| `dot_config/htop/`         | `~/.config/htop/`          |                                         |

Repo-only (see `.chezmoiignore`, not deployed to `$HOME`): `_setup/` (bootstrap scripts),
`_utils/` (terminal colour tooling), `README.md`, `TODO.md`.

## Toolchain

| Category | Tool |
| --- | --- |
| Shell | zsh + [zinit](https://github.com/zdharma-continuum/zinit) |
| Prompt | [starship](https://starship.rs) |
| History | [atuin](https://atuin.sh) |
| Node | [fnm](https://github.com/Schniz/fnm) |
| Python | [uv](https://github.com/astral-sh/uv) |
| Nav / find | [zoxide](https://github.com/ajeetdsouza/zoxide), [fzf](https://github.com/junegunn/fzf) |
| ls/cat/grep | eza, bat, ripgrep |

## Usage

```sh
# On a new machine
chezmoi init --branch chezmoi git@github.com:phillhood/.dotfiles.git
chezmoi diff          # preview
chezmoi apply         # apply

# Day to day
chezmoi edit ~/.zshrc # edit source, then:
chezmoi apply
chezmoi cd            # jump into the source repo to commit/push
```

See [`TODO.md`](./TODO.md) for outstanding migration items (nvim, Hyprland rice, .claude).
