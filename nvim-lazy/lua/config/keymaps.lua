-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- add your keymaps here
map("n", "zz", "<cmd>ZenMode<cr>")

-- NVIM-DAP
-- map("n", "ñ", "<cmd>lua require'dap'.toggle_breakpoint()<cr>")

-- TODO: do something with popup from nui.nvim
-- map("n", "Ñ", function()
--   require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
-- end)
-- map("n", "<F5>", function()
--   require("dap").continue()
-- end)
--
-- map("n", "<F10>", function()
--   require("dap").step_over()
-- end)
-- map("n", "<F11>", function()
--   require("dap").step_into()
-- end)
-- map("n", "<F12>", function()
--   require("dap").step_out()
-- end)
-- map("n", "<Leader>dr", function()
--   require("dap").repl.open()
-- end)
-- map({ "n", "v" }, "<Leader>dh", function()
--   require("dap.ui.widgets").hover()
-- end)
-- map({ "n", "v" }, "<Leader>dp", function()
--   require("dap.ui.widgets").preview()
-- end)
-- map("n", "<Leader>df", function()
--   local widgets = require("dap.ui.widgets")
--   widgets.centered_float(widgets.frames)
-- end)
-- map("n", "<Leader>ds", function()
--   local widgets = require("dap.ui.widgets")
--   widgets.centered_float(widgets.scopes)
-- end)
--

vim.keymap.set("i", "<A-h>", "<Left>", { noremap = true, desc = "move one character to the left" })
vim.keymap.set("i", "<A-l>", "<Right>", { noremap = true, desc = "move one character to the left" })
--vim.keymap.set("i", "<A-w>", "<Up>", { noremap = true, desc = "move one character to the left" })
--vim.keymap.set("i", "<A-s>", "<Down>", { noremap = true, desc = "move one character to the left" })
vim.keymap.set("i", "<A-q>", "<C-o>b", { noremap = true, desc = "move one character to the left" })
vim.keymap.set("i", "<A-e>", "<C-o>e", { noremap = true, desc = "move one character to the left" })

-- Move selected lines with shift+j or shift+k
-- clear floating terminal keys
-- vim.keymap.set("n", "<leader>ft", "<nop>", {})
-- vim.keymap.set("n", "<leader>fT", "<nop>", {})
--vim.keymap.set("n", "<c-/>", "<nop>", {})
--vim.keymap.set("n", "<c-_>", "<nop>", {})

-- vim.keymap.set(
--   { "n", "v" },
--   "<leader>ft",
--   ":ToggleTerm direction=horizontal <CR>",
--   { desc = "Open horizontal terminal split" }
-- )
-- -- Join line while keeping the cursor in the same position

-- vim.keymap.set(
--   { "n", "v" },
--   "<C-/>",
--   ":ToggleTerm direction=horizontal <CR>",
--   { desc = "Open horizontal terminal split" }
-- )
-- vim.keymap.set("n", "J", "mzJ`z")
--
-- -- Keep cursor centred while scrolling up and down
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
--
-- -- Next and previous instance of the highlighted letter
-- vim.keymap.set("n", "n", "nzzzv")
-- vim.keymap.set("n", "N", "Nzzzv")
--
-- -- Better paste (prevents new paste buffer)
vim.keymap.set("x", "<leader>p", [["_dP]])
--
-- -- Copy to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
--
-- -- Delete to void register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
--
-- -- Fixed ctrl+c weirdness to exit from vertical select mode
vim.keymap.set("i", "<C-c>", "<Esc>")
--
-- -- Delete shift+q keymap
vim.keymap.set("n", "Q", "<nop>")
--
-- -- Quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
--
-- -- Search and replace current position word
-- vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
--
-- Make file executable
vim.keymap.set("n", "<leader>fx", "<cmd>!chmod +x %<CR>", {
  silent = true,
  desc = "chmod + x",
})
-- file tree toggle left
--
vim.keymap.set("n", "<leader>wt", "<cmd>Neotree filesystem toggle<CR>", { desc = "FileTree togle" })
-- -- Harpoon
-- local mark = require("harpoon.mark")
-- local ui = require("harpoon.ui")
--
-- vim.keymap.set("n", "<leader>ha", mark.add_file)
-- vim.keymap.set("n", "<leader>he", ui.toggle_quick_menu)
--
-- vim.keymap.set("n", "<leader>h1", function()
--   ui.nav_file(1)
-- end)
-- vim.keymap.set("n", "<leader>h2", function()
--   ui.nav_file(2)
-- end)
-- vim.keymap.set("n", "<leader>h3", function()
--   ui.nav_file(3)
-- end)
-- vim.keymap.set("n", "<leader>h4", function()
--   ui.nav_file(4)
-- end)
--
--
--
