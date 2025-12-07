#!/bin/bash

# Bootstrap script for Fedora KDE host
# This installs GUI apps (wezterm, nvim, starship) on the native OS
# Development tools should be installed in toolbox using bootstrap-toolbox.sh

set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#shellcheck disable=SC1091
source "$SCRIPT_DIR/../utils/utils.sh"
set -e

echo "=== Fedora KDE Host Bootstrap ==="
echo "This will install GUI applications on the host system"
echo "Development tools will be installed in toolbox separately"
echo ""

# Update system
echo "Updating system packages..."
sudo dnf update -y

# Install essential tools
echo "Installing essential packages..."
sudo dnf install -y \
    git \
    curl \
    wget \
    unzip \
    zsh \
    util-linux-user

# Install toolbox if not present
if ! command -v toolbox &> /dev/null; then
    echo "Installing toolbox..."
    sudo dnf install -y toolbox
fi

# Change default shell to zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

# Install starship prompt
if ! command -v starship &> /dev/null; then
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install neovim
if ! command -v nvim &> /dev/null; then
    echo "Installing neovim..."
    sudo dnf install -y neovim
fi

# Install wezterm
if ! command -v wezterm &> /dev/null; then
    echo "Installing wezterm..."
    sudo dnf copr enable wezfurlong/wezterm-nightly -y
    sudo dnf install -y wezterm
fi

# Install zoxide
if ! command -v zoxide &> /dev/null; then
    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Install eza (modern replacement for ls)
if ! command -v eza &> /dev/null; then
    echo "Installing eza..."
    sudo dnf install -y eza
fi

# Create config properties file
touch "$HOME/.zsh_config.properties"

# Create symbolic links for configurations
echo "Creating symbolic links..."

# Use slim configs for Fedora host (lightweight, no dev tools)
export NVIM_CONFIG="nvim-slim"
export ZSH_CONFIG="zsh-slim"

# Save the parent directory as SCRIPT_DIR for common-symlinks.sh
SCRIPT_DIR="$SCRIPT_DIR/.."
source "$SCRIPT_DIR/bootstrap/common-symlinks.sh"

echo ""
echo "=== Fedora Host Bootstrap Complete ==="
echo ""
echo "Next steps:"
echo "1. Create a toolbox: toolbox create dev"
echo "2. Enter the toolbox: toolbox enter dev"
echo "3. Run the toolbox bootstrap script: ./bootstrap-toolbox.sh"
echo "4. (Optional) Add 'toolbox-dev' alias to your .zshrc"
echo ""
echo "You may need to log out and back in for the shell change to take effect."
