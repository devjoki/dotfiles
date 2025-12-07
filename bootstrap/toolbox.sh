#!/bin/bash

# Bootstrap script for Fedora toolbox
# This installs development tools inside a toolbox container
# GUI apps (wezterm, nvim, starship) should be on the host

set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#shellcheck disable=SC1091
source "$SCRIPT_DIR/../utils/utils.sh"
set -e

echo "=== Toolbox Development Environment Bootstrap ==="
echo "This will install development tools in the current toolbox"
echo ""

# Check if we're in a toolbox
if [ -z "$TOOLBOX_PATH" ]; then
    echo_warn "Warning: TOOLBOX_PATH not set. Are you inside a toolbox?"
    if ! choice "Continue anyway?"; then
        exit 1
    fi
fi

# Update system
echo "Updating toolbox packages..."
sudo dnf update -y

# Install build tools
echo "Installing build tools..."
# dnf5 uses "group install", older dnf uses "groupinstall"
# In dnf5, the group name changed from "Development Tools" to "development-tools" or "C Development Tools and Libraries"
if dnf --version 2>&1 | grep -q "dnf5"; then
    sudo dnf group install -y "development-tools" || sudo dnf install -y @development-tools || sudo dnf install -y gcc gcc-c++ make
else
    sudo dnf groupinstall -y "Development Tools"
fi
sudo dnf install -y \
    gcc \
    gcc-c++ \
    make \
    cmake \
    git \
    curl \
    wget \
    unzip \
    which \
    zsh \
    util-linux-user

# Change default shell to zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

# Install Neovim (full version with LSP support)
if ! command -v nvim &> /dev/null; then
    echo "Installing Neovim..."
    sudo dnf install -y neovim
fi

# Install starship prompt
if ! command -v starship &> /dev/null; then
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install version manager (vfox)
if ! command -v vfox &> /dev/null; then
    echo "Installing vfox..."
    curl -sSL https://raw.githubusercontent.com/version-fox/vfox/main/install.sh | bash
fi

# Activate vfox
eval "$(vfox activate bash)"

# Install rustup
if ! command -v rustup &> /dev/null; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    rustup install stable
fi

# Install lazygit via dnf copr
if ! command -v lazygit &> /dev/null; then
    echo "Installing lazygit..."
    sudo dnf copr enable atim/lazygit -y
    sudo dnf install -y lazygit
fi

# Install zoxide
if ! command -v zoxide &> /dev/null; then
    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Install eza (modern replacement for ls)
if ! command -v eza &> /dev/null; then
    echo "Installing eza..."
    # eza is not in default Fedora repos, install from GitHub releases
    EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    curl -Lo /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz"
    sudo tar -xzf /tmp/eza.tar.gz -C /usr/local/bin
    rm /tmp/eza.tar.gz
fi

# Install mcfly (smart command history)
if ! command -v mcfly &> /dev/null; then
    echo "Installing mcfly..."
    curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly
fi

# Install fzf (fuzzy finder - required by fzf-tab)
if ! command -v fzf &> /dev/null; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc
fi

# SDK VERSIONS
JAVA_VERSION="latest"
GRADLE_VERSION="latest"
MAVEN_VERSION="latest"
NODE_VERSION="latest"
GO_VERSION="latest"

echo "Installing SDKs via vfox..."

# Install Java
if ! command -v java &> /dev/null; then
    echo "Installing Java $JAVA_VERSION..."
    vfox add java
    vfox install "java@$JAVA_VERSION"
    vfox use -g java
fi

# Install Maven
if ! command -v mvn &> /dev/null; then
    echo "Installing Maven $MAVEN_VERSION..."
    vfox add maven
    vfox install "maven@$MAVEN_VERSION"
    vfox use -g maven
fi

# Install Gradle
if ! command -v gradle &> /dev/null; then
    echo "Installing Gradle $GRADLE_VERSION..."
    vfox add gradle
    vfox install "gradle@$GRADLE_VERSION"
    vfox use -g gradle
fi

# Install Node.js
if ! command -v node &> /dev/null; then
    echo "Installing Node.js $NODE_VERSION..."
    vfox add nodejs
    vfox install "nodejs@$NODE_VERSION"
    vfox use -g nodejs
fi

# Install Go
if ! command -v go &> /dev/null; then
    echo "Installing Go $GO_VERSION..."
    vfox add golang
    vfox install "golang@$GO_VERSION"
    vfox use -g golang
fi

# Optional: Install Python development tools
if choice "Install Python development tools?"; then
    sudo dnf install -y python3 python3-pip python3-devel
fi

# Optional: Install Docker/Podman tools
if choice "Install container tools (podman, docker-compose)?"; then
    sudo dnf install -y podman podman-compose
fi

# Setup configurations
echo "Setting up configurations..."
# Save the parent directory as SCRIPT_DIR for common-symlinks.sh
SCRIPT_DIR="$SCRIPT_DIR/.."

# Use full configs for toolbox (with LSP support and dev tools)
export NVIM_CONFIG="nvim-full"
export ZSH_CONFIG="zsh-full"
source "$SCRIPT_DIR/bootstrap/common-symlinks.sh"

echo ""
echo "=== Toolbox Bootstrap Complete ==="
echo ""
echo "Development tools installed:"
echo "  - Build tools (gcc, make, cmake)"
echo "  - Homebrew"
echo "  - vfox (version manager)"
echo "  - rustup & cargo"
echo "  - lazygit"
echo "  - Java $JAVA_VERSION"
echo "  - Maven $MAVEN_VERSION"
echo "  - Gradle $GRADLE_VERSION"
echo "  - Node.js $NODE_VERSION"
echo ""
echo "Your home directory is shared between host and toolbox."
echo "Neovim, Wezterm, and Starship configs from the host will work here."
echo ""
echo "To use this toolbox, run: toolbox enter $(toolbox list | grep -v CONTAINER | grep -v IMAGE | awk '{print $2}' | head -1)"
