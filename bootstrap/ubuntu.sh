#!/bin/bash
# Ubuntu/Debian Bootstrap Script

echo "=== Ubuntu/Debian Bootstrap ==="

# Update and upgrade
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install build tools
install_package_if_not_exists "build-essential"

# Install essential tools
install_package_if_not_exists "git"
install_package_if_not_exists "curl"
install_package_if_not_exists "wget"
install_package_if_not_exists "unzip"
install_package_if_not_exists "zsh"

# Change shell to zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
	chsh -s "$(which zsh)"
fi

# Install Homebrew
if ! command -v brew &> /dev/null; then
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Install tools via brew
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

[ ! -x "$(command -v java)" ] && vfox add java && vfox install "java@$JAVA_VERSION" && vfox use -g java
[ ! -x "$(command -v mvn)" ] && vfox add maven && vfox install "maven@$MAVEN_VERSION" && vfox use -g maven
[ ! -x "$(command -v gradle)" ] && vfox add gradle && vfox install "gradle@$GRADLE_VERSION" && vfox use -g gradle
[ ! -x "$(command -v node)" ] && vfox add nodejs && vfox install "nodejs@$NODE_VERSION" && vfox use -g nodejs
[ ! -x "$(command -v go)" ] && vfox add golang && vfox install "golang@$GO_VERSION" && vfox use -g golang

install_package_if_not_exists "latexmk"
install_package_if_not_exists "zathura"

touch "$HOME/.zsh_config.properties"
export NVIM_CONFIG="nvim-full"
export ZSH_CONFIG="zsh-full"
source "$SCRIPT_DIR/bootstrap/common-symlinks.sh"

echo "=== Ubuntu Bootstrap Complete ==="
