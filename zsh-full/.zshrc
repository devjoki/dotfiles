# Add ~/.local/bin to PATH (for zoxide, starship, vfox, etc.)
export PATH="$HOME/.local/bin:$PATH"

source "$HOME/.config/utils/utils.sh"
source "$HOME/.config/zsh/aliases"

export EZA_CONFIG_DIR="$HOME/.config/eza"

# Initialize tools (check if they exist first to avoid errors)
command -v starship &> /dev/null && eval "$(starship init zsh)"
command -v vfox &> /dev/null && eval "$(vfox activate zsh)"
command -v mcfly &> /dev/null && eval "$(mcfly init zsh)"
autoload -U compinit; compinit

# fzf-tab configuration (must be before loading the plugin)
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

source "$HOME/.config/zsh-shared/zsh_extensions/fzf-tab/fzf-tab.plugin.zsh"
command -v zoxide &> /dev/null && eval "$(zoxide init zsh --cmd cd)"
# Additinal config that should not be sourceControlled
source_if_exists "$HOME/.config/zsh-shared/zsh_extensions/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source_if_exists "$HOME/.cargo/env"
source_if_exists "$HOME/.config/zsh-shared/work/aliases.sh"
# History
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

if [ -d /proc/version ] && grep -qi microsoft /proc/version && [ -f ~/.wsl_bash_sysinit ]; then
    . ~/.wsl_bash_sysinit
fi
