return {
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    dependencies = { 'folke/which-key.nvim' },
    opts = {
      -- Default configuration
      labels = 'asdfghjklqwertyuiopzxcvbnm',
      search = {
        multi_window = true,
        forward = true,
        wrap = true,
      },
      jump = {
        jumplist = true,
        pos = 'start',
        history = false,
        register = false,
        nohlsearch = false,
      },
      label = {
        uppercase = true,
        rainbow = {
          enabled = false,
          shade = 5,
        },
      },
      modes = {
        search = {
          enabled = true,
        },
        char = {
          enabled = true,
          jump_labels = true,
        },
      },
    },
    config = function(_, opts)
      require('flash').setup(opts)

      -- Register keymaps with which-key
      require('which-key').add {
        -- Main flash jump (replaces 's' which is rarely used - you can use 'cl' instead)
        {
          's',
          function()
            require('flash').jump()
          end,
          mode = { 'n', 'x', 'o' },
          desc = 'Flash Jump',
        },
        -- Treesitter jump (replaces 'S' which is rarely used - you can use 'cc' instead)
        {
          'S',
          function()
            require('flash').treesitter()
          end,
          mode = { 'n', 'x', 'o' },
          desc = 'Flash Treesitter',
        },
        -- Remote operations - using 'gs' prefix to avoid conflicting with 'r' (replace char)
        {
          'gs',
          function()
            require('flash').remote()
          end,
          mode = 'o',
          desc = 'Remote Flash',
        },
        {
          'gS',
          function()
            require('flash').treesitter_search()
          end,
          mode = { 'o', 'x' },
          desc = 'Treesitter Search',
        },
        -- Toggle in search mode
        {
          '<c-s>',
          function()
            require('flash').toggle()
          end,
          mode = { 'c' },
          desc = 'Toggle Flash Search',
        },
      }
    end,
  },
}
