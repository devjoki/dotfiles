# load utils
source "$HOME/.scripts/utils.sh"
#load extra env
source_if_exists "$HOME/.zshenv.extra"
source_if_exists "$HOME/.cargo/env"
# common aliases
alias lvim="NVIM_APPNAME=nvim-lazy nvim"
