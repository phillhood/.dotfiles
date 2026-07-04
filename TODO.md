# Dotfiles migration TODO

Follow-ups after the EndeavourOS → Arch chezmoi migration.

## Neovim
- [ ] Decide on nvim config: current Arch system runs **LazyVim**; old EndeavourOS ran **NvChad**.
- [ ] Once decided, `chezmoi add ~/.config/nvim` (LazyVim) OR restore old NvChad from
      `nvme2n1p2:/home/phill/.dotfiles/.config/nvim`.
- [ ] Add `lazy-lock.json` / `lazy-vim.json` to tracking; ignore the plugins/ dir.

## Hyprland desktop rice (currently untracked)
- [ ] The live desktop uses `~/.config/hypr/hyprland.lua` (not hyprland.conf) — stale
      bootstrap placeholder was removed from chezmoi.
- [ ] Decide what to track: hypr, waybar, walker, ghostty, nwg-look, wireplumber, cava, fastfetch, btop.
- [ ] `chezmoi add` the ones worth version-controlling (watch for machine-specific monitor/env lines
      — consider chezmoi templates for those).

## Claude Code (~/.claude)
Done (2026-07-04):
- [x] `hooks/uv-python.sh` restored + wired into settings.json (rewrites python/pip → uv). Tracked in chezmoi.
- [x] Statusline: `~/.claude/ccline/ccline` wired into settings.json. ccline is a separately-installed
      binary (not tracked in chezmoi) — settings.json only references it.
- [x] settings.json: restored `effortLevel: xhigh` + `alwaysThinkingEnabled: true` (kept model=opus, theme=dark-ansi).
- [x] Strategy: settings.json IS tracked in chezmoi (`dot_claude/settings.json`), alongside the hook and
      `plugins/known_marketplaces.json`. Backup at `~/.claude/settings.json.bak-premigrate`.
- Dropped: old `settings.local.json` (stale X11/KDE/kitty/WoW perms).

Remaining:
- [ ] ccline: statusline binary + `~/.claude/ccline/{config.toml,models.toml,themes/}` are installed
      locally but not tracked. On a fresh machine settings.json's statusline breaks until ccline is
      installed — decide whether to track its config and/or script its install in `_setup/`.
- [ ] Plugins: old config enabled 6 plugins (fullstack-dev-skills, claude-code-setup, frontend-design,
      superpowers, code-simplifier, skill-creator) — none installed on new system. Reinstall via `/plugin`
      if wanted, then re-add `enabledPlugins` to settings.json.
- [ ] Optional: global `~/.claude/.claudeignore` (.venv/__pycache__/*.pyc/node_modules) — skipped (marginal;
      .claudeignore is normally per-project). Add if desired.

## Terminal / tmux
- [ ] Current `~/.tmux.conf` is the clean bootstrap (kept). Old had tmux-powerline
      (material-monokai theme) under `.config/tmux/` + `.config/tmux-powerline/` — restore only if wanted.
- [ ] Old kitty config dropped (new terminal is ghostty). Track ghostty config if desired.

## Editor / misc from old repo (not yet migrated — decide per item)
- [ ] `.config/Code/keybindings.json` (VS Code keybindings — verify correct path Code/User/).
- [ ] `.config/systemd/user/code-tunnel.service` (VS Code remote tunnel — machine/service state).
- [ ] `.config/envman/` (webinstall envman PATH manager — likely superseded by explicit PATH in zshrc).

## K8s tooling (configs migrated, tools not installed)
- [ ] Install when needed: kubectl, kubectx/kubens, helm, k9s, kubeseal, argocd.
- [ ] k9s/helm configs are already in place; zshrc aliases (k/kctx/kns) + utils/k8s ready.

## Bootstrap scripts (`_setup/`)
- [ ] `_setup/setup` is the old distro bootstrap (still stow/nvm/oh-my-posh oriented).
- [ ] Update for Arch + chezmoi + starship/fnm before relying on it for a fresh machine.
