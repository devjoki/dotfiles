-- Shared plugins initialization
-- This file loads all shared plugins for both nvim-full and nvim-slim

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Get the shared plugins directory
local config_home = vim.fn.stdpath("config")

-- Resolve symlinks to get the real path, then get parent directory
local config_real = vim.loop.fs_realpath(config_home) or config_home
local config_parent = vim.fn.fnamemodify(config_real, ":h")
local shared_path = config_parent .. "/nvim-shared"

-- Load shared plugins
local shared_plugins = {}

-- Dynamically load all shared plugin files
local shared_plugins_path = shared_path .. "/plugins"
if vim.fn.isdirectory(shared_plugins_path) == 1 then
  for _, file in ipairs(vim.fn.readdir(shared_plugins_path)) do
    if file:match("%.lua$") then
      local module_name = file:gsub("%.lua$", "")
      -- Load the shared plugin file directly
      local plugin_file = shared_plugins_path .. "/" .. file
      local ok, plugin_config = pcall(dofile, plugin_file)
      if ok and type(plugin_config) == "table" then
        for _, plugin in ipairs(plugin_config) do
          table.insert(shared_plugins, plugin)
        end
      end
    end
  end
end

return shared_plugins
