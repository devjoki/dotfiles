local success, work = pcall(require, 'work')
local work_cfg = success and work.which_key_config() or {}
return {
  { -- Useful plugin to show you pending keybinds.
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
          '<leader>d',
          group = '[D]ocument',
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
          '<leader>bw',
          [[<cmd>bw <CR>]],
          desc = '[W]ipe buffer',
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
