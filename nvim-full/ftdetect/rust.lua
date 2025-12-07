vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.rs',
  callback = function()
    vim.bo.filetype = 'rust'
  end,
})
