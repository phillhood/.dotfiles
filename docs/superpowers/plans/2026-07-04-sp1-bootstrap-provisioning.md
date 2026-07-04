# SP1 Bootstrap & Dependency Provisioning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A fresh Arch machine is provisioned to the current working setup with one command — `_setup/bootstrap` installs git+chezmoi, then `chezmoi init --apply` installs the correct toolchain via yay and lays down all tracked dotfiles, idempotently.

**Architecture:** chezmoi-native provisioning (Approach C from the spec). A minimal `_setup/bootstrap` is the bare-machine entrypoint; the real work runs during `chezmoi apply` via `.chezmoidata/packages.yaml` (grouped package lists) + `.chezmoiscripts/` (one templated installer that runs `yay -S --needed`, plus four small post-install scripts). Replaces the stow-era `_setup/` (25 per-tool scripts + `stow .`).

**Tech Stack:** chezmoi v2.70.5 (templates, `.chezmoidata`, `.chezmoiscripts`, `promptBoolOnce`), bash, yay (AUR helper), pacman, Arch Linux.

## Global Constraints

*Every task's requirements implicitly include this section.*

- **Target distro:** Arch only. No ubuntu/debian/darwin branches anywhere.
- **Package installer:** `yay -S --needed --noconfirm` (wraps pacman for official repos, builds AUR). `paru` is not used.
- **Execution model:** scripts run as the normal user; escalate with `sudo` per-command. Never assume root; `_setup/bootstrap` must refuse to run as root.
- **Clone URL (bootstrap + tests):** `https://github.com/phillhood/.dotfiles.git`, branch `chezmoi` (HTTPS so a bare machine needs no SSH key).
- **tpm clone path:** `~/.tmux/plugins/tpm` (exactly what `dot_tmux.conf:24` runs — `~/.tmux/plugins/tpm/tpm`).
- **Every script header:** `#!/usr/bin/env bash` then `set -euo pipefail`.
- **SAFETY — never run a real `chezmoi apply` on this machine during development.** This repo IS chezmoi's source dir (`chezmoi source-path` = `/home/phill/.dotfiles`), so a real apply would actually install packages. On-machine verification uses only `chezmoi execute-template` and `chezmoi apply --dry-run`. Real end-to-end runs happen only inside the throwaway container in Task 10.
- **Commits are deferred to the user.** The repo has no baseline commit yet and the user is structuring the initial commit themselves. Do NOT run `git commit` during execution. Each task ends at a **Checkpoint** (verification), not a commit. (Once the user establishes a baseline commit, they may commit per task if they choose.)
- **shellcheck:** install once before verifying — `sudo pacman -S --needed --noconfirm shellcheck`.
- **Package names (verbatim, for `.chezmoidata/packages.yaml`):** core: `zsh`; cli: `starship atuin fnm eza bat ripgrep fzf zoxide direnv jq uv rustup go tmux neovim fastfetch`; secrets: `sops age`; docker: `docker docker-compose docker-buildx`; k8s (opt-in): `kubectl kubectx k9s helm kubeseal argocd`. (yay resolves official-vs-AUR automatically; don't classify.)

## File Structure

**Create:**
- `.chezmoidata/packages.yaml` — grouped package lists (the only place package names live).
- `.chezmoi.toml.tmpl` — `promptBoolOnce` → `data.installK8s`.
- `.chezmoiscripts/run_onchange_before_10-install-packages.sh.tmpl` — ensure base-devel+yay, then `yay -S --needed` all groups (k8s gated).
- `.chezmoiscripts/run_once_after_20-set-default-shell.sh` — chsh to zsh.
- `.chezmoiscripts/run_onchange_after_30-docker.sh` — enable docker + group.
- `.chezmoiscripts/run_once_after_40-tmux-tpm.sh` — clone tpm.
- `.chezmoiscripts/run_once_after_50-rust-node.sh` — rust stable + node LTS.
- `_setup/bootstrap` — bare-machine entrypoint.
- `_setup/smoke-test.sh` — container end-to-end test harness.

**Delete:**
- `_setup/_dependencies/` (all 25 per-tool scripts).
- `_setup/setup` (old stow/nvm/ohmyposh bootstrap).

**Modify:**
- `README.md` — new bootstrap one-liner in Usage.
- `TODO.md` — check off the *Bootstrap scripts (`_setup/`)* section.

**Keep untouched:** `_setup/_kek/` (invoked by `_setup/bootstrap`), `_utils/`.

---

### Task 1: Package data + k8s opt-in prompt

**Files:**
- Create: `.chezmoidata/packages.yaml`
- Create: `.chezmoi.toml.tmpl`

**Interfaces:**
- Produces: template data `.packages.core`, `.packages.cli`, `.packages.secrets`, `.packages.docker`, `.packages.k8s` (each a list of strings); `.installK8s` (bool). Task 2 consumes these.

- [ ] **Step 1: Install shellcheck (one-time tooling)**

Run: `sudo pacman -S --needed --noconfirm shellcheck`
Expected: shellcheck installed (or "up to date").

- [ ] **Step 2: Write the failing render check**

The data doesn't exist yet, so rendering a field must fail first.

Run: `chezmoi execute-template '{{ .packages.cli }}'`
Expected: FAIL — error like `map has no entry for key "packages"`.

- [ ] **Step 3: Create `.chezmoidata/packages.yaml`**

```yaml
packages:
  core:
    - zsh
  cli:
    - starship
    - atuin
    - fnm
    - eza
    - bat
    - ripgrep
    - fzf
    - zoxide
    - direnv
    - jq
    - uv
    - rustup
    - go
    - tmux
    - neovim
    - fastfetch
  secrets:
    - sops
    - age
  docker:
    - docker
    - docker-compose
    - docker-buildx
  k8s:
    - kubectl
    - kubectx
    - k9s
    - helm
    - kubeseal
    - argocd
```

- [ ] **Step 4: Create `.chezmoi.toml.tmpl`**

```
{{- $installK8s := promptBoolOnce . "installK8s" "Install Kubernetes CLI tools?" false -}}
[data]
    installK8s = {{ $installK8s }}
```

- [ ] **Step 5: Verify the render check now passes**

Run: `chezmoi execute-template '{{ .packages.cli }}'`
Expected: PASS — prints `[starship atuin fnm eza bat ripgrep fzf zoxide direnv jq uv rustup go tmux neovim fastfetch]`

Run: `chezmoi execute-template --init --promptBool installK8s=true '{{ .installK8s }}'`
Expected: PASS — prints `true`

- [ ] **Step 6: Checkpoint**

Verify: both renders above succeed and `chezmoi data` lists the `packages` map. (No commit — see Global Constraints.)

---

### Task 2: Package installer script

**Files:**
- Create: `.chezmoiscripts/run_onchange_before_10-install-packages.sh.tmpl`

**Interfaces:**
- Consumes: `.packages.*` and `.installK8s` from Task 1.
- Produces: no template data; installs all packages during `chezmoi apply`.

- [ ] **Step 1: Write the installer template**

```
#!/usr/bin/env bash
set -euo pipefail

# chezmoi template: the package list is inlined below, so this script's content
# hash changes whenever packages.yaml changes — which makes chezmoi re-run it
# (run_onchange) and install any newly-added packages.

echo "==> Ensuring build prerequisites (base-devel, git)"
sudo pacman -S --needed --noconfirm base-devel git

if ! command -v yay >/dev/null 2>&1; then
  echo "==> Installing yay (AUR helper)"
  tmpdir="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
  ( cd "$tmpdir/yay-bin" && makepkg -si --noconfirm )
  rm -rf "$tmpdir"
fi

{{- $pkgs := concat .packages.core .packages.cli .packages.secrets .packages.docker }}
{{- if .installK8s }}{{ $pkgs = concat $pkgs .packages.k8s }}{{ end }}
packages=(
{{- range $pkgs }}
  {{ . }}
{{- end }}
)

echo "==> Installing ${#packages[@]} packages via yay"
yay -S --needed --noconfirm "${packages[@]}"
```

- [ ] **Step 2: Render both branches and confirm valid bash**

Run (k8s off):
```bash
chezmoi execute-template --init --promptBool installK8s=false \
  < .chezmoiscripts/run_onchange_before_10-install-packages.sh.tmpl > /tmp/pkg-off.sh
bash -n /tmp/pkg-off.sh && echo "SYNTAX OK"
```
Expected: `SYNTAX OK`; `/tmp/pkg-off.sh` contains the `packages=( … )` array with `zsh` through `docker-buildx` and **no** kubectl/helm/etc.

Run (k8s on):
```bash
chezmoi execute-template --init --promptBool installK8s=true \
  < .chezmoiscripts/run_onchange_before_10-install-packages.sh.tmpl > /tmp/pkg-on.sh
bash -n /tmp/pkg-on.sh && echo "SYNTAX OK"
grep -q 'kubectl' /tmp/pkg-on.sh && grep -q 'argocd' /tmp/pkg-on.sh && echo "K8S INCLUDED"
```
Expected: `SYNTAX OK` and `K8S INCLUDED`.

- [ ] **Step 3: shellcheck the rendered output**

Run: `shellcheck /tmp/pkg-on.sh`
Expected: no errors. (If SC2086-type warnings appear on the array expansion, they're acceptable/quoted; fix any genuine errors.)

- [ ] **Step 4: Checkpoint**

Verify: both branches render to valid bash, k8s gating works, shellcheck clean.

---

### Task 3: Set default shell script

**Files:**
- Create: `.chezmoiscripts/run_once_after_20-set-default-shell.sh`

- [ ] **Step 1: Write the script**

```bash
#!/usr/bin/env bash
set -euo pipefail

zsh_path="$(command -v zsh)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"

if [ "$current_shell" != "$zsh_path" ]; then
  echo "==> Setting default shell to zsh ($zsh_path)"
  sudo chsh -s "$zsh_path" "$USER"
fi
```

Note: `sudo chsh … "$USER"` (root changes the user's shell) avoids an interactive password prompt and makes the container test non-interactive.

- [ ] **Step 2: shellcheck**

Run: `shellcheck .chezmoiscripts/run_once_after_20-set-default-shell.sh`
Expected: no errors.

- [ ] **Step 3: Checkpoint**

Verify: shellcheck clean; script is a no-op when the login shell is already zsh.

---

### Task 4: Docker setup script

**Files:**
- Create: `.chezmoiscripts/run_onchange_after_30-docker.sh`

- [ ] **Step 1: Write the script**

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ -d /run/systemd/system ]; then
  echo "==> Enabling docker.service"
  sudo systemctl enable --now docker.service
else
  echo "==> systemd not running; skipping docker.service enable"
fi

if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
  echo "==> Adding $USER to docker group (re-login required to take effect)"
  sudo usermod -aG docker "$USER"
fi
```

The `/run/systemd/system` guard keeps this correct on real machines and safe inside the (systemd-less) test container.

- [ ] **Step 2: shellcheck**

Run: `shellcheck .chezmoiscripts/run_onchange_after_30-docker.sh`
Expected: no errors.

- [ ] **Step 3: Checkpoint**

Verify: shellcheck clean; group-add guarded (idempotent); service enable skipped without systemd.

---

### Task 5: tmux tpm clone script

**Files:**
- Create: `.chezmoiscripts/run_once_after_40-tmux-tpm.sh`

- [ ] **Step 1: Write the script**

```bash
#!/usr/bin/env bash
set -euo pipefail

tpm_dir="$HOME/.tmux/plugins/tpm"
if [ ! -d "$tpm_dir" ]; then
  echo "==> Cloning tpm to $tpm_dir"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
fi
```

Path matches `dot_tmux.conf:24` (`run '~/.tmux/plugins/tpm/tpm'`).

- [ ] **Step 2: shellcheck**

Run: `shellcheck .chezmoiscripts/run_once_after_40-tmux-tpm.sh`
Expected: no errors.

- [ ] **Step 3: Checkpoint**

Verify: shellcheck clean; guarded so a re-run doesn't re-clone.

---

### Task 6: Rust + Node toolchain script

**Files:**
- Create: `.chezmoiscripts/run_once_after_50-rust-node.sh`

- [ ] **Step 1: Write the script**

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting Rust stable as the default toolchain"
rustup default stable

echo "==> Installing Node LTS via fnm"
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"
fnm install --lts
fnm default lts-latest
```

`rustup` (the package) installs only the toolchain manager; `rustup default stable` fetches + selects the stable toolchain. `fnm install --lts` creates the `lts-latest` alias that the next line makes the default.

- [ ] **Step 2: shellcheck**

Run: `shellcheck .chezmoiscripts/run_once_after_50-rust-node.sh`
Expected: no errors (SC2046 on `eval "$(fnm env)"` is quoted; fine).

- [ ] **Step 3: Checkpoint**

Verify: shellcheck clean.

---

### Task 7: Bare-machine bootstrap entrypoint

**Files:**
- Create: `_setup/bootstrap`

**Interfaces:**
- Consumes: nothing (runs on a bare machine). Invokes `chezmoi init --apply`, which triggers Tasks 2–6.

- [ ] **Step 1: Write the script**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Fresh-machine entrypoint. Run as your NORMAL user (not root); steps escalate
# with sudo where needed. Installs the minimum to hand off to chezmoi, which
# then provisions packages and applies dotfiles.

REPO="https://github.com/phillhood/.dotfiles.git"
BRANCH="chezmoi"

if [ "$(id -u)" -eq 0 ]; then
  echo "Do not run bootstrap as root — yay/makepkg must build as a normal user." >&2
  exit 1
fi

echo "==> Installing prerequisites (git, chezmoi)"
sudo pacman -Sy --needed --noconfirm git chezmoi

echo "==> Initializing chezmoi and applying (this provisions the machine)"
chezmoi init --apply --branch "$BRANCH" "$REPO"

# Easter egg — run after everything completes
src="$(chezmoi source-path)"
if [ -f "$src/_setup/_kek/butHesNotaRapper" ]; then
  bash "$src/_setup/_kek/butHesNotaRapper" || true
fi
```

- [ ] **Step 2: Make it executable + shellcheck**

Run:
```bash
chmod +x _setup/bootstrap
shellcheck _setup/bootstrap
```
Expected: no errors.

- [ ] **Step 3: Checkpoint**

Verify: shellcheck clean; root guard present; uses HTTPS clone URL. (Do NOT execute it here — it would provision this machine.)

---

### Task 8: Remove the stow-era `_setup/`

**Files:**
- Delete: `_setup/_dependencies/` (recursively), `_setup/setup`

- [ ] **Step 1: Delete the obsolete files**

Run:
```bash
rm -rf _setup/_dependencies
rm -f _setup/setup
```

- [ ] **Step 2: Verify what remains**

Run: `find _setup -type f | sort`
Expected: only `_setup/bootstrap`, `_setup/smoke-test.sh` (added in Task 10), and `_setup/_kek/butHesNotaRapper`, `_setup/_kek/supaHotFire`. No `_dependencies/`, no `setup`.

- [ ] **Step 3: Confirm chezmoi is unaffected**

Run: `chezmoi status`
Expected: no errors; `_setup/` is repo-only (ignored via `.chezmoiignore`) so its removal produces no target changes.

- [ ] **Step 4: Checkpoint**

Verify: obsolete files gone; `_kek/` intact; `chezmoi status` clean.

---

### Task 9: Docs — README + TODO

**Files:**
- Modify: `README.md` (Usage section)
- Modify: `TODO.md` (Bootstrap scripts section)

- [ ] **Step 1: Update the README Usage block**

Replace the `# On a new machine` block in `README.md` with:

````markdown
```sh
# On a new machine (bare Arch) — installs deps + applies dotfiles
git clone --branch chezmoi https://github.com/phillhood/.dotfiles.git /tmp/dotfiles
/tmp/dotfiles/_setup/bootstrap   # run as your normal user, NOT root

# Day to day
chezmoi edit ~/.zshrc # edit source, then:
chezmoi apply
chezmoi cd            # jump into the source repo to commit/push
```
````

(The `/tmp` clone just provides the bootstrap script; `chezmoi init` re-clones to `~/.local/share/chezmoi` as the managed source.)

- [ ] **Step 2: Check off the TODO bootstrap section**

In `TODO.md`, replace the `## Bootstrap scripts (`_setup/`)` section body with:

```markdown
## Bootstrap scripts (`_setup/`)
- [x] Rewritten for Arch + chezmoi (SP1): `_setup/bootstrap` installs git+chezmoi then
      `chezmoi init --apply`; packages live in `.chezmoidata/packages.yaml` and install via
      `.chezmoiscripts/` (yay). Old stow/nvm/oh-my-posh `_dependencies/` + `setup` removed.
```

- [ ] **Step 3: Checkpoint**

Verify: README one-liner references `_setup/bootstrap` and HTTPS URL; TODO bootstrap section marked done.

---

### Task 10: End-to-end container smoke test

**Files:**
- Create: `_setup/smoke-test.sh`

**Interfaces:**
- Consumes: everything (real `chezmoi apply` inside a throwaway Arch container).

- [ ] **Step 1: Write the smoke-test harness**

```bash
#!/usr/bin/env bash
set -euo pipefail

# End-to-end test of the bootstrap flow in a throwaway Arch container.
# Provisions a non-root sudo user, runs bootstrap twice (second run proves
# idempotency: no rebuilds, yay --needed no-ops). systemd is absent in the
# container, so the docker service-enable step self-skips by design.

img="archlinux:latest"

docker run --rm "$img" bash -euo pipefail -c '
  pacman -Sy --noconfirm --needed git base-devel sudo
  useradd -m -G wheel tester
  echo "tester ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/tester

  su - tester -c "
    set -euo pipefail
    git clone --branch chezmoi https://github.com/phillhood/.dotfiles.git /tmp/dotfiles
    echo === FIRST RUN ===
    /tmp/dotfiles/_setup/bootstrap
    echo === SECOND RUN (idempotency) ===
    chezmoi apply
    echo === VERIFY ===
    command -v starship && command -v eza && command -v yay
    test -f ~/.zshrc && echo zshrc-applied
  "
'
echo "SMOKE TEST PASSED"
```

- [ ] **Step 2: Make executable + shellcheck**

Run:
```bash
chmod +x _setup/smoke-test.sh
shellcheck _setup/smoke-test.sh
```
Expected: no errors.

- [ ] **Step 3: Run the smoke test**

Run: `_setup/smoke-test.sh`
Expected: completes with `SMOKE TEST PASSED`. During the run you should see packages install on the first run, the `=== SECOND RUN ===` produce no package rebuilds, the docker step print "systemd not running; skipping", and `VERIFY` print the tool paths + `zshrc-applied`.

Note: this pulls the Arch image and builds yay from source — expect a few minutes and network egress. If `git@`/private-repo auth is ever required, switch the clone to an authenticated URL; the default HTTPS assumes the repo is reachable unauthenticated (or that credentials are available in the container).

- [ ] **Step 4: Checkpoint**

Verify: `SMOKE TEST PASSED`; second run is a no-op for packages (idempotency proven).

---

## Self-Review

**Spec coverage:**
- Arch-only / drop other distros → Global Constraints + no distro branches (Tasks 2–7). ✓
- pacman/AUR-first via yay → Task 2. ✓
- Package groups core/cli/secrets/docker + k8s opt-in → Task 1 (data) + Task 2 (gating). ✓
- k8s `promptBoolOnce` → Task 1 (`.chezmoi.toml.tmpl`). ✓
- chezmoi-native flow + ordering (before/after prefixes) → Tasks 2–6 filenames. ✓
- run-as-user model + root guard → Task 7. ✓
- Default Rust stable + Node LTS → Task 6. ✓
- Keep easter eggs, run at end → Task 7 invokes `butHesNotaRapper`. ✓
- Remove `_dependencies/` + old `setup` → Task 8. ✓
- Docs (README one-liner, TODO check-off) → Task 9. ✓
- Error handling / idempotency (`set -euo pipefail`, `--needed`, guards) → all script tasks. ✓
- Testing layers (shellcheck, execute-template, dry-run, container) → Tasks 1–10; container in Task 10. ✓
- tpm path reconciled → Task 5 uses `~/.tmux/plugins/tpm` (was deferred in spec). ✓
- age key out of scope → not installed anywhere; only `sops`/`age` binaries in Task 1 data. ✓

**Placeholder scan:** No TBD/TODO; every script shown in full; every command has expected output. ✓

**Type/name consistency:** `.installK8s` (bool) and `.packages.{core,cli,secrets,docker,k8s}` defined in Task 1 and consumed with identical names in Task 2. tpm path identical in constraint + Task 5. Clone URL identical in constraint + Tasks 7, 9, 10. ✓
