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
- [x] `settings.json` untracked from the `claude` package (Claude/GSD rewrite it live) — canonical
      copy now kept in `canonical/.claude/settings.json`.
- [ ] Curate `canonical/.claude/settings.json` down to your own prefs (model/theme/effortLevel/
      permissions/statusLine); drop the GSD-generated `hooks` block (GSD recreates it on install,
      with the correct machine node path).
- [ ] Bootstrap: install GSD (`npx gsd-core …`, regenerates hooks) then **merge** the canonical
      prefs into `~/.claude/settings.json` (e.g. `jq -s '.[0] * .[1]'`) — don't overwrite.
