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


# Install fzf (fuzzy finder)
if ! command -v fzf &> /dev/null; then
    echo "Installing fzf..."
    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi
    ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# Install fd (faster alternative to find)
if ! command -v fd &> /dev/null; then
    echo "Installing fd..."
    FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    curl -Lo /tmp/fd.tar.gz "https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd-${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
    sudo tar -xzf /tmp/fd.tar.gz -C /tmp
    sudo cp /tmp/fd-*/fd /usr/local/bin/
    rm -rf /tmp/fd.tar.gz /tmp/fd-*
fi

# Install bat (cat with syntax highlighting)
if ! command -v bat &> /dev/null; then
    echo "Installing bat..."
    BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    curl -Lo /tmp/bat.tar.gz "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat-${BAT_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
    sudo tar -xzf /tmp/bat.tar.gz -C /tmp
    sudo cp /tmp/bat-*/bat /usr/local/bin/
    rm -rf /tmp/bat.tar.gz /tmp/bat-*
fi

# Install ripgrep (faster grep)
if ! command -v rg &> /dev/null; then
    echo "Installing ripgrep..."
    sudo dnf install -y ripgrep
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

    echo "Installing SDKs via vfox..."

    if [ ! -x "$(command -v java)" ]; then
        vfox_install_sdk java "$VFOX_JAVA_VERSION"
    fi

    if [ ! -x "$(command -v mvn)" ]; then
        vfox_install_sdk maven "$VFOX_MAVEN_VERSION"
    fi

    if [ ! -x "$(command -v gradle)" ]; then
        vfox_install_sdk gradle "$VFOX_GRADLE_VERSION"
    fi

    if [ ! -x "$(command -v node)" ]; then
        vfox_install_sdk nodejs "$VFOX_NODE_VERSION"
    fi

    if [ ! -x "$(command -v go)" ]; then
        vfox_install_sdk golang "$VFOX_GO_VERSION"
    fi

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
