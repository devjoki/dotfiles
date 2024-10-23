return {
  {
    'mfussenegger/nvim-lint',
    event = 'VeryLazy',
    config = function()
      require 'config.plugin.lint'
    end,
  },
}
