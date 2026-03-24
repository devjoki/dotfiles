return {
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp',
    dependencies = {
      'rafamadriz/friendly-snippets', -- Collection of snippets for various languages
    },
    config = function()
      local luasnip = require 'luasnip'

      -- Load friendly-snippets
      require('luasnip.loaders.from_vscode').lazy_load()

      -- Load custom snippets from snippets directory
      require('luasnip.loaders.from_lua').lazy_load { paths = vim.fn.stdpath 'config' .. '/snippets' }

      -- Keymaps for snippet navigation using which-key
      require('which-key').add {
        {
          '<C-k>',
          function()
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            end
          end,
          mode = { 'i', 's' },
          desc = 'Snippet: Expand or jump forward',
        },
        {
          '<C-j>',
          function()
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            end
          end,
          mode = { 'i', 's' },
          desc = 'Snippet: Jump backward',
        },
        {
          '<C-l>',
          function()
            if luasnip.choice_active() then
              luasnip.change_choice(1)
            end
          end,
          mode = 'i',
          desc = 'Snippet: Select next choice',
        },
      }
    end,
  },
}
