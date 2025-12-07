return {

  ensure_installed = {
    -- 'kotlin-language-server',
    -- 'ktlint',
    'ts_ls',
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
    'latexindent',
    'bibtex-tidy',
    'terraformls',
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
    texlab = {
      settings = {
        texlab = {
          build = {
            executable = 'latexmk',
            args = {
              '-pdf',
              '-interaction=nonstopmode',
              '-synctex=1',
              '-outdir=build',
              '-auxdir=build',
              '%f',
            },
            onSave = false, -- Let VimTeX handle compilation
            forwardSearchAfter = false,
          },
          auxDirectory = 'build',
          forwardSearch = {
            executable = 'displayline',  -- For Skim
            args = { '%l', '%p', '%f' },
            -- For Zathura use: executable = 'zathura', args = { '--synctex-forward', '%l:1:%f', '%p' }
          },
          chktex = {
            onOpenAndSave = true,
            onEdit = false,
          },
          diagnosticsDelay = 300,
          latexFormatter = 'latexindent',
          latexindent = {
            ['local'] = nil, -- Path to local indentconfig.yaml
            modifyLineBreaks = false,
          },
          bibtexFormatter = 'texlab',
          formatterLineLength = 80,
        },
      },
    },
  },
}
