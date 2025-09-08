-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('nvim-joki-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local function is_normal_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local bt = vim.api.nvim_buf_get_option(bufnr, 'buftype')
  return bt == ''
end

vim.api.nvim_create_autocmd('InsertEnter', {
  callback = function()
    if is_normal_buffer() then
      vim.b.updaterestore = vim.opt.updatetime:get()
      vim.opt.updatetime = 10000
    end
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  callback = function()
    if is_normal_buffer() and vim.b.updaterestore then
      vim.opt.updatetime = vim.b.updaterestore
      vim.b.updaterestore = nil
    end
  end,
})
