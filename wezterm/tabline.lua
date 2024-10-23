local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
return {
	setup = function()
		tabline.setup({
			options = { theme = "Tokyo Night" },
			sections = {
				tabline_a = { "mode" },
				tabline_b = { "workspace" },
				tabline_c = { " " },
				tab_active = {
					"index",
					{ "parent", padding = 0 },
					"/",
					{ "cwd", padding = { left = 0, right = 1 } },
					{ "zoomed", padding = 0 },
				},
				tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
				tabline_x = { "ram", "cpu" },
				tabline_y = { "datetime", "battery" },
				tabline_z = { "hostname" },
			},
		})
	end,
}
