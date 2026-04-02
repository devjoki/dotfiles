local wezterm = require("wezterm")
local colorscheme = require("colorscheme")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
return {
	setup = function(config)
		local tabline_opts = {
			sections = {
				tabline_a = { "mode" },
				tabline_b = { "workspace" },
				tabline_c = { " " },
				tab_active = {
					"▶",
					"index",
					{ "parent", padding = 0 },
					"/",
					{ "cwd", max_length = 50, padding = { left = 0, right = 1 } },
					{ "zoomed", padding = 0 },
				},
				tab_inactive = {
					"index",
					{ "parent", padding = 0 },
					"/",
					{ "cwd", max_length = 50, padding = { left = 0, right = 1 } },
				},
				tabline_x = { "ram", "cpu" },
				tabline_y = { "datetime", "battery" },
				tabline_z = { "hostname" },
			},
		}

		tabline_opts.options = { theme = colorscheme.scheme }

		tabline.setup(tabline_opts)
	end,
}
