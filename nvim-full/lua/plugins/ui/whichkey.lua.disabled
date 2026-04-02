local success, work = pcall(require, 'work')
local work_cfg = success and work.which_key_config() or {}
return {
  {                     -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy', -- Sets the loading event to 'VimEnter' 'VeryLazy'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').add(require('utils').merge_tables({
        {
          '<leader>c',
          group = '[C]ode',
        },
        {
          '<leader>r',
          group = '[R]ename',
        },
        {
          '<leader>s',
          group = '[S]earch',
        },
        {
          '<leader>w',
          group = '[W]orkspace',
        },
        -- Diagnostics moved to workspace group
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
        {
          '<leader>?',
          function()
            require('which-key').show('<leader>')
          end,
          desc = 'Show leader keybindings',
        },
        {
          '<leader>g',
          group = '[G]it',
        },
        {
          '<leader>p',
          group = '[P]ersistance',
        },
        {
          '<leader>t',
          group = '[T]rouble',
        },
        {
          '<leader>u',
          group = '[U]tils',
        },
        -- Utility keymaps (defined in default_keymaps.lua)
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
