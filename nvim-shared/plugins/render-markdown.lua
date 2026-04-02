-- Render markdown inline (headers, tables, code blocks, checkboxes)
-- Shared between nvim-full and nvim-slim

return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
    keys = {
      { '<leader>mt', '<cmd>RenderMarkdown toggle<cr>', desc = '[M]arkdown [T]oggle' },
    },
  },
}
