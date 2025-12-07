#!/bin/bash
# Neovim wrapper scripts for dual config setup

# nvim-slim: Lightweight config (no LSP) - for host
nv() {
    NVIM_APPNAME=nvim-slim nvim "$@"
}

# nvim-dev: Full config (with LSP) - for toolbox
nvd() {
    NVIM_APPNAME=nvim nvim "$@"
}

# Default nvim based on environment
# If in toolbox, use full config
# If on host, use slim config
nvi() {
    if [ -n "$TOOLBOX_PATH" ]; then
        # In toolbox - use full config
        NVIM_APPNAME=nvim nvim "$@"
    else
        # On host - use slim config
        NVIM_APPNAME=nvim-slim nvim "$@"
    fi
}

# Export functions so they're available in shell
export -f nv nvd nvi 2>/dev/null || true
