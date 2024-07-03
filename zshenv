# load utils
source "$HOME/.scripts/utils.sh"
export ZSH_CONFIG_PROPERTIES="$HOME/.zsh_config.properties"
#load extra env
source_if_exists $(read_property  "$ZSH_CONFIG_PROPERTIES" "ZSH_EXTRA_ENV") "true"
source_if_exists "$HOME/.cargo/env"
# common aliases
alias lvim="NVIM_APPNAME=nvim-lazy nvim"
alias nvo='nvim_at'
alias notes='nvim_at "$HOME/notes/"'
