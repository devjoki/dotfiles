-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.api.nvim_set_var('shell', '/bin/zsh')
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`
vim.opt.termguicolors = true -- bufferlinme
-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history with custom handling for long paths
vim.opt.undofile = true
local undodir = vim.fn.stdpath('data') .. '/undo'
vim.fn.mkdir(undodir, 'p')
vim.opt.undodir = undodir

-- Hook into Neovim's undo file creation to shorten long filenames
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('UndoFileShorten', { clear = true }),
  callback = function(ev)
    local filepath = vim.api.nvim_buf_get_name(ev.buf)
    if filepath and filepath ~= '' then
      -- Calculate what the undo filename would be
      local encoded = filepath:gsub('/', '%%'):gsub(':', '%%')
      -- If it's too long (approaching filesystem limit), use a hash-based name
      if #encoded > 200 then
        local hash = vim.fn.sha256(filepath):sub(1, 32)
        local basename = vim.fn.fnamemodify(filepath, ':t')
        -- Set buffer-local undofile name by creating a custom undo directory
        local custom_undo = undodir .. '/' .. basename .. '.' .. hash
        vim.bo[ev.buf].undofile = false  -- Disable default
        -- We'll manually manage undo persistence
        vim.api.nvim_create_autocmd('BufWritePost', {
          buffer = ev.buf,
          callback = function()
            vim.cmd('wundo! ' .. vim.fn.fnameescape(custom_undo))
          end,
        })
        vim.api.nvim_create_autocmd('BufReadPost', {
          buffer = ev.buf,
          once = true,
          callback = function()
            if vim.fn.filereadable(custom_undo) == 1 then
              vim.cmd('silent! rundo ' .. vim.fn.fnameescape(custom_undo))
            end
          end,
        })
      end
    end
  end,
})

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
