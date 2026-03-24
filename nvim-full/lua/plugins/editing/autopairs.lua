return {
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      local autopairs = require 'nvim-autopairs'
      autopairs.setup {
        check_ts = true, -- Use treesitter for better pair detection
        ts_config = {
          lua = { 'string' }, -- Don't add pairs in lua string treesitter nodes
          javascript = { 'template_string' },
          java = false, -- Don't check treesitter on java
        },
        disable_filetype = { 'TelescopePrompt', 'vim' },
        disable_in_macro = false, -- Enable in macros
        disable_in_visualblock = false, -- Enable in visual block mode
        disable_in_replace_mode = true,
        ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=], -- Ignore alphanumeric and some special chars
        enable_moveright = true,
        enable_afterquote = true, -- Add bracket pairs after quote
        enable_check_bracket_line = true, -- Check if bracket is in same line
        enable_bracket_in_quote = true, -- Enable bracket inside quotes
        enable_abbr = false, -- Trigger abbreviation
        break_undo = true, -- Break undo sequence on pair insertion
        map_cr = true, -- Map <CR> key
        map_bs = true, -- Map backspace key
        map_c_h = false, -- Map <C-h> to delete pair
        map_c_w = false, -- Map <C-w> to delete pair
        fast_wrap = {
          map = '<M-e>', -- Alt-e to fast wrap
          chars = { '{', '[', '(', '"', "'" },
          pattern = [=[[%'%"%>%]%)%}%,]]=],
          end_key = '$',
          keys = 'qwertyuiopzxcvbnmasdfghjkl',
          check_comma = true,
          highlight = 'Search',
          highlight_grey = 'Comment',
        },
      }

      -- Integration with nvim-cmp
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
    dependencies = {
      'hrsh7th/nvim-cmp',
      'nvim-treesitter/nvim-treesitter',
    },
  },
}
