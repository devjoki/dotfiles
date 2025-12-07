#!/bin/bash
# Arch Linux Bootstrap Script

echo "=== Arch Linux Bootstrap ==="

sudo pacman -Syu --noconfirm

# Install essential tools
sudo pacman -S --noconfirm git curl wget unzip zsh base-devel

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

# Install Homebrew
if ! command -v brew &> /dev/null; then
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Dev tools
install_app_if_not_exists "vfox" "brew install vfox"
install_app_if_not_exists "lazygit" "brew install jesseduffield/lazygit/lazygit"

# Rust
if ! command -v rustup &> /dev/null; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source "$HOME/.cargo/env"
	rustup install stable
fi

# SDKs
eval "$(vfox activate bash)"
JAVA_VERSION="17-open"
GRADLE_VERSION="8.7"
MAVEN_VERSION="3.9.6"
NODE_VERSION="latest"

[ ! -x "$(command -v java)" ] && vfox add java && vfox install "java@$JAVA_VERSION" && vfox use -g java
[ ! -x "$(command -v mvn)" ] && vfox add maven && vfox install "maven@$MAVEN_VERSION" && vfox use -g maven
[ ! -x "$(command -v gradle)" ] && vfox add gradle && vfox install "gradle@$GRADLE_VERSION" && vfox use -g gradle
[ ! -x "$(command -v node)" ] && vfox add nodejs && vfox install "nodejs@$NODE_VERSION" && vfox use -g nodejs

sudo pacman -S --noconfirm texlive-most zathura

touch "$HOME/.zsh_config.properties"
export NVIM_CONFIG="nvim-full"
export ZSH_CONFIG="zsh-full"
source "$SCRIPT_DIR/bootstrap/common-symlinks.sh"

echo "=== Arch Bootstrap Complete ==="
