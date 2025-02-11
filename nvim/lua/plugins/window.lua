return {
  'mrjones2014/smart-splits.nvim',
  lazy = false,
  keys = {
    {
      '<C-h>',
      function()
        require('smart-splits').move_cursor_left()
      end,
      mode = { 'i', 'n', 'v' },
      desc = 'Move to left window',
    },
    {
      '<C-j>',
      function()
        require('smart-splits').move_cursor_down()
      end,
      mode = { 'i', 'n', 'v' },
      desc = 'Move to bottom window',
    },
    {
      '<C-k>',
      function()
        require('smart-splits').move_cursor_up()
      end,
      mode = { 'i', 'n', 'v' },
      desc = 'Move to top window',
    },
    {
      '<C-l>',
      function()
        require('smart-splits').move_cursor_right()
      end,
      mode = { 'i', 'n', 'v' },
      desc = 'Move to right window',
    },
    {
      '<A-h>',
      function()
        require('smart-splits').resize_left()
      end,
      mode = { 'i', 'n', 'v' },
      desc = 'Resize window to left',
    },
    {
      '<A-j>',
      function()
        require('smart-splits').resize_down()
      end,
      mode = { 'i', 'n', 'v' },
      desc = 'Resize window to bottom',
    },
    {
      '<A-k>',
      function()
        require('smart-splits').resize_up()
      end,
      mode = { 'i', 'n', 'v' },
      desc = 'Resize window to top',
    },
    {
      '<A-l>',
      function()
        require('smart-splits').resize_right()
      end,
      mode = { 'i', 'n', 'v' },
      desc = 'Resize window to right',
    },
  },
  config = function()
    require('smart-splits').setup {}
  end,
}
