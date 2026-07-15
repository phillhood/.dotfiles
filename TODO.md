# Dotfiles TODO

Open follow-ups for the stow-based dotfiles.

## Neovim
- [ ] Decide nvim config: Arch runs a stock LazyVim (`~/.config/nvim` is still a real dir — untouched
      starter, empty `extras`, unmodified `example.lua`); old EndeavourOS ran NvChad.
- [ ] Once decided, add an `nvim/` stow package (`nvim/.config/nvim/…`); track `lazy-lock.json` and
      `lua/plugins/` — that's config, not plugin code. lazy.nvim installs plugins to
      `~/.local/share/nvim/lazy`, outside the package, so there is nothing to ignore.

## Hyprland desktop rice
- [x] Track the core rice as stow packages — hypr, waybar, walker, ghostty, cava, fastfetch, btop are
      all packages and in `Makefile` `PACKAGES` (`575be02`).
- [ ] Decide whether to track the last two: `~/.config/nwg-look/config` (282 B, GTK theme) and
      `~/.config/wireplumber/wireplumber.conf.d/` (drop-ins). Both still real dirs.
- [ ] Machine-specific lines ship as-is in `hypr/.config/hypr/hyprland.lua`: monitors hardcoded to
      `DP-3`/`DP-2` (lines 10-11) and an Nvidia env block (lines 24-26). Stowing on another machine
      misconfigures it; a generic fallback sits commented out at line 15.

## Claude Code (~/.claude)
- [x] `settings.json` untracked from the `claude` package (Claude Code rewrites it live) — canonical
      copy kept in `tools/canonical/.claude/settings.json` (`afa7977`, relocated in `9d0a014`).
- [x] Curate the canonical copy down to real prefs (`9d0a014`, 203 → 51 lines).
- [ ] Bootstrap: apply `tools/canonical/.claude/settings.json` on a fresh machine by **merging** into
      `~/.claude/settings.json` (`jq -s '.[0] * .[1]'`), never overwriting — Claude Code owns that file
      at runtime. Keep the canonical copy free of `//` comments so `jq` can parse it. Note the
      `statusLine` depends on `~/.claude/ccline/ccline`, which bootstrap must install.
