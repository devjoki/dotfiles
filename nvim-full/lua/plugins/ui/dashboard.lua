return {
  {
    'rmagatti/auto-session',
    lazy = false,
    dependencies = { 'folke/which-key.nvim' },
    opts = {
      auto_session_suppress_dirs = { '~/', '~/Downloads', '~/Documents', '/tmp' },
      auto_save_enabled = true,
      auto_restore_enabled = false, -- Don't auto-restore, use manual keybindings
      auto_session_use_git_branch = false,
      -- Built-in nvim-tree handling
      pre_save_cmds = { 'NvimTreeClose' },
      post_restore_cmds = {
        function()
          -- Re-trigger FileType detection for all buffers to ensure ftplugin files run
          -- This is crucial for LSP (like JDTLS) to attach and set up keybindings
          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) then
              local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
              if ft ~= '' then
                vim.api.nvim_buf_call(bufnr, function()
                  vim.cmd('doautocmd FileType ' .. ft)
                end)
              end
            end
          end

          -- Delay NvimTreeOpen slightly to ensure proper restoration
          vim.defer_fn(function()
            if vim.fn.exists(':NvimTreeOpen') > 0 then
              vim.cmd('NvimTreeOpen')

              -- After opening nvim-tree, switch focus back to a normal file buffer
              vim.defer_fn(function()
                -- Find the first normal buffer (not special buffers)
                for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                  if vim.api.nvim_buf_is_loaded(bufnr) then
                    local bufname = vim.api.nvim_buf_get_name(bufnr)
                    local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
                    local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')

                    -- Check if it's a normal file (not nvim-tree, dashboard, etc.)
                    if bufname ~= '' and buftype == '' and ft ~= 'NvimTree' and ft ~= 'dashboard' then
                      -- Find the window showing this buffer and focus it
                      for _, winid in ipairs(vim.api.nvim_list_wins()) do
                        if vim.api.nvim_win_get_buf(winid) == bufnr then
                          vim.api.nvim_set_current_win(winid)
                          return
                        end
                      end
                    end
                  end
                end
              end, 50)
            end
          end, 100)
        end
      },
      session_lens = {
        load_on_setup = true,
        theme_conf = { border = true },
        previewer = false,
      },
    },
    config = function(_, opts)
      require('auto-session').setup(opts)

      -- Register keymaps with which-key
      require('which-key').add {
        { '<leader>ws', group = '[S]ession' },
        { '<leader>wss', '<cmd>AutoSession save<cr>', mode = { 'n', 'v' }, desc = '[S]ave session' },
        { '<leader>wsl', '<cmd>AutoSession restore<cr>', mode = { 'n', 'v' }, desc = '[L]oad session' },
        { '<leader>wsd', '<cmd>AutoSession delete<cr>', mode = { 'n', 'v' }, desc = '[D]elete session' },
        { '<leader>wsf', '<cmd>AutoSession search<cr>', mode = { 'n', 'v' }, desc = '[F]ind session' },
        { '<leader>wd', [[:execute 'tabnew | Dashboard'<cr>]], mode = { 'n', 'v' }, desc = 'Open Dashboard' },
      }
    end,
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
            { action = "AutoSession restore",             desc = " Restore Session",           icon = " ", key = "s" },
            { action = 'lua require("which-key").show("<leader>uc")',                                 desc = " UI Color Scheme",           icon = "󰏘 ", key = "u" },
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
