-- Colorscheme persistence - loads before plugins
local M = {}

-- Path to store the selected colorscheme
M.colorscheme_file = vim.fn.stdpath('data') .. '/colorscheme.txt'
M.default_scheme = 'tokyonight-moon'
M.wezterm_colorscheme_config = vim.fn.expand('~/.config/wezterm/colorscheme.lua')

-- Mapping between Neovim and WezTerm colorscheme names
M.colorscheme_map = {
  ['tokyonight'] = 'tokyonight',
  ['tokyonight-night'] = 'tokyonight_night',
  ['tokyonight-storm'] = 'tokyonight_storm',
  ['tokyonight-moon'] = 'tokyonight_moon',
  ['tokyonight-day'] = 'tokyonight_day',
  ['catppuccin'] = 'catppuccin-mocha',
  ['catppuccin-mocha'] = 'catppuccin-mocha',
  ['catppuccin-frappe'] = 'catppuccin-frappe',
  ['catppuccin-macchiato'] = 'catppuccin-macchiato',
  ['catppuccin-latte'] = 'catppuccin-latte',
  ['kanagawa'] = 'Kanagawa (Gogh)',
  ['kanagawa-wave'] = 'Kanagawa (Gogh)',
  ['kanagawa-dragon'] = 'Kanagawa Dragon (Gogh)',
  ['kanagawa-lotus'] = 'Kanagawa Lotus',  -- Custom light theme
  ['rose-pine'] = 'rose-pine',
  ['rose-pine-main'] = 'rose-pine',
  ['rose-pine-moon'] = 'rose-pine-moon',
  ['rose-pine-dawn'] = 'rose-pine-dawn',
  ['gruvbox'] = 'GruvboxDark',
}


-- Function to update WezTerm colorscheme
function M.update_wezterm_colorscheme(scheme)
  -- Check if colorscheme has a WezTerm mapping
  local wezterm_scheme = M.colorscheme_map[scheme]
  if not wezterm_scheme then
    vim.notify('Colorscheme "' .. scheme .. '" not found in WezTerm mapping', vim.log.levels.WARN)
    return false
  end

  -- Read the current WezTerm colorscheme config
  local file = io.open(M.wezterm_colorscheme_config, 'r')
  if not file then
    vim.notify('Could not open WezTerm colorscheme config', vim.log.levels.WARN)
    return false
  end

  local content = file:read('*all')
  file:close()

  -- Replace the scheme line in colorscheme.lua
  local new_content = content:gsub(
    '(M%.scheme%s*=%s*")[^"]*(")',
    '%1' .. wezterm_scheme .. '%2'
  )

  -- Write back the updated config
  file = io.open(M.wezterm_colorscheme_config, 'w')
  if not file then
    vim.notify('Could not write WezTerm colorscheme config', vim.log.levels.WARN)
    return false
  end

  file:write(new_content)
  file:close()

  return true
end

-- Function to save colorscheme preference
function M.save_colorscheme(scheme)
  -- Save to Neovim persistence file
  local file = io.open(M.colorscheme_file, 'w')
  if file then
    file:write(scheme)
    file:close()
  else
    vim.notify('Failed to save colorscheme', vim.log.levels.ERROR)
    return
  end

  -- Update WezTerm config
  local wezterm_updated = M.update_wezterm_colorscheme(scheme)

  if wezterm_updated then
    vim.notify('Saved colorscheme: ' .. scheme .. ' (synced to WezTerm)', vim.log.levels.INFO)
  else
    vim.notify('Saved colorscheme: ' .. scheme .. ' (sync failed)', vim.log.levels.WARN)
  end
end

-- Function to load saved colorscheme
function M.load_saved_colorscheme()
  local file = io.open(M.colorscheme_file, 'r')
  if file then
    local scheme = file:read('*all'):gsub('%s+', '') -- Remove whitespace
    file:close()
    if scheme and scheme ~= '' then
      return scheme
    end
  end
  return M.default_scheme
end

-- Apply saved colorscheme (call this after plugins load)
function M.apply_saved_scheme()
  local saved_scheme = M.load_saved_colorscheme()
  local ok, err = pcall(vim.cmd.colorscheme, saved_scheme)
  if not ok then
    vim.notify('Failed to load colorscheme: ' .. saved_scheme, vim.log.levels.WARN)
    pcall(vim.cmd.colorscheme, M.default_scheme)
  end
end

-- Setup autocmd to save colorscheme when changed
function M.setup_autocmd()
  vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
      if vim.g.colors_name then
        M.save_colorscheme(vim.g.colors_name)
      end
    end,
  })
end

return M
