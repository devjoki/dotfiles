-- lua/plugins/dap.lua
return {
  -- Core DAP
  { 'mfussenegger/nvim-dap' },

  -- Nice UI
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio', 'folke/which-key.nvim' },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup()

      -- Close nvim-tree when debugging starts (from tests, etc.)
      dap.listeners.after.event_initialized['dapui_config'] = function()
        local nvim_tree_api = require('nvim-tree.api')
        if nvim_tree_api.tree.is_visible() then
          nvim_tree_api.tree.close()
        end
        dapui.open()
      end

      -- Helper functions to manage nvim-tree with DAP UI (for manual open/close/toggle)
      local function dapui_open_wrapper()
        local nvim_tree_api = require('nvim-tree.api')
        if nvim_tree_api.tree.is_visible() then
          nvim_tree_api.tree.close()
        end
        dapui.open()
      end

      local function dapui_close_wrapper()
        dapui.close()
        -- Small delay to let LSP clean up before reopening nvim-tree
        vim.defer_fn(function()
          local nvim_tree_api = require('nvim-tree.api')
          nvim_tree_api.tree.open()
          -- Return focus to the first normal file window
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buftype = vim.bo[buf].buftype
            if buftype == '' then  -- Normal file buffer
              vim.api.nvim_set_current_win(win)
              break
            end
          end
        end, 100)
      end

      local function dapui_toggle_wrapper()
        local nvim_tree_api = require('nvim-tree.api')
        -- Check if DAP UI is currently open by checking for visible DAP UI windows
        local dapui_open = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft:match('^dapui_') then
            dapui_open = true
            break
          end
        end

        if dapui_open then
          -- Closing DAP UI, open nvim-tree after small delay
          dapui.toggle()
          vim.defer_fn(function()
            nvim_tree_api.tree.open()
            -- Return focus to the first normal file window
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local buftype = vim.bo[buf].buftype
              if buftype == '' then  -- Normal file buffer
                vim.api.nvim_set_current_win(win)
                break
              end
            end
          end, 100)
        else
          -- Opening DAP UI, close nvim-tree
          if nvim_tree_api.tree.is_visible() then
            nvim_tree_api.tree.close()
          end
          dapui.toggle()
        end
      end

      -- Keymaps
      require('which-key').add {
        -- Function keys for debugging
        { '<F5>', dap.continue, desc = 'DAP Continue' },
        { '<F10>', dap.step_over, desc = 'DAP Step Over' },
        { '<F11>', dap.step_into, desc = 'DAP Step Into' },
        { '<F12>', dap.step_out, desc = 'DAP Step Out' },

        -- Debug group
        { '<leader>d', group = '[D]ebug' },
        { '<leader>dc', dap.continue, desc = '[C]ontinue' },
        { '<leader>ds', dap.step_over, desc = '[S]tep Over' },
        { '<leader>di', dap.step_into, desc = 'Step [I]nto' },
        { '<leader>do', dap.step_out, desc = 'Step [O]ut' },
        { '<leader>dt', dap.terminate, desc = '[T]erminate' },
        { '<leader>dr', dap.restart, desc = '[R]estart' },

        -- Breakpoints
        { '<leader>db', group = '[B]reakpoints' },
        { '<leader>dbt', dap.toggle_breakpoint, desc = '[T]oggle Breakpoint' },
        {
          '<leader>dbc',
          function()
            dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
          end,
          desc = '[C]onditional Breakpoint',
        },
        { '<leader>dbl', dap.list_breakpoints, desc = '[L]ist Breakpoints' },
        { '<leader>dbx', dap.clear_breakpoints, desc = 'Clear All Breakpoints' },

        -- DAP UI
        { '<leader>du', group = 'DAP [U]I' },
        { '<leader>duc', dapui_close_wrapper, desc = '[C]lose UI' },
        { '<leader>duo', dapui_open_wrapper, desc = '[O]pen UI' },
        { '<leader>dut', dapui_toggle_wrapper, desc = '[T]oggle UI' },
      }
    end,
  },

  -- Mason bridge for DAP adapters
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = { 'williamboman/mason.nvim', 'mfussenegger/nvim-dap' },
    opts = {
      ensure_installed = {
        'python', -- debugpy
        'js', -- node debug (js-debug-adapter)
        'codelldb', -- rust/c++
        'javadbg', -- java debugging
        'javatest', -- java test runner (fixed in v0.43.2)
      },
      automatic_installation = true,
      handlers = {
        -- Default handler sets up adapters from mason automatically
        function(config)
          require('mason-nvim-dap').default_setup(config)
        end,
      },
    },
  },
}
