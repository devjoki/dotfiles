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
# dnf5 uses "group install", older dnf uses "groupinstall"
# In dnf5, the group name changed from "Development Tools" to "development-tools" or "C Development Tools and Libraries"
if dnf --version 2>&1 | grep -q "dnf5"; then
    sudo dnf group install -y "development-tools" || sudo dnf install -y @development-tools || sudo dnf install -y gcc gcc-c++ make
else
    sudo dnf groupinstall -y "Development Tools"
fi
install_app_if_not_exists "vfox" "brew install vfox"
install_app_if_not_exists "lazygit" "brew install jesseduffield/lazygit/lazygit"
install_app_if_not_exists "eza" "brew install eza"
install_app_if_not_exists "zoxide" "brew install zoxide"
install_app_if_not_exists "mcfly" "brew install mcfly"

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

install_package_if_not_exists "latexmk"

touch "$HOME/.zsh_config.properties"
export NVIM_CONFIG="nvim-full"
export ZSH_CONFIG="zsh-full"
source "$SCRIPT_DIR/bootstrap/common-symlinks.sh"

echo "=== Fedora Bootstrap Complete ==="
