-- Shared Neovim configuration
-- This file is sourced by both nvim (full) and nvim-slim configs

-- Get the path to nvim-shared directory
local config_path = vim.fn.stdpath("config")

-- Resolve symlinks to get the real path, then get parent directory
local config_real = vim.loop.fs_realpath(config_path) or config_path
local config_parent = vim.fn.fnamemodify(config_real, ":h")
local shared_path = config_parent .. "/nvim-shared"

-- Add nvim-shared to Lua package path so modules can be required
package.path = shared_path .. "/?.lua;" .. package.path

-- Helper to source a shared file
local function source_shared(filename)
  local filepath = shared_path .. "/" .. filename
  if vim.fn.filereadable(filepath) == 1 then
    dofile(filepath)
  else
    vim.notify("Shared config not found: " .. filepath, vim.log.levels.WARN)
  end
end

-- Load shared configurations in order
source_shared("options.lua")
source_shared("keymaps.lua")
source_shared("autocmds.lua")
-- colorscheme.lua commented out - using plugin-based colorschemes instead
-- source_shared("colorscheme.lua")

-- Return module for optional direct require
return {
  source_shared = source_shared,
  shared_path = shared_path,
}
