return {
  'catppuccin/nvim',
  name = 'catppuccin',
  lazy = false,
  priority = 1000,
  opts = {
    flavour = 'mocha', -- latte, frappe, macchiato, mocha
    transparent_background = false,
    show_end_of_buffer = false,
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      telescope = true,
      which_key = true,
      illuminate = true,
      native_lsp = {
        enabled = true,
        inlay_hints = {
          background = true,
        },
      },
    },
  },
}
