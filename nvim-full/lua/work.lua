local Work = {}

function Work.query_quotes(env)
  vim.cmd([[:execute 'enew | r ! ]] .. env .. [[_quotes '.input('quoteId: ')]])
  local buff = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(buff, 'filetype', 'json')
  print(vim.api.nvim_buf_get_lines(buff, 0, -1, false))
end

function Work.which_key_config()
  return {
    -- Work-specific keybindings can be added here
  }
end
return Work
