# Dotfiles

Easy symlink management for all my dotfiles!

## Requirements

- GNU Stow

`<package_manager> install stow`

## Shell

Custom zsh config inspired by [Elliot Minns](https://github.com/elliottminns)

### Requirements

1. **Shell:** [Zsh](https://zsh.sourceforge.io/)
2. **Package Manager:** [zinit](https://github.com/zdharma-continuum/zinit?tab=readme-ov-file#install)
3. **Prompt:** [oh-my-posh](https://ohmyposh.dev/docs)

### Usage

1. Clone this repo into `~/.dotfiles`
2. Move or create any configs or dotfiles to stow into `~/.dotfiles`. Make sure they have the same structure as they would within `~/`
3. Stow them when inside this directory `stow .`
4. Files can be accessed or modifed by directly referencing their symlinks in `~/`
5. Make sure to commit and push to this repo for the future!
