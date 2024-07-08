return {

  ensure_installed = {
    -- 'kotlin-language-server',
    -- 'ktlint',
    'tsserver',
    'jdtls',
    'stylua',
    'lua_ls',
    'eslint_d',
    'prettier',
    'prettierd',
    'rust_analyzer',
    'codelldb',
    'bashls',
    'shellcheck',
    'tailwindcss',
    'texlab',
  },
  handler_config = {
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    --    https://github.com/pmizio/typescript-tools.nvim
    --
    -- But for many setups, the LSP (`tsserver`) will work just fine
    -- tsserver = {},
    --

    lua_ls = {
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          },
          diagnostics = {
            globals = { 'vim' },
          },
          workspace = {
            library = {
              vim.env.VIMRUNTIME,
            },
          },
          completion = {
            callSnippet = 'Replace',
          },
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
        },
      },
    },
    -- ['kotlin_language_server'] = {},
    tsserver = {},
    bashls = {
      filetypes = { 'sh', 'zsh' },
    },
  },
}
