#!/bin/bash

# Bootstrap script for Fedora toolbox
# This installs development tools inside a toolbox container
# GUI apps (wezterm, nvim, starship) should be on the host

set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#shellcheck disable=SC1091
source "$SCRIPT_DIR/utils/utils.sh"
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
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y \
    gcc \
    gcc-c++ \
    make \
    cmake \
    git \
    curl \
    wget \
    unzip \
    which

# Install Homebrew (useful for some development tools)
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Set up Homebrew environment
    if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        # Add to profile
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.profile"
    fi
else
    echo "Homebrew is already installed"
    eval "$(brew shellenv)" 2>/dev/null || true
fi

# Install Neovim (full version with LSP support)
if ! command -v nvim &> /dev/null; then
    echo "Installing Neovim..."
    sudo dnf install -y neovim python3-neovim
fi

# Install version manager (vfox)
if ! command -v vfox &> /dev/null; then
    echo "Installing vfox..."
    brew install vfox
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

# Install lazygit
if ! command -v lazygit &> /dev/null; then
    echo "Installing lazygit..."
    brew install jesseduffield/lazygit/lazygit
fi

# SDK VERSIONS
JAVA_VERSION="17-open"
GRADLE_VERSION="8.7"
MAVEN_VERSION="3.9.6"
NODE_VERSION="latest"

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

# Optional: Install Python development tools
if choice "Install Python development tools?"; then
    sudo dnf install -y python3 python3-pip python3-devel
fi

# Optional: Install Docker/Podman tools
if choice "Install container tools (podman, docker-compose)?"; then
    sudo dnf install -y podman podman-compose
fi

# Setup Neovim config (full version with LSPs)
echo "Setting up Neovim configuration..."
SCRIPT_DIR="$HOME/.config"

# Use full nvim config for toolbox (with LSP support)
export NVIM_CONFIG="nvim-full"
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
