return {
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    lazy = false,
    version = false,
    opts = {
      provider = 'claude',
      auto_suggestions_provider = 'claude',
      providers = {
        claude = {
          endpoint = 'https://api.anthropic.com',
          model = 'claude-sonnet-4-5-20250929',
          api_version = 'v1',
          extra_request_body = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
      },
      behaviour = {
        auto_suggestions = false, -- Set to true for copilot-like auto suggestions
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        auto_approve_tool_permissions = false,
        enable_token_counting = false,   -- Whether to enable token counting. Default to true.
        confirmation_ui_style = 'popup', -- Use popup dialog for tool permissions (better keyboard support)
        acp_follow_agent_locations = false,
      },
      file_selector = {
        provider = 'native',
      },
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = 'co',
          theirs = 'ct',
          all_theirs = 'ca',
          both = 'cb',
          cursor = 'cc',
          next = ']x',
          prev = '[x',
        },
        suggestion = {
          accept = '<M-l>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
        jump = {
          next = ']]',
          prev = '[[',
        },
        submit = {
          normal = '<CR>',
          insert = '<C-s>',
        },
      },
      hints = { enabled = true },
      windows = {
        ---@type "right" | "left" | "top" | "bottom"
        position = 'right',
        wrap = true,
        width = 40, -- Increased width for better visibility
        sidebar_header = {
          align = 'center',
          rounded = true,
        },
        edit = {
          border = 'rounded',
          start_insert = true,
        },
        ask = {
          floating = false, -- Keep it in sidebar
          start_insert = true,
          border = 'rounded',
          focus_on_apply = 'ours',
        },
        input = {
          prefix = "> ",
          height = 10, -- Height of the input window in vertical layout
        },
      },
      highlights = {
        ---@type AvanteConflictHighlights
        diff = {
          current = 'DiffText',
          incoming = 'DiffAdd',
        },
      },
      --- @class AvanteConflictUserConfig
      diff = {
        autojump = true,
        ---@type string | fun(): any
        list_opener = 'copen',
      },
    },
    build = 'make',
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- Optional dependencies
      'nvim-tree/nvim-web-devicons',
      'zbirenbaum/copilot.lua', -- for copilot integration
      {
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
          },
        },
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
    config = function(_, opts)
      require('avante').setup(opts)

      -- Setup which-key keybindings
      require('which-key').add {
        -- Avante AI group
        { '<leader>a',  group = '[A]vante AI' },
        { '<leader>aa', '<cmd>AvanteAsk<cr>',     desc = '[A]sk Claude',       mode = { 'n', 'v' } },
        { '<leader>ae', '<cmd>AvanteEdit<cr>',    desc = '[E]dit with Claude', mode = { 'n', 'v' } },
        { '<leader>ar', '<cmd>AvanteRefresh<cr>', desc = '[R]efresh' },
        { '<leader>at', '<cmd>AvanteToggle<cr>',  desc = '[T]oggle Sidebar' },
        { '<leader>af', '<cmd>AvanteFocus<cr>',   desc = '[F]ocus Sidebar' },
        {
          '<leader>as',
          function()
            -- Force stop Avante
            vim.cmd('AvanteStop')
            vim.notify('Avante stopped', vim.log.levels.WARN)
          end,
          desc = '[S]top/Cancel Request',
        },
        {
          '<leader>aS',
          function()
            -- Nuclear option - close all Avante windows and stop
            pcall(vim.cmd, 'AvanteStop')
            pcall(vim.cmd, 'AvanteToggle')
            -- Close any Avante-related buffers
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              local ft = vim.bo[buf].filetype
              if ft == 'Avante' or ft == 'AvanteInput' then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end
            end
            vim.notify('Avante force stopped and closed', vim.log.levels.ERROR)
          end,
          desc = 'Force [S]top & Close (Emergency)',
        },
      }
    end,
  },
}
