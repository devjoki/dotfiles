#!/bin/bash
# Install zsh extensions

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Installing zsh extensions..."

# Install fzf-tab
if [ ! -d "$SCRIPT_DIR/fzf-tab" ]; then
    echo "Installing fzf-tab..."
    git clone https://github.com/Aloxaf/fzf-tab "$SCRIPT_DIR/fzf-tab"
else
    echo "fzf-tab already installed"
fi

# Install zsh-syntax-highlighting
if [ ! -d "$SCRIPT_DIR/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SCRIPT_DIR/zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting already installed"
fi

echo "Zsh extensions installed successfully!"
