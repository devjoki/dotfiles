-- Load all colorscheme plugins from the colorschemes directory
local colorschemes = {
  require('plugins.ui.colorschemes.tokyonight'),
  require('plugins.ui.colorschemes.catppuccin'),
  require('plugins.ui.colorschemes.kanagawa'),
  require('plugins.ui.colorschemes.rose-pine'),
  require('plugins.ui.colorschemes.gruvbox'),
}

-- Add a minimal plugin to handle colorscheme persistence after all colorschemes load
table.insert(colorschemes, {
  'folke/which-key.nvim', -- Piggyback on which-key since it's already loaded
  lazy = false,
  priority = 998, -- Load after colorschemes (which have priority 1000)
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
            local state = require('telescope.state')

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
      once = true, -- Only run once
    })
  end,
})

return colorschemes
