source "$HOME/.config/utils/utils.sh"
source "$HOME/.config/zsh/aliases"

export EZA_CONFIG_DIR="$HOME/.config/eza"

eval "$(starship init zsh)"
autoload -U compinit; compinit

# Additinal config that should not be sourceControlled
source_if_exists "$HOME/.cargo/env"
source_if_exists "$HOME/.config/zsh/work/aliases.sh"

# History
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
