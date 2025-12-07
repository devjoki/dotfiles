-- Pull in the wezterm API
local wezterm = require("wezterm")
local utils = require("utils")
local config = wezterm.config_builder()
local smart_splits = require("smart_splits")
local resurrect = require("resurrect")
local options = require("options")
local colorscheme = require("colorscheme")
local tabline = require("tabline")
local env = require("env")

-- Register custom color schemes
config.color_schemes = colorscheme.custom_schemes

-- Set color scheme before tabline setup so it can detect it
config.color_scheme = colorscheme.scheme

-- Setup tabline (pass config so it can access resolved colors for custom schemes)
tabline.setup(config)
env.setup(config)
config.leader = options.leader
config.enable_scroll_bar = options.enable_scroll_bar
config.keys = utils.merge({
	options.keys,
	smart_splits.keys,
	resurrect.keys,
})

-- Automatically reload configuration when it changes
config.automatically_reload_config = true

return config
