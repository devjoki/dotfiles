local M = {}
local wezterm = require("wezterm")
local colorscheme = require("colorscheme")
local maximized = false

M.keys = {
	{
		mods = "LEADER",
		key = "-",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "=",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "m",
		action = wezterm.action.TogglePaneZoomState,
	},
	{
		key = "E",
		mods = "ALT|SHIFT",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "Q",
		mods = "ALT|SHIFT",
		action = wezterm.action.CloseCurrentTab({ confirm = false }),
	},
	{ key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "CMD", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "CMD", action = wezterm.action.ActivateTab(4) },
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	{
		key = "n",
		mods = "LEADER",
		action = wezterm.action.PromptInputLine({
			description = "Enter name for new workspace",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(
						wezterm.action.SwitchToWorkspace({ name = line }),
						pane
					)
				end
			end),
		}),
	},
	{
		key = "M",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, _)
			if maximized then
				maximized = false
				window:restore()
			else
				maximized = true
				window:maximize()
			end
		end),
	},
	{
		key = "C",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		key = "F",
		mods = "CMD|SHIFT",
		action = wezterm.action.Search({ CaseSensitiveString = "" }),
	},
	{
		key = "Space",
		mods = "LEADER",
		action = wezterm.action.RotatePanes("Clockwise"),
	},
	{
		key = "q",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentTab({ confirm = false }),
	},
	{ key = "UpArrow", mods = "SHIFT", action = wezterm.action.ScrollToPrompt(-1) },
	{ key = "DownArrow", mods = "SHIFT", action = wezterm.action.ScrollToPrompt(1) },
	{
		key = "w",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},
	{
		key = "p",
		mods = "CMD|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	},
}
M.color_scheme = colorscheme.scheme
M.leader = { key = "W", mods = "CMD|SHIFT", timeout_milliseconds = 1000 }
M.enable_scroll_bar = true

M.keys[#M.keys + 1] = { key = "X", mods = "CMD|SHIFT", action = wezterm.action.QuitApplication }
M.keys[#M.keys + 1] = { key = "q", mods = "CMD", action = wezterm.action.ActivateTabRelative(-1) }
M.keys[#M.keys + 1] = { key = "e", mods = "CMD", action = wezterm.action.ActivateTabRelative(1) }
M.keys[#M.keys + 1] = { key = "k", mods = "CMD", action = wezterm.action.SendString("\x1bOA") }
M.keys[#M.keys + 1] = { key = "j", mods = "CMD", action = wezterm.action.SendString("\x1bOB") }
M.keys[#M.keys + 1] = { key = "L", mods = "ALT|SHIFT", action = wezterm.action.ShowDebugOverlay }
return M
