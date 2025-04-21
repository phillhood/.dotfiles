# Dotfiles

My personal dotfiles for macOS, Linux, and WSL, and suite of installation scripts for bootstrapping a new machine. Forever a work in progress. Needs more memes.



### Development
|||
|-|-|
| Go | [go](https://docs.docker.com/engine/install/)
| Python | [conda](https://www.anaconda.com/docs/getting-started/miniconda/main0)  |
| Node.js | [nvm](https://github.com/nvm-sh/nvm)
| Virtualization | [docker](https://docs.docker.com/engine/install/) |

### Config Management
|||
|-|-|
| Version Control | [git](https://git-scm.com/) |
| Symlink Manager | [stow](https://www.gnu.org/software/stow/) | 

### Command Line
|||
|-|-|
| Shell | [zsh](https://zsh.sourceforge.io/) |
| Package Manager | [zinit](https://github.com/zdharma-continuum/zinit?tab=readme-ov-file#install) |
| Fuzzy Finding | [fzf](https://githib.com/junegunn/fzf) |
| Smart Navigation | [zoxide](https://github.com/ajeetdsouza/zoxide) |
| Prompt Styling | [oh my posh](https://ohmyposh.dev/docs) |
| Multiplexer | [tmux](https://github.com/tmux/tmux/wiki)


## Usage
### Installation
#### For fresh installs:
1. Clone/copy this repo into `~/.dotfiles`
    ```shell
    git clone git@github.com:phillhood/dotfiles.git
    ``` 
2. Run this command: 
    ```shell
    cd ~/.dotfiles && sudo bash _setup/installer 
    ```
3. Wait for SupaHotFire to _spit some bars_
#### Selected Installations:



### Updating configs
1. Move configs within `~/` into `~/.dotfiles`. Make sure they have the same structure as they would within `~/` and `~/.config/`
2. Stow them from the root path of this repo `cd ~/.dotfiles && stow .`
3. Files can be accessed or modifed by directly referencing their symlinks in `~/..`
4. Commit and push changes to the repo