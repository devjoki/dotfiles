local M = {}

local theme_file = io.open(os.getenv("HOME") .. "/.config/.theme/wezterm", "r")
if theme_file then
	M.scheme = theme_file:read("*l")
	theme_file:close()
else
	M.scheme = "tokyonight_moon"
end

return M
