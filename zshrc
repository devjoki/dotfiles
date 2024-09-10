# oh my zsh path
export ZSH="$HOME/.oh-my-zsh"
# theme
ZSH_THEME="steeef"
source "$HOME/.scripts/utils.sh"
# plugins
plugins=(
  aliases
  brew
  copybuffer
  copyfile
  copypath
  docker
  docker-compose
  encode64
  extract
  git
  gitignore
  history
  starship
  sudo
)
#  safe-paste
# Additinal plugins
source_if_exists "$(read_property  "$ZSH_CONFIG_PROPERTIES" "ZSH_EXTRA_PLUGINS")" "true"
# oh my zsh
source "$ZSH/oh-my-zsh.sh"

eval "$(vfox activate zsh)"
# common exports
export ZVM_VI_EDITOR="nvim"
# Additinal config that should not be sourceControlled
source_if_exists "$(read_property  "$ZSH_CONFIG_PROPERTIES" "ZSH_EXTRA_CONFIG")" "true"

if [ -d /proc/version ] && grep -qi microsoft /proc/version && [ -f ~/.wsl_bash_sysinit ]; then
    . ~/.wsl_bash_sysinit
fi
