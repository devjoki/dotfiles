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
      local function on_attach(bufnr)
        local api = require('nvim-tree.api')

        -- Default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- Register keybindings with which-key
        require('which-key').add({
          -- Smart-splits navigation
          {
            '<C-h>',
            function()
              require('smart-splits').move_cursor_left()
            end,
            desc = 'Move to left window',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<C-j>',
            function()
              require('smart-splits').move_cursor_down()
            end,
            desc = 'Move to bottom window',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<C-k>',
            function()
              require('smart-splits').move_cursor_up()
            end,
            desc = 'Move to top window',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<C-l>',
            function()
              require('smart-splits').move_cursor_right()
            end,
            desc = 'Move to right window',
            buffer = bufnr,
            mode = 'n',
          },
          -- Smart-splits resizing
          {
            '<A-h>',
            function()
              require('smart-splits').resize_left()
            end,
            desc = 'Resize window left',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<A-j>',
            function()
              require('smart-splits').resize_down()
            end,
            desc = 'Resize window down',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<A-k>',
            function()
              require('smart-splits').resize_up()
            end,
            desc = 'Resize window up',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<A-l>',
            function()
              require('smart-splits').resize_right()
            end,
            desc = 'Resize window right',
            buffer = bufnr,
            mode = 'n',
          },
        })
      end

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
        update_focused_file = {
          enable = true,
        },
        on_attach = on_attach,
      }
    end,
  },
}
