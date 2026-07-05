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
- [ ] Root `.claude/settings.json` (this repo's own project allowlist) still permits
      `chezmoi managed/status/diff/...` — dead entries now that chezmoi is gone; prune when convenient.

## Bootstrap (separate repo)
- [ ] Build `phillhood/bootstrap`: install.sh, packages/{core,cli,docker,k8s}.txt,
      post-install.sh, lib/ (distro detect), smoke-test.sh, easter egg. Source material is in
      git history on the `chezmoi` branch (`.chezmoidata/packages.yaml`, `.chezmoiscripts/*`,
      `_setup/*`). See docs/superpowers/specs/2026-07-05-stow-migration-design.md.
