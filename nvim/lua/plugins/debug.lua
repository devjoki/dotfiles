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

      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      -- Don't auto-close on test termination so you can see results
      -- Manually close with :DapTerminate or <leader>dc if needed
      -- dap.listeners.before.event_terminated['dapui_config'] = function()
      --   dapui.close()
      -- end
      -- dap.listeners.before.event_exited['dapui_config'] = function()
      --   dapui.close()
      -- end

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
        { '<leader>duc', dapui.close, desc = '[C]lose UI' },
        { '<leader>duo', dapui.open, desc = '[O]pen UI' },
        { '<leader>dut', dapui.toggle, desc = '[T]oggle UI' },
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
