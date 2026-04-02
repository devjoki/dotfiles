source "$HOME/.config/zsh-shared/shared.sh"

# vfox
command -v vfox &> /dev/null && eval "$(vfox activate zsh)"

# fzf-tab (must be after compinit)
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
source "$HOME/.config/zsh-shared/zsh_extensions/fzf-tab/fzf-tab.plugin.zsh"

# fzf config
source_if_exists "$HOME/.config/zsh-shared/fzf-config.sh"

# Syntax highlighting
source_if_exists "$HOME/.config/zsh-shared/zsh_extensions/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Restore prefix history search (fzf key-bindings overrides these)
source "$HOME/.config/zsh-shared/keybindings.sh"

# Force initial prompt render so Ctrl+C before first command works
(( ${+functions[_omp_precmd]} )) && _omp_precmd

# WSL support
if [ -d /proc/version ] && grep -qi microsoft /proc/version && [ -f ~/.wsl_bash_sysinit ]; then
    . ~/.wsl_bash_sysinit
fi
