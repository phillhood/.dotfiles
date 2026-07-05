# Design: chezmoi → GNU Stow migration (dotfiles repo)

**Date:** 2026-07-05
**Branch:** `stow` (off current `chezmoi` HEAD)
**Scope of this spec:** the dotfiles repo only. The provisioning/bootstrap tooling
becomes a **separate `bootstrap` repo** built in a later session (see
[Follow-up](#follow-up-bootstrap-repo-separate-session)).

## Goal

Replace chezmoi with a clean, idiomatic GNU Stow setup, following the philosophy in
[this gist](https://gist.github.com/simoninglis/98d47f3107db65d0a33aa2ecc72bba85):
one top-level folder per "package", each mirroring the `$HOME` layout, symlinked into
place with `stow`. The dotfiles repo becomes **pure symlink management** — no package
installation, no templating, no imperative provisioning.

### Why this is clean (findings from the current repo)

- **No deployed file uses chezmoi templating.** Every `dot_*` source is static and just
  needs renaming. (The only `{{ }}` in a deployed file is a `docker stats --format`
  string, not a template.)
- **Multi-account git/ssh is pure git config** (`includeIf` + `core.sshCommand`) — it
  works identically as plain static files under stow.
- **The `private_` attribute is moot under stow** — a symlink inherits the repo file's
  mode, and ssh/htop don't care about config-file mode as long as it isn't
  group/world-writable. Repo files stay `0644`.
- **The only chezmoi-specific machinery is provisioning** (`.chezmoidata`,
  `.chezmoiscripts`) — which leaves this repo entirely for the `bootstrap` repo.

## Non-goals

- Building the `bootstrap` repo (packages, install.sh, post-install). Separate session.
- Installing software. The dotfiles repo only symlinks configs.
- Migrating still-untracked items (nvim, Hyprland rice) — those remain open TODOs.
- Merging `stow` → `main`. Decided later, once the setup is proven.

## Architecture: one-way dependency

```
phillhood/dotfiles   (this repo — pure stow, standalone)
    stow packages + Makefile + README
    `make install` works on any already-provisioned machine.
    Depends on nothing.

phillhood/bootstrap  (later — provisioner, sits on top)
    installs packages, then clones + `make install` dotfiles.
    Depends on dotfiles (by URL). dotfiles does NOT depend on it.
```

No git submodules, no mutual references. The dotfiles repo never knows bootstrap exists,
except for one pointer line in its README.

## Target repo layout

```
~/.dotfiles/
├── zsh/        .zshrc, .hushlogin, .config/utils/{general,docker,k8s,distro/arch}
├── starship/   .config/starship.toml
├── git/        .gitconfig, .gitconfig-shy, .gitignore_global
├── tmux/       .tmux.conf
├── ssh/        .ssh/config
├── claude/     .claude/{settings.json, CLAUDE.md, hooks/uv-python.sh, plugins/known_marketplaces.json}
├── bat/        .config/bat/config
├── htop/       .config/htop/htoprc
├── k9s/        .config/k9s/{config.yaml, aliases.yaml, skins/transparent.yaml}
├── helm/       .config/helm/repositories.yaml
│
├── Makefile          # stow wrapper (see Makefile section)
├── README.md         # rewritten for stow
├── CLAUDE.md         # rewritten (drop chezmoi source-mapping model)
├── docs/             # superpowers specs/plans (kept, incl. this file)
├── tools/            # terminal colour tooling (renamed from _utils/)
└── .gitignore        # rewritten (drop chezmoi guards)
```

**10 stow packages**, each independently `stow`-able. Shell-support files (`utils/*`,
`.hushlogin`) live in the `zsh` package since they're the shell's own sourced config, not
standalone apps. Meta files (Makefile, README, etc.) sit at repo root and are **never
passed to stow** — the Makefile enumerates packages explicitly, so there is no `stow *`
glob risk and no `.stow-local-ignore` is needed.

## Source → target rename map (git mv)

| Current source (chezmoi)                              | New path (stow package)                        |
| ----------------------------------------------------- | ---------------------------------------------- |
| `dot_zshrc`                                           | `zsh/.zshrc`                                    |
| `dot_hushlogin`                                       | `zsh/.hushlogin`                                |
| `dot_config/utils/general`                            | `zsh/.config/utils/general`                     |
| `dot_config/utils/docker`                             | `zsh/.config/utils/docker`                      |
| `dot_config/utils/k8s`                                | `zsh/.config/utils/k8s`                         |
| `dot_config/utils/distro/arch`                        | `zsh/.config/utils/distro/arch`                 |
| `dot_config/starship.toml`                            | `starship/.config/starship.toml`                |
| `dot_gitconfig`                                       | `git/.gitconfig`                                |
| `dot_gitconfig-shy`                                   | `git/.gitconfig-shy`                            |
| `dot_gitignore_global`                                | `git/.gitignore_global`                         |
| `dot_tmux.conf`                                       | `tmux/.tmux.conf`                               |
| `private_dot_ssh/private_config`                      | `ssh/.ssh/config`                               |
| `dot_claude/settings.json`                            | `claude/.claude/settings.json`                  |
| `dot_claude/CLAUDE.md`                                | `claude/.claude/CLAUDE.md`                      |
| `dot_claude/hooks/executable_uv-python.sh`            | `claude/.claude/hooks/uv-python.sh` (keep +x)   |
| `dot_claude/plugins/known_marketplaces.json`          | `claude/.claude/plugins/known_marketplaces.json`|
| `dot_config/bat/config`                               | `bat/.config/bat/config`                        |
| `dot_config/htop/private_htoprc`                      | `htop/.config/htop/htoprc`                      |
| `dot_config/k9s/config.yaml`                          | `k9s/.config/k9s/config.yaml`                   |
| `dot_config/k9s/aliases.yaml`                         | `k9s/.config/k9s/aliases.yaml`                  |
| `dot_config/k9s/skins/transparent.yaml`               | `k9s/.config/k9s/skins/transparent.yaml`        |
| `dot_config/helm/repositories.yaml`                   | `helm/.config/helm/repositories.yaml`           |

Attribute handling:
- Drop the `dot_` prefix → literal `.` filenames.
- Drop `private_` → repo files stay `0644` (not group/world-writable). ssh/htop unaffected.
- Drop `executable_` but **preserve the `+x` bit** on `uv-python.sh` (git tracks it).

Use `git mv` so history follows each file.

## Chezmoi machinery to remove

Delete from the repo (all recoverable from git history on the `chezmoi` branch):

- `.chezmoi.toml.tmpl`
- `.chezmoidata/packages.yaml`
- `.chezmoiscripts/` (all 5 scripts)
- `.chezmoiignore`
- `_setup/` (bootstrap, smoke-test.sh, `_kek/` easter egg)

**Preserve for the `bootstrap` repo (session 2):** the provisioning knowledge in
`.chezmoidata/packages.yaml`, `.chezmoiscripts/*`, and `_setup/*` is not lost — it stays
in git history on the `chezmoi` branch and is retrievable with e.g.
`git show chezmoi:.chezmoiscripts/run_once_after_50-rust-node.sh`. The bootstrap spec will
port it. No separate copy is kept in the dotfiles repo.

Rename `_utils/` → `tools/` (terminal colour-scheme conversion tooling; repo-only, not a
stow package — it generates terminal configs).

## Makefile

```make
PACKAGES := zsh starship git tmux ssh claude bat htop k9s helm

.PHONY: help install stow unstow restow adopt

help:            ## list targets
	@grep -E '^[a-z]+:.*##' $(MAKEFILE_LIST) | sed 's/:.*##/ —/'

install: stow    ## symlink all packages into $HOME (does NOT install software)

stow:            ## stow all packages
	stow --verbose --target=$$HOME --restow $(PACKAGES)

unstow:          ## remove all symlinks
	stow --verbose --target=$$HOME --delete $(PACKAGES)

restow:          ## re-link after adding/renaming files
	stow --verbose --target=$$HOME --restow $(PACKAGES)

adopt:           ## one-time takeover of existing real files (chezmoi handoff)
	stow --verbose --target=$$HOME --adopt $(PACKAGES)
```

- `install`/`stow`/`restow` all use `--restow` (idempotent: safe to re-run; cleans stale
  links). `install` explicitly does **not** install software — that's the bootstrap repo's
  job; the README documents the manual package step.
- `adopt` is the one-time migration helper (see next section). Not part of normal use.
- Per-package operations are just raw stow: `stow git tmux`, `stow -D k9s`.

### `~/.config` folding note

Multiple packages (`starship`, `bat`, `htop`, `k9s`, `helm`, `zsh`) contain `.config/…`.
Because `~/.config` already exists on the live machine, stow descends into it and creates
per-file/per-subdir symlinks rather than folding the whole directory — the desired
behaviour. Default folding is fine; no `--no-folding` needed. On a fresh machine where a
subdir like `~/.config/k9s` doesn't exist yet, stow may fold that single subdir to one
symlink (harmless — one package owns it).

## One-time live-machine handoff (chezmoi → stow)

Current state (verified): `chezmoi source-path` = `~/.dotfiles`; all targets
(`~/.zshrc`, `~/.gitconfig`, …) are **real files** chezmoi wrote, so plain `stow` would
conflict. `chezmoi diff` currently errors on the `installK8s` template key, so we do NOT
rely on it. Since no deployed file uses templating, each target is byte-identical to its
source — which the handoff verifies via git.

Handoff steps (run once, on this machine, after the reorg is committed on `stow`):

1. **Back up** current targets defensively:
   `cp -a ~/.zshrc ~/.zshrc.pre-stow` … (or a tarball of the target set). The files are
   also in git, so this is belt-and-suspenders.
2. **`make adopt`** — `stow --adopt` replaces each real file with a symlink and moves the
   live content into the repo package path.
3. **Verify `git status` is clean.** Because live == committed source, adopt produces no
   diff. Any diff it *does* show is genuine live drift (something edited directly in
   `$HOME`, bypassing chezmoi) — review it, then `git checkout -- <file>` to keep the
   committed version, or commit the drift if it's wanted.
4. **Spot-check symlinks resolve:** `ls -l ~/.zshrc` → points into `~/.dotfiles/zsh/`;
   open a new shell; `git config user.email` in `~/Dev/shychedelic` → hobby identity.
5. **Optional cleanup:** `sudo pacman -R chezmoi`; remove the stale
   `~/.local/share/chezmoi` directory (chezmoi's default source dir — unused, since the
   real source is `~/.dotfiles`).

Rollback if needed: `make unstow` then restore from the `.pre-stow` backups (or
`git checkout` the files and let chezmoi re-apply before uninstalling it).

## `.gitignore` rewrite

Remove chezmoi-era lines (`_setup/markers/`, `_setup/logs/`, `**/logs/`, `**/markers/`,
`.chezmoistate.boltdb`). Keep:

```gitignore
# Claude Code local (per-user) settings
.claude/settings.local.json

# superpowers SDD scratch
.superpowers/
```

## Docs rewrite

- **README.md** — stow workflow: prerequisites (`stow` installed), `make install` /
  per-package `stow <pkg>`, `make unstow`/`restow`, the one-time `make adopt` note, and a
  single pointer: "Fresh machine? See `phillhood/bootstrap`."
- **CLAUDE.md** — replace the "source-name mapping" section with the stow model: edit files
  in-place inside package dirs (`zsh/.zshrc`, not `~/.zshrc`); `make restow` after adding a
  new file to a package; targets are symlinks so edits are live immediately (no `apply`
  step). Note the sibling `bootstrap` repo owns provisioning. Update the "Commands" and
  "Layout" sections accordingly. Keep the git-commit style rules.
- **TODO.md** — drop completed chezmoi-migration items; keep genuinely-open ones (nvim
  LazyVim-vs-NvChad decision, Hyprland rice tracking, ccline statusline install). Reframe
  the "Bootstrap scripts" section to point at the future `bootstrap` repo.

## Testing / verification

No build/test/lint exists. Verification is behavioural:

1. `make stow` on the migrated repo produces the expected symlinks (spot-check the table
   above; `stow -n` dry-run shows no conflicts).
2. A fresh login shell sources cleanly (zsh + utils + starship + atuin + fnm all load).
3. `git config user.email` resolves to the correct identity in `~/Dev/phillhood` (personal)
   vs `~/Dev/shychedelic` (hobby).
4. `make unstow` cleanly removes all symlinks; `make restow` re-creates them (idempotency).
5. `git status` clean after `make adopt` (the live==source invariant).

## Follow-up: bootstrap repo (separate session)

Captured here so the next session has the contract. **Not built now.**

- New repo `phillhood/bootstrap`. Contents:
  `install.sh` (prereqs → yay → packages → clone+`make install` dotfiles → post-install),
  `packages/{core,cli,docker,k8s}.txt` (from `.chezmoidata/packages.yaml`),
  `post-install.sh` (chsh zsh, tpm clone, `rustup default stable`, `fnm install --lts`,
  docker enable + usermod — ported from `.chezmoiscripts/*`), `lib/` (distro detection),
  `smoke-test.sh`, and the `_kek/` easter egg.
- Source material lives in git history on the `chezmoi` branch (see "Preserve" above).
- Fresh-machine entry: `curl -fsSL <raw install.sh> | bash`.
