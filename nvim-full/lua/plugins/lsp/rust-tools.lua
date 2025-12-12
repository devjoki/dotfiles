return {
  'mrcjkb/rustaceanvim',
  version = '^5',
  lazy = false,
  ft = { 'rust' },
  dependencies = {
    'jay-babu/mason-nvim-dap.nvim',
    'folke/which-key.nvim',
  },
  config = function()
    local home = os.getenv 'HOME'
    local nvim_app_name = vim.env.NVIM_APPNAME or 'nvim'
    local share_path = home .. '/.local/share/' .. nvim_app_name
    local mason_path = share_path .. '/mason/'
    local extension_path = mason_path .. 'packages/codelldb/extension/'
    local codelldb_path = extension_path .. 'adapter/codelldb'

    -- Platform-specific liblldb path
    local liblldb_path
    if vim.fn.has('mac') == 1 then
      liblldb_path = extension_path .. 'lldb/lib/liblldb.dylib'
    else
      liblldb_path = extension_path .. 'lldb/lib/liblldb.so'
    end

    vim.g.rustaceanvim = {
      dap = {
        adapter = require('rustaceanvim.config').get_codelldb_adapter(codelldb_path, liblldb_path),
      },
      server = {
        on_attach = function(client, bufnr)
          -- Enable inlay hints (shows lifetimes, parameter names, inferred types, etc.)
          if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end

          require('which-key').add {
            {
              '<C-space>',
              function()
                vim.cmd.RustLsp { 'hover', 'actions' }
              end,
              desc = 'Rust hover actions',
              buffer = bufnr,
            },
            {
              '<Leader>ca',
              function()
                vim.cmd.RustLsp { 'codeAction' }
              end,
              desc = 'Rust [C]ode [A]ctions',
              buffer = bufnr,
            },
            {
              '<Leader>r',
              group = '[R]ust',
              buffer = bufnr,
            },
            {
              '<Leader>rr',
              function()
                vim.cmd.RustLsp('runnables')
              end,
              desc = '[R]unnables',
              buffer = bufnr,
            },
            {
              '<Leader>rd',
              function()
                vim.cmd.RustLsp('debuggables')
              end,
              desc = '[D]ebuggables',
              buffer = bufnr,
            },
            {
              '<Leader>rt',
              function()
                vim.cmd.RustLsp('testables')
              end,
              desc = '[T]estables',
              buffer = bufnr,
            },
            {
              '<Leader>re',
              function()
                vim.cmd.RustLsp('expandMacro')
              end,
              desc = '[E]xpand Macro',
              buffer = bufnr,
            },
            {
              '<Leader>rc',
              function()
                vim.cmd.RustLsp('openCargo')
              end,
              desc = 'Open [C]argo.toml',
              buffer = bufnr,
            },
            {
              '<Leader>rp',
              function()
                vim.cmd.RustLsp('parentModule')
              end,
              desc = '[P]arent Module',
              buffer = bufnr,
            },
          }
        end,
        default_settings = {
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
            },
            check = {
              command = 'clippy',
            },
            procMacro = {
              enable = true,
            },
            inlayHints = {
              lifetimeElisionHints = {
                enable = 'always',
              },
            },
          },
        },
      },
      tools = {
        hover_actions = {
          auto_focus = true,
        },
      },
    }
  end,
}
