#!/bin/bash
# Arch Linux Bootstrap Script

echo "=== Arch Linux Bootstrap ==="

sudo pacman -Syu --noconfirm

# Install essential tools
sudo pacman -S --noconfirm git curl wget unzip zsh base-devel gcc-libs

# Change shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
	chsh -s "$(which zsh)"
fi


# Install from official repos
sudo pacman -S --noconfirm neovim

# Install starship
if ! command -v starship &> /dev/null; then
	curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install wezterm (from AUR - requires yay or manual)
if ! command -v wezterm &> /dev/null; then
	if command -v yay &> /dev/null; then
		yay -S --noconfirm wezterm
	else
		echo_warn "wezterm not installed - install manually or use yay"
	fi
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
	EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
	curl -Lo /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz"
	sudo tar -xzf /tmp/eza.tar.gz -C /usr/local/bin
	rm /tmp/eza.tar.gz
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

# Rust
if ! command -v rustup &> /dev/null; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source "$HOME/.cargo/env"
	rustup install stable
fi

# SDKs
eval "$(vfox activate bash)"
JAVA_VERSION="latest"
GRADLE_VERSION="latest"
MAVEN_VERSION="latest"
NODE_VERSION="latest"
GO_VERSION="latest"

[ ! -x "$(command -v java)" ] && vfox add java && vfox install "java@$JAVA_VERSION" && vfox use -g java
[ ! -x "$(command -v mvn)" ] && vfox add maven && vfox install "maven@$MAVEN_VERSION" && vfox use -g maven
[ ! -x "$(command -v gradle)" ] && vfox add gradle && vfox install "gradle@$GRADLE_VERSION" && vfox use -g gradle
[ ! -x "$(command -v node)" ] && vfox add nodejs && vfox install "nodejs@$NODE_VERSION" && vfox use -g nodejs
[ ! -x "$(command -v go)" ] && vfox add golang && vfox install "golang@$GO_VERSION" && vfox use -g golang

# Optional: Install LaTeX
if choice "Install LaTeX (texlive-most and zathura)?"; then
    sudo pacman -S --noconfirm texlive-most zathura
fi

touch "$HOME/.zsh_config.properties"

# Ask user to select slim or full configuration
select_config_type

source "$SCRIPT_DIR/bootstrap/common-symlinks.sh"

echo "=== Arch Bootstrap Complete ==="
