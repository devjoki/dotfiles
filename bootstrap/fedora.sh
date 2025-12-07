#!/bin/bash
# Fedora Bootstrap Script (all-in-one)

echo "=== Fedora Bootstrap ==="

sudo dnf update -y

# Install essential tools
sudo dnf install -y git curl wget unzip zsh util-linux-user

# Change shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
	chsh -s "$(which zsh)"
fi


# Install starship
if ! command -v starship &> /dev/null; then
	curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install neovim and wezterm
if ! command -v wezterm &> /dev/null; then
	sudo dnf copr enable wezfurlong/wezterm-nightly -y
	sudo dnf install -y wezterm
fi

# Install Homebrew
if ! command -v brew &> /dev/null; then
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Dev tools
sudo dnf groupinstall -y "Development Tools"
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

install_package_if_not_exists "latexmk"

touch "$HOME/.zsh_config.properties"
export NVIM_CONFIG="nvim-full"
source "$SCRIPT_DIR/bootstrap/common-symlinks.sh"

echo "=== Fedora Bootstrap Complete ==="
