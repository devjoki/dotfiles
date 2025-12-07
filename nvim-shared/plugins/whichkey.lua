-- Which-key - Show pending keybindings
-- Shared between nvim-full and nvim-slim
-- Note: Additional keybindings are registered by individual plugins in nvim-full

return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup()

      -- Document basic key groups (common to both configs)
      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>g', group = '[G]it' },
        { '<leader>p', group = '[P]ersistence' },
        { '<leader>t', group = '[T]rouble' },
        { '<leader>u', group = '[U]tils' },
        { '<leader>e', group = 'Buff[e]rs' },
        {
          '<leader>?',
          function()
            require('which-key').show('<leader>')
          end,
          desc = 'Show leader keybindings',
        },
        {
          '<leader>wd',
          [[:execute 'tabnew | Dashboard'<cr>]],
          mode = { 'n', 'v' },
          desc = 'Open Dashboard',
        },
      }
    end,
  },
}
