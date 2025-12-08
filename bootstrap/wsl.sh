#!/bin/bash
# Windows WSL Bootstrap Script

echo "=== Windows WSL Bootstrap ==="

# WSL-specific configurations
echo "Configuring WSL-specific settings..."
sudo bash "$SCRIPT_DIR/../utils/run_util_function.sh" "append_unique_lines_to_file" "/etc/environment" "export WAYLAND_DISPLAY=wayland-0" "export DISPLAY=:0"

# Required for vimtex neovim plugin
if [ -f "$SCRIPT_DIR/wsl_bash_sysinit" ]; then
	create_symlink "$SCRIPT_DIR/wsl_bash_sysinit" "$HOME/.wsl_bash_sysinit" --override
fi

# Update and upgrade
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install build tools
echo "Installing build-essential..."
install_package_if_not_exists "build-essential"

# Install essential tools
echo "Installing essential packages..."
install_package_if_not_exists "git"
install_package_if_not_exists "curl"
install_package_if_not_exists "wget"
install_package_if_not_exists "unzip"
install_package_if_not_exists "xclip"

# Install Zsh
install_package_if_not_exists "zsh"

# Change default shell to zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
	echo "Changing default shell to zsh..."
	chsh -s "$(which zsh)"
fi

# Install Homebrew for Linux
if ! command -v brew &> /dev/null; then
	echo "Installing Homebrew..."
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# Configure Homebrew environment
	if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		readarray -t LINES_TO_EXPORT <<< "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		sudo bash "$SCRIPT_DIR/../utils/run_util_function.sh" "append_unique_lines_to_file" "/etc/profile" "${LINES_TO_EXPORT[@]}"
	fi
else
	echo "Homebrew is already installed"
	eval "$(brew shellenv)"
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

# Activate vfox
eval "$(vfox activate bash)"

# SDK VERSIONS
JAVA_VERSION="latest"
GRADLE_VERSION="latest"
MAVEN_VERSION="latest"
NODE_VERSION="latest"
GO_VERSION="latest"

echo "Installing SDKs via vfox..."

if ! command -v java &> /dev/null; then
	vfox add java && vfox install "java@$JAVA_VERSION" && vfox use -g java
fi

if ! command -v mvn &> /dev/null; then
	vfox add maven && vfox install "maven@$MAVEN_VERSION" && vfox use -g maven
fi

if ! command -v gradle &> /dev/null; then
	vfox add gradle && vfox install "gradle@$GRADLE_VERSION" && vfox use -g gradle
fi

if ! command -v node &> /dev/null; then
	vfox add nodejs && vfox install "nodejs@$NODE_VERSION" && vfox use -g nodejs
fi

if ! command -v go &> /dev/null; then
	vfox add golang && vfox install "golang@$GO_VERSION" && vfox use -g golang
fi

# Optional: Install LaTeX
if choice "Install LaTeX (latexmk and zathura)?"; then
    install_package_if_not_exists "latexmk"
    install_package_if_not_exists "zathura"
fi

# Create config properties file
touch "$HOME/.zsh_config.properties"

# Create symbolic links
echo "Creating symbolic links..."

# Ask user to select slim or full configuration
select_config_type

source "$SCRIPT_DIR/bootstrap/common-symlinks.sh"

echo "=== WSL Bootstrap Complete ==="
