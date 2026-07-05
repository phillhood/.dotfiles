# Dotfiles TODO

Open follow-ups for the stow-based dotfiles.

## Neovim
- [ ] Decide nvim config: Arch system runs LazyVim; old EndeavourOS ran NvChad.
- [ ] Once decided, add an `nvim/` stow package (`nvim/.config/nvim/…`); track
      `lazy-lock.json`, ignore the plugins dir.

## Hyprland desktop rice (currently untracked)
- [ ] Decide what to track: hypr, waybar, walker, ghostty, nwg-look, wireplumber, cava,
      fastfetch, btop. Add as stow packages. Watch for machine-specific monitor/env lines.

## Claude Code (~/.claude)
- [ ] `settings.json` is tracked but non-portable: its GSD hooks + statusline hardcode a
      specific fnm node path (`~/.local/share/fnm/node-versions/vX/.../node`) and reference
      `gsd-*.js`/`gsd-*.sh` hook scripts that are NOT tracked in the `claude` package. On a
      fresh machine (or after a node bump) every gsd hook + statusline breaks until that node
      version and the hook scripts exist. Decide in the bootstrap repo: install the gsd hooks
      + pin/relink node, or template the node path.
- [ ] `known_marketplaces.json` tracks a `lastUpdated` timestamp that Claude bumps on every
      marketplace refresh → recurring noise diffs. Decide whether to keep tracking it.

## Bootstrap (separate repo) — built
- [x] `phillhood/bootstrap` built at `~/Dev/phillhood/bootstrap` (local, branch `main`):
      `install.sh` + `lib/` (distro dispatch) + `steps/` + `packages/{core,cli,docker,k8s}.txt` + `kek/`.
- [ ] Push it to GitHub (`gh repo create phillhood/bootstrap --public`) to enable the `curl | bash` one-liner.
- [ ] Coordination: bootstrap clones dotfiles at `DOTFILES_BRANCH` (default `main`); until the stow
      layout is on `main`, fresh-machine runs need `DOTFILES_BRANCH=stow`. Resolve when pushing `stow`.
- [ ] Port the deferred container smoke-test for end-to-end idempotency verification.
