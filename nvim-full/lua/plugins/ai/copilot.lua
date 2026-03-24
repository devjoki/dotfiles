return {
  {
    'github/copilot.vim',
    config = function()
      -- Use Ctrl-Enter to accept Copilot suggestions
      vim.keymap.set('i', '<C-CR>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = 'Accept Copilot suggestion',
      })
      -- Disable default Tab mapping to avoid conflicts with completion and tabout
      vim.g.copilot_no_tab_map = true

      -- Make Copilot suggestions more subtle so they don't hide autopaired characters
      vim.cmd([[
        highlight CopilotSuggestion guifg=#555555 ctermfg=8
      ]])
    end,
  },
}
