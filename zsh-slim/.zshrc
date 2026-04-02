source "$HOME/.config/zsh-shared/shared.sh"

source "$HOME/.config/zsh-shared/keybindings.sh"

# Force initial prompt render so Ctrl+C before first command works
(( ${+functions[_omp_precmd]} )) && _omp_precmd
