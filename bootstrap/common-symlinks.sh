#!/bin/bash
# Common symlink creation logic used by all platform bootstrap scripts

if [ -f "$SCRIPT_DIR/zsh/.zshrc" ]; then
	create_symlink "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc" --override
elif [ -f "$SCRIPT_DIR/zshrc" ]; then
	create_symlink "$SCRIPT_DIR/zshrc" "$HOME/.zshrc" --override
fi

if [ -f "$SCRIPT_DIR/zsh/.zshenv" ]; then
	create_symlink "$SCRIPT_DIR/zsh/.zshenv" "$HOME/.zshenv" --override
elif [ -f "$SCRIPT_DIR/zshenv" ]; then
	create_symlink "$SCRIPT_DIR/zshenv" "$HOME/.zshenv" --override
fi

create_symlink "$SCRIPT_DIR/utils/utils.sh" "$HOME/.scripts/utils.sh" --override
create_symlink "$SCRIPT_DIR/utils/run_util_function.sh" "$HOME/.scripts/run_util_function.sh" --override

if [ -f "$SCRIPT_DIR/ideavimrc" ]; then
	create_symlink "$SCRIPT_DIR/ideavimrc" "$HOME/.ideavimrc" --override
fi

# Link nvim config based on NVIM_CONFIG variable
# NVIM_CONFIG should be set by the calling bootstrap script to either "nvim-full" or "nvim-slim"
# Default to nvim-full if not set
NVIM_CONFIG=${NVIM_CONFIG:-"nvim-full"}

if [ -d "$SCRIPT_DIR/$NVIM_CONFIG" ] && [ "$SCRIPT_DIR/$NVIM_CONFIG" != "$HOME/.config/nvim" ]; then
	echo "Linking $NVIM_CONFIG to ~/.config/nvim"
	create_symlink "$SCRIPT_DIR/$NVIM_CONFIG" "$HOME/.config/nvim" --override
else
	echo "Nvim config already in place at $HOME/.config/nvim"
fi

# Always link nvim-shared (required by both nvim-full and nvim-slim)
if [ -d "$SCRIPT_DIR/nvim-shared" ] && [ "$SCRIPT_DIR/nvim-shared" != "$HOME/.config/nvim-shared" ]; then
	create_symlink "$SCRIPT_DIR/nvim-shared" "$HOME/.config/nvim-shared" --override
else
	echo "Nvim-shared already in place at $HOME/.config/nvim-shared"
fi

# Skip starship.toml if it's already in the right place
if [ -f "$SCRIPT_DIR/starship.toml" ] && [ "$SCRIPT_DIR/starship.toml" != "$HOME/.config/starship.toml" ]; then
	create_symlink "$SCRIPT_DIR/starship.toml" "$HOME/.config/starship.toml" --override
else
	echo "Starship config already in place at $HOME/.config/starship.toml"
fi

# Link wezterm config if needed
if [ -d "$SCRIPT_DIR/wezterm" ] && [ "$SCRIPT_DIR/wezterm" != "$HOME/.config/wezterm" ]; then
	create_symlink "$SCRIPT_DIR/wezterm" "$HOME/.config/wezterm" --override
else
	echo "Wezterm config already in place at $HOME/.config/wezterm"
fi

if [ -f "$SCRIPT_DIR/wezterm.lua" ]; then
	create_symlink "$SCRIPT_DIR/wezterm.lua" "$HOME/.wezterm.lua" --override
fi

# Link git config
if [ -d "$SCRIPT_DIR/git" ]; then
	create_symlink "$SCRIPT_DIR/git" "$HOME/.config/git" --override
fi

# Link lazygit config
if [ -d "$SCRIPT_DIR/lazygit" ]; then
	create_symlink "$SCRIPT_DIR/lazygit" "$HOME/.config/lazygit" --override
fi

# Link eza config
if [ -d "$SCRIPT_DIR/eza" ]; then
	create_symlink "$SCRIPT_DIR/eza" "$HOME/.config/eza" --override
fi

# Link ghostty config
if [ -d "$SCRIPT_DIR/ghostty" ]; then
	create_symlink "$SCRIPT_DIR/ghostty" "$HOME/.config/ghostty" --override
fi

# Link gtk-2.0 config (Linux only)
if [ -d "$SCRIPT_DIR/gtk-2.0" ]; then
	create_symlink "$SCRIPT_DIR/gtk-2.0" "$HOME/.config/gtk-2.0" --override
fi

# Link ideavim config directory
if [ -d "$SCRIPT_DIR/ideavim" ]; then
	create_symlink "$SCRIPT_DIR/ideavim" "$HOME/.config/ideavim" --override
fi
