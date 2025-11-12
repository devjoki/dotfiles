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
        width = 30, -- percentage
        sidebar_header = {
          align = 'center',
          rounded = true,
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
        { '<leader>a', group = '[A]vante AI' },
        { '<leader>aa', '<cmd>AvanteAsk<cr>', desc = '[A]sk Claude', mode = { 'n', 'v' } },
        { '<leader>ae', '<cmd>AvanteEdit<cr>', desc = '[E]dit with Claude', mode = { 'n', 'v' } },
        { '<leader>ar', '<cmd>AvanteRefresh<cr>', desc = '[R]efresh' },
        { '<leader>at', '<cmd>AvanteToggle<cr>', desc = '[T]oggle Sidebar' },
        {
          '<leader>ac',
          function()
            -- Find a valid file buffer
            local found_valid_buffer = false
            local current_buftype = vim.bo.buftype

            if current_buftype ~= '' and current_buftype ~= 'acwrite' then
              -- Try to find a normal file buffer
              for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
                  local bufname = vim.api.nvim_buf_get_name(buf)
                  if bufname ~= '' and not bufname:match('^%[') then
                    vim.api.nvim_set_current_buf(buf)
                    found_valid_buffer = true
                    break
                  end
                end
              end
            else
              found_valid_buffer = true
            end

            if found_valid_buffer then
              local ok, err = pcall(vim.cmd, 'AvanteClear')
              if not ok then
                vim.notify('AvanteClear error: ' .. tostring(err), vim.log.levels.WARN)
              end
            else
              vim.notify('No valid file buffer found. Open a file first.', vim.log.levels.WARN)
            end
          end,
          desc = '[C]lear Chat'
        },
        { '<leader>af', '<cmd>AvanteFocus<cr>', desc = '[F]ocus Sidebar' },
        {
          '<leader>as',
          function()
            require('avante.api').switch_provider()
          end,
          desc = '[S]witch Provider',
        },
      }
    end,
  },
}
