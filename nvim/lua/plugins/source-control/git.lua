return {
  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    dependencies = { 'folke/which-key.nvim' },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
    },
    config = function(_, opts)
      require('gitsigns').setup(opts)

      -- Register keymaps with which-key
      require('which-key').add {
        { '<leader>gp', ':Gitsigns preview_hunk<CR>', mode = { 'n', 'v' }, desc = 'Gitsigns preview hunk' },
        { '<leader>gt', ':Gitsigns toggle_current_line_blame<CR>', mode = { 'n', 'v' }, desc = 'Gitsigns toggle blame' },
      }
    end,
  },
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/which-key.nvim',
    },
    -- Keep keys for lazy-loading, which-key will pick it up automatically
    keys = {
      { '<leader>gl', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },
}
