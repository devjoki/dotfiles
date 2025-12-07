-- NvimTree - File explorer
-- Shared between nvim-full and nvim-slim
-- Note: Java-specific navigation helpers are in nvim-full only

return {
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'folke/which-key.nvim',
    },
    config = function()
      local function on_attach(bufnr)
        local api = require('nvim-tree.api')

        -- Default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- Register keybindings with which-key (smart-splits navigation)
        require('which-key').add({
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
        })
      end

      require('nvim-tree').setup {
        sync_root_with_cwd = true,
        sort = {
          sorter = 'case_sensitive',
        },
        view = {
          adaptive_size = true,
        },
        renderer = {
          group_empty = true,
          highlight_git = true,
          icons = {
            show = {
              git = true,
              folder = true,
              file = true,
              folder_arrow = true,
            },
            glyphs = {
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        filters = {
          dotfiles = false,
          custom = { '.git', 'node_modules', '.cache' },
        },
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        diagnostics = {
          enable = false,
        },
        git = {
          enable = true,
          ignore = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            window_picker = {
              enable = true,
            },
          },
        },
        trash = {
          cmd = "trash",
          require_confirm = true,
        },
        live_filter = {
          prefix = "[FILTER]: ",
          always_show_folders = false,
        },
        on_attach = on_attach,
      }

      -- Register global keymaps with which-key
      require('which-key').add {
        { '<leader>wf', group = '[F]iles (NvimTree)' },
        { '<leader>wft', ':NvimTreeToggle<CR>', mode = { 'n', 'v' }, desc = '[T]oggle tree' },
        { '<leader>wff', ':NvimTreeFindFile<CR>', mode = { 'n', 'v' }, desc = '[F]ind current file in tree' },
        { '<leader>wfc', ':NvimTreeCollapse<CR>', mode = { 'n', 'v' }, desc = '[C]ollapse all folders' },
        {
          '<leader>wfo',
          function()
            require('nvim-tree.api').tree.expand_all()
          end,
          mode = { 'n', 'v' },
          desc = '[O]pen/Expand all folders',
        },
      }
    end,
  },
}
