#!/bin/bash
execute_if_dir_not_exists() {
	TARGET="$1"
	CMD="$2"
	if [ -e "$TARGET" ]; then
		echo "$TARGET already exists!"
	else
		echo "Creating directory: '$TARGET'..."
		eval "$CMD" 2>&1 | sed "s/^/    /"
	fi
}
install_oh_my_zsh() {
	execute_if_dir_not_exists "$HOME/.oh-my-zsh" "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash"
	execute_if_dir_not_exists "$HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode" "git clone https://github.com/jeffreytse/zsh-vi-mode $HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode"
}

WSL="$1"
if [[ -n "$WSL" && "$WSL" != "--not-wsl" && "$WSL" != "-nw" ]]; then
	>&2 echo "Invalid flag it must be either empty or \"-nw\"/\"--no-wsl\""
	return 1
fi
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#shellcheck disable=SC1091
source "$SCRIPT_DIR/utils.sh"
set -e
if [[ -z "$WSL" ]]; then
	sudo bash "$SCRIPT_DIR/run_util_function.sh" "append_unique_lines_to_file" "/etc/environment" "export WAYLAND_DISPLAY=wayland-0" "export DISPLAY=:0"
fi
sudo apt-get update
sudo apt-get upgrade
install_package_if_not_exists "build-essential"
sudo curl -fsSL "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" | bash
readarray -t LINES_TO_EXPORT <<< "$(eval /home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo bash "$SCRIPT_DIR/run_util_function.sh" "append_unique_lines_to_file" "/etc/profile" "${LINES_TO_EXPORT[@]}"
for EXPORT in "${LINES_TO_EXPORT[@]}"; do
	eval "$EXPORT"
done
#install dependencies
install_package_if_not_exists "zsh"
chsh -s "$(which zsh)"
touch "$HOME/.zsh_config.properties"
install_package_if_not_exists "unzip"
install_oh_my_zsh
install_app_if_not_exists "nvim" "brew install nvim"
install_app_if_not_exists "starship" "brew install starship"
install_app_if_not_exists "vfox" "brew install vfox" 
install_app_if_not_exists "rustup" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" "rustup install stable"
install_app_if_not_exists "lazygit" "brew install jesseduffield/lazygit/lazygit"
eval "$(vfox activate bash)"
# SDK VERSIONS
JAVA_VERSION="17-open"
GRADLE_VERSION="8.7"
MAVEN_VERSION="3.9.6"
NODE_VERSION=latest
# INSTALL SDKs
install_app_if_not_exists "java" "vfox add java" "vfox install java@$JAVA_VERSION" "vfox use -g java"
install_app_if_not_exists "mvn" "vfox add maven" "vfox install maven@$MAVEN_VERSION" "vfox use -g maven"
install_app_if_not_exists "gradle" "vfox add gradle" "vfox install gradle@$GRADLE_VERSION" "vfox use -g gradle"
install_app_if_not_exists "node" "vfox add nodejs" "vfox install nodejs@$NODE_VERSION" "vfox use -g nodejs"

#create symbolic links
create_symlink "$SCRIPT_DIR/zshrc" "$HOME/.zshrc" --override
create_symlink "$SCRIPT_DIR/zshenv" "$HOME/.zshenv" --override
create_symlink "$SCRIPT_DIR/utils.sh" "$HOME/.scripts/utils.sh" --override
create_symlink "$SCRIPT_DIR/run_util_function.sh" "$HOME/.scripts/run_util_function.sh" --override
create_symlink "$SCRIPT_DIR/ideavimrc" "$HOME/.ideavimrc" --override
create_symlink "$SCRIPT_DIR/nvim-joco" "$HOME/.config/nvim" --override
create_symlink "$SCRIPT_DIR/nvim-lazy" "$HOME/.config/nvim-lazy" --override
