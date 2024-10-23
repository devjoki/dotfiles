#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/../utils/utils.sh"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Z_PROFILE="$HOME/.config/zsh/.zprofile"
append_unique_lines_to_file "$Z_PROFILE" 'eval "$(/opt/homebrew/bin/brew shellenv)"'
eval "$(/opt/homebrew/bin/brew shellenv)"
source "$Z_PROFILE"

brew install --cask wezterm
brew install starship
brew install fzf
brew install neovim
brew install lazygit
brew install zoxide
brew install unzip
brew install eza
brew install jq
brew install gpg
brew install vfox
brew install rustup
brew install lua
brew install hammerspoon --cask

