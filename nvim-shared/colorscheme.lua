-- Basic colorscheme without plugins
-- This works without any plugin manager

-- Set termguicolors for better colors
vim.opt.termguicolors = true

-- Try to use a good built-in colorscheme
-- These are available without plugins
local colorscheme = "habamax" -- or "slate", "desert", "evening", "murphy"

local status_ok, _ = pcall(vim.cmd.colorscheme, colorscheme)
if not status_ok then
  vim.notify("Colorscheme " .. colorscheme .. " not found! Using default.", vim.log.levels.WARN)
  return
end

-- Optional: Set some highlights manually for better experience
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
