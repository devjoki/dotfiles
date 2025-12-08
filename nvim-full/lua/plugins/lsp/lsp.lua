-- lua/plugins/lsp.lua
return {
  -- Mason core
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    opts = {
      ui = { border = 'rounded' },
      PATH = 'prepend', -- Prepend Mason's bin to PATH so LSPs can be found
    },
    config = function(_, opts)
      require('mason').setup(opts)

      -- Ensure jdtls is installed (jdtls is special, not managed by mason-lspconfig)
      -- Note: java-debug-adapter and java-test are handled by mason-nvim-dap in debug.lua
      local mr = require('mason-registry')
      local p = mr.get_package('jdtls')
      if not p:is_installed() then
        p:install()
      end
    end,
  },

  -- Mason bridge for lspconfig
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      -- list the servers you actually want installed
      ensure_installed = {
        'lua_ls',
        'bashls',
        'jsonls',
        'yamlls',
        'gopls',
        'ts_ls', -- typescript-language-server (new name in lspconfig)
        'eslint',
        'pyright',
        'zls', -- Zig language server
        -- NOTE: do NOT put jdtls here – jdtls is special (we start it per-project below)
      },
      automatic_installation = true,
      -- Disable automatic setup since we're using vim.lsp.config directly
      handlers = {},
    },
  },

  -- Core LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'folke/neodev.nvim', -- nicer Lua dev experience
      'folke/which-key.nvim',
    },
    config = function()
      require('neodev').setup {}

      -- Capabilities (add cmp if you use it)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      pcall(function()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
      end)

      -- Global LSP keybindings (not buffer-specific)
      require('which-key').add {
        {
          '<leader>wlr',
          function()
            -- Restart LSP for current buffer
            vim.cmd 'LspRestart'
            vim.notify('LSP restarted', vim.log.levels.INFO)
          end,
          desc = '[L]SP [R]estart',
        },
        {
          '<leader>er',
          function()
            -- Close and reopen current file to reattach LSP
            local filepath = vim.fn.expand('%:p')
            if filepath == '' then
              vim.notify('No file to reopen', vim.log.levels.WARN)
              return
            end
            vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
            vim.notify('File reopened', vim.log.levels.INFO)
          end,
          desc = '[R]eopen buffer',
        },
      }

      -- Common on_attach
      local on_attach = function(client, bufnr)
        require('which-key').add {
          { 'gd', vim.lsp.buf.definition, desc = 'Go to definition', buffer = bufnr },
          { 'gr', vim.lsp.buf.references, desc = 'References', buffer = bufnr },
          { 'K', vim.lsp.buf.hover, desc = 'Hover', buffer = bufnr },
          { '<leader>rn', vim.lsp.buf.rename, desc = 'Rename', buffer = bufnr },
          { '<leader>ca', vim.lsp.buf.code_action, desc = 'Code action', buffer = bufnr },
          {
            '<leader>fd',
            function()
              vim.diagnostic.open_float { border = 'rounded' }
            end,
            desc = 'Line diagnostics',
            buffer = bufnr,
          },
          { '[d', vim.diagnostic.goto_prev, desc = 'Prev diagnostic', buffer = bufnr },
          { ']d', vim.diagnostic.goto_next, desc = 'Next diagnostic', buffer = bufnr },
        }

        -- formatting (prefer none for jdtls; we set it in ftplugin/java.lua)
        if client.supports_method 'textDocument/formatting' then
          require('which-key').add {
            {
              '<leader>f',
              function()
                vim.lsp.buf.format { async = true }
              end,
              desc = 'Format buffer',
              buffer = bufnr,
            },
          }
        end
      end

      -- Diagnostics look
      vim.diagnostic.config {
        virtual_text = { spacing = 2, prefix = '●' },
        float = { border = 'rounded' },
        severity_sort = true,
      }

      -- Servers (excluding jdtls!)
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        ts_ls = {},
        bashls = {},
        jsonls = {},
        yamlls = {},
        gopls = {},
        pyright = {},
        eslint = {},
        zls = {},
      }

      -- Use the new vim.lsp.config API (Neovim 0.11+)
      for name, opts in pairs(servers) do
        vim.lsp.config[name] = vim.tbl_extend('force', vim.lsp.config[name] or {}, {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = opts.settings,
        })
        vim.lsp.enable(name)
      end

      -- Completely disable automatic jdtls startup (we handle it in ftplugin/java.lua)
      -- We must set cmd to a function that does nothing to prevent auto-start
      vim.lsp.config.jdtls = {
        cmd = function()
          return nil
        end,
        filetypes = {},
        autostart = false,
      }
    end,
  },
}
