-- Telescope - Fuzzy finder
-- Shared between nvim-full and nvim-slim
-- Note: LSP-specific pickers (diagnostics) are added in nvim-full

return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/which-key.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons' },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              -- ['<c-enter>'] = 'to_fuzzy_refine',
            },
          },
        },
        pickers = {
          colorscheme = {
            enable_preview = true,
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'

      -- Register keymaps with which-key
      require('which-key').add {
        { '<leader>sh', builtin.help_tags, desc = '[H]elp' },
        { '<leader>sk', builtin.keymaps, desc = '[K]eymaps' },
        { '<leader>sf', builtin.find_files, desc = '[F]iles' },
        { '<leader>sF', function() builtin.find_files { hidden = true } end, desc = '[F]iles (hidden)' },
        {
          '<leader>sd',
          function()
            local pickers = require('telescope.pickers')
            local finders = require('telescope.finders')
            local conf = require('telescope.config').values
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            local dirs = vim.fn.systemlist('find . -type d -not -path "*/\\.git/*" -not -path "*/node_modules/*" -not -path "*/.cache/*"')

            pickers.new({}, {
              prompt_title = 'Find Directory',
              finder = finders.new_table { results = dirs },
              sorter = conf.generic_sorter({}),
              attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                  local selection = action_state.get_selected_entry()
                  actions.close(prompt_bufnr)
                  local path = vim.fn.fnamemodify(selection[1], ':p')
                  local api = require('nvim-tree.api')
                  api.tree.find_file({ buf = path, open = true, focus = true })
                end)
                return true
              end,
            }):find()
          end,
          desc = '[D]irectories',
        },
        { '<leader>ss', builtin.builtin, desc = '[S]elect Telescope' },
        { '<leader>sw', builtin.grep_string, desc = 'current [W]ord' },
        { '<leader>sg', builtin.live_grep, desc = 'by [G]rep' },
        {
          '<leader>sG',
          function()
            builtin.live_grep { additional_args = { '--hidden', '--glob', '!.git/' } }
          end,
          desc = 'by [G]rep (hidden files)',
        },
        { '<leader>sr', builtin.resume, desc = '[R]esume' },
        { '<leader>s.', builtin.oldfiles, desc = 'Recent Files ("." for repeat)' },
        { '<leader><leader>', builtin.buffers, desc = 'Find existing buffers' },
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

            builtin.colorscheme({
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
        {
          '<leader>/',
          function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
              winblend = 10,
              previewer = false,
            })
          end,
          desc = '[/] Fuzzily search in current buffer',
        },
        {
          '<leader>s/',
          function()
            builtin.live_grep {
              grep_open_files = true,
              prompt_title = 'Live Grep in Open Files',
            }
          end,
          desc = '[/] in Open Files',
        },
        {
          '<leader>sn',
          function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
          end,
          desc = '[N]eovim files',
        },
        {
          '<leader>sd',
          function()
            builtin.find_files {
              find_command = { 'fd', '--type', 'd', '--hidden', '--exclude', '.git' },
              prompt_title = 'Find Directories',
              attach_mappings = function(prompt_bufnr)
                local actions = require('telescope.actions')
                local action_state = require('telescope.actions.state')
                actions.select_default:replace(function()
                  local selection = action_state.get_selected_entry()
                  actions.close(prompt_bufnr)
                  if selection then
                    local path = selection.value
                    if not vim.startswith(path, '/') then
                      path = vim.fn.getcwd() .. '/' .. path
                    end
                    local api = require('nvim-tree.api')
                    api.tree.open()
                    api.tree.find_file(path)
                    local node = api.tree.get_node_under_cursor()
                    if node and not node.open then
                      api.node.open.edit()
                    end
                  end
                end)
                return true
              end,
            }
          end,
          desc = '[D]irectories (focus in tree)',
        },
      }
    end,
  },
}
