local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end

vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- Load shared plugins first
local config_home = vim.fn.stdpath("config")

-- Resolve symlinks to get the real path, then get parent directory
local config_real = vim.loop.fs_realpath(config_home) or config_home
local config_parent = vim.fn.fnamemodify(config_real, ":h")

local shared_plugins_init = config_parent .. "/nvim-shared/plugins-init.lua"
local shared_plugins_spec = {}

if vim.fn.filereadable(shared_plugins_init) == 1 then
  local shared_plugins = dofile(shared_plugins_init)
  -- Add shared plugins to spec
  for _, plugin in ipairs(shared_plugins) do
    table.insert(shared_plugins_spec, plugin)
  end
end

-- Setup lazy with both shared and full plugins
-- Merge shared plugins with full-specific plugins
local full_spec = {
  { import = 'plugins.ai' },
  { import = 'plugins.completion' },
  { import = 'plugins.editing' },
  { import = 'plugins.lsp' },
  { import = 'plugins.navigation' },
  { import = 'plugins.source-control' },
  { import = 'plugins.ui' },
}

-- Combine shared and full specs
for _, plugin in ipairs(shared_plugins_spec) do
  table.insert(full_spec, plugin)
end

require('lazy').setup({
  spec = full_spec,
  -- defaults = {
  --   -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
  --   -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
  --   lazy = false,
  --   -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
  --   -- have outdated releases, which may break your Neovim install.
  --   version = false, -- always use the latest git commit
  --   -- version = "*", -- try installing the latest stable version for plugins that support semver
  -- },
  ui = {
    -- If you have a Nerd Font, set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
  -- install = { colorscheme = { 'tokyonight', 'habamax' } },
  -- checker = { enabled = true }, -- automatically check for plugin updates
  -- performance = {
  --   rtp = {
  --     -- disable some rtp plugins
  --     disabled_plugins = {
  --       'gzip',
  --       -- "matchit",
  --       -- "matchparen",
  --       -- "netrwPlugin",
  --       'tarPlugin',
  --       'tohtml',
  --       'tutor',
  --       'zipPlugin',
  --     },
  --   },
  -- },
})
