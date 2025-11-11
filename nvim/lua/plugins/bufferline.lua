return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'BufReadPre',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/which-key.nvim' },
    opts = {
      options = {
        diagnostics = 'nvim_lsp',
        always_show_bufferline = true,
        mode = 'buffers',
        separator_style = 'thin',
        close_command = 'bdelete! %d',
        right_mouse_command = 'bdelete! %d',
        show_buffer_close_icons = true,
        show_close_icon = false,
        offsets = {
          {
            filetype = 'NvimTree',
            text = 'File Explorer',
            highlight = 'Directory',
            separator = true,
          },
        },
        diagnostics_indicator = function(count, level)
          local icon = level:match 'error' and ' ' or ' '
          return ' ' .. icon .. count
        end,
      },
    },
    config = function(_, opts)
      require('bufferline').setup(opts)

      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd('BufAdd', {
        callback = function()
          vim.schedule(function()
            pcall(vim.cmd, 'BufferLineSortByDirectory')
          end)
        end,
      })

      -- Register buffer navigation keybindings with which-key
      require('which-key').add {
        { '<leader>bl', '<cmd>BufferLinePick<CR>', desc = 'Pick buffer', mode = 'n' },
        { '<leader>bn', '<cmd>BufferLineCycleNext<CR>', desc = '[N]ext buffer', mode = 'n' },
        { '<leader>bp', '<cmd>BufferLineCyclePrev<CR>', desc = '[P]revious buffer', mode = 'n' },
        { '<leader>bd', '<cmd>bp|bd #<CR>', desc = '[D]elete buffer', mode = 'n' },
        { '<leader>bD', '<cmd>bp|bd! #<CR>', desc = 'Force [D]elete buffer', mode = 'n' },
        {
          '<leader>bc',
          '<cmd>BufferLinePickClose<CR>',
          desc = 'Pick buffer to [C]lose',
          mode = 'n',
        },
        {
          '<leader>bC',
          '<cmd>BufferLineCloseOthers<CR>',
          desc = '[C]lose all other buffers',
          mode = 'n',
        },
        {
          '<leader>bH',
          '<cmd>BufferLineCloseLeft<CR>',
          desc = 'Close all buffers to the left',
          mode = 'n',
        },
        {
          '<leader>bL',
          '<cmd>BufferLineCloseRight<CR>',
          desc = 'Close all buffers to the right',
          mode = 'n',
        },
        { '<leader>bm', group = '[M]ove buffer' },
        {
          '<leader>bmn',
          '<cmd>BufferLineMoveNext<CR>',
          desc = '[M]ove buffer [N]ext',
          mode = 'n',
        },
        {
          '<leader>bmp',
          '<cmd>BufferLineMovePrev<CR>',
          desc = '[M]ove buffer [P]revious',
          mode = 'n',
        },
        -- Quick navigation with Tab
        { '<Tab>', '<cmd>BufferLineCycleNext<CR>', desc = 'Next buffer', mode = 'n' },
        { '<S-Tab>', '<cmd>BufferLineCyclePrev<CR>', desc = 'Previous buffer', mode = 'n' },
      }
    end,
  },
}
