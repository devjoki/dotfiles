return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'BufReadPre',
    dependencies = 'nvim-tree/nvim-web-devicons',
    keys = {
      -- { '<leader>bl', ':BufferLinePick<CR>', desc = 'Bufferline pick' },
    },
    opts = {
      options = {
       -- stylua: ignore
        diagnostics = 'nvim_lsp',
        always_show_bufferline = true,
        mode = 'buffers',
        offsets = {
          {
            filetype = 'NvimTree',
            text = 'File Explorer',
            highlight = 'Directory',
            separator = true,
          },
        },
      },
    },
    config = function(_, opts)
      require('bufferline').setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd('BufAdd', {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },
}
