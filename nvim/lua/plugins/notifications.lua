return {
  -- Notification manager with history
  {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    config = function()
      local notify = require 'notify'

      -- Configure nvim-notify
      notify.setup {
        -- Animation style
        stages = 'fade_in_slide_out',
        -- Default timeout
        timeout = 3000,
        -- Max width of notification window
        max_width = 50,
        -- Max height of notification window
        max_height = 10,
        -- Render style: 'default', 'minimal', 'simple', 'compact'
        render = 'default',
        -- Minimum level to show
        level = vim.log.levels.INFO,
        -- Icons for each level
        icons = {
          ERROR = '',
          WARN = '',
          INFO = '',
          DEBUG = '',
          TRACE = '✎',
        },
      }

      -- Set as default notify function
      vim.notify = notify

      -- Register keymaps with which-key
      require('which-key').add {
        {
          '<leader>wn',
          group = '[N]otifications',
        },
        {
          '<leader>wns',
          function()
            require('telescope').extensions.notify.notify()
          end,
          desc = '[S]how history',
        },
        {
          '<leader>wnd',
          function()
            require('notify').dismiss { silent = true, pending = true }
          end,
          desc = '[D]ismiss all',
        },
      }
    end,
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'folke/which-key.nvim',
    },
  },

  -- LSP progress notifications
  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    opts = {
      notification = {
        window = {
          winblend = 0, -- Background transparency (0-100)
          relative = 'editor', -- Position relative to editor
        },
      },
    },
  },
}
