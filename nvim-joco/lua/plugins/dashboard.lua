return {
  {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath 'state' .. '/sessions/'), -- directory where session files are saved
      options = { 'buffers', 'curdir', 'tabpages', 'winsize' }, -- sessionoptions used for saving
      -- pre_save = nil, -- a function to call before saving the session
      save_empty = false, -- don't save if there are no open file buffers
    },
    keys = {
      { '<leader>ps', [[<cmd>lua require("persistence").load()<cr>]], mode = { 'n', 'v' }, desc = 'Restore session for current dir' },
      { '<leader>pl', [[<cmd>lua require("persistence").load({ last = true })<cr>]], mode = { 'n', 'v' }, desc = 'Restore last session' },
      { '<leader>pd', [[<cmd>lua require("persistence").stop()<cr>]], mode = { 'n', 'v' }, desc = 'Prevent saving session on exit' },
      { '<leader>wd', [[:execute 'tabnew | Dashboard'<cr>]], mode = { 'n', 'v' }, desc = 'Open Dashboard' },
    },
  },
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    opts = function()
      local logo = [[
         ▄▄        ▄  ▄               ▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄       ▄▄         ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄    ▄  ▄▄▄▄▄▄▄▄▄▄▄
        ▐░░▌      ▐░▌▐░▌             ▐░▌▐░░░░░░░░░░░▌▐░░▌     ▐░░▌       ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌  ▐░▌▐░░░░░░░░░░░▌
        ▐░▌░▌     ▐░▌ ▐░▌           ▐░▌  ▀▀▀▀█░█▀▀▀▀ ▐░▌░▌   ▐░▐░▌        ▀▀▀▀▀█░█▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░▌ ▐░▌  ▀▀▀▀█░█▀▀▀▀
        ▐░▌▐░▌    ▐░▌  ▐░▌         ▐░▌       ▐░▌     ▐░▌▐░▌ ▐░▌▐░▌             ▐░▌    ▐░▌       ▐░▌▐░▌▐░▌       ▐░▌
        ▐░▌ ▐░▌   ▐░▌   ▐░▌       ▐░▌        ▐░▌     ▐░▌ ▐░▐░▌ ▐░▌ ▄▄▄▄▄▄▄▄▄▄▄ ▐░▌    ▐░▌       ▐░▌▐░▌░▌        ▐░▌
        ▐░▌  ▐░▌  ▐░▌    ▐░▌     ▐░▌         ▐░▌     ▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌▐░▌    ▐░▌       ▐░▌▐░░▌         ▐░▌
        ▐░▌   ▐░▌ ▐░▌     ▐░▌   ▐░▌          ▐░▌     ▐░▌   ▀   ▐░▌ ▀▀▀▀▀▀▀▀▀▀▀ ▐░▌    ▐░▌       ▐░▌▐░▌░▌        ▐░▌
        ▐░▌    ▐░▌▐░▌      ▐░▌ ▐░▌           ▐░▌     ▐░▌       ▐░▌             ▐░▌    ▐░▌       ▐░▌▐░▌▐░▌       ▐░▌
        ▐░▌     ▐░▐░▌       ▐░▐░▌        ▄▄▄▄█░█▄▄▄▄ ▐░▌       ▐░▌        ▄▄▄▄▄█░▌    ▐░█▄▄▄▄▄▄▄█░▌▐░▌ ▐░▌  ▄▄▄▄█░█▄▄▄▄
        ▐░▌      ▐░░▌        ▐░▌        ▐░░░░░░░░░░░▌▐░▌       ▐░▌       ▐░░░░░░░▌    ▐░░░░░░░░░░░▌▐░▌  ▐░▌▐░░░░░░░░░░░▌
         ▀        ▀▀          ▀          ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀         ▀▀▀▀▀▀▀      ▀▀▀▀▀▀▀▀▀▀▀  ▀    ▀  ▀▀▀▀▀▀▀▀▀▀▀
      ]]

      logo = string.rep('\n', 8) .. logo .. '\n\n'

      local opts = {
        theme = 'doom',
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = vim.split(logo, '\n'),
          -- stylua: ignore
          center = {
            { action = 'lua require("utils").load_cmd_result_to_buffer()',                            desc = " Execute CMD",               icon = " ", key = "e" },
            { action = "Telescope find_files",                                                        desc = " Find File",                 icon = " ", key = "f" },
            { action = "ene | startinsert",                                                           desc = " New File",                  icon = " ", key = "n" },
            { action = "Telescope oldfiles",                                                          desc = " Recent Files",              icon = " ", key = "r" },
            { action = "Telescope live_grep",                                                         desc = " Find Text",                 icon = " ", key = "g" },
            { action = [[require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }]], desc = " Config",                    icon = " ", key = "c" },
            { action = [[lua require("persistence").load()]],             desc = " Restore Session",           icon = " ", key = "s" },
            { action = "LazyGit",                                                                     desc = " LazyGit",                   icon = " ", key = "l" },
            { action = "Lazy",                                                                        desc = " Lazy Package Manager",      icon = "󰒲 ", key = "p" },
            { action = "Mason",                                                                       desc = " Mason Package Manager",     icon = " ", key = "m" },
            { action = "NvimTreeToggle",                                                              desc = " File tree toogle",          icon = "󱏒 ", key = "t" },
            { action = "q",                                                                           desc = " Quit",                      icon = " ", key = "q" },
          },
          footer = function()
            local stats = require('lazy').stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(' ', 43 - #button.desc)
        button.key_format = '  %s'
      end

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == 'lazy' then
        vim.cmd.close()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'DashboardLoaded',
          callback = function()
            require('lazy').show()
          end,
        })
      end

      return opts
    end,
  },
}
