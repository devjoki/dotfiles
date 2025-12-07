-- Shared colorscheme plugins (used by both nvim-full and nvim-slim)
-- Includes Telescope-based colorscheme picker

return {
  -- Colorscheme picker with Telescope and persistence
  {
    'folke/which-key.nvim',
    optional = true,
    keys = {
      {
        '<leader>uc',
        function()
          local persist = require('colorscheme-persist')

          -- Define allowed colorschemes (only our custom themes)
          local allowed_colorschemes = {
            'tokyonight',
            'tokyonight-night',
            'tokyonight-storm',
            'tokyonight-moon',
            'tokyonight-day',
            'catppuccin',
            'catppuccin-mocha',
            'catppuccin-frappe',
            'catppuccin-macchiato',
            'catppuccin-latte',
            'kanagawa',
            'kanagawa-wave',
            'kanagawa-dragon',
            'kanagawa-lotus',
            'rose-pine',
            'rose-pine-main',
            'rose-pine-moon',
            'rose-pine-dawn',
            'gruvbox',
          }

          -- Create a lookup table for faster checks
          local allowed_set = {}
          for _, name in ipairs(allowed_colorschemes) do
            allowed_set[name] = true
          end

          require('telescope.builtin').colorscheme({
            enable_preview = true,
            attach_mappings = function(prompt_bufnr, map)
              local actions = require('telescope.actions')
              local action_state = require('telescope.actions.state')
              local finders = require('telescope.finders')

              -- Filter colorschemes to only show allowed ones
              local current_picker = action_state.get_current_picker(prompt_bufnr)
              local all_colorschemes = vim.fn.getcompletion('', 'color')
              local filtered_colorschemes = {}

              for _, colorscheme in ipairs(all_colorschemes) do
                if allowed_set[colorscheme] then
                  table.insert(filtered_colorschemes, colorscheme)
                end
              end

              -- Replace the finder with filtered results
              current_picker:refresh(finders.new_table({
                results = filtered_colorschemes,
              }), { reset_prompt = false })

              -- Save colorscheme on Enter
              actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                  vim.schedule(function()
                    vim.cmd.colorscheme(selection.value)
                    persist.save_colorscheme(selection.value)
                  end)
                end
              end)

              return true
            end,
          })
        end,
        desc = '[U]I [C]olorscheme (switch)',
      },
    },
    init = function()
      -- Apply saved colorscheme on VimEnter (after all plugins are loaded)
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          local persist = require('colorscheme-persist')
          persist.apply_saved_scheme()
        end,
        once = true,
      })
    end,
  },

  -- Tokyo Night
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    opts = {
      style = 'night',
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
      },
    },
  },

  -- Catppuccin
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      flavour = 'mocha',
      transparent_background = false,
      term_colors = true,
      styles = {
        comments = { 'italic' },
        conditionals = { 'italic' },
      },
    },
  },

  -- Kanagawa
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    opts = {
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,
      terminalColors = true,
      theme = 'wave',
    },
  },

  -- Rose Pine
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000,
    opts = {
      variant = 'main',
      dark_variant = 'main',
      disable_background = false,
      disable_float_background = false,
      disable_italics = false,
    },
  },

  -- Gruvbox
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    opts = {
      terminal_colors = true,
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true,
      contrast = '',
      palette_overrides = {},
      overrides = {},
      dim_inactive = false,
      transparent_mode = false,
    },
  },
}
