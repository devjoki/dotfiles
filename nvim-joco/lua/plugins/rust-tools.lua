return {
  'simrat39/rust-tools.nvim',
  -- event = 'VeryLazy',
  dependencies = {
    'jay-babu/mason-nvim-dap.nvim',
  },
  config = function()
    local rt = require 'rust-tools'
    local mason_registry = require 'mason-registry'

    -- print(mason_registry.is_installed 'codelldb')
    -- print('location: ' .. mason_registry.get_package 'codelldb')
    -- local codelldb = mason_registry.get_package 'codelldb'
    -- print(codelldb)
    -- local extension_path = codelldb:get_install_path() .. '/extension/'
    -- print(codelldb.get_install_path())
    -- local codelldb_path = extension_path .. 'adapter/codelldb'
    -- local liblldb_path = extension_path .. 'lldb/lib/liblldb.dylib'

    local home = os.getenv 'HOME'
    local nvim_app_name = vim.env.NVIM_APPNAME or 'nvim'
    local share_path = home .. '/.local/share/' .. nvim_app_name
    local mason_path = share_path .. '/mason/'
    local extension_path = mason_path .. 'packages/codelldb/extension/'
    local codelldb_path = extension_path .. 'adapter/codelldb'
    local liblldb_path = extension_path .. 'lldb/lib/liblldb.so'

    rt.setup {
      dap = {
        adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
      },
      server = {
        on_attach = function(_, bufnr)
          -- Hover actions
          vim.keymap.set('n', '<C-space>', rt.hover_actions.hover_actions, { buffer = bufnr })
          -- Code action groups
          vim.keymap.set('n', '<Leader>a', rt.code_action_group.code_action_group, { buffer = bufnr })
        end,
      },
      tools = {
        hover_actions = {
          auto_focus = true,
        },
      },
    }
  end,
}
