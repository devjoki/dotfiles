local M = {}
local wezterm = require("wezterm")

-- Load custom color schemes
local kanagawa_lotus = require("colorschemes.kanagawa-lotus")

-- Register custom color schemes with WezTerm (just the color palettes)
M.custom_schemes = {
  ["Kanagawa Lotus"] = kanagawa_lotus.colors,
}

-- Export tabline colors for custom schemes
M.custom_tabline_colors = {
  ["Kanagawa Lotus"] = kanagawa_lotus.tabline_colors,
}

-- Centralized color scheme configuration
-- Change this to update both WezTerm terminal and tabline theme
M.scheme = "tokyonight_moon"

return M
