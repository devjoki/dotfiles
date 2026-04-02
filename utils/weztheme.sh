weztheme() {
  local theme_file="$HOME/.config/.theme/wezterm"
  local wez_config="$HOME/.config/wezterm/wezterm.lua"

  if [ -z "$1" ]; then
    if [ -f "$theme_file" ]; then
      echo "Current: $(cat "$theme_file")"
    else
      echo "Current: tokyonight_moon (default)"
    fi
    echo "Usage: weztheme <theme_name>"
    return 0
  fi

  mkdir -p "$HOME/.config/.theme"
  echo "$1" > "$theme_file"
  # Force wezterm config reload by rewriting the file
  local content=$(cat "$wez_config")
  echo "$content" > "$wez_config"
  echo "Theme changed to: $1"
}
