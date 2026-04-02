-- Colorscheme persistence - loads before plugins
local M = {}

M.colorscheme_file = vim.fn.stdpath('data') .. '/colorscheme.txt'
M.default_scheme = 'tokyonight-moon'

function M.save_colorscheme(scheme)
  local dir = vim.fn.fnamemodify(M.colorscheme_file, ':h')
  vim.fn.mkdir(dir, 'p')
  local file = io.open(M.colorscheme_file, 'w')
  if file then
    file:write(scheme)
    file:close()
    vim.notify('Saved colorscheme: ' .. scheme, vim.log.levels.INFO)
  end
end

function M.load_saved_colorscheme()
  local file = io.open(M.colorscheme_file, 'r')
  if file then
    local scheme = file:read('*all'):gsub('%s+', '')
    file:close()
    if scheme ~= '' then return scheme end
  end
  return M.default_scheme
end

function M.apply_saved_scheme()
  local saved_scheme = M.load_saved_colorscheme()
  local ok = pcall(vim.cmd.colorscheme, saved_scheme)
  if not ok then
    vim.notify('Failed to load colorscheme: ' .. saved_scheme .. ', using default', vim.log.levels.WARN)
    pcall(vim.cmd.colorscheme, M.default_scheme)
  end
end

function M.setup_autocmd()
  vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
      if vim.g.colors_name then
        M.save_colorscheme(vim.g.colors_name)
      end
    end,
  })
end

return M
