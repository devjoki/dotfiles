-- nvim-full: Full Neovim config with LSP/plugins/debugger
-- Loads shared configuration from nvim-shared

-- Load shared configuration first
local config_home = vim.fn.stdpath("config")

-- Resolve symlinks to get the real path, then get parent directory
local config_real = vim.loop.fs_realpath(config_home) or config_home
local config_parent = vim.fn.fnamemodify(config_real, ":h")

local shared_init = config_parent .. "/nvim-shared/init-shared.lua"

if vim.fn.filereadable(shared_init) == 1 then
  dofile(shared_init)
else
  vim.notify("Shared config not found at: " .. shared_init, vim.log.levels.ERROR)
  vim.notify("Make sure ~/.config/nvim-shared/ exists", vim.log.levels.ERROR)
end

-- Load full config specific modules
require 'utils'
pcall(require, 'config.work_keymaps')
require 'config.plugins'
require 'config.health'
