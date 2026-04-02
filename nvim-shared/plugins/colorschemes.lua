-- Shared colorscheme plugins (used by both nvim-full and nvim-slim)
-- Includes Telescope-based colorscheme picker

-- Add nvim-shared to package path before requiring modules
local config_home = vim.fn.stdpath("config")
local config_real = vim.loop.fs_realpath(config_home) or config_home
local config_parent = vim.fn.fnamemodify(config_real, ":h")
local shared_path = config_parent .. "/nvim-shared"
package.path = shared_path .. "/?.lua;" .. package.path

return {
  -- Tokyo Night
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      style = 'night',
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
      },
    },
    config = function(_, opts)
      require('tokyonight').setup(opts)

      -- Apply saved colorscheme after all colorscheme plugins are loaded
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          local persist = require('colorscheme-persist')
          persist.apply_saved_scheme()
          -- Setup autocmd to save colorscheme when changed
          persist.setup_autocmd()
        end,
        once = true,
      })
    end,
  },

  -- Catppuccin
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    lazy = false,
    opts = {
      flavour = 'mocha',
      transparent_background = false,
      term_colors = true,
      styles = {
        comments = { 'italic' },
        conditionals = { 'italic' },
      },
    },
  },

  -- Kanagawa
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,
      terminalColors = true,
      theme = 'wave',
    },
  },

  -- Rose Pine
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000,
    lazy = false,
    opts = {
      variant = 'main',
      dark_variant = 'main',
      disable_background = false,
      disable_float_background = false,
      disable_italics = false,
    },
  },

  -- Gruvbox
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      terminal_colors = true,
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true,
      contrast = '',
      palette_overrides = {},
      overrides = {},
      dim_inactive = false,
      transparent_mode = false,
    },
  },
}
