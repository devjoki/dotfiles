return {
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'folke/which-key.nvim' },
    keys = {
      { '<leader>ct', '<cmd>TSJToggle<cr>', desc = '[T]oggle Split/Join' },
      { '<leader>cj', '<cmd>TSJJoin<cr>', desc = '[J]oin code block' },
      { '<leader>cs', '<cmd>TSJSplit<cr>', desc = '[S]plit code block' },
    },
    config = function()
      require('treesj').setup {
        use_default_keymaps = false, -- Use custom keymaps defined above
        check_syntax_error = true, -- Check for syntax errors before split/join
        max_join_length = 999, -- Maximum line length when joining (set high to allow long lines)
        cursor_behavior = 'hold', -- 'hold' or 'start' or 'end'
        notify = true, -- Show notifications
        dot_repeat = true, -- Enable dot repeat
        on_error = nil, -- Function to call on error
      }

      -- Register with which-key
      require('which-key').add {
        { '<leader>ct', '<cmd>TSJToggle<cr>', desc = '[T]oggle Split/Join' },
        { '<leader>cj', '<cmd>TSJJoin<cr>', desc = '[J]oin code block' },
        { '<leader>cs', '<cmd>TSJSplit<cr>', desc = '[S]plit code block' },
      }
    end,
  },
}
