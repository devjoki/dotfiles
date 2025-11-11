-- Pull in the wezterm API
local wezterm = require("wezterm")
local utils = require("utils")
local config = wezterm.config_builder()
local smart_splits = require("smart_splits")
local resurrect = require("resurrect")
local options = require("options")
local tabline = require("tabline")
local env = require("env")

tabline.setup()
env.setup(config)

config.color_scheme = options.color_scheme
config.leader = options.leader
config.enable_scroll_bar = options.enable_scroll_bar
config.keys = utils.merge({
	options.keys,
	smart_splits.keys,
	resurrect.keys,
})

return config
