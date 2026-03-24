-- Which-key extensions for nvim-full
-- Additional keybindings that are specific to the full config
-- (Shared base config is in nvim-shared/plugins/whichkey.lua)

return {
  {
    'folke/which-key.nvim',
    optional = true, -- This plugin is already loaded from shared
    config = function()
      -- Load work config if available
      local success, work = pcall(require, 'work')
      local work_cfg = success and work.which_key_config() or {}

      -- Add full-specific keybindings to the already-loaded which-key
      require('which-key').add(require('utils').merge_tables({
          -- Diagnostics keybindings (LSP-specific)
          {
            '<leader>we',
            vim.diagnostic.open_float,
            mode = { 'n', 'v' },
            desc = 'Show diagnostic [E]rror messages',
          },
          {
            '<leader>wq',
            vim.diagnostic.setloclist,
            mode = { 'n', 'v' },
            desc = 'Open diagnostic [Q]uickfix list',
          },

          -- Which-key exploration keybindings
          {
            '<leader>ww',
            group = '[W]hich-key',
          },
          {
            '<leader>wwe',
            '<cmd>WhichKey<CR>',
            desc = '[E]xplore all keybindings',
          },
          {
            '<leader>wwb',
            function()
              require('which-key').show({ global = false })
            end,
            desc = '[B]uffer keybindings',
          },
          {
            '<leader>wwm',
            function()
              local mode = vim.fn.input('Mode (n/v/i/x/o): ')
              if mode ~= '' then
                require('which-key').show({ mode = mode })
              end
            end,
            desc = '[M]ode keybindings',
          },
          {
            '<leader>wws',
            '<cmd>Telescope keymaps<CR>',
            desc = '[S]earch keybindings',
          },
          {
            '<leader>wwp',
            function()
              local prefix = vim.fn.input('Prefix: ')
              if prefix ~= '' then
                require('which-key').show(prefix)
              end
            end,
            desc = '[P]refix keybindings',
          },

          -- Utility keymaps (defined in utils.lua - full config only)
          {
            '<leader>ue',
            '<cmd>lua require("utils").load_cmd_result_to_buffer() <CR>',
            mode = 'n',
            desc = 'Execute command and load result into a buffer',
          },
          {
            '<leader>ur',
            '<cmd>lua require("utils").save_as_root() <CR>',
            mode = { 'n', 'v' },
            desc = 'Save current buffer as root',
          },
          {
            '<leader>up',
            group = '[P]rint[U]tils',
          },
          {
            '<leader>upm',
            [[<cmd>lua require("utils").print_module() <CR>]],
            mode = { 'n', 'v' },
            desc = 'Prints module by name',
          },
          {
            '<leader>upe',
            [[<cmd>lua require("utils").execute_and_print() <CR>]],
            mode = { 'n', 'v' },
            desc = 'Executes lua code and prints the result',
          },
        }, work_cfg))
    end,
  },
}
