#!/bin/bash

cat <<EOF > "$HOME/.zshenv"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export ZDOTDIR=$XDG_CONFIG_HOME/zsh
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
EOF

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh/zsh_extensions/zsh-syntax-highlighting
git clone https://github.com/Aloxaf/fzf-tab ~/.config/zsh/zsh_extensions/fzf-tab
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

