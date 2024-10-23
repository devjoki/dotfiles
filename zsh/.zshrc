source "$HOME/.config/utils/utils.sh"
source "$HOME/.config/zsh/aliases"

export EZA_CONFIG_DIR="$HOME/.config/eza"

eval "$(starship init zsh)"
eval "$(vfox activate zsh)"
autoload -U compinit; compinit
source "$HOME/.config/zsh/zsh_extensions/fzf-tab/fzf-tab.plugin.zsh"
eval "$(zoxide init zsh --cmd cd)"
# Additinal config that should not be sourceControlled
source_if_exists "$HOME/.config/zsh/zsh_extensions/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source_if_exists "$HOME/.cargo/env"
source_if_exists "$HOME/.config/zsh/work/aliases.sh"
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
