#!/bin/bash
# Windows WSL Bootstrap Script

echo "=== Windows WSL Bootstrap ==="



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
install_package_if_not_exists "libatomic1"

install_package_if_not_exists "wl-clipboard"

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

# Install oh-my-posh
if ! command -v oh-my-posh &> /dev/null; then
	echo "Installing oh-my-posh..."
	curl -s https://ohmyposh.dev/install.sh | bash -s
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
	LAZYGIT_ARCH=$(uname -m)
	case "$LAZYGIT_ARCH" in
		x86_64) LAZYGIT_ARCH="x86_64" ;;
		aarch64) LAZYGIT_ARCH="arm64" ;;
	esac
	curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
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

# Install fzf
if ! command -v fzf &> /dev/null; then
	echo "Installing fzf..."
	if [ ! -d ~/.fzf ]; then
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	fi
	~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# Install fd (faster alternative to find, used by Telescope)
if ! command -v fd &> /dev/null; then
	echo "Installing fd..."
	FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
	curl -Lo /tmp/fd.deb "https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd_${FD_VERSION#v}_amd64.deb"
	sudo dpkg -i /tmp/fd.deb
	rm /tmp/fd.deb
fi

# Install bat (cat with syntax highlighting)
if ! command -v bat &> /dev/null; then
	echo "Installing bat..."
	BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
	curl -Lo /tmp/bat.deb "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat_${BAT_VERSION#v}_amd64.deb"
	sudo dpkg -i /tmp/bat.deb
	rm /tmp/bat.deb
fi

# Install ripgrep (faster grep, used by Telescope)
if ! command -v rg &> /dev/null; then
	echo "Installing ripgrep..."
	RG_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
	curl -Lo /tmp/ripgrep.deb "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION#v}_amd64.deb"
	sudo dpkg -i /tmp/ripgrep.deb
	rm /tmp/ripgrep.deb
fi

# Install Rust
if ! command -v rustup &> /dev/null; then
	echo "Installing Rust..."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source "$HOME/.cargo/env"
fi

# Activate vfox
eval "$(vfox activate bash)"

echo "Installing SDKs via vfox..."

if ! command -v java &> /dev/null; then
	vfox_install_sdk java "$VFOX_JAVA_VERSION"
fi

if ! command -v mvn &> /dev/null; then
	vfox_install_sdk maven "$VFOX_MAVEN_VERSION"
fi

if ! command -v gradle &> /dev/null; then
	vfox_install_sdk gradle "$VFOX_GRADLE_VERSION"
fi

if ! command -v node &> /dev/null; then
	vfox_install_sdk nodejs "$VFOX_NODE_VERSION"
fi

if ! command -v go &> /dev/null; then
	vfox_install_sdk golang "$VFOX_GO_VERSION"
fi

# Optional: Install Python
if choice "Install Python $VFOX_PYTHON_VERSION?"; then
    vfox_install_sdk python "$VFOX_PYTHON_VERSION"
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
