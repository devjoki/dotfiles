#!/bin/bash
# Cleanup script for dotfiles-managed configurations
# This removes configs, data, and caches for tools managed by this dotfiles repo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/utils.sh"

# Helper function to safely remove directories/files with error reporting
safe_remove() {
    local path=$1
    if [ -e "$path" ]; then
        echo "  Removing: $path"
        if rm -rf "$path" 2>/dev/null; then
            echo "  ✓ Removed: $path"
        else
            echo_warn "  Permission denied, trying with sudo..."
            if sudo rm -rf "$path" 2>/dev/null; then
                echo "  ✓ Removed with sudo: $path"
            else
                echo_err "  ✗ Failed to remove even with sudo: $path"
            fi
        fi
    else
        echo "  - Not found: $path (skipping)"
    fi
}

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
echo "Affected tools: Neovim, Zsh, Starship, Wezterm, Mason, vfox, Git, fzf, zoxide"
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
    safe_remove ~/.config/nvim
fi

if $CLEAN_STATE; then
    echo "Cleaning Neovim state/share..."
    safe_remove ~/.local/share/nvim
    safe_remove ~/.local/state/nvim
fi

if $CLEAN_CACHE; then
    echo "Cleaning Neovim cache..."
    safe_remove ~/.cache/nvim
fi

# Mason
if $CLEAN_STATE; then
    echo "Cleaning Mason..."
    safe_remove ~/.local/share/mason
fi

# Zsh
if $CLEAN_CONFIG; then
    echo "Cleaning Zsh config..."
    safe_remove ~/.zshenv
    safe_remove ~/.zshrc
    safe_remove ~/.zsh_config.properties
    safe_remove ~/.config/zsh
    safe_remove ~/.config/zsh-shared
fi

if $CLEAN_STATE; then
    echo "Cleaning Zsh state..."
    safe_remove ~/.zsh_history
    safe_remove ~/.zsh_sessions
    # Zsh extensions
    safe_remove ~/.local/share/zsh
fi

# Starship
if $CLEAN_CONFIG; then
    echo "Cleaning Starship config..."
    safe_remove ~/.config/starship.toml
fi

# Wezterm
if $CLEAN_CONFIG; then
    echo "Cleaning Wezterm config..."
    safe_remove ~/.config/wezterm
    safe_remove ~/.wezterm.lua
fi

# Neovim shared
if $CLEAN_CONFIG; then
    echo "Cleaning Neovim shared config..."
    safe_remove ~/.config/nvim-shared
fi

# Utils
if $CLEAN_CONFIG; then
    echo "Cleaning utils..."
    safe_remove ~/.config/utils
    safe_remove ~/.scripts
fi

# Git
if $CLEAN_CONFIG; then
    echo "Cleaning Git config..."
    safe_remove ~/.config/git
fi

# Lazygit
if $CLEAN_CONFIG; then
    echo "Cleaning Lazygit config..."
    safe_remove ~/.config/lazygit
fi

# Eza
if $CLEAN_CONFIG; then
    echo "Cleaning Eza config..."
    safe_remove ~/.config/eza
fi

# Ghostty
if $CLEAN_CONFIG; then
    echo "Cleaning Ghostty config..."
    safe_remove ~/.config/ghostty
fi

# GTK-2.0
if $CLEAN_CONFIG; then
    echo "Cleaning GTK-2.0 config..."
    safe_remove ~/.config/gtk-2.0
fi

# IdeaVim
if $CLEAN_CONFIG; then
    echo "Cleaning IdeaVim config..."
    safe_remove ~/.ideavimrc
    safe_remove ~/.config/ideavim
fi

# vfox
if $CLEAN_STATE; then
    echo "Cleaning vfox..."
    # Just remove the entire vfox directory (includes all SDKs, cache, and config)
    safe_remove ~/.version-fox
    safe_remove ~/.local/share/vfox
    safe_remove ~/.local/state/vfox
fi

# fzf
if $CLEAN_STATE; then
    echo "Cleaning fzf..."
    safe_remove ~/.fzf
fi

# zoxide
if $CLEAN_STATE; then
    echo "Cleaning zoxide..."
    safe_remove ~/.local/share/zoxide
fi

echo ""
echo "=== Cleanup Complete ==="
echo ""
if $CLEAN_CONFIG || $CLEAN_STATE; then
    echo "To restore your configuration, run ./bootstrap.sh"
fi
echo ""
