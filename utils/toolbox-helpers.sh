#!/bin/bash

# Helper functions for working with Fedora toolbox

# Enter the development toolbox
dev() {
    local TOOLBOX_NAME="${1:-dev}"

    # Check if toolbox exists
    if ! toolbox list | grep -q "$TOOLBOX_NAME"; then
        echo "Toolbox '$TOOLBOX_NAME' does not exist."
        if choice "Create it now?"; then
            toolbox create "$TOOLBOX_NAME"
        else
            return 1
        fi
    fi

    # Enter the toolbox
    toolbox enter "$TOOLBOX_NAME"
}

# Run a command in the development toolbox without entering it
dev-run() {
    local TOOLBOX_NAME="dev"
    if [[ "$1" == "-t" ]]; then
        TOOLBOX_NAME="$2"
        shift 2
    fi

    toolbox run -c "$TOOLBOX_NAME" "$@"
}

# Create a new development toolbox
dev-create() {
    local TOOLBOX_NAME="${1:-dev}"
    local FEDORA_VERSION="${2:-latest}"

    if [[ "$FEDORA_VERSION" == "latest" ]]; then
        toolbox create "$TOOLBOX_NAME"
    else
        toolbox create -r "$FEDORA_VERSION" "$TOOLBOX_NAME"
    fi

    echo ""
    echo "Toolbox '$TOOLBOX_NAME' created!"
    echo "Enter it with: toolbox enter $TOOLBOX_NAME"
    echo "Then run the bootstrap script: ./bootstrap-toolbox.sh"
}

# List all toolboxes
dev-list() {
    toolbox list
}

# Remove a toolbox
dev-remove() {
    local TOOLBOX_NAME="${1:-dev}"

    if toolbox list | grep -q "$TOOLBOX_NAME"; then
        echo "This will remove toolbox: $TOOLBOX_NAME"
        if choice "Are you sure?"; then
            toolbox rm "$TOOLBOX_NAME"
            echo "Toolbox '$TOOLBOX_NAME' removed."
        fi
    else
        echo "Toolbox '$TOOLBOX_NAME' does not exist."
    fi
}

# Open a new terminal in the toolbox (if using wezterm)
dev-wezterm() {
    local TOOLBOX_NAME="${1:-dev}"

    if command -v wezterm &> /dev/null; then
        wezterm start --cwd "$HOME" toolbox enter "$TOOLBOX_NAME" &
    else
        echo "Wezterm is not installed"
        return 1
    fi
}

# Source this in your .zshrc to get these helpers
# Add to .zshrc: source ~/.config/utils/toolbox-helpers.sh
