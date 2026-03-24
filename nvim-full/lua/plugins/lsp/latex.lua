return {
  'lervag/vimtex',
  lazy = false, -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- PDF Viewer configuration
    -- Choose one based on what you have installed:
    vim.g.vimtex_view_method = 'skim'           -- Skim (recommended for macOS)
    -- vim.g.vimtex_view_method = 'zathura'     -- Zathura
    -- vim.g.vimtex_view_method = 'general'     -- macOS Preview (fallback)

    -- Compiler configuration
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_compiler_latexmk = {
      aux_dir = 'build',
      out_dir = 'build',
      callback = 1,
      continuous = 1,
      executable = 'latexmk',
      options = {
        '-xelatex',  -- Use XeLaTeX instead of pdflatex (required for fontspec)
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
      },
    }

    -- Performance optimizations
    vim.g.vimtex_syntax_enabled = 0  -- Disable VimTeX syntax (using Treesitter/LSP)
    vim.g.vimtex_quickfix_mode = 0   -- Don't auto-open quickfix

    -- TOC configuration
    vim.g.vimtex_toc_config = {
      name = 'TOC',
      layers = { 'content', 'todo', 'include' },
      split_width = 30,
      todo_sorted = 0,
      show_help = 1,
      show_numbers = 1,
    }

    -- Folding configuration (optional, disable if you don't use folding)
    vim.g.vimtex_fold_enabled = 0

    -- Conceal configuration for better math rendering
    vim.g.vimtex_syntax_conceal = {
      accents = 1,
      ligatures = 1,
      cites = 1,
      fancy = 1,
      spacing = 0,
      greek = 1,
      math_bounds = 0,
      math_delimiters = 1,
      math_fracs = 1,
      math_super_sub = 1,
      math_symbols = 1,
      sections = 0,
      styles = 1,
    }

    -- Ignore warnings for common patterns
    vim.g.vimtex_quickfix_ignore_filters = {
      'Underfull',
      'Overfull',
      'specifier changed to',
      'Token not allowed in a PDF string',
    }

    -- Enable shell escape for minted/other packages
    vim.g.vimtex_compiler_latexmk_engines = {
      _ = '-pdf',
      pdflatex = '-pdf',
      lualatex = '-lualatex',
      xelatex = '-xelatex',
    }
  end,
  config = function()
    -- Keymaps using which-key
    require('which-key').add {
      { '<leader>l', group = 'LaTeX', icon = '' },
      { '<leader>ll', '<cmd>VimtexCompile<cr>', desc = 'Toggle compilation', icon = '' },
      { '<leader>lv', '<cmd>VimtexView<cr>', desc = 'View PDF', icon = '' },
      { '<leader>lc', '<cmd>VimtexClean<cr>', desc = 'Clean auxiliary files', icon = '' },
      { '<leader>lC', '<cmd>VimtexClean!<cr>', desc = 'Clean all output', icon = '' },
      { '<leader>lt', '<cmd>VimtexTocOpen<cr>', desc = 'Open TOC', icon = '' },
      { '<leader>lT', '<cmd>VimtexTocToggle<cr>', desc = 'Toggle TOC', icon = '' },
      { '<leader>le', '<cmd>VimtexErrors<cr>', desc = 'Show errors', icon = '' },
      { '<leader>lo', '<cmd>VimtexCompileOutput<cr>', desc = 'Show compile output', icon = '' },
      { '<leader>ls', '<cmd>VimtexStatus<cr>', desc = 'Show status', icon = '' },
      { '<leader>li', '<cmd>VimtexInfo<cr>', desc = 'Show info', icon = '' },
      { '<leader>lk', '<cmd>VimtexStop<cr>', desc = 'Stop compilation', icon = '' },
      { '<leader>lK', '<cmd>VimtexStopAll<cr>', desc = 'Stop all', icon = '' },
    }
  end,
}
