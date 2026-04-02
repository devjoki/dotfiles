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

      -- Wait for registry to be ready, then install jdtls if needed
      if mr.is_installed('jdtls') then
        return -- Already installed
      end

      -- Use pcall to handle case where registry isn't fully loaded yet
      local ok, pkg = pcall(mr.get_package, 'jdtls')
      if ok and pkg and not pkg:is_installed() then
        pkg:install()
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

      -- Global LspAttach: applies to ALL LSP clients (including rustaceanvim, jdtls, etc.)
      -- Uses vim.schedule to run after Neovim's built-in LspAttach defaults
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          vim.schedule(function()
            local buf = args.buf
            require('which-key').add {
              { 'gd', '<cmd>Telescope lsp_definitions<CR>', desc = 'Go to definition', buffer = buf },
              { 'grr', '<cmd>Telescope lsp_references<CR>', desc = 'References', buffer = buf },
              { 'gi', '<cmd>Telescope lsp_implementations<CR>', desc = 'Implementations', buffer = buf },
              { 'gy', '<cmd>Telescope lsp_type_definitions<CR>', desc = 'Type definitions', buffer = buf },
              { '<leader>wls', '<cmd>Telescope lsp_document_symbols<CR>', desc = 'Document [S]ymbols', buffer = buf },
              { '<leader>wlS', '<cmd>Telescope lsp_workspace_symbols<CR>', desc = 'Workspace [S]ymbols', buffer = buf },
              { '<leader>wld', '<cmd>Telescope diagnostics<CR>', desc = '[D]iagnostics', buffer = buf },
            }
          end)
        end,
      })

      -- Common on_attach
      local on_attach = function(client, bufnr)
        require('which-key').add {
          { 'K', vim.lsp.buf.hover, desc = 'Hover', buffer = bufnr },
          { '<leader>rn', vim.lsp.buf.rename, desc = 'Rename', buffer = bufnr },
          { '<leader>ca', vim.lsp.buf.code_action, desc = 'Code action', buffer = bufnr },
          {
            '<leader>ch',
            function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
            end,
            desc = 'Toggle inlay [H]ints',
            buffer = bufnr,
          },
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
            { '<leader>f', group = '[F]ormat/Diagnostics', buffer = bufnr },
            {
              '<leader>ff',
              function()
                vim.lsp.buf.format { async = true }
              end,
              desc = '[F]ormat buffer',
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
