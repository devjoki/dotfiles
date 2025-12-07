return {
  {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      -- providers: order matters, first available is used
      providers = {
        'lsp',
        'treesitter',
        'regex',
      },
      -- delay in milliseconds before highlighting
      delay = 100,
      -- filetypes to exclude
      filetypes_denylist = {
        'dirvish',
        'fugitive',
        'alpha',
        'NvimTree',
        'lazy',
        'neogitstatus',
        'Trouble',
        'lir',
        'Outline',
        'spectre_panel',
        'toggleterm',
        'DressingSelect',
        'TelescopePrompt',
      },
      -- modes to illuminate in
      modes_denylist = {},
      -- use treesitter to find references when possible
      under_cursor = true,
      -- large files performance
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { 'lsp' },
      },
      -- min number of matches required to illuminate
      min_count_to_highlight = 1,
    },
    config = function(_, opts)
      require('illuminate').configure(opts)

      -- Keymaps for navigating between references (with wrapping)
      require('which-key').add {
        {
          ']r',
          function()
            require('illuminate').goto_next_reference(true) -- wrap = true
          end,
          desc = 'Next reference (illuminate)',
          mode = 'n',
        },
        {
          '[r',
          function()
            require('illuminate').goto_prev_reference(true) -- wrap = true
          end,
          desc = 'Previous reference (illuminate)',
          mode = 'n',
        },
      }
    end,
  },
}
