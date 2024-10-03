return {
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<leader>wt', ':NvimTreeToggle<CR>', mode = { 'n', 'v' }, desc = 'NvimTree Toggle' },
    },
    config = function()
      require('nvim-tree').setup {
        sync_root_with_cwd = true,
        sort = {
          sorter = 'case_sensitive',
        },
        view = {
          -- width = 30,
          adaptive_size = true,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = true,
        },
      }
    end,
  },
}
