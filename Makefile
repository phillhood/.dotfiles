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
