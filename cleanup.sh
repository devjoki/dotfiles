#!/bin/bash
# Cleanup script for dotfiles-managed configurations
# This removes configs, data, and caches for tools managed by this dotfiles repo

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/utils.sh"

echo "=== Dotfiles Cleanup Script ==="
echo ""
echo "Select what to clean:"
echo "  1) Config only (~/.config, symlinks)"
echo "  2) State/Share only (~/.local/share, ~/.local/state)"
echo "  3) Cache only (~/.cache)"
echo "  4) All of the above"
echo "  5) Cancel"
echo ""
read -p "Enter your choice [1-5]: " CLEANUP_CHOICE

case $CLEANUP_CHOICE in
    1) CLEAN_CONFIG=true; CLEAN_STATE=false; CLEAN_CACHE=false ;;
    2) CLEAN_CONFIG=false; CLEAN_STATE=true; CLEAN_CACHE=false ;;
    3) CLEAN_CONFIG=false; CLEAN_STATE=false; CLEAN_CACHE=true ;;
    4) CLEAN_CONFIG=true; CLEAN_STATE=true; CLEAN_CACHE=true ;;
    5) echo "Cleanup cancelled."; exit 0 ;;
    *) echo_err "Invalid choice!"; exit 1 ;;
esac

echo ""
echo "This will clean:"
$CLEAN_CONFIG && echo "  - Config files (~/.config, symlinks)"
$CLEAN_STATE && echo "  - State/Share data (~/.local/share, ~/.local/state)"
$CLEAN_CACHE && echo "  - Cache files (~/.cache)"
echo ""
echo "Affected tools: Neovim, Zsh, Starship, Wezterm, Mason, vfox, Git, fzf, mcfly, zoxide"
echo ""
echo "Your dotfiles repo will NOT be affected."
echo ""

if ! choice "Are you sure you want to continue?"; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Starting cleanup..."

# Neovim
if $CLEAN_CONFIG; then
    echo "Cleaning Neovim config..."
    rm -rf ~/.config/nvim
fi

if $CLEAN_STATE; then
    echo "Cleaning Neovim state/share..."
    rm -rf ~/.local/share/nvim
    rm -rf ~/.local/state/nvim
fi

if $CLEAN_CACHE; then
    echo "Cleaning Neovim cache..."
    rm -rf ~/.cache/nvim
fi

# Mason
if $CLEAN_STATE; then
    echo "Cleaning Mason..."
    rm -rf ~/.local/share/mason
fi

# Zsh
if $CLEAN_CONFIG; then
    echo "Cleaning Zsh config..."
    rm -f ~/.zshenv
    rm -f ~/.zshrc
    rm -f ~/.zsh_config.properties
    rm -rf ~/.config/zsh
    rm -rf ~/.config/zsh-shared
fi

if $CLEAN_STATE; then
    echo "Cleaning Zsh state..."
    rm -f ~/.zsh_history
    rm -rf ~/.zsh_sessions
    # Zsh extensions
    rm -rf ~/.local/share/zsh
fi

# Starship
if $CLEAN_CONFIG; then
    echo "Cleaning Starship config..."
    rm -f ~/.config/starship.toml
fi

# Wezterm
if $CLEAN_CONFIG; then
    echo "Cleaning Wezterm config..."
    rm -rf ~/.config/wezterm
    rm -f ~/.wezterm.lua
fi

# Neovim shared
if $CLEAN_CONFIG; then
    echo "Cleaning Neovim shared config..."
    rm -rf ~/.config/nvim-shared
fi

# Utils
if $CLEAN_CONFIG; then
    echo "Cleaning utils..."
    rm -rf ~/.config/utils
    rm -rf ~/.scripts
fi

# Git
if $CLEAN_CONFIG; then
    echo "Cleaning Git config..."
    rm -rf ~/.config/git
fi

# Lazygit
if $CLEAN_CONFIG; then
    echo "Cleaning Lazygit config..."
    rm -rf ~/.config/lazygit
fi

# Eza
if $CLEAN_CONFIG; then
    echo "Cleaning Eza config..."
    rm -rf ~/.config/eza
fi

# Ghostty
if $CLEAN_CONFIG; then
    echo "Cleaning Ghostty config..."
    rm -rf ~/.config/ghostty
fi

# GTK-2.0
if $CLEAN_CONFIG; then
    echo "Cleaning GTK-2.0 config..."
    rm -rf ~/.config/gtk-2.0
fi

# IdeaVim
if $CLEAN_CONFIG; then
    echo "Cleaning IdeaVim config..."
    rm -f ~/.ideavimrc
    rm -rf ~/.config/ideavim
fi

# vfox
if $CLEAN_STATE; then
    echo "Cleaning vfox..."
    rm -rf ~/.version-fox
fi

# fzf
if $CLEAN_STATE; then
    echo "Cleaning fzf..."
    rm -rf ~/.fzf
fi

# mcfly
if $CLEAN_STATE; then
    echo "Cleaning mcfly..."
    rm -rf ~/.local/share/mcfly
fi

# zoxide
if $CLEAN_STATE; then
    echo "Cleaning zoxide..."
    rm -rf ~/.local/share/zoxide
fi

echo ""
echo "=== Cleanup Complete ==="
echo ""
if $CLEAN_CONFIG || $CLEAN_STATE; then
    echo "To restore your configuration, run ./bootstrap.sh"
fi
echo ""
