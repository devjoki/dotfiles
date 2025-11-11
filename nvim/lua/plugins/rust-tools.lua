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
    local liblldb_path = extension_path .. 'lldb/lib/liblldb.so'

    vim.g.rustaceanvim = {
      dap = {
        adapter = {
          type = 'executable',
          command = codelldb_path,
          args = { '--port', '${port}' },
          name = 'codelldb',
        },
      },
      server = {
        on_attach = function(client, bufnr)
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
              '<Leader>a',
              function()
                vim.cmd.RustLsp { 'codeAction' }
              end,
              desc = 'Rust code actions',
              buffer = bufnr,
            },
          }
        end,
        default_settings = {
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
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
