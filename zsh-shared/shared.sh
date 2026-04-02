# Shared zsh config - sourced by both zsh-full and zsh-slim

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Utils and aliases
source "$HOME/.config/utils/utils.sh"
source "$HOME/.config/utils/weztheme.sh"
source "$HOME/.config/zsh/aliases"

# Environment
export EDITOR=nvim
export EZA_CONFIG_DIR="$HOME/.config/eza"

# Completions
autoload -U compinit; compinit

# Zoxide
command -v zoxide &> /dev/null && eval "$(zoxide init zsh --cmd cd)"

# Additional config that should not be source controlled
source_if_exists "$HOME/.cargo/env"
source_if_exists "$HOME/.config/zsh-shared/work/aliases.sh"
source_if_exists "$HOME/.config/zsh-shared/work/tools.sh"

# History
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# Vi mode
bindkey -v
export KEYTIMEOUT=5

# Cursor shape + vi mode env for Oh My Posh
zle-keymap-select() {
  if [[ $KEYMAP == vicmd ]] || [[ $1 == block ]]; then
    echo -ne '\e[2 q'
    export SHELL_VI_MODE=NORMAL
  else
    echo -ne '\e[6 q'
    export SHELL_VI_MODE=INSERT
  fi
  eval "$(_omp_get_prompt primary --eval)"
  zle reset-prompt
}
zle -N zle-keymap-select
export SHELL_VI_MODE=INSERT
echo -ne '\e[6 q'

# Prompt (after vi mode to avoid keymap reset)
command -v oh-my-posh &> /dev/null && eval "$(oh-my-posh init zsh --config $HOME/.config/omp_themes/custom.omp.json)"
