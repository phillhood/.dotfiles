# Stow Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the dotfiles repo from chezmoi to GNU Stow — 10 stow packages, no provisioning, and take over the live machine's real config files as symlinks.

**Architecture:** Each top-level dir becomes a stow package mirroring `$HOME`. `git mv` the `dot_*`/`private_*`/`executable_*` sources into package paths; delete all chezmoi machinery; add a `Makefile` wrapping stow; rewrite docs; then `stow --adopt` on the live machine to replace chezmoi-written real files with symlinks.

**Tech Stack:** GNU Stow, GNU Make, git, zsh, Arch Linux.

## Global Constraints

- Branch: `stow` (already created, off `chezmoi` HEAD). All commits land here.
- Commit messages: simple, lowercase, no `Co-Authored-By` / "Generated with Claude Code" trailer (per user global CLAUDE.md).
- The repo does **symlink management only** — no package installation, no templating, no provisioning scripts.
- 10 packages exactly: `zsh starship git tmux ssh claude bat htop k9s helm`.
- No deployed file uses templating — every source is byte-identical to its live target, which the handoff (Task 5) relies on.
- `chezmoi source-path` = `/home/phill/.dotfiles`; all live targets are currently **real files**, not symlinks.
- Preserve git history via `git mv` (never delete-and-recreate a moved file).

---

### Task 1: Reorganize sources into 10 stow packages

**Files:**
- Move (git mv): all 22 `dot_*` / `private_*` / `executable_*` source files → package paths (table below).
- Delete: emptied `dot_config/`, `dot_claude/`, `private_dot_ssh/` directories.

**Interfaces:**
- Produces: the package tree `zsh/ starship/ git/ tmux/ ssh/ claude/ bat/ htop/ k9s/ helm/`, each mirroring `$HOME`, consumed by the `Makefile` (Task 3) and handoff (Task 5).

Rename map:

| Current source                               | New path                                         |
| -------------------------------------------- | ------------------------------------------------ |
| `dot_zshrc`                                  | `zsh/.zshrc`                                      |
| `dot_hushlogin`                              | `zsh/.hushlogin`                                  |
| `dot_config/utils/general`                   | `zsh/.config/utils/general`                       |
| `dot_config/utils/docker`                    | `zsh/.config/utils/docker`                        |
| `dot_config/utils/k8s`                       | `zsh/.config/utils/k8s`                           |
| `dot_config/utils/distro/arch`               | `zsh/.config/utils/distro/arch`                   |
| `dot_config/starship.toml`                   | `starship/.config/starship.toml`                  |
| `dot_gitconfig`                              | `git/.gitconfig`                                  |
| `dot_gitconfig-shy`                          | `git/.gitconfig-shy`                              |
| `dot_gitignore_global`                       | `git/.gitignore_global`                           |
| `dot_tmux.conf`                              | `tmux/.tmux.conf`                                 |
| `private_dot_ssh/private_config`             | `ssh/.ssh/config`                                 |
| `dot_claude/settings.json`                   | `claude/.claude/settings.json`                    |
| `dot_claude/CLAUDE.md`                       | `claude/.claude/CLAUDE.md`                        |
| `dot_claude/hooks/executable_uv-python.sh`   | `claude/.claude/hooks/uv-python.sh`               |
| `dot_claude/plugins/known_marketplaces.json` | `claude/.claude/plugins/known_marketplaces.json`  |
| `dot_config/bat/config`                      | `bat/.config/bat/config`                          |
| `dot_config/htop/private_htoprc`             | `htop/.config/htop/htoprc`                        |
| `dot_config/k9s/config.yaml`                 | `k9s/.config/k9s/config.yaml`                     |
| `dot_config/k9s/aliases.yaml`                | `k9s/.config/k9s/aliases.yaml`                    |
| `dot_config/k9s/skins/transparent.yaml`      | `k9s/.config/k9s/skins/transparent.yaml`          |
| `dot_config/helm/repositories.yaml`          | `helm/.config/helm/repositories.yaml`             |

- [ ] **Step 1: Confirm clean starting state**

Run:
```bash
cd ~/.dotfiles && git branch --show-current && git status --porcelain
```
Expected: prints `stow` and no output (clean tree). If not on `stow` or not clean, stop and resolve first.

- [ ] **Step 2: Create package directory skeleton**

```bash
cd ~/.dotfiles
mkdir -p zsh/.config/utils/distro starship/.config git tmux ssh/.ssh \
  claude/.claude/hooks claude/.claude/plugins bat/.config/bat \
  htop/.config/htop k9s/.config/k9s/skins helm/.config/helm
```

- [ ] **Step 3: git mv all sources into packages**

```bash
cd ~/.dotfiles
git mv dot_zshrc zsh/.zshrc
git mv dot_hushlogin zsh/.hushlogin
git mv dot_config/utils/general zsh/.config/utils/general
git mv dot_config/utils/docker zsh/.config/utils/docker
git mv dot_config/utils/k8s zsh/.config/utils/k8s
git mv dot_config/utils/distro/arch zsh/.config/utils/distro/arch
git mv dot_config/starship.toml starship/.config/starship.toml
git mv dot_gitconfig git/.gitconfig
git mv dot_gitconfig-shy git/.gitconfig-shy
git mv dot_gitignore_global git/.gitignore_global
git mv dot_tmux.conf tmux/.tmux.conf
git mv private_dot_ssh/private_config ssh/.ssh/config
git mv dot_claude/settings.json claude/.claude/settings.json
git mv dot_claude/CLAUDE.md claude/.claude/CLAUDE.md
git mv dot_claude/hooks/executable_uv-python.sh claude/.claude/hooks/uv-python.sh
git mv dot_claude/plugins/known_marketplaces.json claude/.claude/plugins/known_marketplaces.json
git mv dot_config/bat/config bat/.config/bat/config
git mv dot_config/htop/private_htoprc htop/.config/htop/htoprc
git mv dot_config/k9s/config.yaml k9s/.config/k9s/config.yaml
git mv dot_config/k9s/aliases.yaml k9s/.config/k9s/aliases.yaml
git mv dot_config/k9s/skins/transparent.yaml k9s/.config/k9s/skins/transparent.yaml
git mv dot_config/helm/repositories.yaml helm/.config/helm/repositories.yaml
```

- [ ] **Step 4: Ensure the Claude hook keeps its executable bit**

chezmoi stored the source without the `+x` bit (it applied it via the `executable_` prefix). Stow symlinks inherit the repo file's mode, so set it now and stage the mode change:
```bash
cd ~/.dotfiles
chmod +x claude/.claude/hooks/uv-python.sh
git add --chmod=+x claude/.claude/hooks/uv-python.sh
```

- [ ] **Step 5: Remove emptied source directories**

```bash
cd ~/.dotfiles
find dot_config dot_claude private_dot_ssh -type f 2>/dev/null   # expect NO output
rm -rf dot_config dot_claude private_dot_ssh
```
Expected: the `find` prints nothing (all files moved), then the empty dirs are removed.

- [ ] **Step 6: Verify the new structure**

Run:
```bash
cd ~/.dotfiles
echo "file count:"; find zsh starship git tmux ssh claude bat htop k9s helm -type f | wc -l
echo "stray dot_ sources:"; ls -d dot_* private_dot_* 2>/dev/null || echo "none"
echo "hook executable?"; test -x claude/.claude/hooks/uv-python.sh && echo yes || echo NO
```
Expected: `file count: 22`, `stray dot_ sources: none`, `hook executable? yes`.

- [ ] **Step 7: Commit**

```bash
cd ~/.dotfiles
git add -A
git commit -m "reorganize sources into stow packages"
```

---

### Task 2: Remove chezmoi machinery, rename tooling dir, rewrite .gitignore

**Files:**
- Delete: `.chezmoi.toml.tmpl`, `.chezmoidata/`, `.chezmoiscripts/`, `.chezmoiignore`, `_setup/`.
- Move: `_utils/` → `tools/`.
- Modify: `.gitignore` (full rewrite).

**Interfaces:**
- Produces: a repo containing only stow packages + meta files. Provisioning knowledge is preserved in git history on the `chezmoi` branch (not copied here).

- [ ] **Step 1: Delete chezmoi machinery and stale bootstrap**

```bash
cd ~/.dotfiles
git rm -r .chezmoi.toml.tmpl .chezmoidata .chezmoiscripts .chezmoiignore _setup
```

- [ ] **Step 2: Rename the tooling directory**

```bash
cd ~/.dotfiles
git mv _utils tools
```

- [ ] **Step 3: Rewrite .gitignore**

Replace the entire contents of `~/.dotfiles/.gitignore` with:
```gitignore
# Claude Code local (per-user) settings
.claude/settings.local.json

# superpowers SDD scratch
.superpowers/
```

- [ ] **Step 4: Verify removal and rename**

Run:
```bash
cd ~/.dotfiles
echo "chezmoi remnants:"; ls -d .chezmoi* _setup 2>/dev/null || echo "none"
echo "tools dir:"; test -d tools && echo present || echo MISSING
echo "top-level dirs:"; ls -d */ | tr -d /
```
Expected: `chezmoi remnants: none`, `tools dir: present`, and top-level dirs = the 10 packages plus `docs` and `tools`.

- [ ] **Step 5: Commit**

```bash
cd ~/.dotfiles
git add -A
git commit -m "remove chezmoi machinery; rename _utils to tools"
```

---

### Task 3: Add the stow Makefile

**Files:**
- Create: `Makefile`.

**Interfaces:**
- Consumes: the 10 package dirs from Task 1.
- Produces: `make install|stow|unstow|restow|adopt` targets. Task 5 uses `make adopt`.

- [ ] **Step 1: Create the Makefile**

Create `~/.dotfiles/Makefile` with exactly:
```makefile
# Stow-based dotfiles. Each top-level dir is a stow package mirroring $HOME.
PACKAGES := zsh starship git tmux ssh claude bat htop k9s helm
STOW := stow --verbose --target=$(HOME)

.PHONY: help install stow unstow restow adopt

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-8s\033[0m %s\n", $$1, $$2}'

install: stow ## Symlink all packages into $HOME (does NOT install software)

stow: ## Stow (symlink) all packages
	$(STOW) --restow $(PACKAGES)

unstow: ## Remove all symlinks
	$(STOW) --delete $(PACKAGES)

restow: ## Re-link all packages (after adding/renaming files)
	$(STOW) --restow $(PACKAGES)

adopt: ## One-time takeover of existing real files (chezmoi handoff)
	$(STOW) --adopt $(PACKAGES)
```
Note: recipe lines must be indented with a TAB, not spaces.

- [ ] **Step 2: Verify the Makefile parses and targets resolve**

Run:
```bash
cd ~/.dotfiles
make help
make -n stow
```
Expected: `make help` lists the 6 targets with descriptions; `make -n stow` prints (without executing) the line `stow --verbose --target=/home/phill --restow zsh starship git tmux ssh claude bat htop k9s helm`.

- [ ] **Step 3: Commit**

```bash
cd ~/.dotfiles
git add Makefile
git commit -m "add stow Makefile"
```

---

### Task 4: Rewrite docs (README, CLAUDE.md, TODO)

**Files:**
- Modify: `README.md`, `CLAUDE.md`, `TODO.md` (full rewrites).

**Interfaces:**
- Produces: docs describing the stow model and pointing at the future `bootstrap` repo. No functional dependency.

- [ ] **Step 1: Rewrite README.md**

Replace the entire contents of `~/.dotfiles/README.md` with:
````markdown
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
| `claude`   | `~/.claude/{settings.json,CLAUDE.md,hooks/,plugins/}`     |
| `bat`      | `~/.config/bat/config`                                    |
| `htop`     | `~/.config/htop/htoprc`                                   |
| `k9s`      | `~/.config/k9s/*`                                         |
| `helm`     | `~/.config/helm/repositories.yaml`                        |

Repo-only (not stowed): `tools/` (terminal colour-scheme tooling), `docs/`.

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
````

- [ ] **Step 2: Rewrite CLAUDE.md**

Replace the entire contents of `~/.dotfiles/CLAUDE.md` with:
````markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for Arch Linux (Hyprland/Wayland), managed with [GNU Stow](https://www.gnu.org/software/stow/).
This is the `stow` branch — a migration off the earlier chezmoi setup. The dotfiles repo does **only**
symlink management; machine provisioning (package installs, post-install steps) lives in a separate
`bootstrap` repo.

## The model: stow packages

Each top-level directory (`zsh/`, `git/`, `tmux/`, …) is a **stow package** whose contents mirror the
layout under `$HOME`. `stow <package>` creates symlinks: `zsh/.zshrc` → `~/.zshrc`,
`starship/.config/starship.toml` → `~/.config/starship.toml`, and so on.

**Deployed files are symlinks back into this repo.** Edit `zsh/.zshrc` here and `~/.zshrc` reflects it
immediately — there is no apply/render step. They are the same inode; never expect the repo and the
target to diverge.

When you **add a new file** to a package, re-link with `make restow` (stow only links files that exist
at stow time).

## Commands

```sh
make install     # symlink all packages into $HOME (alias: make stow)
make unstow      # remove all symlinks
make restow      # re-link after adding/renaming files
make adopt       # one-time: take over pre-existing real files as symlinks
stow git tmux    # stow individual packages
stow -D k9s      # unstow one package
stow -n zsh      # dry-run
```

`make install` does not install software — package provisioning is the `bootstrap` repo's job.

## Layout

- **`zsh/`** — `.zshrc` (zinit, starship, atuin, fnm, uv, zoxide/fzf), `.hushlogin`, and
  `.config/utils/*` (shell function/alias files sourced by `.zshrc`: `general`, `docker`, `k8s`, and
  `distro/arch`). `.zshrc` sources every file in `~/.config/utils/*`, then a distro-specific
  `~/.config/utils/distro/<os-release $ID>`. Add a helper by dropping a file in `zsh/.config/utils/`
  and running `make restow`.
- **`git/`** — `.gitconfig` (with a per-directory `includeIf` → `.gitconfig-shy` for the hobby
  identity) and `.gitignore_global`. Multi-account SSH is handled by `core.sshCommand`, not host
  aliases.
- **`ssh/`** — only `.ssh/config`. Private keys are never tracked (this repo is public).
- **`claude/`** — tracked pieces of `~/.claude`: `settings.json`, `CLAUDE.md`, `hooks/uv-python.sh`
  (rewrites python/pip → uv), `plugins/known_marketplaces.json`. Runtime state, caches, and
  credentials under `~/.claude` are NOT tracked and belong to no package.
- **`starship/`, `tmux/`, `bat/`, `htop/`, `k9s/`, `helm/`** — single-app config packages.
- **`tools/`** — terminal colour-scheme conversion tooling (Material Monokai across
  kitty/iTerm2/fbterm/nvim/Windows Terminal). Repo-only, not stowed.

## Provisioning

Package installs and post-install steps (set default shell, tmux tpm, rustup, fnm, docker) are **not**
in this repo. They live in `phillhood/bootstrap`, which installs packages then clones + `make install`s
these dotfiles. One-way dependency: bootstrap → dotfiles.
````

- [ ] **Step 3: Rewrite TODO.md**

Replace the entire contents of `~/.dotfiles/TODO.md` with:
```markdown
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
```

- [ ] **Step 4: Verify no chezmoi commands remain in docs**

Run:
```bash
cd ~/.dotfiles
grep -rn 'chezmoi apply\|chezmoi add\|chezmoi diff\|chezmoi edit\|dot_' README.md CLAUDE.md && echo "FOUND stale refs" || echo "clean"
```
Expected: `clean` (historical mentions of the word "chezmoi" as context are fine; there must be no live `chezmoi apply/add/diff/edit` instructions or `dot_` source references).

- [ ] **Step 5: Commit**

```bash
cd ~/.dotfiles
git add README.md CLAUDE.md TODO.md
git commit -m "rewrite docs for stow workflow"
```

---

### Task 5: Live-machine handoff (chezmoi → stow symlinks)

**Files:**
- No repo files change (unless live drift is found). This task converts the running `$HOME` from chezmoi-written real files to stow symlinks.

**Interfaces:**
- Consumes: package tree (Task 1) and `make adopt` (Task 3).
- Produces: a live machine whose config targets are symlinks into `~/.dotfiles`.

- [ ] **Step 1: Back up current targets**

```bash
tar czf ~/dotfiles-pre-stow-backup.tar.gz -C "$HOME" \
  .zshrc .hushlogin .gitconfig .gitconfig-shy .gitignore_global .tmux.conf \
  .ssh/config .config/starship.toml .config/bat/config .config/htop/htoprc \
  .config/k9s .config/helm .config/utils \
  .claude/settings.json .claude/CLAUDE.md .claude/hooks/uv-python.sh \
  .claude/plugins/known_marketplaces.json 2>/dev/null
ls -lh ~/dotfiles-pre-stow-backup.tar.gz
```
Expected: the tarball exists and is non-empty. (Belt-and-suspenders — the content is also in git.)

- [ ] **Step 2: Dry-run the adopt to preview**

```bash
cd ~/.dotfiles
stow -n --verbose=2 --target="$HOME" --adopt zsh starship git tmux ssh claude bat htop k9s helm 2>&1 | head -40
```
Expected: stow prints planned LINK/MV actions and no fatal conflict errors. (With `--adopt`, existing real files are planned for takeover rather than reported as conflicts.)

- [ ] **Step 3: Perform the takeover**

```bash
cd ~/.dotfiles && make adopt
```
Expected: stow reports it linked all packages (moving each real target into the repo and replacing it with a symlink).

- [ ] **Step 4: Verify the repo is unchanged (live == source invariant)**

```bash
cd ~/.dotfiles && git status --porcelain
```
Expected: **no output.** Because every live target was byte-identical to its committed source, `--adopt` produced no diff.
If there IS output, it is genuine live drift (a file edited directly in `$HOME`). Review each with `git diff <file>`; keep the committed version with `git checkout -- <file>`, or `git commit` the drift if it is wanted. Do not proceed until `git status` is intentional.

- [ ] **Step 5: Verify symlinks resolve and the shell works**

```bash
echo "zshrc:";  ls -l "$HOME/.zshrc"    | sed 's#.* -> #-> #'
echo "gitcfg:"; ls -l "$HOME/.gitconfig"| sed 's#.* -> #-> #'
echo "hook x?:"; test -x "$HOME/.claude/hooks/uv-python.sh" && echo yes || echo NO
echo "shell loads:"; zsh -ic 'command -v starship >/dev/null && echo starship-ok' 2>/dev/null
echo "personal id:"; git -C "$HOME" config user.email
[ -d "$HOME/Dev/shychedelic" ] && echo "hobby id:" && git -C "$HOME/Dev/shychedelic" config user.email
```
Expected: both `ls -l` lines show `-> …/.dotfiles/…`; `hook x?: yes`; `shell loads: starship-ok`; `personal id: phill@phillhood.ca`; and if `~/Dev/shychedelic` exists, `hobby id: shy@shychedelic.com`.

- [ ] **Step 6: Test idempotency (unstow → restow)**

```bash
cd ~/.dotfiles
make unstow >/dev/null 2>&1
ls -l "$HOME/.zshrc" 2>&1   # expect: No such file (symlink removed)
make restow >/dev/null 2>&1
ls -l "$HOME/.zshrc" | sed 's#.* -> #-> #'   # expect: symlink restored into ~/.dotfiles/zsh
```
Expected: after `unstow` the symlink is gone; after `restow` it is back, pointing into the repo.

- [ ] **Step 7 (optional): Retire chezmoi**

Only after the above all pass:
```bash
command -v chezmoi && sudo pacman -R --noconfirm chezmoi
rm -rf "$HOME/.local/share/chezmoi"   # stale default source dir (unused; real source was ~/.dotfiles)
```
Expected: chezmoi removed; stale source dir gone. (Skip if you'd rather keep chezmoi installed for now.)

- [ ] **Step 8: Final state check (no commit needed unless drift was committed in Step 4)**

```bash
cd ~/.dotfiles && git log --oneline -6 && git status
```
Expected: the four migration commits present (`reorganize…`, `remove chezmoi…`, `add stow Makefile`, `rewrite docs…`), working tree clean.

---

## Self-Review

**Spec coverage** (checked against `docs/superpowers/specs/2026-07-05-stow-migration-design.md`):
- 10-package layout + full rename map → Task 1. ✓
- Strip chezmoi machinery; preserve provisioning in git history → Task 2. ✓
- `private_`/`executable_` attribute handling → Task 1 Step 4 (hook +x); `private_` dropped implicitly by rename (repo files stay 0644). ✓
- `_utils` → `tools` rename → Task 2. ✓
- `.gitignore` rewrite → Task 2. ✓
- Makefile targets (install/stow/unstow/restow/adopt) → Task 3. ✓
- One-time `make adopt` handoff, backup, `git status` verification, rollback → Task 5. ✓
- Docs rewrite (README/CLAUDE.md/TODO) → Task 4. ✓
- `~/.config` folding note, standalone-repo property → covered by design; behaviourally verified in Task 5 Steps 5–6. ✓
- Bootstrap repo deferred → referenced in TODO (Task 4) and spec; not built. ✓

**Placeholder scan:** none — every step has concrete commands/content and expected output.

**Type consistency:** package list `zsh starship git tmux ssh claude bat htop k9s helm` is identical across Makefile (Task 3), dry-run (Task 5 Step 2), and verification (Task 1 Step 6). File paths in the Task 1 table match the Task 4 README/CLAUDE.md layout tables.
