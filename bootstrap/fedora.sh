#!/bin/bash
# Fedora Bootstrap Script
# Works for all Fedora variants: Workstation, Silverblue, Kinoite, Bazzite, etc.
# Supports both host and container installations
# Choose between slim (minimal) or full (complete dev environment) during setup

# Note: This script inherits SCRIPT_DIR from bootstrap.sh
# SCRIPT_DIR points to the dotfiles root directory

echo "=== Fedora Bootstrap ==="
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
    util-linux-user \
    libatomic

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

# Install neovim (latest stable release from GitHub)
if ! command -v nvim &> /dev/null; then
    echo "Installing neovim (latest stable from GitHub)..."
    NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    curl -fsSL -o /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
    if [ $? -eq 0 ] && [ -f /tmp/nvim.tar.gz ]; then
        sudo rm -rf /opt/nvim-linux-x86_64
        sudo tar -C /opt -xzf /tmp/nvim.tar.gz
        sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
        rm /tmp/nvim.tar.gz
        echo "Neovim ${NVIM_VERSION} installed successfully"
    else
        echo_err "Failed to download Neovim"
    fi
else
    # Check if version is old and upgrade
    CURRENT_VERSION=$(nvim --version | head -n1 | grep -oP 'v\K[0-9]+\.[0-9]+')
    if [[ $(echo "$CURRENT_VERSION < 0.11" | bc -l) -eq 1 ]]; then
        echo "Neovim $CURRENT_VERSION detected (older than 0.11)"
        echo "Upgrading to latest Neovim from GitHub..."
        NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -oP '"tag_name": "\K[^"]+')
        curl -fsSL -o /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
        if [ $? -eq 0 ] && [ -f /tmp/nvim.tar.gz ]; then
            sudo rm -rf /opt/nvim-linux-x86_64
            sudo tar -C /opt -xzf /tmp/nvim.tar.gz
            sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
            rm /tmp/nvim.tar.gz
            echo "Neovim ${NVIM_VERSION} upgraded successfully"
        else
            echo_err "Failed to download Neovim"
        fi
    else
        echo "Neovim $CURRENT_VERSION is up to date"
    fi
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

# Install fzf (fuzzy finder)
if ! command -v fzf &> /dev/null; then
    echo "Installing fzf..."
    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi
    ~/.fzf/install --bin
fi

# Install lazygit
if ! command -v lazygit &> /dev/null; then
    echo "Installing lazygit..."
    sudo dnf copr enable atim/lazygit -y
    sudo dnf install -y lazygit
fi

# Create config properties file
touch "$HOME/.zsh_config.properties"

# Ask user to select slim or full configuration
echo ""
select_config_type
echo ""

# Install dev tools only for full configuration
if [ "$NVIM_CONFIG" = "nvim-full" ]; then
    echo "Installing development tools (full configuration)..."

    # Install build tools
    if dnf --version 2>&1 | grep -q "dnf5"; then
        sudo dnf group install -y "development-tools" || sudo dnf install -y @development-tools || sudo dnf install -y gcc gcc-c++ make
    else
        sudo dnf groupinstall -y "Development Tools"
    fi

    # Install vfox (version manager)
    if ! command -v vfox &> /dev/null; then
        echo "Installing vfox..."
        curl -sSL https://raw.githubusercontent.com/version-fox/vfox/main/install.sh | bash
    fi

    # Install Rust
    if ! command -v rustup &> /dev/null; then
        echo "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        rustup install stable
    fi

    # Install SDKs
    eval "$(vfox activate bash)"
    JAVA_VERSION="latest"
    GRADLE_VERSION="latest"
    MAVEN_VERSION="latest"
    NODE_VERSION="latest"
    GO_VERSION="latest"

    echo "Installing SDKs via vfox..."
    [ ! -x "$(command -v java)" ] && vfox add java && vfox install "java@$JAVA_VERSION" && vfox use -g java
    [ ! -x "$(command -v mvn)" ] && vfox add maven && vfox install "maven@$MAVEN_VERSION" && vfox use -g maven
    [ ! -x "$(command -v gradle)" ] && vfox add gradle && vfox install "gradle@$GRADLE_VERSION" && vfox use -g gradle
    [ ! -x "$(command -v node)" ] && vfox add nodejs && vfox install "nodejs@$NODE_VERSION" && vfox use -g nodejs
    [ ! -x "$(command -v go)" ] && vfox add golang && vfox install "golang@$GO_VERSION" && vfox use -g golang

    # Install LaTeX
    if choice "Install LaTeX (latexmk)?"; then
        sudo dnf install -y latexmk
    fi
fi

# Create symbolic links
echo "Creating symbolic links..."
source "$SCRIPT_DIR/bootstrap/common-symlinks.sh"

echo ""
echo "=== Fedora Bootstrap Complete ==="
echo ""
if [ "$NVIM_CONFIG" = "nvim-full" ]; then
    echo "Full configuration installed with development tools"
else
    echo "Slim configuration installed"
    echo ""
    echo "For development work, you can:"
    echo "  - Run this bootstrap again and choose 'full' configuration"
    echo "  - Use containers (toolbox/distrobox) for dev environments"
fi
echo ""
echo "You may need to log out and back in for shell changes to take effect."
echo ""
