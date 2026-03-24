#!/bin/bash
# Enhanced fzf configuration
# This file provides advanced fzf integration for better file search, history, and git workflows

# ============================================================================
# Core fzf Configuration
# ============================================================================

# Default fzf options - appearance and behavior
export FZF_DEFAULT_OPTS="
  --height 60%
  --layout=reverse
  --border
  --info=inline
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
  --color=fg:#d0d0d0,bg:#121212,hl:#5f87af
  --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
  --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
  --color=marker:#87ff00,spinner:#af5fff,header:#87afaf
  --preview-window=right:60%:wrap
  --bind='ctrl-n:down,ctrl-p:up'
  --bind='ctrl-e:preview-down,ctrl-y:preview-up'
  --bind='shift-down:preview-page-down,shift-up:preview-page-up'
  --bind='ctrl-/:toggle-preview'
  --bind='alt-a:select-all,alt-d:deselect-all'
  --bind='ctrl-space:toggle'
"

# Use fd for faster file search if available, otherwise fall back to find
if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules'
else
    export FZF_CTRL_T_COMMAND="find . -type f -not -path '*/\.git/*' -not -path '*/node_modules/*'"
    export FZF_ALT_C_COMMAND="find . -type d -not -path '*/\.git/*' -not -path '*/node_modules/*'"
fi

# Preview files with bat (syntax highlighting) or cat as fallback
if command -v bat &> /dev/null; then
    export FZF_CTRL_T_OPTS="
      --preview 'bat --style=numbers,changes --color=always --line-range :500 {}'
      --bind 'ctrl-/:toggle-preview'
    "
else
    export FZF_CTRL_T_OPTS="
      --preview 'cat {}'
      --bind 'ctrl-/:toggle-preview'
    "
fi

# Preview directories with eza or ls
if command -v eza &> /dev/null; then
    export FZF_ALT_C_OPTS="
      --preview 'eza --tree --level=2 --color=always --icons {} 2>/dev/null || eza --color=always --icons {}'
      --bind 'ctrl-/:toggle-preview'
    "
else
    export FZF_ALT_C_OPTS="
      --preview 'ls -la {}'
      --bind 'ctrl-/:toggle-preview'
    "
fi

# ============================================================================
# Enhanced History Search (Ctrl+R replacement)
# ============================================================================

fzf-history-widget-enhanced() {
    local selected
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null

    selected=$(fc -rl 1 | awk '{$1="";print substr($0,2)}' |
        fzf --tac --no-sort --exact \
            --query="${LBUFFER}" \
            --preview 'echo {}' \
            --preview-window=down:3:wrap \
            --bind 'ctrl-y:execute-silent(echo -n {+} | pbcopy)+abort' \
            --header '⌃Y: copy | ⌃/: toggle preview | ⏎: execute')

    if [ -n "$selected" ]; then
        BUFFER=$selected
        CURSOR=$#BUFFER
        zle reset-prompt
    fi
}

zle -N fzf-history-widget-enhanced
bindkey '^R' fzf-history-widget-enhanced

# Bind Alt+F to file finder (same as Ctrl+T)
bindkey '\ef' fzf-file-widget

# ============================================================================
# Search File Contents with Ripgrep + fzf
# ============================================================================

# Search for text in files and open in editor
# Usage: fzs <search-term>
fzs() {
    if ! command -v rg &> /dev/null; then
        echo "ripgrep (rg) is required but not installed"
        return 1
    fi

    local search_term="$1"
    local selected

    if [ -z "$search_term" ]; then
        echo "Usage: fzs <search-term>"
        return 1
    fi

    selected=$(rg --color=always --line-number --no-heading --smart-case "$search_term" |
        fzf --ansi \
            --delimiter ':' \
            --preview 'bat --style=numbers,changes --color=always --highlight-line {2} {1}' \
            --preview-window 'right:60%:+{2}-/2' \
            --bind 'enter:become(nvim {1} +{2})')
}

# Interactive ripgrep with live preview
# Usage: frg
frg() {
    if ! command -v rg &> /dev/null; then
        echo "ripgrep (rg) is required but not installed"
        return 1
    fi

    local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    local INITIAL_QUERY="${*:-}"

    : | fzf --ansi --disabled --query "$INITIAL_QUERY" \
        --bind "start:reload:$RG_PREFIX {q}" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'right:60%:+{2}-/2' \
        --bind 'enter:become(nvim {1} +{2})'
}

# ============================================================================
# Git Integration with fzf
# ============================================================================

# Fuzzy find and checkout git branch
# Usage: fgb
fgb() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not a git repository"
        return 1
    fi

    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" |
        fzf --preview 'git log --oneline --color=always $(echo {} | sed "s/.* //" | sed "s#remotes/origin/##")' \
            --header 'Select branch to checkout') &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/origin/##")
}

# Fuzzy find git commits and show details
# Usage: fgc
fgc() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not a git repository"
        return 1
    fi

    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview 'git show --color=always $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1)' \
        --bind 'enter:execute(git show --color=always $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1) | less -R)'
}

# Fuzzy find modified files and open in editor
# Usage: fgf
fgf() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not a git repository"
        return 1
    fi

    local selected
    selected=$(git status --short |
        fzf --preview 'git diff --color=always $(echo {} | awk "{print \$2}")' \
            --header 'Select modified file to edit') &&
    nvim $(echo "$selected" | awk '{print $2}')
}

# ============================================================================
# Process Management with fzf
# ============================================================================

# Fuzzy find and kill process
# Usage: fkill
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf --multi --header 'Select process to kill' | awk '{print $2}')

    if [ -n "$pid" ]; then
        echo "$pid" | xargs kill -"${1:-9}"
    fi
}

# ============================================================================
# Directory Navigation Enhancements
# ============================================================================

# Fuzzy cd into subdirectories (including hidden)
# Usage: fcd
fcd() {
    local dir
    if command -v fd &> /dev/null; then
        dir=$(fd --type d --hidden --follow --exclude .git --exclude node_modules 2> /dev/null | fzf --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || ls -la {}')
    else
        dir=$(find . -type d -not -path '*/\.git/*' -not -path '*/node_modules/*' 2> /dev/null | fzf --preview 'ls -la {}')
    fi

    if [ -n "$dir" ]; then
        cd "$dir" || return
    fi
}

# Widget wrapper for fcd to use with bindkey
fcd-widget() {
    fcd
    zle reset-prompt
}

zle -N fcd-widget
bindkey '\ed' fcd-widget

# ============================================================================
# Load fzf shell integrations
# ============================================================================

# Load key bindings (Ctrl+T, Alt+C, etc.)
if [ -f ~/.fzf/shell/key-bindings.zsh ]; then
    source ~/.fzf/shell/key-bindings.zsh
elif [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
elif [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
fi

# Load completion
if [ -f ~/.fzf/shell/completion.zsh ]; then
    source ~/.fzf/shell/completion.zsh
elif [ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]; then
    source /opt/homebrew/opt/fzf/shell/completion.zsh
elif [ -f /usr/share/fzf/completion.zsh ]; then
    source /usr/share/fzf/completion.zsh
fi
