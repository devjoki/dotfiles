require('lint').linters_by_ft = {
  javascript = { 'eslint_d' },
  typescript = { 'eslint_d' },
  sh = { 'shellcheck' },
  zsh = { 'zsh' },
}
-- require('lint').linters = {
--   eslint_d = {
--     args = {
--       '--no-warn-ignored', -- <-- this is the key argument
--       '--format',
--       'json',
--       '--stdin',
--       '--stdin-filename',
--       function()
--         return vim.api.nvim_buf_get_name(0)
--       end,
--     },
--   },
-- }
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  callback = function()
    require('lint').try_lint()
  end,
})
