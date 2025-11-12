return {
  -- Better buffer deletion (handles the last buffer case)
  {
    'famiu/bufdelete.nvim',
  },
  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'BufReadPre',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/which-key.nvim', 'famiu/bufdelete.nvim' },
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

      -- Auto-delete empty [No Name] buffers when opening a new file
      vim.api.nvim_create_autocmd('BufReadPost', {
        callback = function()
          vim.schedule(function()
            -- Find all empty unnamed buffers
            local bufs = vim.api.nvim_list_bufs()
            for _, buf in ipairs(bufs) do
              if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
                local name = vim.api.nvim_buf_get_name(buf)
                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                local is_empty = #lines == 1 and lines[1] == ''
                local is_unnamed = name == ''
                local is_modified = vim.bo[buf].modified

                -- Delete if it's an empty, unnamed, unmodified buffer
                if is_empty and is_unnamed and not is_modified then
                  pcall(vim.api.nvim_buf_delete, buf, { force = false })
                end
              end
            end
          end)
        end,
      })

      -- Register buffer navigation keybindings with which-key
      require('which-key').add {
        { '<leader>e', group = 'Buff[e]rs' },
        { '<leader>el', '<cmd>BufferLinePick<CR>', desc = 'Pick buffer', mode = 'n' },
        { '<leader>en', '<cmd>BufferLineCycleNext<CR>', desc = '[N]ext buffer', mode = 'n' },
        { '<leader>ep', '<cmd>BufferLineCyclePrev<CR>', desc = '[P]revious buffer', mode = 'n' },
        { '<leader>ed', '<cmd>Bdelete<CR>', desc = '[D]elete buffer', mode = 'n' },
        { '<leader>eD', '<cmd>Bdelete!<CR>', desc = 'Force [D]elete buffer', mode = 'n' },
        {
          '<leader>ec',
          '<cmd>BufferLinePickClose<CR>',
          desc = 'Pick buffer to [C]lose',
          mode = 'n',
        },
        {
          '<leader>eC',
          '<cmd>BufferLineCloseOthers<CR>',
          desc = '[C]lose all other buffers',
          mode = 'n',
        },
        {
          '<leader>eH',
          '<cmd>BufferLineCloseLeft<CR>',
          desc = 'Close all buffers to the left',
          mode = 'n',
        },
        {
          '<leader>eL',
          '<cmd>BufferLineCloseRight<CR>',
          desc = 'Close all buffers to the right',
          mode = 'n',
        },
        { '<leader>em', group = '[M]ove buffer' },
        {
          '<leader>emn',
          '<cmd>BufferLineMoveNext<CR>',
          desc = '[M]ove buffer [N]ext',
          mode = 'n',
        },
        {
          '<leader>emp',
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
