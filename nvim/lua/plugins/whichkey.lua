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
          '<leader>b',
          group = '[B]uffers',
        },
        {
          '<leader>u',
          group = '[U]tils',
        },
        {
          '<leader>up',
          group = '[P]rint[U]tils',
        },
      }, work_cfg))
    end,
  },
}
