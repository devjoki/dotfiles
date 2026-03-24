return {
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'folke/which-key.nvim',
    },
    config = function()

      local function on_attach(bufnr)
        local api = require('nvim-tree.api')

        -- Default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- Register keybindings with which-key
        require('which-key').add({
          -- Smart-splits navigation
          {
            '<C-h>',
            function()
              require('smart-splits').move_cursor_left()
            end,
            desc = 'Move to left window',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<C-j>',
            function()
              require('smart-splits').move_cursor_down()
            end,
            desc = 'Move to bottom window',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<C-k>',
            function()
              require('smart-splits').move_cursor_up()
            end,
            desc = 'Move to top window',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<C-l>',
            function()
              require('smart-splits').move_cursor_right()
            end,
            desc = 'Move to right window',
            buffer = bufnr,
            mode = 'n',
          },
          -- Smart-splits resizing
          {
            '<A-h>',
            function()
              require('smart-splits').resize_left()
            end,
            desc = 'Resize window left',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<A-j>',
            function()
              require('smart-splits').resize_down()
            end,
            desc = 'Resize window down',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<A-k>',
            function()
              require('smart-splits').resize_up()
            end,
            desc = 'Resize window up',
            buffer = bufnr,
            mode = 'n',
          },
          {
            '<A-l>',
            function()
              require('smart-splits').resize_right()
            end,
            desc = 'Resize window right',
            buffer = bufnr,
            mode = 'n',
          },
        })
      end

      require('nvim-tree').setup {
        sync_root_with_cwd = true,
        sort = {
          sorter = 'case_sensitive',
        },
        view = {
          -- width = 30,
          adaptive_size = true,
        },
        renderer = {
          group_empty = true,
          highlight_git = true,
          icons = {
            show = {
              git = true,
              folder = true,
              file = true,
              folder_arrow = true,
            },
            glyphs = {
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        filters = {
          dotfiles = false, -- Show dotfiles by default (toggle with 'H')
          custom = { '.git', 'node_modules', '.cache' }, -- Always hide these
        },
        update_focused_file = {
          enable = true,
          update_root = false, -- Don't change root when opening files
        },
        diagnostics = {
          enable = false, -- Disabled due to sign compatibility issues
        },
        git = {
          enable = true,
          ignore = false, -- Show gitignored files
        },
        actions = {
          open_file = {
            quit_on_open = false,
            window_picker = {
              enable = true,
            },
          },
        },
        trash = {
          cmd = "trash",
          require_confirm = true,
        },
        live_filter = {
          prefix = "[FILTER]: ",
          always_show_folders = false,
        },
        on_attach = on_attach,
      }

      -- Function to find all src directories in multi-module projects
      local function find_all_src_dirs(dir_type)
        local search_path = 'src/' .. dir_type
        local cwd = vim.fn.getcwd()

        -- Use find command to locate all matching directories
        local find_cmd = string.format(
          "find %s -type d -path '*/%s' 2>/dev/null",
          vim.fn.shellescape(cwd),
          search_path
        )

        local output = vim.fn.system(find_cmd)
        local dirs = {}

        for line in output:gmatch("[^\r\n]+") do
          if line ~= '' then
            table.insert(dirs, line)
          end
        end

        return dirs
      end

      -- Function to navigate to a directory in nvim-tree and expand it
      local function navigate_to_dir(path)
        local api = require('nvim-tree.api')

        -- Open nvim-tree if not open
        if not api.tree.is_visible() then
          api.tree.open()
        end

        -- Find and reveal the directory, with open=true to expand parent folders
        api.tree.find_file({ open = true, focus = true, buf = path })

        -- Wait a bit then expand the target directory itself
        vim.schedule(function()
          local node = api.tree.get_node_under_cursor()
          if node and node.type == 'directory' then
            if not node.open then
              api.node.open.edit()
            end
          end
        end)

        vim.notify('Navigated and expanded: ' .. path, vim.log.levels.INFO)
      end

      -- Function to jump to Java directories with module and subfolder selection
      local function jump_to_java_dir(dir_type)
        -- Find all matching src directories
        local src_dirs = find_all_src_dirs(dir_type)

        if #src_dirs == 0 then
          vim.notify('No ' .. dir_type .. ' directories found (src/' .. dir_type .. ')', vim.log.levels.WARN)
          return
        end

        local function select_subfolder(src_path)
          -- Check which subfolders exist (java and/or resources)
          local java_path = src_path .. '/java'
          local resources_path = src_path .. '/resources'

          local subfolders = {}
          if vim.fn.isdirectory(java_path) == 1 then
            table.insert(subfolders, { name = 'java', path = java_path })
          end
          if vim.fn.isdirectory(resources_path) == 1 then
            table.insert(subfolders, { name = 'resources', path = resources_path })
          end

          if #subfolders == 0 then
            vim.notify('No java or resources folders found in: ' .. src_path, vim.log.levels.WARN)
            return
          elseif #subfolders == 1 then
            -- Only one subfolder, navigate directly
            navigate_to_dir(subfolders[1].path)
          else
            -- Multiple subfolders, let user choose
            local choices = {}
            for i, folder in ipairs(subfolders) do
              choices[i] = folder.name
            end

            vim.ui.select(choices, {
              prompt = 'Select subfolder:',
            }, function(choice, idx)
              if idx then
                navigate_to_dir(subfolders[idx].path)
              end
            end)
          end
        end

        if #src_dirs == 1 then
          -- Only one module found, go to subfolder selection
          select_subfolder(src_dirs[1])
        else
          -- Multiple modules found, let user choose module first
          local choices = {}
          for i, path in ipairs(src_dirs) do
            -- Extract module name (parent directory before src/)
            local module_name = path:match("([^/]+)/src/" .. dir_type)
            if not module_name then
              module_name = path:match("([^/]+)$")
            end
            choices[i] = string.format("%s (%s)", module_name, path)
          end

          vim.ui.select(choices, {
            prompt = 'Select ' .. dir_type .. ' module:',
          }, function(choice, idx)
            if idx then
              select_subfolder(src_dirs[idx])
            end
          end)
        end
      end

      local function jump_to_java_main()
        jump_to_java_dir('main')
      end

      local function jump_to_java_test()
        jump_to_java_dir('test')
      end

      -- Function to search for folders using Telescope and navigate to them
      local function search_and_navigate_to_folder()
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        -- Find all directories in project
        local find_command = { 'find', '.', '-type', 'd', '-not', '-path', '*/\\.git/*', '-not', '-path', '*/node_modules/*' }

        pickers
          .new({}, {
            prompt_title = 'Find Folder',
            finder = finders.new_oneshot_job(find_command, {}),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                  local folder_path = vim.fn.getcwd() .. '/' .. selection[1]
                  navigate_to_dir(folder_path)
                end
              end)
              return true
            end,
          })
          :find()
      end

      -- Register global keymaps with which-key
      require('which-key').add {
        { '<leader>wf', group = '[F]iles (NvimTree)' },
        { '<leader>wft', ':NvimTreeToggle<CR>', mode = { 'n', 'v' }, desc = '[T]oggle tree' },
        { '<leader>wff', ':NvimTreeFindFile<CR>', mode = { 'n', 'v' }, desc = '[F]ind current file in tree' },
        { '<leader>wfd', search_and_navigate_to_folder, mode = { 'n', 'v' }, desc = 'Search for [D]irectory' },
        { '<leader>wfc', ':NvimTreeCollapse<CR>', mode = { 'n', 'v' }, desc = '[C]ollapse all folders' },
        {
          '<leader>wfo',
          function()
            require('nvim-tree.api').tree.expand_all()
          end,
          mode = { 'n', 'v' },
          desc = '[O]pen/Expand all folders',
        },
        { '<leader>wfj', group = '[J]ava directories' },
        {
          '<leader>wfjm',
          jump_to_java_main,
          mode = { 'n', 'v' },
          desc = 'Jump to [M]ain package',
        },
        {
          '<leader>wfjt',
          jump_to_java_test,
          mode = { 'n', 'v' },
          desc = 'Jump to [T]est package',
        },
      }
    end,
  },
}
