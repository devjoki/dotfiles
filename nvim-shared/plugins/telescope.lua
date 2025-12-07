-- Telescope - Fuzzy finder
-- Shared between nvim-full and nvim-slim
-- Note: LSP-specific pickers (diagnostics) are added in nvim-full

return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/which-key.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons' },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              -- ['<c-enter>'] = 'to_fuzzy_refine',
            },
          },
        },
        pickers = {
          colorscheme = {
            enable_preview = true,
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'

      -- Register keymaps with which-key
      require('which-key').add {
        { '<leader>sh', builtin.help_tags, desc = '[H]elp' },
        { '<leader>sk', builtin.keymaps, desc = '[K]eymaps' },
        { '<leader>sf', builtin.find_files, desc = '[F]iles' },
        { '<leader>ss', builtin.builtin, desc = '[S]elect Telescope' },
        { '<leader>sw', builtin.grep_string, desc = 'current [W]ord' },
        { '<leader>sg', builtin.live_grep, desc = 'by [G]rep' },
        { '<leader>sr', builtin.resume, desc = '[R]esume' },
        { '<leader>s.', builtin.oldfiles, desc = 'Recent Files ("." for repeat)' },
        { '<leader><leader>', builtin.buffers, desc = 'Find existing buffers' },
        {
          '<leader>/',
          function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
              winblend = 10,
              previewer = false,
            })
          end,
          desc = '[/] Fuzzily search in current buffer',
        },
        {
          '<leader>s/',
          function()
            builtin.live_grep {
              grep_open_files = true,
              prompt_title = 'Live Grep in Open Files',
            }
          end,
          desc = '[/] in Open Files',
        },
        {
          '<leader>sn',
          function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
          end,
          desc = '[N]eovim files',
        },
      }
    end,
  },
}
