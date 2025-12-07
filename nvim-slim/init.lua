-- nvim-slim: Lightweight Neovim config without LSP/plugins
-- Perfect for quick edits on the host system

-- Disable some features to keep it lightweight
vim.g.loaded_node_provider = 0  -- Disable Node.js provider
vim.g.loaded_perl_provider = 0  -- Disable Perl provider
vim.g.loaded_ruby_provider = 0  -- Disable Ruby provider

-- Load shared configuration (options, keymaps, autocmds, colorscheme)
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

-- Load shared plugins (colorschemes, mini, treesitter, which-key, window navigation)
local shared_plugins_init = config_parent .. "/nvim-shared/plugins-init.lua"
if vim.fn.filereadable(shared_plugins_init) == 1 then
  local shared_plugins = dofile(shared_plugins_init)

  -- Setup lazy.nvim with shared plugins
  require('lazy').setup(shared_plugins, {
    ui = {
      icons = vim.g.have_nerd_font and {} or {
        cmd = '⌘', config = '🛠', event = '📅', ft = '📂',
        init = '⚙', keys = '🗝', plugin = '🔌', runtime = '💻',
        require = '🌙', source = '📄', start = '🚀', task = '📌',
        lazy = '💤 ',
      },
    },
  })
end

-- Show a message that we're in slim mode
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      vim.notify("Neovim Slim Mode", vim.log.levels.INFO)
    end, 100)
  end,
})
