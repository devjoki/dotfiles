#!/bin/bash
# macOS Bootstrap Script

echo "=== macOS Bootstrap ==="

# Install Command Line Tools if not present
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Please complete the installation and run this script again."
    exit 1
fi

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# Set up Homebrew PATH
	if [[ -f "/opt/homebrew/bin/brew" ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	elif [[ -f "/usr/local/bin/brew" ]]; then
		eval "$(/usr/local/bin/brew shellenv)"
	fi
else
	echo "Homebrew is already installed"
	eval "$(brew shellenv)"
fi

# Install essential tools
echo "Installing essential packages..."
install_package_if_not_exists "git"
install_package_if_not_exists "curl"
install_package_if_not_exists "wget"
install_package_if_not_exists "unzip"

# Install Zsh (usually pre-installed on macOS)
if ! command -v zsh &> /dev/null; then
	install_package_if_not_exists "zsh"
fi

# Change default shell to zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
	echo "Changing default shell to zsh..."
	if ! grep -q "$(which zsh)" /etc/shells; then
		echo "$(which zsh)" | sudo tee -a /etc/shells
	fi
	chsh -s "$(which zsh)"
fi

# Install development tools
echo "Installing development tools..."
install_app_if_not_exists "nvim" "brew install neovim"
install_app_if_not_exists "starship" "brew install starship"
install_app_if_not_exists "vfox" "brew install vfox"
install_app_if_not_exists "lazygit" "brew install jesseduffield/lazygit/lazygit"
install_app_if_not_exists "eza" "brew install eza"
install_app_if_not_exists "zoxide" "brew install zoxide"
install_app_if_not_exists "mcfly" "brew install mcfly"
install_app_if_not_exists "fzf" "brew install fzf"

# Install Rust
if ! command -v rustup &> /dev/null; then
	echo "Installing Rust..."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source "$HOME/.cargo/env"
	rustup install stable
fi

# Install Wezterm
if ! command -v wezterm &> /dev/null; then
	echo "Installing Wezterm..."
	brew install --cask wezterm
fi

# Activate vfox
eval "$(vfox activate bash)"

echo "Installing SDKs via vfox..."

# Install Java
if ! command -v java &> /dev/null; then
	echo "Installing Java $VFOX_JAVA_VERSION..."
	vfox_install_sdk java "$VFOX_JAVA_VERSION"
fi

# Install Maven
if ! command -v mvn &> /dev/null; then
	echo "Installing Maven $VFOX_MAVEN_VERSION..."
	vfox_install_sdk maven "$VFOX_MAVEN_VERSION"
fi

# Install Gradle
if ! command -v gradle &> /dev/null; then
	echo "Installing Gradle $VFOX_GRADLE_VERSION..."
	vfox_install_sdk gradle "$VFOX_GRADLE_VERSION"
fi

# Install Node.js
if ! command -v node &> /dev/null; then
	echo "Installing Node.js $VFOX_NODE_VERSION..."
	vfox_install_sdk nodejs "$VFOX_NODE_VERSION"
fi

# Install Go
if ! command -v go &> /dev/null; then
	echo "Installing Go $VFOX_GO_VERSION..."
	vfox_install_sdk golang "$VFOX_GO_VERSION"
fi

# Install LaTeX (optional)
# Note: latexmk comes with MacTeX/BasicTeX distributions
if ! command -v latexmk &> /dev/null; then
    echo "LaTeX tools (latexmk) not found."
    if choice "Install BasicTeX (LaTeX distribution)?"; then
        brew install --cask basictex
        echo "Note: You may need to restart your terminal or run: eval \"\$(/usr/libexec/path_helper)\""
    else
        echo "Skipping LaTeX installation"
    fi
fi

# Create config properties file
touch "$HOME/.zsh_config.properties"

# Create symbolic links
echo "Creating symbolic links..."
touch "$HOME/.zsh_config.properties"

# Ask user to select slim or full configuration
select_config_type

source "$SCRIPT_DIR/bootstrap/common-symlinks.sh"

# Link hammerspoon config (macOS only)
if [ -d "$SCRIPT_DIR/hammerspoon" ]; then
	echo "Linking Hammerspoon config..."
	create_symlink "$SCRIPT_DIR/hammerspoon" "$HOME/.hammerspoon" --override
fi

echo "=== macOS Bootstrap Complete ==="
