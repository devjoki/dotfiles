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
          name = '[C]ode',
        },
        {
          '<leader>d',
          name = '[D]ocument',
        },
        {
          '<leader>r',
          name = '[R]ename',
        },
        {
          '<leader>s',
          name = '[S]earch',
        },
        {
          '<leader>w',
          name = '[W]orkspace',
        },
        {
          '<leader>g',
          name = '[G]it',
        },
        {
          '<leader>p',
          name = '[P]ersistance',
        },
        {
          '<leader>t',
          name = '[T]rouble',
        },
        {
          '<leader>b',
          name = '[B]uffers',
        },
        {
          '<leader>u',
          name = '[U]tils',
        },
        {
          '<leader>up',
          name = '[P]rint[U]tils',
        },
      }, work_cfg))
    end,
  },
}
