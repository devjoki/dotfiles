return {
  {
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
    -- Autoformat
    {
      'stevearc/conform.nvim',
      events = { 'BufReadPre', 'BufNewFile' },
      config = function()
        require('conform').setup {
          notify_on_error = true,
          format_on_save = function(bufnr)
            -- Disable "format_on_save lsp_fallback" for languages that don't
            -- have a well standardized coding style. You can add additional
            -- languages here or re-enable it for the disabled ones.
            local disable_filetypes = { c = true, cpp = true }
            return {
              timeout_ms = 500,
              lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
            }
          end,
          formatters_by_ft = {
            lua = { 'stylua' },
            javascript = { { 'prettierd', 'prettier' } },
            typescript = { { 'prettierd', 'prettier' } },
            -- kotlin = { 'ktlint' },
            -- typescript = { 'eslint_d' },
            -- Conform can also run multiple formatters sequentially
            -- python = { "isort", "black" },
            --
            -- You can use a sub-list to tell conform to run *until* a formatter
            -- is found.
          },
          formatters = {
            -- ['eslint_d'] = {
            --   meta = {
            --     url = 'https://github.com/mantoni/eslint_d.js/',
            --     description = 'Like ESLint, but faster.',
            --   },
            --   command = require('conform.util').from_node_modules 'eslint_d',
            --   args = { '--fix-to-stdout', '--stdin', '--stdin-filename', '$FILENAME' },
            --   cwd = require('conform.util').root_file {
            --     'package.json',
            --   },
            -- },
          },
        }
      end,
    },
    { -- Add indentation guides even on blank lines
      'lukas-reineke/indent-blankline.nvim',
      -- Enable `lukas-reineke/indent-blankline.nvim`
      -- See `:help ibl`
      main = 'ibl',
      opts = {
        exclude = {
          filetypes = { 'help', 'nvimtree', 'dashboard' },
          buftypes = { 'terminal', 'nofile', 'quickfix' },
        },
        scope = {
          show_end = true,
        },
      },
    },
  },
}
