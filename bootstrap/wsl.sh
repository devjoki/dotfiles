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
install_package_if_not_exists "libatomic1"

# Install Zsh
install_package_if_not_exists "zsh"

# Change default shell to zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
	echo "Changing default shell to zsh..."
	chsh -s "$(which zsh)"
fi

# Install development tools
echo "Installing development tools..."

# Install neovim
if ! command -v nvim &> /dev/null; then
	echo "Installing neovim..."
	sudo add-apt-repository ppa:neovim-ppa/unstable -y
	sudo apt-get update
	sudo apt-get install -y neovim
fi

# Install starship
if ! command -v starship &> /dev/null; then
	echo "Installing starship..."
	curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install vfox
if ! command -v vfox &> /dev/null; then
	echo "Installing vfox..."
	curl -sSL https://raw.githubusercontent.com/version-fox/vfox/main/install.sh | bash
fi

# Install lazygit
if ! command -v lazygit &> /dev/null; then
	echo "Installing lazygit..."
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
	sudo install /tmp/lazygit /usr/local/bin
	rm /tmp/lazygit.tar.gz /tmp/lazygit
fi

# Install eza
if ! command -v eza &> /dev/null; then
	echo "Installing eza..."
	sudo mkdir -p /etc/apt/keyrings
	wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
	echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
	sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
	sudo apt-get update
	sudo apt-get install -y eza
fi

# Install zoxide
if ! command -v zoxide &> /dev/null; then
	echo "Installing zoxide..."
	curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Install mcfly
if ! command -v mcfly &> /dev/null; then
	echo "Installing mcfly..."
	curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly
fi

# Install fzf
if ! command -v fzf &> /dev/null; then
	echo "Installing fzf..."
	if [ ! -d ~/.fzf ]; then
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	fi
	~/.fzf/install --bin
fi

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
	vfox add java
	vfox install "java@$JAVA_VERSION"
	vfox use -g "java@$JAVA_VERSION"
fi

if ! command -v mvn &> /dev/null; then
	vfox add maven
	vfox install "maven@$MAVEN_VERSION"
	vfox use -g "maven@$MAVEN_VERSION"
fi

if ! command -v gradle &> /dev/null; then
	vfox add gradle
	vfox install "gradle@$GRADLE_VERSION"
	vfox use -g "gradle@$GRADLE_VERSION"
fi

if ! command -v node &> /dev/null; then
	vfox add nodejs
	vfox install "nodejs@$NODE_VERSION"
	vfox use -g "nodejs@$NODE_VERSION"
fi

if ! command -v go &> /dev/null; then
	vfox add golang
	vfox install "golang@$GO_VERSION"
	vfox use -g "golang@$GO_VERSION"
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
