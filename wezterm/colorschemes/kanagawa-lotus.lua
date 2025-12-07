-- Kanagawa Lotus (Light) color scheme for WezTerm
-- Based on the lotus variant from kanagawa.nvim
-- Using official lotus colors from the palette

local M = {}

-- WezTerm color scheme
M.colors = {
  -- Background and foreground
  foreground = "#545464",   -- lotusInk1
  background = "#f2ecbc",   -- lotusWhite3

  -- Cursor colors
  cursor_bg = "#545464",    -- lotusInk1
  cursor_fg = "#f2ecbc",    -- lotusWhite3
  cursor_border = "#545464",

  -- Selection colors
  selection_fg = "#545464", -- lotusInk1
  selection_bg = "#c7d7e0", -- lotusBlue1

  -- Split/pane colors
  split = "#c9cbd1",        -- lotusViolet3

  -- Scrollbar
  scrollbar_thumb = "#a09cac", -- lotusViolet1

  -- Tab bar colors
  tab_bar = {
    background = "#e5ddb0",   -- lotusWhite2
    active_tab = {
      bg_color = "#f2ecbc",   -- lotusWhite3
      fg_color = "#545464",   -- lotusInk1
    },
    inactive_tab = {
      bg_color = "#dcd5ac",   -- lotusWhite1
      fg_color = "#8a8980",   -- lotusGray3
    },
    inactive_tab_hover = {
      bg_color = "#e5ddb0",   -- lotusWhite2
      fg_color = "#545464",   -- lotusInk1
    },
    new_tab = {
      bg_color = "#dcd5ac",   -- lotusWhite1
      fg_color = "#8a8980",   -- lotusGray3
    },
    new_tab_hover = {
      bg_color = "#e5ddb0",   -- lotusWhite2
      fg_color = "#545464",   -- lotusInk1
    },
  },

  -- ANSI colors (normal)
  ansi = {
    "#545464", -- black (lotusInk1)
    "#c84053", -- red (lotusRed)
    "#6f894e", -- green (lotusGreen)
    "#77713f", -- yellow (lotusYellow)
    "#4d699b", -- blue (lotusBlue4)
    "#b35b79", -- magenta (lotusPink)
    "#597b75", -- cyan (lotusAqua)
    "#dcd7ba", -- white (lotusGray)
  },

  -- ANSI colors (bright)
  brights = {
    "#43436c", -- bright black (lotusInk2)
    "#d7474b", -- bright red (lotusRed2)
    "#6e915f", -- bright green (lotusGreen2)
    "#836f4a", -- bright yellow (lotusYellow2)
    "#6693bf", -- bright blue (lotusTeal2)
    "#766b90", -- bright magenta (lotusViolet2)
    "#5e857a", -- bright cyan (lotusAqua2)
    "#f2ecbc", -- bright white (lotusWhite3)
  },
}

-- Complete tabline theme (no fallback needed)
M.tabline_colors = {
  -- Normal mode (default)
  normal_mode = {
    a = { fg = "#f2ecbc", bg = "#4d699b" },  -- lotusWhite3 / lotusBlue4
    b = { fg = "#545464", bg = "#e5ddb0" },  -- lotusInk1 / lotusWhite2
    c = { fg = "#545464", bg = "#f2ecbc" },  -- lotusInk1 / lotusWhite3
  },
  -- Copy mode
  copy_mode = {
    a = { fg = "#f2ecbc", bg = "#cc6d00" },  -- lotusWhite3 / lotusOrange
    b = { fg = "#545464", bg = "#e5ddb0" },
    c = { fg = "#545464", bg = "#f2ecbc" },
  },
  -- Search mode
  search_mode = {
    a = { fg = "#f2ecbc", bg = "#6f894e" },  -- lotusWhite3 / lotusGreen
    b = { fg = "#545464", bg = "#e5ddb0" },
    c = { fg = "#545464", bg = "#f2ecbc" },
  },
  -- Window mode
  window_mode = {
    a = { fg = "#f2ecbc", bg = "#b35b79" },  -- lotusWhite3 / lotusPink
    b = { fg = "#545464", bg = "#e5ddb0" },
    c = { fg = "#545464", bg = "#f2ecbc" },
  },
  -- Font mode (if using custom font key table)
  font_mode = {
    a = { fg = "#f2ecbc", bg = "#597b75" },  -- lotusWhite3 / lotusAqua
    b = { fg = "#545464", bg = "#e5ddb0" },
    c = { fg = "#545464", bg = "#f2ecbc" },
  },
  -- Resize mode (if using resize key table)
  resize_mode = {
    a = { fg = "#f2ecbc", bg = "#c84053" },  -- lotusWhite3 / lotusRed
    b = { fg = "#545464", bg = "#e5ddb0" },
    c = { fg = "#545464", bg = "#f2ecbc" },
  },
  -- Tab colors
  tab = {
    active = { fg = "#545464", bg = "#e5ddb0" },     -- lotusInk1 / lotusWhite2
    inactive = { fg = "#8a8980", bg = "#dcd5ac" },   -- lotusGray3 / lotusWhite1
    inactive_hover = { fg = "#545464", bg = "#dcd5ac" },  -- lotusInk1 / lotusWhite1
  },
}

return M
