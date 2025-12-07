local wezterm = require("wezterm")
local colorscheme = require("colorscheme")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
return {
	setup = function(config)
		-- Build tabline setup options with sections
		local tabline_opts = {
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
		}

		-- Only set theme for built-in schemes
		-- For custom schemes, omit options entirely to let tabline derive from terminal colors
		if not colorscheme.custom_schemes[colorscheme.scheme] then
			-- Built-in scheme - pass the theme name
			tabline_opts.options = {
				theme = colorscheme.scheme
			}
		end
		-- For custom schemes, don't set any theme/colors - let it auto-detect

		tabline.setup(tabline_opts)
	end,
}
