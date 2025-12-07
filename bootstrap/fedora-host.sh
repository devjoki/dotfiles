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

# Create config properties file
touch "$HOME/.zsh_config.properties"

# Create symbolic links for configurations
echo "Creating symbolic links..."

if [ -f "$SCRIPT_DIR/../zsh/.zshrc" ]; then
    create_symlink "$SCRIPT_DIR/../zsh/.zshrc" "$HOME/.zshrc" --override
elif [ -f "$SCRIPT_DIR/../zsh/.zshrc" ]; then
    create_symlink "$SCRIPT_DIR/../zsh/.zshrc" "$HOME/.zshrc" --override
fi

if [ -f "$SCRIPT_DIR/../zsh/.zshenv" ]; then
    create_symlink "$SCRIPT_DIR/../zsh/.zshenv" "$HOME/.zshenv" --override
elif [ -f "$SCRIPT_DIR/../zshenv" ]; then
    create_symlink "$SCRIPT_DIR/../zshenv" "$HOME/.zshenv" --override
fi

create_symlink "$SCRIPT_DIR/../utils/utils.sh" "$HOME/.scripts/utils.sh" --override
create_symlink "$SCRIPT_DIR/../utils/run_util_function.sh" "$HOME/.scripts/run_util_function.sh" --override

if [ -f "$SCRIPT_DIR/../ideavimrc" ]; then
    create_symlink "$SCRIPT_DIR/../ideavimrc" "$HOME/.ideavimrc" --override
fi

# Use nvim-slim for Fedora host (lightweight, no LSP)
export NVIM_CONFIG="nvim-slim"

# Create symlinks (using common logic)
if [ -f "$SCRIPT_DIR/../starship.toml" ]; then
    create_symlink "$SCRIPT_DIR/../starship.toml" "$HOME/.config/starship.toml" --override
fi

if [ -d "$SCRIPT_DIR/../wezterm" ]; then
    create_symlink "$SCRIPT_DIR/../wezterm" "$HOME/.config/wezterm" --override
fi

# Link nvim config and nvim-shared
# Save the parent directory as SCRIPT_DIR for common-symlinks.sh
SCRIPT_DIR="$SCRIPT_DIR/.."
source "$SCRIPT_DIR/bootstrap/common-symlinks.sh"

if [ -f "$SCRIPT_DIR/wezterm.lua" ]; then
    create_symlink "$SCRIPT_DIR/wezterm.lua" "$HOME/.wezterm.lua" --override
fi

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
