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
- [ ] ccline statusline binary + `~/.claude/ccline/{config.toml,models.toml,themes/}` are
      installed locally but not tracked. Decide whether to track config and/or script the
      install in the bootstrap repo.
- [ ] Plugins: reinstall via `/plugin` if wanted, then re-add `enabledPlugins` to settings.json.

## Bootstrap (separate repo)
- [ ] Build `phillhood/bootstrap`: install.sh, packages/{core,cli,docker,k8s}.txt,
      post-install.sh, lib/ (distro detect), smoke-test.sh, easter egg. Source material is in
      git history on the `chezmoi` branch (`.chezmoidata/packages.yaml`, `.chezmoiscripts/*`,
      `_setup/*`). See docs/superpowers/specs/2026-07-05-stow-migration-design.md.
